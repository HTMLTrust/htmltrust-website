---
title: 'Trademark policy'
description: 'You may implement HTMLTrust without asking anyone. The name is what this policy governs, and the only bar on using it is passing the conformance suite.'
date: 2026-09-03
toc: false
htmltrust:
  sign: true
  claims:
    content-type: 'Policy'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

HTMLTrust&trade; is a trademark of Jason Grey. This policy says what you may do with the name. It governs the name alone, is separate from and additional to the copyright licence on any given repository, and each repository states its own licence.

The short version: implement freely, describe your work accurately, and do not use the name for something that would fail the conformance suite.

## You need no permission for any of this

- **Implementing the specification.** Write an implementation in any language, for any purpose, commercial or otherwise. A specification exists to be implemented and no permission is required or ever will be.
- **Saying what your software does.** "Implements HTMLTrust", "supports HTMLTrust", "verifies HTMLTrust signatures", "compatible with HTMLTrust". Describing your product by reference to the standard it implements is ordinary, accurate use.
- **Writing about the project.** Articles, papers, talks, documentation, comparisons, and criticism. Favourable or not.
- **Linking here**, quoting the specification under its licence, and citing the work.

## Using the name for your implementation

Call your implementation HTMLTrust something, or name it in a way a reader would take as this project's own release, only if it passes the published [conformance suite](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/conformance).

State the revision you passed against when you make the claim. The suite grows, so "passes the HTMLTrust conformance suite" without a revision is not a checkable statement, and the point of the bar is that anyone can check it. Run it with `conformance/run-all.sh`.

This is the whole mechanism. There is no application to file, no registry to join, no fee, and nobody to ask. The suite is the gate, it is public, and it treats every implementation the same way.

## What the name may not be used for

- **A modified specification.** Fork the work if you want to, the licence permits what it permits, but publish the result under a different name. Two incompatible things called HTMLTrust would make the name useless to readers, which is the one outcome this policy exists to prevent.
- **Implying endorsement or affiliation** that does not exist, including in a company name, product name, domain name, or logo that a reasonable reader would take as official.
- **Anything that fails the conformance suite** while carrying the name.

## Why a trademark rather than a restrictive licence

A copyright licence cannot stop anyone reimplementing a protocol from its description, and should not try. Restricting the code to prevent forks would mostly succeed at preventing adoption, which is the opposite of the goal.

What a name can do is stay meaningful. If "HTMLTrust" reliably tells a reader that an implementation produces the same canonical bytes as every other one, the name is worth keeping accurate, and that is worth more to an implementer than a fork would be. The conformance suite is what makes the claim checkable, so the trademark and the suite are the same mechanism seen from two sides.

## Questions

Ask. Anything this policy does not cover, any use you are unsure about, and any request to use the name in a way it does not permit: `jason@jason-grey.com`. The answer to a reasonable request is usually yes.

This policy may change. It will not change retroactively to make a conformant implementation non-compliant.
