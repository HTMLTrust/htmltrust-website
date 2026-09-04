---
title: 'What the five implementations actually proved'
summary: 'The paper now says explicitly that its interoperability result describes a revision that no longer exists. Deleting the claim would have been wrong; leaving it unqualified would have been worse.'
date: 2026-09-03
authors:
  - jason
tags:
  - paper
  - canonicalization
  - method
htmltrust:
  sign: true
  claims:
    content-type: 'Article'
    license: 'CC-BY-4.0'
    ai-assistance: 'Human+AI'
---

[v0.3.0](/blog/v0-3-0-one-core-and-a-licence-that-permits-adoption/) replaced five independently written canonicalization implementations with one Rust core and four bindings. That left the paper describing an architecture that no longer exists, and the fix is more interesting than it sounds, because there were three ways to handle it and two of them were wrong.

## The result in question

The paper reports that five language implementations, written separately against the specification and sharing no code, jointly accepted 121 of 4,846 archived news pages, and that 119 of those produced identical SHA-256 digests. It reports a 123-fixture conformance suite passing across all five, at that revision; the suite is 130 fixtures as of v0.3.0. The numbers are modest on purpose: 2.5% joint acceptance is not a triumphant figure, and the paper says so at some length.

The temptation, having just consolidated onto one core, is to treat that result as obsolete. It is not obsolete. It is the only evidence the project has for the claim that actually matters.

## What an interoperability result is evidence of

A canonicalization algorithm is specifiable only if two people reading the same document produce the same bytes. That is a property of the *writing*, not of the code. You cannot demonstrate it by running one implementation, however carefully tested, because a single implementation is self-consistent by construction. Every ambiguity in the prose gets silently resolved the same way each time, and the tests pass, and you learn nothing about whether the prose was clear.

Five independent implementations agreeing byte-for-byte is a test of the specification. Every place they disagreed was a place the text was ambiguous, and the disagreements were the useful output: a quote character in the wrong class, five different URL serializations, entity tables of different sizes, whether to walk into a `<template>`. Each one was a defect in the writing that no amount of testing a single implementation would have surfaced.

That is why the result survives the consolidation. It was never a claim that the shipping code has five implementations. It was a claim that the rules are precise enough to reimplement, which is exactly what a standards body needs to believe before adopting anything.

## Three options, two of them wrong

**Delete the result and report the new architecture.** Wrong, and the most tempting, because it produces the cleanest-looking paper. It also destroys the only evidence for specifiability and leaves the project asserting that its algorithm is reimplementable with nothing behind the assertion.

**Leave it as written.** Also wrong, and worse. The paper used the present tense about an architecture that changed. Nothing in it was false at the time, everything was pinned to a named revision, and a careful reader could reconstruct the timeline. But "a careful reader could work it out" is the standard you apply to your own drafts, not to something you ask other people to evaluate. A reviewer who opens the repository, finds one implementation, and returns to a paper describing five has just learned to check everything else you wrote.

**Scope it explicitly.** What [the revision](https://github.com/HTMLTrust/htmltrust-spec/pull/13) does. The results section now says its measurements describe the revision where the implementations shared no code, and why that independence is the point of the test rather than an incidental detail. A new availability paragraph records the licensing, notes that v0.3.0 consolidated the bindings, and tells the reader in as many words to treat every independence claim as scoped to the evaluated revision.

No measurement changed. Refreshing the evidence against the released core is a separate pass that needs the corpus rerun, and writing new numbers without a run behind them is the one thing that would be genuinely dishonest rather than merely untidy.

## Why bother

This project's entire proposition is that a reader should be able to check who said something instead of trusting a claim about it. A paper from that project that quietly lets a superseded architecture stand, because the correction is inconvenient and probably nobody would notice, is not a small inconsistency. It is the thesis failing at home.

The same reasoning produced the [superseded notice](/blog/paper-published/) on the April post, which announced a paper as published when it never was. That one is more embarrassing and was easier to decide: leave it at its address, say plainly what was wrong, and let the record stand. Deleting it would have been the cheapest option available and the one hardest to defend.

Dated evidence, clearly scoped, is worth more than a claim that reads well. The trust network only works if the people building it hold themselves to the check they are asking readers to perform.
