---
title: 'First draft of the HTMLTrust paper: Toward Decentralized Trust and Verifiable Content on the Web'
summary: 'The April 2026 announcement of the founding HTMLTrust draft paper, kept online as a record. Superseded: this describes an early draft, and the paper was never published as this post claimed.'
date: 2026-04-01
lastmod: 2026-09-03
toc: false
authors:
  - jason
tags:
  - paper
  - specification
  - announcement
  - superseded
htmltrust:
  sign: true
  claims:
    content-type: 'Article'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

{{< notice label="Superseded, kept for the record" >}}
**This post is from 1 April 2026 and describes a very early draft.** It is left at its original address rather than deleted, because a project about verifiable authorship should not quietly rewrite its own history. Read it as a snapshot of what the project believed in April, not as current information.

What has changed since, as of 3 September 2026:

- **The paper was never published anywhere.** The original title of this post said it was, which was wrong at the time and is worth stating plainly. It was submitted to arXiv and declined. The current draft is an eleven-page revision under external review, and it will get a citable DOI through Zenodo rather than a preprint server.
- **The claims in this post predate the evidence.** Everything here was written before any corpus study existed. The measured results, including the five-port interoperability figures, arrived months later and are described with their dates on the [implementation page](/implementation/).
- **The reference implementations described below have moved on considerably**, including a consolidation of canonicalization onto a single Rust core. What is actually running, and what is merely built, is listed per component on the [implementation page](/implementation/).
- **The specification is now two documents**, an [IETF Internet-Draft](/spec/ietf-draft/) for the wire protocol and a [W3C Community Group Report](/spec/w3c-cg/) for the HTML integration. Neither has been submitted to its standards body.

For current material, start with [the specification](/spec/) or [the trust network](/trust-network/).
{{< /notice >}}

We're pleased to share *Toward Decentralized Trust and Verifiable Content on the Web*, the paper that lays out the technical foundation for the HTMLTrust project.

## Abstract

> We propose a decentralized, standards-aligned framework for embedding cryptographic trust directly into HTML content. Using a new `<signed-section>` element, content creators and publishing platforms can sign semantically meaningful regions of web pages and include identity-linked metadata in-band. Signatures are validated using public key infrastructure (PKI) such as DIDs, and can be enhanced with third-party endorsements submitted to optional, federated trust directories. We introduce a simple canonicalization method for content normalization and outline how browsers and CMS systems can support user-configured web-of-trust policies for live content validation. Unlike blockchain-based or DRM-centric systems, our approach is lightweight, browser-compatible, and web-native — designed to scale across publishing workflows, civic media, and knowledge networks.

## Key contributions

1. A proposed `<signed-section>` HTML element for encapsulating signed regions of a page
2. A canonicalization algorithm for consistent content normalization
3. A trust model supporting both direct signature verification and third-party endorsements
4. Integration paths for browsers and content management systems

## Reference implementations

Alongside the paper, we've published reference implementations:

- **[Trust Directory Server](https://github.com/HTMLTrust/htmltrust-server-reference):** Node.js and MongoDB API for author management, content signing, verification, and reputation tracking
- **[Browser Extension](https://github.com/HTMLTrust/htmltrust-browser-reference):** Chrome, Firefox, and Safari extensions for client-side signature validation
- **[CMS Plugins](https://github.com/HTMLTrust/htmltrust-cms-reference):** WordPress plugin and Hugo integration for server-side content signing
- **[Canonicalization Libraries](https://github.com/HTMLTrust/htmltrust-canonicalization):** JavaScript, Go, PHP, Rust, and Python implementations that pass the same conformance suite

## Read the paper

The paper and its LaTeX source are available in the [htmltrust-spec](https://github.com/HTMLTrust/htmltrust-spec) repository.

We welcome feedback and contributions. Visit the [GitHub repositories](https://github.com/HTMLTrust) to get involved, or reach out at `jason@jason-grey.com`.
