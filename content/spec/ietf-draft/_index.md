---
title: 'IETF Internet-Draft: HTMLTrust Wire Protocol'
description: 'Pre-submission draft of the IETF Internet-Draft covering HTMLTrust canonicalization, signing payload, encoding, key resolution, trust-directory HTTP API, and endorsement format.'
date: 2026-05-19
htmltrust:
  sign: true
  claims:
    content-type: 'Specification (IETF Internet-Draft)'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

This page hosts the IETF Internet-Draft for the HTMLTrust wire protocol. It covers the canonicalization algorithm, the signing payload, encoding rules, the algorithm registry, key resolution, the federated trust-directory HTTP API, the endorsement format, and the verification procedure. The HTML and DOM integration lives in a [companion W3C CG Report](/spec/w3c-cg/).

## Status

**Pre-submission draft.** This document has not been posted to the IETF datatracker. It is published here to gather feedback from W3C Community Group reviewers (notably [Credible Web](https://credweb.org/) and DeFacto) and any other interested protocol implementers before posting `draft-grey-htmltrust-00` and pursuing publication via the Independent Submission Editor (Experimental status).

## Read it

- [Rendered draft (HTML, via IETF author-tools)](./draft-grey-htmltrust-00.html)
- [kramdown-rfc source (markdown)](./draft-grey-htmltrust-00.md)
- [Full review report](./review.md): security and interoperability review against the reference implementations

## Top known issues

The full review enumerates 16 first-pass and 11 second-pass findings. The top critical items:

1. **Hash and signature encoding split between spec and code.** The draft requires canonical unpadded standard Base64 (with percent-encoding when placed in URL paths). Some reference prototypes still emit padded Base64 or hex.
2. **Origin binding semantics.** The draft binds the full serialized origin (scheme, host, non-default port). Some prototypes still bind hostname only, permitting cross-scheme and cross-port replay.
3. **Claims hash serialization.** The draft serializes every direct-child `<meta name content>` pair as `name:content\n` sorted lexically by normalized name. The browser client previously serialized only `claim:*` entries as `name=value` and excluded `signed-at` and `author`.
4. **Trust directory API shape.** Reference server endpoints (`/api/directory/content`, API-key auth) do not match the draft's root-level endpoints and HTTP Message Signature (RFC 9421) authentication.
5. **Endorsement signing format.** The draft requires RFC 8785 JCS over the full endorsement document with `signature` omitted. Some prototypes sign only `{contentHash}:{timestamp}`.
6. **Signature and key wire formats.** ECDSA signature byte format (DER vs IEEE P1363 raw), RSA-PSS salt length, and key document encoding (SPKI DER vs PEM vs JWK) need single normative choices per algorithm before signatures will interoperate across languages.
7. **Attribute-record domain separation.** Signed semantic attributes (`href`, `src`, `alt`, `aria-label`) are currently serialized into the same canonical byte string as text content using a `@attr:` record prefix. Without domain separation or length-prefixing, ordinary text can collide with attribute records.

The full review's "Mismatch Matrix Between Draft and Existing Code/Conformance" section enumerates 20+ rows of concrete spec-vs-code divergences. The `-01` revision targets convergence on a single wire profile before submission to the datatracker.

## Feedback

File issues on the [htmltrust-spec repository](https://github.com/HTMLTrust/htmltrust-spec) or email `jason@jason-grey.com`.
