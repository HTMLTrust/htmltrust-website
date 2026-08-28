---
title: 'Reference implementations'
description: 'Open-source code for browsers, CMS integrations, trust directories, and canonicalization.'
date: 2026-05-13
htmltrust:
  sign: true
  claims:
    content-type: 'Information'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

Reference implementations exist for every layer of the system and live under the [HTMLTrust GitHub organization](https://github.com/HTMLTrust). Each repository states its own license.

## Canonicalization libraries

Every implementation passes the same conformance corpus and produces the same canonical output.

| Language | Repo | Dependencies | Used by |
|---|---|---|---|
| JavaScript | [htmltrust-canonicalization/javascript](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/javascript) | None (browser + Node) | Browser extension, Hugo signing script |
| Go | [htmltrust-canonicalization/go](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/go) | `golang.org/x/text` (NFKC) | Hugo module |
| PHP | [htmltrust-canonicalization/php](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/php) | `ext-intl`, `ext-mbstring` | WordPress plugin |
| Rust | [htmltrust-canonicalization/rust](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/rust) | `html5ever` | Independent verifier and conformance checks |
| Python | [htmltrust-canonicalization/python](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/python) | `beautifulsoup4`, `lxml` | Independent verifier and conformance checks |

The shared conformance suite covers all five language implementations and checks byte-identical output for the same input.

```js
// JavaScript
import { normalizeText } from '@htmltrust/canonicalization';
const canonical = normalizeText('He said, "Hello…"');
// → 'He said, "Hello..."'
```

## Trust directory server

**[htmltrust-server-reference](https://github.com/HTMLTrust/htmltrust-server-reference)**

- **Stack:** Node.js, OpenAPI-first, MongoDB
- **Endpoints:** keys, content hashes, endorsements, reputation
- **Federation:** directories can mirror and cross-reference each other
- **Conformance suite** for interop with other directory implementations
- Additional directory implementations can be developed against the published
  protocol and conformance corpus.

A directory is optional infrastructure. Signature verification is local. A network call occurs when `keyid` points at a directory or the user requests reputation data.

## Browser extension

**[htmltrust-browser-reference](https://github.com/HTMLTrust/htmltrust-browser-reference)**

Chrome, Firefox, and Safari builds are available. Chromium-based browsers such as Edge use the Chrome build.

- Scans every page for `<signed-section>` elements
- Canonicalizes and hashes locally without a network call
- Resolves `keyid` by the configured method (DID, URL, directory)
- Renders a per-block trust badge with hover detail
- User trust policy editable in the options page

The eventual goal is native browser support via a W3C standard. The extension is the stepping stone.

## CMS plugins

**[htmltrust-cms-reference](https://github.com/HTMLTrust/htmltrust-cms-reference)**

- **WordPress:** production-ready reference plugin
- **Hugo:** module and signing script
- Architecture supports any CMS that can call an HTTP API and embed HTML attributes

Author workflow:

1. Write a post normally
2. Plugin canonicalizes the post body
3. Browser-side key signs the canonical payload
4. Plugin wraps the body in `<signed-section>` with the attributes
5. Optional: post hash + keyid to a configured directory

## Verifying in code

The site ships a browser bundle of the canonicalization library for small
integration checks. A complete verifier should also resolve the page's `keyid`
and verify its signature with the protocol rules.

```html
<script src="/canon-test.js"></script>
<script>
  const section = document.querySelector('signed-section');
  const canonical = globalThis.$canon.extractCanonicalText(section.innerHTML, {
    baseUrl: document.baseURI,
  });
  console.log(globalThis.$canonVersion, canonical);
</script>
```

## Status &amp; roadmap

| Component | Status |
|---|---|
| Specification | ✅ Published |
| Trust directory server | ✅ Reference implementation |
| Browser extension (Chrome) | ✅ Available |
| Browser extension (Firefox, Safari) | ✅ Available |
| WordPress plugin | ✅ Available |
| Hugo module | ✅ Available |
| Canonicalization (JS, Go, PHP, Rust, Python) | ✅ Available, conformant |
| W3C proposal | ⬜ Planned |

## Open design questions

We have strong preferences but have not yet committed normatively. Community feedback welcome.

- **HTML-to-text extraction (Stage 1 canonicalization):** the [spec](/spec/#stage-1--extract-canonical-text-from-html) defines the current rules for DOM walking, skipped elements, signed attributes, block boundaries, and `<br>` handling. Parser-backed verification and malformed-input coverage remain active hardening work.
- **Hash encoding:** fixed as unpadded standard Base64 in the current protocol draft.
- **Attribute expansion:** `href`, `src`, `alt`, and `aria-label` are covered now. The community should help decide which additional attributes carry signed meaning.
- **Wrapped re-signing:** formalizing the republisher attribution chain
- **Reputation scoring:** defining the minimal directory contract

## Get involved

- Browse the [GitHub repositories](https://github.com/HTMLTrust)
- Open issues or pull requests on any repo
- Try the reference implementations and report what breaks
- Contact `jason@jason-grey.com` for collaboration
