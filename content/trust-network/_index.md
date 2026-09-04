---
title: 'The trust network'
description: 'How a reader assembles a trust decision from their own list, signed endorsements, and any number of federated directories, none of which is required to verify a signature.'
date: 2026-09-03
numbered: true
htmltrust:
  sign: true
  claims:
    content-type: 'Specification'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

A signature proves that a particular key signed a particular text. That is arithmetic, and it is the easy half. The hard half is that a reader who has never seen the key learns almost nothing from a valid signature, and any system that answers "is this key trustworthy" on the reader's behalf has just appointed itself the authority the design was meant to avoid.

HTMLTrust's answer is to keep the two operations apart and give the second one to the reader. What follows is how that works in the shipping reference implementations, including the arithmetic, the failure behaviour, and what it costs an attacker to try to move a score.

## Two layers, and why the boundary matters

Verification is local, deterministic, and identical everywhere. Canonicalize the signed region, hash it, resolve the key named in `keyid`, check the signature. Every conforming implementation returns the same answer for the same bytes, which is the property the [five independent language ports](/implementation/) were built to demonstrate.

The trust decision sits strictly above that boundary. It never changes whether a signature is valid, it cannot rescue an invalid one, and it is allowed to be different for every reader on the same page.

{{< diagram label="Figure 1" alt="A flow diagram: page HTML enters layer one, cryptographic verification, which either rejects or passes to layer two, the reader's trust policy, which produces a score and an indicator." caption="Layer 1 answers a yes-or-no question locally. Layer 2 is the reader's policy, and every input to it is optional." >}}
                          page HTML
                              |
                              v
      +--------------------------------------------------+
      |  LAYER 1   cryptographic verification (local)    |
      |                                                  |
      |    canonicalize -- hash -- resolve keyid          |
      |                              |                   |
      |                       verify signature           |
      +--------------------------------------------------+
                    |                     |
                 invalid                 valid
                    |                     |
                    v                     v
        score 0, indicator red    +---------------------------------+
        (no policy input can      |  LAYER 2   trust policy         |
         raise it)                |            (the reader's)       |
                                  |                                 |
                                  |   baseline, verified but     50 |
                                  |   unknown signer                |
                                  |   personal trust list       +40 |
                                  |   trusted publication       +30 |
                                  |   origin                        |
                                  |   each subscribed          +/-  |
                                  |   directory, by weight          |
                                  |                                 |
                                  |   clamped to 0..100             |
                                  +---------------------------------+
                                              |
                                              v
                                     score, then indicator
{{< /diagram >}}

## What the reader controls

Three inputs, all held in the user agent, all optional, none of which can be set by a publisher.

**A personal trust list.** Key identifiers the reader has decided to believe. It is local state, it answers to nobody, and in the reference extension a listed key adds 40 points.

**Trusted publication origins.** Domains whose signed content the reader treats as known-good, worth 30 points. This is weaker than a key: origins change hands.

**Directory subscriptions.** Zero or more trust directories, each with a weight between 0 and 1 and an enabled flag. A subscription is a standing instruction to ask that directory what it thinks of a signer, and to count the answer at the weight the reader chose.

## The arithmetic, and its status

The reference browser client computes a score like this. A verified signature from a signer with no other information starts at 50, the neutral baseline. Then, for each subscribed directory, the directory's reputation for that exact `keyid` contributes:

```
contribution = (trustScore - 0.5) * weight * 40
```

`trustScore` is the directory's own figure in the range 0 to 1, so a directory that considers a signer exactly average contributes nothing, and a fully weighted directory can move a score by at most 20 points in either direction. The total is clamped to 0 through 100, and mapped to an indicator: below 20 shows red, 20 through 69 shows yellow, 70 and above shows green.

One rule sits outside the arithmetic. If any subscribed directory reports one or more abuse reports against the signer, the indicator is forced to red no matter what the score says. A reader who subscribed to a directory has already said they want its warnings, and a warning that personal-trust points can drown out is not a warning.

{{< notice label="Not normative" >}}
These numbers are the reference extension's default policy, not a requirement of the specification. The spec requires that a user agent present trust as a graduated outcome and keep it visually distinct from signature validity. It deliberately does not standardize a scoring formula, because a standard formula would be a standard authority. Expect other implementations to weigh these inputs differently.
{{< /notice >}}

## What a directory serves

A trust directory is an ordinary HTTP service. The reference implementation is Node.js and MongoDB, OpenAPI-first, and the endpoints that matter to a reader are these:

| Endpoint | Purpose |
|---|---|
| `GET /.well-known/htmltrust` | Capability discovery, cacheable, with `ETag` |
| `GET /keys/{id}` | Key resolution, for authors who would rather not self-host a key |
| `GET /signers/{id}/reputation` | The directory's computed opinion of a signer, plus its report count |
| `GET /content/{hash}/endorsements` | Endorsements filed against one specific content hash |
| `GET /api/directory/content/{hash}/occurrences` | Every domain this directory has seen serve this exact content |
| `POST /api/directory/signer-votes` | File an opinion about a signer, authenticated |
| `POST /api/directory/content/report` | Report content, authenticated |

The occurrences endpoint is the one that closes the loop on republishing. Because the content hash is computed from canonical text, the same article mirrored on nine other hosts hashes identically on all of them, and a directory that has crawled those hosts can say so. Attribution becomes a query rather than an investigation.

## Endorsements are about documents, not people

An endorsement is a signed JSON statement about one content hash:

```json
{
  "endorser":    "did:web:publisher.org",
  "endorsement": "sha256-RAyBCvKT...",
  "signature":   "BASE64_SIG",
  "timestamp":   "2026-05-01T00:00:00Z"
}
```

The consumer verifies the endorser's signature before the endorsement counts toward anything. Directories store and serve these, indexed by content hash.

The scope is deliberately narrow. A fact-checker who endorses one article has endorsed that article at that moment, and has said nothing about whatever the author publishes next year. Ongoing opinions about a signer live in directory reputation instead, where they can be recomputed, disputed, and dropped. Keeping point-in-time attestations separate from standing reputation is what stops an endorsement from quietly becoming a credential.

## Federation without agreement

Directories are not replicas of each other and are never asked to agree. Two directories can hold opposite opinions of the same signer, and a reader subscribed to both simply gets two contributions with opposite signs, each scaled by the weight they assigned. There is no quorum, no tie-break, and no merge.

Votes are recorded per exact signer key identifier, one current vote per authenticated voter, so a directory cannot inflate an opinion by resubmitting it, and an opinion about one key does not silently transfer to a key rotation.

The reference end-to-end scenario exercises this with multiple directories at different weights, planted malicious signer profiles, and deliberate directory outages, and confirms that conflicting contributions resolve without a signature ever failing and that flagged signers are identified without false positives against honest ones. Those figures belong to the v1 coordinated baseline of September 2026 and are reproducible from the [end-to-end harness](https://github.com/HTMLTrust/htmltrust-e2e).

## Failure behaviour

Every directory interaction is best-effort by construction. A reputation query runs against a 5 second timeout, and any failure at all, network error, non-200 status, malformed body, unparseable score, causes that directory to contribute nothing rather than to fail the page.

{{< diagram label="Figure 2" alt="Three failure cases: a directory that is offline contributes nothing, a directory that lies contributes at most its assigned weight, and an unsubscribed directory contributes nothing at all." caption="What each failure costs a reader. In no case does it affect whether the signature verifies." >}}
  directory offline, slow, or malformed
      -- contributes nothing; score keeps its other inputs
      -- signature still verifies; page still renders

  directory lies about a signer
      -- moves the score by at most (weight * 20) points
      -- reader can lower the weight or unsubscribe

  directory the reader never subscribed to
      -- is never queried and contributes nothing
      -- its opinion of a signer is unreachable by any publisher

  key revoked or expired
      -- fails in Layer 1 with key-revoked, before signature checking
      -- no policy input can raise the result
{{< /diagram >}}

This is what "a directory is a convenience, never an authority" means operationally. The worst outcome available to a hostile directory is to spend the influence a reader explicitly granted it, and the reader can withdraw that in one setting.

## What an attacker gets

Standing up a directory is cheap, and that is fine, because a directory nobody subscribes to is inert. The scarce resource in this design is subscription share, not compute, so the attack is not to run a directory but to persuade readers to weight one. That is a reputational cost rather than a computational one, and it is the cost the design intends to impose.

Two limits are worth stating plainly rather than leaving to a reader to discover:

**Sybil resistance is currently modelled, not measured.** The sensitivity analysis is deterministic. It has not been validated against deployed federation with observed attacker costs, and that measurement is on the research plan.

**Reputation queries leak reading behaviour.** Asking a directory about a `keyid` tells that directory which signer a reader is reading, and by inference which page. The client sends no cookies, no referrer, and follows no redirects on those requests, which limits correlation but does not remove it. A reader who considers that unacceptable can run with zero subscriptions and lose nothing except third-party opinions: verification is unaffected, because it never involved a directory in the first place.

## Status

| Component | State |
|---|---|
| Two-layer verification and trust separation | Specified and implemented |
| Weighted multi-directory subscriptions | Implemented in the browser client and extension |
| Signer votes per exact key identifier | Implemented in the directory server |
| Endorsements by content hash | Implemented, format still marked draft in the spec |
| Content occurrence tracking across domains | Implemented in the directory server |
| Sybil and federation economics | Deterministic model only, not yet measured on deployed directories |
| Reader comprehension of validity against trust | Not yet studied; planned once the interface states settle |

## Next

- [The specification](/spec/) for the element, the canonicalization algorithm, and the endorsement format
- [System architecture](/architecture/) for how authors, CMSes, browsers, crawlers, and directories interact
- [Reference implementations](/implementation/) for what is running today, per component
