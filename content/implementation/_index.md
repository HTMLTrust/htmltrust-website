---
title: 'Reference implementations'
description: 'Reference code for browsers, CMS integrations, trust directories, and canonicalization.'
date: 2026-05-13
htmltrust:
  sign: true
  claims:
    content-type: 'Information'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

Reference implementations exist for every layer of the system and live under the [HTMLTrust GitHub organization](https://github.com/HTMLTrust). The code is Apache-2.0, which includes an express patent grant, so implementing the protocol needs no permission and carries no patent surprise. The specification and this site are CC BY 4.0. Using the *name* has one condition, described in the [trademark policy](/trademark/).

## Canonicalization libraries

**Current release: [v0.3.0](https://github.com/HTMLTrust/htmltrust-canonicalization/releases/tag/v0.3.0).** One Rust implementation of the algorithm, reached from five languages. Every binding calls the same core, so there is exactly one place where canonical bytes are decided.

| Language | Binds via | Notes |
|---|---|---|
| Rust | native | The core itself |
| Go | C ABI | Loads the shared library by explicit absolute path |
| JavaScript | WebAssembly and native | Published from the repository root as `@htmltrust/canonicalization` |
| Python | C ABI | |
| PHP | C ABI | Used by the WordPress plugin |

The core is built and run-linked for Linux, macOS and Windows on AMD64 and ARM64, with Linux and Windows i686 as compatibility lanes, plus Android libraries for all four NDK ABIs and an iOS device and simulator XCFramework. Those artifacts are unsigned and retained for review: signing, notarization, Maven and SwiftPM publication, and mobile runtime testing are still ahead.

The conformance suite is 130 fixtures at v0.3.0 and remains the definition of correct behaviour. It is also the bar in the [trademark policy](/trademark/): pass it and you may use the name.

{{< notice label="Read the independence claim carefully" >}}
The five-port agreement is **dated evidence, not a description of current architecture.** It was measured at the v1 coordinated baseline, before v0.3.0: 128 shared fixtures across the five ports, plus a corpus study in which the ports jointly accepted 121 of 4,846 archived web records and produced matching digests for 119 of them.

**That consolidation landed in v0.3.0 on 3 September 2026.** The bindings are no longer independent implementations, because five hand-maintained ports of a byte-exact algorithm is a permanent divergence risk rather than an ongoing feature. The interoperability result stays exactly what it was: historical evidence that the written specification is precise enough for separate people to reimplement and agree on the bytes. That is the property a standard needs, and it is why the result is worth preserving rather than quietly restating as though the current code proved it.
{{< /notice >}}

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

Production bundles are built for Chrome, Firefox, and Safari, and each stays inside its store's size limit. Chromium-based browsers such as Edge use the Chrome build.

Verification coverage is not equal across the three. A Chromium check loads the built MV3 extension and confirms a cryptographically valid, source-verified section through its service worker, so the Chrome build is exercised end to end as a packaged extension. The Firefox and Safari bundles are packaging targets: they build, they lint, and the verification lifecycle passes in Firefox and WebKit through the test harness, but neither is yet loaded and driven as an installed extension in automation. Treat them as usable and unproven rather than released.

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

| Component | Status | Basis |
|---|---|---|
| Canonicalization core and bindings | Released, v0.3.0 | 130 conformance fixtures; 11-job platform artifact matrix green |
| Platform artifacts (desktop, Android, Apple) | Built, unsigned | Compile and smoke-tested in CI; no device or emulator runtime tests yet |
| Trust directory server | Reference implementation | 103 tests, OpenAPI lint, 12 conformance fixtures, v1 smoke check |
| Browser extension, Chrome | Verified as packaged | MV3 extension loaded and driven in Chromium automation |
| Browser extension, Firefox and Safari | Builds, unproven | Bundles within size limits; not yet loaded as installed extensions |
| WordPress plugin | Built, integration broken | Cannot complete a sign against the current trust directory server, a protocol version skew; verified end to end only against a pre-v1 server revision. A fix is in an open PR |
| Hugo module | In production | Signs this site at build time |
| IETF Internet-Draft | Pre-submission | Not posted to the datatracker |
| W3C CG Report | Pre-submission | Not submitted to a Community Group |
| Downstream consumers on v0.3.0 | In migration | The extension, WordPress plugin, Hugo signer and E2E harness still build against the pre-v0.3.0 core |
| Production adopter | None yet | Crawl-time verification is the next milestone |

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
