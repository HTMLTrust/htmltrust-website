---
title: 'The HTMLTrust spec'
description: 'One new HTML element, four required attributes, an 8-phase canonicalization algorithm, and a federation model.'
date: 2026-05-13
htmltrust:
  sign: true
  claims:
    content-type: 'Specification'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

The HTMLTrust specification is small on purpose. It defines:

1. A new `<signed-section>` HTML element
2. Four required attributes carrying the signature, key reference, content hash, and algorithm
3. A canonical signing payload bound to a publication origin
4. An 8-phase canonicalization algorithm so the same content hashes to the same value regardless of which tool produced it
5. Pluggable key resolution and optional federated trust directories
6. A signed-JSON endorsement format for third-party attestations

The full paper lives in the [htmltrust-spec](https://github.com/HTMLTrust/htmltrust-spec) repository. What follows is a tight tour.

## The `<signed-section>` element

```html
<signed-section
    keyid="did:web:author.example"
    signature="3q2+7w8NslfJ..."
    content-hash="sha256:RAyBCvKT..."
    algorithm="ed25519">
  <meta name="author"        content="Alice Example">
  <meta name="signed-at"     content="2026-05-01T10:30:00Z">
  <meta name="claim:License" content="CC-BY-4.0">
  <article>
    <h1>Verifiable Web Content</h1>
    <p>Content should be provable…</p>
  </article>
</signed-section>
```

Each `<signed-section>` is independent. A single page can host many of them, signed by different authors.

## Four required attributes

| Attribute | Purpose |
|---|---|
| `keyid` | Identifies the signer — DID, URL to a key, or directory reference |
| `signature` | The cryptographic signature, Base64-encoded |
| `content-hash` | Hash of the canonicalized text, e.g. `sha256:…` |
| `algorithm` | Signature algorithm — `ed25519`, `ecdsa`, or `rsa` |

Inner `<meta>` elements carry **claims**: author, timestamp, license, AI involvement, anything the signer wants attested. Claims are folded into the signing payload via a `claims-hash`.

## The canonical signing payload

The signature is computed over a deterministic binding string:

```
{content-hash}:{claims-hash}:{domain}:{signed-at}
```

- `content-hash` — hash of the canonicalized text
- `claims-hash` — hash of the lexically-ordered `<meta>` claim elements
- `domain` — the origin where the content is authoritatively published
- `signed-at` — ISO-8601 timestamp from the corresponding `<meta>` element

The signer's identity is *implicit* in the `keyid` resolution step. Any attempt to claim a signature under a different identity simply resolves to a different public key and fails verification.

**Domain binding** ties a signature to a specific publication origin, preventing signature replay on mirror sites. Legitimate republishing is supported by wrapping the original `<signed-section>` in an outer one — see [the architecture page](/architecture/).

## Canonicalization — two stages

Canonicalization runs in two stages. **Stage 1** reduces the signed region's HTML to a single canonical text string. **Stage 2** normalizes that text through 8 deterministic phases.

This split is deliberate: HTMLTrust signs *what the reader actually consumes* — the words on the page — not the surrounding markup. Markup and attributes of the signed content are not covered by the hash in this revision (see [open design questions](/implementation/#open-design-questions) for the ongoing discussion about extending coverage to meaningful attributes like `href`).

### Stage 1 — extract canonical text from HTML

Given the inner content of a `<signed-section>` element, produce a single UTF-8 text string:

1. **Walk the DOM** of the signed region in document order.
2. **Concatenate text nodes** verbatim. Whitespace within text nodes is preserved at this stage — collapsing happens in Stage 2.
3. **Skip non-content elements entirely:**
   - `<meta>` claim elements (they are hashed separately as `claims-hash`)
   - `<script>`, `<style>`, `<noscript>`, `<template>`
   - HTML comments
4. **Skip nested `<signed-section>` elements.** A nested signed section produces its own independent signature; the outer signature does not cover its inner text. (Republishing chains use this property.)
5. **Insert a single `\n` between block-level elements** (`<article>`, `<section>`, `<p>`, `<h1>`–`<h6>`, `<ul>`, `<ol>`, `<li>`, `<blockquote>`, `<pre>`, `<div>`, `<table>`, `<tr>`, …) so paragraph and list structure survives extraction.
6. **`<br>` produces a single `\n`.**
7. **Inline elements** (`<a>`, `<em>`, `<strong>`, `<code>`, `<span>`, …) **introduce no separator** — their text content is concatenated directly with surrounding text.
8. **Apply Stage 2 (the 8 phases below)** to the resulting string.

The output of Stage 1 is a single text string consisting of the readable words of the signed region, with block boundaries marked by `\n` and all markup discarded. The intent: two different HTML serializations of the same readable content should produce the same Stage 1 output.

> **Open design point.** Stage 1 is being firmed up. The rules above reflect the current direction but are not yet normative. Specifically: the exact list of block-level elements, the treatment of tables (cell separators?), the handling of phrasing-content `<br>` inside inline contexts, and the question of whether to preserve any structural attributes are all subjects of active discussion. Community input is welcome via the [spec repository](https://github.com/HTMLTrust/htmltrust-spec).

### Stage 2 — text canonicalization (8 phases)

To ensure the same Stage 1 output always hashes to the same value regardless of which tool produced the upstream HTML, HTMLTrust defines an 8-phase text canonicalization algorithm:

| Phase | What it does |
|---|---|
| 1. NFKC | Unicode normalize — ligatures, fullwidth/halfwidth, presentation forms |
| 2. Whitespace | All Unicode whitespace → ASCII; collapse runs; trim |
| 3. Quotation marks | Curly, guillemets, CJK brackets → ASCII `"` and `'` |
| 4. Dashes | En, em, figure, non-breaking → ASCII `-` |
| 5. Punctuation | Ellipsis `…` → `...`; minus sign → hyphen-minus |
| 6. Strip invisibles | Remove ZWSP, BOM, variation selectors, tatweel |
| 7. Bidi | Strip bidi controls — use HTML `dir` attribute instead |
| 8. Language | Preserve semantic ZWNJ/ZWJ for Indic, Arabic, emoji |

JavaScript, Go, and PHP implementations of Stage 2 all produce *identical bytes* for the conformance corpus. See [htmltrust-canonicalization](https://github.com/HTMLTrust/htmltrust-canonicalization) for the libraries and test suite. (The conformance suite for Stage 1 is in progress.)

## Key resolution — pluggable by design

Implementations MUST accept multiple `keyid` resolution methods. None is canonical.

- **DID** — `did:web:author.example` resolves via a well-known DID document at the author's origin. No third party involved.
- **Direct URL** — `https://author.example/key.json`, fetched from the author's origin as a static file.
- **Trust directory reference** — `https://directory.example/keys/abc123`, where a federated directory serves as a convenience registry for authors who prefer not to self-host.

The `keyid` is **opaque to the signature protocol**. Only the resolved public key matters for cryptographic verification, which is a local operation in the user agent and never requires contacting a directory.

## Endorsements

Third parties (publishers, experts, other users) may issue signed JSON endorsements of specific content hashes:

```json
{
  "endorser":    "did:web:publisher.org",
  "endorsement": "sha256-RAyBCvKT...",
  "signature":   "BASE64_SIG",
  "timestamp":   "2026-05-01T00:00:00Z"
}
```

- Endorsements target **specific pieces of content**, not signers
- Stored and served by trust directories, indexed by content hash
- Verified cryptographically by the consumer before contributing to any trust score

Ongoing or collective trust of a signer is expressed via that signer's *reputation* in one or more trust directories, not via persistent signer-level endorsement artifacts. This separation keeps endorsement semantics clean: an endorsement is a point-in-time attestation about a specific artifact, while directory reputation reflects an ongoing curatorial opinion about a signer.

## Two layers, kept separate

User agents perform verification in **two distinct layers**:

1. **Cryptographic verification (local).** Canonicalize → hash → resolve key → verify. Yes/no. Local, no network call beyond key resolution.
2. **Trust decision (user policy).** Given a cryptographically valid signature, the user agent applies the current user's trust policy: personal trust lists, endorsements from designated parties, reputation scores from selected directories.

User interfaces SHOULD present the trust outcome as a **graduated score**, not a binary verdict, and SHOULD distinguish the two layers visually. A signature either verifies or it does not. Trust is a matter of degree.

## Next

- **[System architecture](/architecture/)** — how authors, CMSes, browsers, crawlers, and directories interact
- **[Reference implementations](/implementation/)** — what's shipping today
- **[Use cases](/use-cases/)** — where this matters
