---
title: 'W3C CG Report: HTMLTrust'
description: 'Pre-submission draft of the W3C Community Group Report covering the HTMLTrust HTML element and DOM integration.'
date: 2026-05-19
htmltrust:
  sign: true
  claims:
    content-type: 'Specification (W3C CG Report)'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

This page hosts the W3C Community Group Report draft for HTMLTrust. It covers the `<signed-section>` element, the DOM interface, the user-agent processing model, and UI and accessibility guidance. The wire protocol lives in a [companion IETF Internet-Draft](/spec/ietf-draft/).

## Status

**Pre-submission draft.** This document has not been submitted to any W3C Community Group. It is published here to gather early feedback before deciding whether to publish under an existing CG (most likely [Credible Web](https://credweb.org/)), to charter a new HTMLTrust CG, or to remain as an independent proposal.

## Read it

- [Rendered draft (ReSpec)](./draft.html)
- [Full review report](./review.md): security and browser-researcher review against the reference implementations, with explicit findings

## Top known issues

The full review enumerates 12 first-pass and 12 second-pass findings. The top open items from the executive summary:

1. **Verification input model.** The draft requires verification over the live DOM, while the reference extension verifies a separately fetched source snapshot. A "valid" indicator can sit adjacent to content that no longer matches the verified bytes.
2. **Element and IDL coherence.** The draft mixes a hyphenated autonomous-custom-element name with a native `HTMLSignedSectionElement` interface and `[HTMLConstructor]`. The browser, extension, polyfill, and conformance paths do not converge until this is resolved.
3. **Text-only signing scope.** Coverage of canonical text plus four semantic attributes (`href`, `src`, `alt`, `aria-label`) leaves `form action`, `srcset`, `poster`, and ARIA name attributes unsigned. UI language must reflect "text signature valid," not "rendered content verified."
4. **Wire-field inconsistencies across W3C, IETF, and reference code.** Encoding (Base64 vs base64url), origin vs host binding, claims serialization, and failure reason strings currently differ.
5. **Network, CSP, CORS, and service-worker semantics.** The fetch model for key resolution, directory queries, and source refetch is underspecified for browser implementations.

These are the items most likely to draw browser-reviewer pushback. The full review covers another two dozen issues at lower severity, including nested signed sections, page-script exposure of trust results, extension page-marker spoofability, and conformance-summary completeness.

## Feedback

File issues on the [htmltrust-spec repository](https://github.com/HTMLTrust/htmltrust-spec) or email jason@jason-grey.com.
