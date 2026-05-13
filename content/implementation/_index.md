---
title: 'Reference implementations'
description: 'Open-source code for every layer — browser, CMS, server, canonicalization.'
date: 2026-05-13
---

Reference implementations exist for every layer of the system. All are MIT-licensed and live under the [HTMLTrust GitHub organization](https://github.com/HTMLTrust).

## Canonicalization libraries

Same canonical output across languages — every implementation passes the same conformance corpus.

| Language | Repo | Dependencies | Used by |
|---|---|---|---|
| JavaScript | [htmltrust-canonicalization/javascript](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/javascript) | None (browser + Node) | Browser extension, Hugo signing script |
| Go | [htmltrust-canonicalization/go](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/go) | `golang.org/x/text` (NFKC) | Hugo module |
| PHP | [htmltrust-canonicalization/php](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/php) | `ext-intl`, `ext-mbstring` | WordPress plugin |

Rust and Python ports are in progress. The shared conformance suite ensures byte-identical output for the same input across every implementation.

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
- **Second-language port** (Rust/Python) in tree

A directory is optional infrastructure. Verifying a signature never requires contacting one — only key resolution (when the `keyid` points at a directory) and reputation lookup do.

## Browser extension

**[htmltrust-browser-reference](https://github.com/HTMLTrust/htmltrust-browser-reference)**

Chrome (Chromium-based browsers including Edge). Firefox and Safari ports planned.

- Scans every page for `<signed-section>` elements
- Canonicalizes and hashes locally — no network call for verification
- Resolves `keyid` by the configured method (DID, URL, directory)
- Renders a per-block trust badge with hover detail
- User trust policy editable in the options page

The eventual goal is native browser support via a W3C standard. The extension is the stepping stone.

## CMS plugins

**[htmltrust-cms-reference](https://github.com/HTMLTrust/htmltrust-cms-reference)**

- **WordPress** — production-ready reference plugin
- **Hugo** — module + signing script
- Architecture supports any CMS that can call an HTTP API and embed HTML attributes

Author workflow:

1. Write a post normally
2. Plugin canonicalizes the post body
3. Browser-side key signs the canonical payload
4. Plugin wraps the body in `<signed-section>` with the attributes
5. Optional: post hash + keyid to a configured directory

## Verifying in code

```js
async function verifySignedSection(el) {
  const keyid       = el.getAttribute('keyid');
  const sig         = el.getAttribute('signature');
  const algorithm   = el.getAttribute('algorithm');
  const claimedHash = el.getAttribute('content-hash');

  // 1. Canonicalize & hash inner text
  const text = extractCanonicalText(el);
  const computedHash = await sha256(normalizeText(text));
  if (computedHash !== claimedHash) return { ok: false, reason: 'hash' };

  // 2. Build the binding payload
  const claimsHash = await hashClaims(el.querySelectorAll(':scope > meta'));
  const domain     = location.host;
  const signedAt   = el.querySelector('meta[name=signed-at]').content;
  const payload    = `${claimedHash}:${claimsHash}:${domain}:${signedAt}`;

  // 3. Resolve key & verify
  const pubKey = await resolveKey(keyid);
  return await verify(algorithm, pubKey, sig, payload)
    ? { ok: true,  keyid }
    : { ok: false, reason: 'signature' };
}
```

## Status &amp; roadmap

| Component | Status |
|---|---|
| Specification | ✅ Published |
| Trust directory server | ✅ Reference implementation |
| Browser extension (Chrome) | ✅ Available |
| Browser extension (Firefox, Safari) | ⬜ Planned |
| WordPress plugin | ✅ Available |
| Hugo module | ⬜ Planned |
| Canonicalization (JS, Go, PHP) | ✅ Available, conformant |
| Canonicalization (Rust, Python) | ⬜ In progress |
| W3C proposal | ⬜ Planned |

## Open design questions

We have strong preferences but have not yet committed normatively. Community feedback welcome.

- **HTML-to-text extraction (Stage 1 canonicalization)** — the [spec](/spec/#stage-1--extract-canonical-text-from-html) currently sketches the rules: DOM walk, skip `<meta>` claims and `<script>`/`<style>`, single `\n` between block elements, `<br>` → `\n`. The exact list of block-level elements, table cell separators, nested signed-section handling, and whether to ever preserve structural attributes are all being firmed up. A Stage 1 conformance suite is in progress.
- **Hash encoding** — Base64? Hex? Base32? Currently unpadded Base64.
- **Meaningful attribute coverage** — should `href` on `<a>` be in the hash, given link-swap is a phishing vector domain-binding cannot fully address?
- **Wrapped re-signing** — formalizing the republisher attribution chain
- **Reputation scoring** — what minimal directory contract is enough?

## Get involved

- Browse the [GitHub repositories](https://github.com/HTMLTrust)
- Open issues or pull requests on any repo
- Try the reference implementations and report what breaks
- Contact [jason@jason-grey.com](mailto:jason@jason-grey.com) for collaboration
