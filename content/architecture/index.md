---
title: "System Architecture"
description: "How the HTMLTrust system components work together"
date: 2025-05-12
draft: false
htmltrust:
  sign: true
  claims:
    ContentType: "Technical"
    License: "MIT"
    AIAssistance: "Human+AI"
---

## Overview

HTMLTrust is a system for decentralized content authenticity, authorship claims, and endorsement. It defines a method for authors to sign content blocks in HTML, supported by canonicalization rules and cryptographic integrity checks, along with an endorsement and discovery model via public trust directories.

![HTMLTrust System Architecture](/images/architecture1.png)

## Signed HTML Blocks

A proposed new tag, `<signed-section>`, encapsulates a signed region of a page. This tag includes:

- **Canonicalized content** — e.g., a blog post or paragraph
- **Metadata** — author identity (e.g., via [DID](https://www.w3.org/TR/did-core/)), timestamp, content hash
- **Signature** — Base64-encoded digital signature of content + metadata

```html
<signed-section keyid="did:web:author.example"
    signature="BASE64_SIG" algorithm="ed25519"
    content-hash="sha256:abc123...">
  <meta name="author" content="Alice Example">
  <meta name="claim:ContentType" content="Article">
  <article>
    <h1>Verifiable Web Content</h1>
    <p>Content should be provable...</p>
  </article>
</signed-section>
```

## Canonicalization

To ensure consistent signing and verification, content is canonicalized before hashing:

1. Normalize whitespace, strip extra line breaks
2. Sort HTML attributes and metadata
3. Minify and serialize as a UTF-8 string
4. Generate both SHA-256 hash and SimHash for similarity detection

## Trust Directory (Optional)

Signed content MAY be submitted to one or more trust directories that:

- Index content hashes and associated signers
- Store and serve third-party endorsements
- Support key resolution and optional revocation

## Endorsements

Third parties (publishers, experts, other users) can issue signed JSON endorsements of specific content hashes:

```json
{
  "endorser": "did:web:publisher.org",
  "endorsement": "sha256-XYZ",
  "signature": "BASE64_SIG",
  "timestamp": "2025-05-01T00:00Z"
}
```

## Browser Integration

Browser extensions (and eventually native browser support) verify:

- Signature validity via embedded or discovered public key
- Match of content hash to canonicalized DOM
- Trust status of signer and any endorsements

Trust configuration is client-side. UI indicators reflect verification status (e.g., a verified badge or a warning tooltip).

## CMS Integration

Content management systems generate:

- Canonicalized content blocks
- Embedded signatures from author keys
- Optional submissions to trust directories

Reference implementations are available for [WordPress](https://github.com/ArcadeLabsInc/htmltrust-cms-reference) with Hugo and other CMS support planned.

## Reference Implementations

| Component | Repository | Status |
|---|---|---|
| Specification | [htmltrust-spec](https://github.com/ArcadeLabsInc/htmltrust-spec) | ✅ Published |
| Trust Directory Server | [htmltrust-server-reference](https://github.com/ArcadeLabsInc/htmltrust-server-reference) | ✅ Reference implementation |
| Browser Extension | [htmltrust-browser-reference](https://github.com/ArcadeLabsInc/htmltrust-browser-reference) | ✅ Chrome (Firefox/Safari planned) |
| CMS Plugins | [htmltrust-cms-reference](https://github.com/ArcadeLabsInc/htmltrust-cms-reference) | ✅ WordPress (Hugo planned) |