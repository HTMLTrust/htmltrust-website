---
title: 'HTMLTrust'
date: 2026-05-13
toc: false
htmltrust:
  sign: true
  claims:
    content-type: 'Article'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'

hero:
  heading: 'Cryptographic authorship for the open web'
  lede: >
    HTMLTrust embeds cryptographic authorship directly in HTML. An author signs a
    block of content, and a reader's browser verifies that signature locally,
    with no central authority to ask.
  lede_secondary: >
    A signature answers a narrow question: did this key sign this text? Deciding
    whether that key is worth believing is the other half of the system, and
    HTMLTrust hands that decision to the reader, who builds it from their own
    trust list, signed endorsements of specific content, and reputation from
    whichever federated directories they choose to consult.
  actions:
    - text: 'Read the spec'
      url: /spec/
    - text: 'How the trust network works'
      url: /trust-network/
    - text: 'Source on GitHub'
      url: https://github.com/HTMLTrust

facts:
  - value: '1'
    label: 'New HTML element'
  - value: '4'
    label: 'Required attributes'
  - value: '4'
    label: 'Normalization steps'
  - value: '0'
    label: 'Central authorities'
---

## The problem

**TLS certifies the server.** A padlock means the bytes arrived from the host named in the certificate. It says nothing about who wrote them, and nothing survives the copy when those bytes are pasted somewhere else.

**Plausible text is now free.** Generated prose is cheap enough that reading alone no longer distinguishes a staff reporter from a content farm. Readers are asked to judge writing on style, which is precisely the thing that got cheap.

**Republishing strips attribution.** Articles are scraped, mirrored, translated, and screenshotted. The author's name is the first thing lost and the last thing checked.

**Corrections travel slower than copies.** By the time a piece is retracted, the mirrors have their own audiences and no mechanism to hear about it.

None of this is a cryptography problem in isolation. Signing text is easy. The hard part is giving a reader a way to decide whose signatures matter, without appointing anyone to decide it for them.

## Trust as a network

Verification and trust are separate operations, and HTMLTrust keeps them separate on purpose.

The first is arithmetic. Canonicalize the text, hash it, resolve the key named in the `keyid` attribute, check the signature. The answer is yes or no, it is identical in every conforming implementation, and it happens in the reader's own browser.

The second is a judgement, and it has no arithmetic answer. A valid signature from a key you have never heard of tells you almost nothing. So HTMLTrust defines a network the reader assembles for themselves:

- **Their own trust list.** Keys the reader has decided to believe, held locally and answerable to nobody.
- **Endorsements.** Signed statements from third parties about one specific content hash, verified before they count for anything. A fact-checker endorsing one article endorses that article, not its author forever.
- **Directory reputation.** Any number of federated trust directories publish opinions about signers. A reader subscribes to the ones they want, at whatever weight they want, and can drop one without losing the ability to verify anything.

No directory is required. Verification never depends on reaching one, and a directory that disappears, lies, or is captured costs a reader only the opinions they had chosen to consult. That is the whole design constraint: a trust network with no position from which anyone can revoke belief on someone else's behalf.

[How the trust network works](/trust-network/) covers the mechanics: the endorsement format, what a directory serves, how conflicting opinions from different directories combine, and what an attacker gets for the cost of running their own.

## What HTMLTrust does not do

Scope is half of a good standard, and every item here is a deliberate exclusion rather than unfinished work.

- **No access control.** Signatures are inert metadata. Content stays readable, copyable, and quotable with or without a verifier. HTMLTrust never gates rendering.
- **No AI ban.** A signed claim can record how much of a text was machine-written, at whatever granularity the author chooses to disclose. It does not prohibit anything.
- **No ledger.** Public-key cryptography, key resolution over HTTPS, and optional HTTP directories. No chain, no token, no consensus round.
- **No verified badge.** There is no registry to be admitted to and no authority that can eject you. A directory's opinion carries exactly the weight each reader assigns it.
- **No claim about truth.** A signature establishes who said something. Whether it is correct is outside what cryptography can answer, and the specification says so rather than implying otherwise.

## Principles

- **Sign blocks, not pages.** One page can carry many signed regions from many authors, which is what forums, symposia, and edited collections actually look like.
- **Pluggable identity.** DIDs, key URLs, and directory entries all resolve. A conforming implementation must accept several methods, so no identity provider becomes load-bearing.
- **Trust lives in the user agent.** The browser holds the policy. A signature verifies or it does not; how much that is worth is the reader's setting.
- **Federation with no quorum.** Directories coexist without agreeing, and nothing breaks when they disagree. Consensus is not a requirement anywhere in the protocol.
- **Web-native.** One HTML element that degrades to a plain `<div>` in browsers that have never heard of it. No plug-in is required to read a signed page.

## How this relates to prior art

HTMLTrust borrows from decades of work on channel security, message signing, and provenance. It replaces none of it.

| | HTMLTrust | TLS | DKIM | PGP | C2PA |
|---|---|---|---|---|---|
| Proves authorship of HTML text | yes | no | no | partial | no |
| Renders natively in browsers | yes | yes | no | no | partial |
| Signs regions within a document | yes | no | no | no | no |
| Works with no central authority | yes | no | yes | yes | yes |
| Optional federated reputation | yes | no | no | no | no |
| Degrades safely in unaware clients | yes | partial | yes | no | partial |

C2PA is the closest neighbour and the least overlapping: it carries provenance for images, video, and audio through capture and edit pipelines, while HTMLTrust covers the text of a web page. A page can reasonably carry both.

The cautionary example is Signed HTTP Exchanges, which asked browsers to render content served by one origin under another origin's identity and was withdrawn after the objections that raised. HTMLTrust binds a signature to a publication origin and gives up on portable rendering entirely, which is the lesson SXG paid for.

## Where this actually stands

Honest status, since a proposal that overstates itself is not worth reading:

- The **specification** exists as two pre-submission drafts: an [IETF Internet-Draft](/spec/ietf-draft/) for the wire protocol and a [W3C Community Group Report](/spec/w3c-cg/) for the HTML and DOM integration. Neither has been posted to its standards body.
- **Reference implementations** run for canonicalization, a trust directory server, a browser extension, and CMS signing. [What is shipping](/implementation/) is stated per component, with its verification status.
- **No production adopter yet.** The next milestone is crawl-time verification by a search or answer engine, which needs no browser support to be useful.
- **Independent implementation is the evidence that matters.** Five language ports of the canonicalization algorithm produced byte-identical output across a shared conformance corpus. That result is what makes the algorithm specifiable, and it is described with its date and revision on the [implementation page](/implementation/).

Feedback is wanted, particularly from anyone who has run a verifier at crawl scale or maintains a trust directory. Open an issue on [any repository](https://github.com/HTMLTrust), or write to `jason@jason-grey.com`.
