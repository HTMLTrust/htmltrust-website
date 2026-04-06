---
title: "About HTMLTrust"
description: "A decentralized framework for embedding cryptographic trust directly into HTML content"
date: 2025-05-12
draft: false
htmltrust:
  sign: true
  claims:
    ContentType: "Information"
    License: "MIT"
    AIAssistance: "Human+AI"
---

## What Is HTMLTrust?

HTMLTrust is a decentralized, standards-aligned framework for embedding cryptographic trust directly into HTML content. Using a proposed `<signed-section>` element, content creators and publishing platforms can sign semantically meaningful regions of web pages and include identity-linked metadata in-band.

Signatures are validated using public key infrastructure (PKI) such as [DIDs](https://www.w3.org/TR/did-core/), and can be enhanced with third-party endorsements submitted to optional, federated trust directories.

Unlike blockchain-based or DRM-centric systems, HTMLTrust is **lightweight, browser-compatible, and web-native** — designed to scale across publishing workflows, civic media, and knowledge networks.

## Why Is This Needed?

The web lacks a standardized mechanism for proving who wrote a given piece of content. TLS certifies the domain, but not the author. As AI-generated and republished material becomes ubiquitous, users face increasing difficulty determining what content is trustworthy.

Existing methods like digital signatures (e.g., DKIM, PGP) and content fingerprinting (e.g., ISCC) offer pieces of the solution but do not integrate cleanly with web-native publishing workflows or browser verification.

## Who Benefits?

- **Content producers** who need to protect their work from theft and misuse
- **Content consumers** who need to trust the content they read
- **LLM builders** who need high-quality, human-generated training data and want to respect author preferences
- **Web researchers** who need to distinguish between human and AI-generated content
- **Journalists and news organizations** who need to verify sources and track article spread
- **Academic institutions** who need to detect plagiarism and verify research materials

## How It Works

1. **Authors sign content** — A CMS or publishing tool normalizes the content, computes a hash, and signs it with the author's private key
2. **Signatures are embedded in HTML** — The `<signed-section>` element wraps the content with the signature, author key reference, and content hash
3. **Browsers verify** — Browser extensions (or eventually native browser support) validate signatures and display trust indicators
4. **Trust directories track reputation** — Optional federated servers index signatures, serve endorsements, and support key discovery

## Project Status

HTMLTrust is an early-stage open-source project. The current state:

- ✅ [Specification / research paper](https://github.com/ArcadeLabsInc/htmltrust-spec) published
- ✅ [Reference trust directory server](https://github.com/ArcadeLabsInc/htmltrust-server-reference) (Node.js + MongoDB)
- ✅ [Reference browser extension](https://github.com/ArcadeLabsInc/htmltrust-browser-reference) (Chrome — Firefox and Safari planned)
- ✅ [CMS plugins](https://github.com/ArcadeLabsInc/htmltrust-cms-reference) (WordPress — Hugo and others planned)
- ⬜ Formal W3C proposal for extending HTML with signed sections
- ⬜ Standardized canonicalization algorithm
- ⬜ Production-ready trust directory network

## Planned Work

- Research on metadata schema and cryptographic primitives
- Further refinement of canonicalization algorithms
- A formal proposal to the W3C for extending HTML with signed sections
- Additional browser and CMS integrations
- Research into implementing this framework in news feeds and aggregation platforms

## Author

HTMLTrust was created by **Jason Grey** ([jason@jason-grey.com](mailto:jason@jason-grey.com)).

Contributions are welcome — visit the [GitHub repositories](https://github.com/ArcadeLabsInc) to get involved.