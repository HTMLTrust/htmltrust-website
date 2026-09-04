---
title: 'System architecture'
description: 'How authors, CMSes, browsers, crawlers, and federated trust directories interact.'
date: 2026-05-13
htmltrust:
  sign: true
  claims:
    content-type: 'Specification'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

HTMLTrust is a system of small, independent pieces. Authors sign content. CMSes embed signatures. Browsers verify locally. Optional directories store endorsements and surface reputation. No piece is required for verification to work.

## The whole system, one diagram

{{< diagram label="Figure 1" alt="An author's private key stays in their browser. The CMS asks the browser to sign, publishes a page with signed blocks, which readers and crawlers verify locally. Trust directories sit off to the side and are queried only optionally." caption="Solid lines are required paths. Dotted lines are optional directory traffic: remove every directory from this diagram and signature verification still works." >}}
    Author
      |
      | writes
      v
  +--------------+   asks for a signature    +----------------------+
  |              | ------------------------> |   Author's browser   |
  |     CMS      |                           |   holds the private  |
  |              | <------------------------ |   key, which never   |
  +--------------+   returns the signature   |   leaves the browser |
      |                                      +----------------------+
      | publishes
      v
  +------------------------------+
  |   Page with signed blocks    |
  +------------------------------+
      |                        |
      | read                   | crawled
      v                        v
  +----------------+     +----------------+
  | Reader browser |     |    Crawler     |
  +----------------+     +----------------+
      |                        |
      | verify locally         | verify at scale
      v                        v
    trust score           research, flags
      :                        :
      : query reputation       : file reports
      v                        v
  +--------------------------------------------+
  |   Federated trust directories  (0 to n)    |
  +--------------------------------------------+
{{< /diagram >}}

## Two layers, kept separate

{{< diagram label="Figure 2" alt="Layer one canonicalizes, hashes, resolves the key and verifies the signature, producing a valid or invalid result. Only a valid result reaches layer two, which combines the reader's trust list, endorsements and directory reputation into a graduated score." caption="An invalid signature ends at Layer 1. No amount of reputation promotes it." >}}
  LAYER 1   cryptographic verification
            local, deterministic, no network call beyond key resolution

     canonicalize -- hash -- resolve keyid -- verify signature
                                                  |
                     +----------------------------+
                     |                            |
                  invalid                       valid
                     |                            |
                     v                            v
                  reject                    on to Layer 2

  LAYER 2   trust decision
            local, and different for every reader by design

     personal trust list  ---+
     endorsements         ---+---- graduated score ---- indicator
     directory reputation ---+
{{< /diagram >}}

A signature either verifies cryptographically or it does not. That part is binary, local, and identical across implementations. Trust is a matter of degree, and each user agent applies its own policy on top. [The trust network](/trust-network/) documents the reference policy, including the arithmetic and what happens when directories disagree.

## Author flow: signing

1. **Author → CMS.** Write the content as normal.
2. **CMS.** Canonicalize the text of the region to be signed.
3. **CMS.** Compute the content hash and the claims hash.
4. **CMS → browser.** Ask the author's browser to sign the canonical payload.
5. **Browser.** Sign with the private key, which never leaves the browser.
6. **Browser → CMS.** Return the signature only.
7. **CMS.** Embed the signature, key identifier, content hash, and algorithm on the `<signed-section>` element.
8. **CMS → author.** Publish the page.
9. **CMS → directory.** Optionally publish the content hash and key identifier. Skipping this step changes nothing about whether the page verifies.

The private key never leaves the author's browser. The CMS asks the browser to sign a canonical payload, receives the signature, and embeds it in the published HTML.

## Reader flow: verifying

1. **Reader → page origin.** `GET` the page.
2. **Page origin → reader.** HTML containing one or more `<signed-section>` elements.
3. **Reader.** Canonicalize the signed region and hash it.
4. **Reader → key resolver.** Resolve the `keyid`, by DID, key URL, or directory entry.
5. **Key resolver → reader.** The public key.
6. **Reader.** Verify the signature locally. This is the yes-or-no answer.
7. **Reader → directory.** Optionally query reputation and endorsements from each subscribed directory.
8. **Directory → reader.** Reputation and endorsements, or nothing at all if it is unreachable.
9. **Reader.** Apply the local trust policy and render an indicator.

Cryptographic verification is offline-capable once the public key is cached. Steps 7 and 8 feed the trust score only. Remove them and the signature check is unaffected.

## Domain binding

{{< diagram label="Figure 3" alt="Copying signed bytes to another domain makes the signature fail, because the canonical payload binds the publication origin. Wrapping the original section in an outer signature preserves both attributions." caption="The same copy operation gives a different result depending on whether the republisher signs their own wrapper." >}}
  UNAUTHORIZED MIRROR

    author.com  publishes a signed section
        |
        |  bytes copied verbatim
        v
    scraper.com  serves the identical bytes
        |
        v
    signature fails: the canonical payload binds the publication
    origin, and the origin in the payload no longer matches the host

  DELIBERATE REPUBLICATION

    author.com  publishes a signed section
        |
        |  republisher wraps the original section, unmodified,
        |  inside a section it signs with its own key
        v
    republisher.com  serves inner section plus outer signature
        |
        v
    both verify: the inner signature attributes the author,
    the outer one attributes the republisher
{{< /diagram >}}

A signature is bound to a publication origin via the canonical payload. Scrapers and mirror sites can copy the bytes, but the signature will not validate at a different origin. Legitimate republishing has its own mechanism: a republisher wraps the original `<signed-section>` in their own outer signature, preserving the original while adding an attribution chain. Formalizing that chain is [open work](/implementation/#open-design-questions).

## The directory's role

A trust directory MAY:

- **Index** content hashes and signers for discovery
- **Serve** endorsements submitted by third parties
- **Resolve** keys for authors who don't self-host (`keyid` can point at a directory entry)
- **Surface** reputation signals computed from its own curated trust graph

Federation means **many directories can coexist**, users choose which they trust at the higher level, and verification of a signature never requires contacting one. A directory is a convenience, never an authority.

[The trust network](/trust-network/) covers what a directory actually serves, how a reader weights several of them, what happens when two disagree, and what an attacker gets for running one.

## Next

- **[Spec details](/spec/)** for the element, its attributes, and canonicalization
- **[Reference implementations](/implementation/)** for what is running today, per component
