---
title: 'Frequently asked questions'
description: 'Common questions about HTMLTrust and content verification.'
date: 2026-05-13
htmltrust:
  sign: true
  claims:
    content-type: 'Information'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

## What is HTMLTrust?

HTMLTrust is a decentralized framework for embedding cryptographic trust directly into HTML content. It enables content creators to sign semantically meaningful regions of web pages and include identity-linked metadata, so browsers and other tools can verify authorship and content integrity.

## How is HTMLTrust different from existing solutions?

Unlike blockchain-based or DRM-centric systems, HTMLTrust is:

- **Lightweight** — minimal impact on page performance
- **Browser-compatible** — works with standard web technologies
- **Web-native** — designed around HTML, not bolted on
- **Decentralized** — no central authority required
- **User-configurable** — supports personal trust policies

Existing methods like DKIM and PGP provide digital signatures, and ISCC provides content fingerprinting, but none integrate cleanly with web-native publishing or browser-based verification at the content-block level.

## How does it work technically?

HTMLTrust proposes a new HTML element, `<signed-section>`, that wraps a signed region of a page. It includes:

1. The canonicalized content
2. Metadata (author identity via DID, timestamp, content hash)
3. A Base64-encoded digital signature

Browsers (via extensions) verify the signature against the author's public key and display trust indicators. See the [spec](/spec/) for the exact attribute schema.

## What cryptographic algorithms are supported?

The system supports multiple algorithms:

- **Ed25519** (recommended)
- **RSA** (2048-bit+)
- **ECDSA** (secp256k1)

The system is algorithm-agnostic and specified via the `algorithm` attribute on each `<signed-section>`.

## Does it require blockchain?

No. HTMLTrust uses standard public-key cryptography and works with existing web infrastructure. It can optionally integrate with decentralized identity systems like DIDs, but blockchain is not required, used, or planned.

## Can I sign only parts of a page?

Yes — that is a core feature. Each `<signed-section>` is independent, so a single page can have multiple signed blocks from different authors (e.g., a forum, a collaborative article, or a page with editorial and user-generated content).

## What happens in browsers that don't support it?

HTMLTrust degrades gracefully. Unsigned or unrecognized `<signed-section>` elements render as normal content. Only the verification features are unavailable. The page remains fully readable and functional.

## Why does a signed page show as *invalid* in the browser even when the signature is mathematically correct?

This is a real, observed issue: HTMLTrust signs the **static HTML** that leaves the publishing pipeline, but the browser extension verifies against the **live DOM** — the state of the page after every script on the page has finished running. If anything inside a `<signed-section>` is mutated between page load and verification, the recomputed `content-hash` won't match the signed one, and the extension reports an invalid signature.

We hit this on our own site initially: the Hugo Blox docs theme injects a `<button class="copy-button">Copy</button>` into every `<pre>` code block at runtime. The signer never saw the button, so the canonical text the verifier reads includes extra "Copy" tokens that aren't in the hash.

Other common culprits:

- Client-side syntax highlighters (Prism, highlight.js) that rewrite code blocks
- Lazy-loading or share-button widgets that add nodes inside article content
- Theme JS that decorates headings, callouts, or admonitions at runtime

**What to do about it** — until the spec defines a mutation-skip marker, the practical workarounds are:

1. Configure or patch the theme so it does **not** inject nodes inside `<signed-section>` descendants
2. Pre-render any decoration server-side, so the signer hashes it
3. Move runtime-injected decoration **outside** the signed region (as a sibling, not a child)

This is being tracked as a spec open design question — see [Known Issue: Runtime DOM Mutation](https://github.com/HTMLTrust/htmltrust-spec#known-issue-runtime-dom-mutation-breaks-verification) in the spec README.

## What browsers are supported?

A reference browser extension is available for **Chrome** (and Chromium-based browsers like Edge). Firefox and Safari support is planned. Eventually, the goal is native browser support via a W3C standard.

## What CMS platforms are supported?

A reference plugin exists for **WordPress**. Hugo integration is planned, and the architecture supports any CMS that can call an HTTP API and embed HTML attributes. See the [CMS reference repository](https://github.com/HTMLTrust/htmltrust-cms-reference) for details.

## How does HTMLTrust handle AI-generated content?

Content metadata can include claims about AI involvement:

- **Human-only** — no AI was used
- **Human+AI** — human-authored with AI assistance
- **AI+Human** — AI-generated with human editing
- **AI-only** — fully AI-generated

These claims are signed by the author, providing a cryptographically verifiable assertion (though not a proof) of content origin.

## Can HTMLTrust prevent AI training on my content?

HTMLTrust metadata can include explicit AI training preferences (aligned with emerging standards like [Content Preferences](https://datatracker.ietf.org/doc/draft-vaughan-aipref-vocab/)). Technical enforcement depends on AI developers respecting the signals, but HTMLTrust provides a standardized, cryptographically signed way to express creator preferences — distinct from a `robots.txt` that can be silently stripped.

## Is HTMLTrust an official web standard?

Not yet. A formal proposal to the W3C for extending HTML with signed sections is part of the project's roadmap. The current work establishes the technical foundation and reference implementations.

## How can I get involved?

- Browse the [GitHub repositories](https://github.com/HTMLTrust) for the spec, server, browser extension, and CMS plugins
- Open issues or pull requests
- Try the [reference implementations](/implementation/) and provide feedback
- Contact [jason@jason-grey.com](mailto:jason@jason-grey.com) with questions or collaboration ideas
