---
title: 'v0.3.0: one canonicalization core, and a licence that permits adoption'
summary: 'Five hand-maintained ports become one Rust core with five bindings. The project also relicensed to Apache-2.0 and CC BY 4.0, because the old licence forbade the thing the roadmap was built around.'
date: 2026-09-03
authors:
  - jason
tags:
  - release
  - licensing
  - canonicalization
htmltrust:
  sign: true
  claims:
    content-type: 'Article'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

[canonicalization v0.3.0](https://github.com/HTMLTrust/htmltrust-canonicalization/releases/tag/v0.3.0) is released. Two changes matter, and the second one is the more consequential.

## Five implementations become one, on purpose

HTMLTrust's differentiating claim is that the same content hashes to the same value no matter which tool produced it. To show that was achievable, the algorithm was implemented five times, independently, in JavaScript, Go, PHP, Rust and Python, and the ports were made to agree byte-for-byte across a shared conformance corpus.

That result did its job. It demonstrated that the written rules are complete enough for separate implementers to reach the same bytes without sharing code, which is the property a specification needs and the reason this one is worth standardizing.

It was also a liability to keep. Five hand-maintained implementations of a byte-exact algorithm is five places for a Unicode edge case to drift apart, forever, and every fix has to be made five times and proved five times. So v0.3.0 keeps one implementation, in Rust, and binds it from the other four languages. There is now exactly one place where canonical bytes are decided.

The interoperability result stays historical evidence, described with its date and revision on the [implementation page](/implementation/). It would be easy to leave the old claim up and let readers assume the current code proves it. It does not, and saying so is cheaper than being caught.

Also in the release: the core is built and run-linked for Linux, macOS and Windows on AMD64 and ARM64, with i686 compatibility lanes, Android libraries for all four NDK ABIs, and an Apple XCFramework. Those artifacts are unsigned and retained for review. The conformance suite is 130 fixtures.

## The licence was blocking the roadmap

Everything in this project was published under PolyForm Noncommercial, and the specification under CC BY-NC-ND. Both are gone as of today, replaced by **Apache-2.0** for all code and **CC BY 4.0** for the specification, the paper and this site.

That is not a change of heart about openness. It is a correction of a mistake that had gone unexamined, and the mistake was specific.

The next milestone for HTMLTrust is crawl-time verification: a search or answer engine checking signatures as it crawls, which needs no browser support to be useful and produces the operational evidence a standards discussion actually wants. Search engines are commercial. A noncommercial licence meant the reference verifier could not legally be run in the one deployment the roadmap was built around, and that would have surfaced inside somebody's legal review rather than in a conversation, arriving as a "no" with no reason attached.

The specification had a second, sharper problem. Submitting an Internet-Draft requires granting the IETF Trust the rights in BCP 78 and RFC 5378, including the right to create derivative works, because that is what allows a working group to edit a draft at all. A no-derivatives licence does not make submission hard. It makes it impossible. The draft could never have been posted.

So the restrictive licence was not protecting the project from anything. It was blocking the two paths the project exists to travel.

## What actually stops a fork

The instinct behind a restrictive licence is reasonable: you build something, you do not want it taken and splintered. But copyright licensing is the wrong instrument, because anyone may reimplement a protocol from its description no matter what the reference code says. Restricting the code cannot prevent a fork of the standard. It can only prevent adoption of your implementation, which is what it was doing.

What can be kept meaningful is the name. So there is now a [trademark policy](/trademark/), and it grants nearly everything: implement the specification for any purpose, commercial or not, with no permission needed; say your software implements or supports HTMLTrust; write about it, cite it, criticise it.

One condition, on one thing. Call your implementation HTMLTrust, in a way a reader would take as official, only if it passes the [public conformance suite](https://github.com/HTMLTrust/htmltrust-canonicalization/tree/main/conformance). No application, no registry, no fee, and nobody to ask. The suite is the gate, it is public, and it treats every implementation identically, including this project's own.

If "HTMLTrust" reliably tells a reader that an implementation produces the same canonical bytes as every other one, the name is worth keeping accurate, and it is worth more to an implementer than a fork would be. The trademark and the conformance suite are the same mechanism seen from two sides.

Contributions now have a recorded basis too, through the [Developer Certificate of Origin](https://developercertificate.org/) rather than a contributor licence agreement. Sign off your commits; there is nothing to countersign and nobody to email, and you keep the copyright in what you write. The trade is stated plainly in every CONTRIBUTING file: because contributors keep copyright, changing the licence later would need everyone's agreement. That is exactly why the licence was settled first.

## What is not done

The core is released. The things that consume it are not yet on it.

The browser extension, the WordPress plugin, the Hugo signer and the end-to-end harness all still build against the pre-v0.3.0 core, and migrating them is not a version bump. The Go binding in particular now loads its C ABI from an explicit native library path, which changes what has to be present at runtime wherever signing happens. For this site, signing happens in a CI job that holds a production signing key, and expanding what executes alongside that key is a decision worth making deliberately rather than in passing.

So the honest status is: one released core, a conformance suite anyone can run, artifacts for every platform worth naming, and a downstream migration in progress. The [implementation page](/implementation/) lists it per component, with the basis for each claim.

There is still no production adopter. That remains the milestone that matters, and the licence no longer stands in its way.
