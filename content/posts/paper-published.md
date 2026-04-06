---
title: "Research Paper Published: Toward Decentralized Trust and Verifiable Content on the Web"
description: "The foundational HTMLTrust research paper is now available"
date: 2025-05-12
draft: true
tags: ["paper", "specification", "announcement"]
htmltrust:
  sign: true
  claims:
    ContentType: "Article"
    License: "MIT"
    AIAssistance: "Human+AI"
---

We're pleased to share the publication of our research paper, *Toward Decentralized Trust and Verifiable Content on the Web*, which lays out the technical foundation for the HTMLTrust project.

## Paper Abstract

> We propose a decentralized, standards-aligned framework for embedding cryptographic trust directly into HTML content. Using a new `<signed-section>` element, content creators and publishing platforms can sign semantically meaningful regions of web pages and include identity-linked metadata in-band. Signatures are validated using public key infrastructure (PKI) such as DIDs, and can be enhanced with third-party endorsements submitted to optional, federated trust directories. We introduce a simple canonicalization method for content normalization and outline how browsers and CMS systems can support user-configured web-of-trust policies for live content validation. Unlike blockchain-based or DRM-centric systems, our approach is lightweight, browser-compatible, and web-native — designed to scale across publishing workflows, civic media, and knowledge networks.

## Key Contributions

The paper introduces:

1. A proposed `<signed-section>` HTML element for encapsulating signed regions of a page
2. A canonicalization algorithm for consistent content normalization
3. A trust model supporting both direct signature verification and third-party endorsements
4. Integration paths for browsers and content management systems

## Reference Implementations

Alongside the paper, we've published reference implementations:

- **[Trust Directory Server](https://github.com/ArcadeLabsInc/htmltrust-server-reference)** — Node.js + MongoDB API for author management, content signing, verification, and reputation tracking
- **[Browser Extension](https://github.com/ArcadeLabsInc/htmltrust-browser-reference)** — Chrome extension for client-side signature validation
- **[CMS Plugins](https://github.com/ArcadeLabsInc/htmltrust-cms-reference)** — WordPress plugin and Hugo integration for server-side content signing

## Read the Paper

The paper and its LaTeX source are available in the [htmltrust-spec](https://github.com/ArcadeLabsInc/htmltrust-spec) repository.

We welcome feedback and contributions. Visit the [GitHub repositories](https://github.com/ArcadeLabsInc) to get involved, or reach out at [jason@jason-grey.com](mailto:jason@jason-grey.com).