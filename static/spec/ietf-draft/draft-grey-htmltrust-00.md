---
title: "HTMLTrust: Cryptographically Signed Sections of HTML"
abbrev: "HTMLTrust"
category: exp
docname: draft-grey-htmltrust-00
submissiontype: independent
date: {DATE}
consensus: false
v: 3
area: "Applications and Real-Time"
workgroup: "Independent Submission"
keyword:
  - html
  - signatures
  - provenance
  - content authenticity
  - canonicalization
  - decentralized identity
venue:
  github: "jasongrey/htmltrust-spec"
  latest: "https://htmltrust.org/spec/"

author:
  - fullname: Jason Grey
    organization: Improbability Engineers, LLC
    email: jason@jason-grey.com

normative:
  RFC2119:
  RFC8174:
  RFC8259:
  RFC8785:
  RFC8032:
  RFC7515:
  RFC4648:
  RFC3986:
  RFC8615:
  RFC3339:
  RFC9110:
  RFC9111:
  RFC6749:
  RFC7517:
  RFC6454:
  UNICODE-NFC:
    title: "Unicode Standard Annex #15: Unicode Normalization Forms"
    target: https://www.unicode.org/reports/tr15/
    author:
      - org: The Unicode Consortium
    date: 2023
  W3C.did-core:
    title: "Decentralized Identifiers (DIDs) v1.0"
    target: https://www.w3.org/TR/did-core/
    author:
      - org: W3C
    date: 2022

informative:
  RFC6376:
  RFC9421:
  RFC8446:
  RFC5280:
  HTMLTRUST-W3C:
    title: "HTMLTrust: Signed Sections for the Web (W3C Community Group Report)"
    target: https://htmltrust.org/spec/
    author:
      - name: Jason Grey
    date: 2026
  C2PA:
    title: "C2PA Technical Specification 2.0"
    target: https://c2pa.org/specifications/specifications/2.0/specs/C2PA_Specification.html
    author:
      - org: Coalition for Content Provenance and Authenticity
    date: 2024
  SXG:
    title: "Signed HTTP Exchanges"
    target: https://datatracker.ietf.org/doc/draft-yasskin-http-origin-signed-responses/
    author:
      - name: J. Yasskin
    date: 2024
  W3C.VC-DATA-MODEL-2:
    title: "Verifiable Credentials Data Model v2.0"
    target: https://www.w3.org/TR/vc-data-model-2.0/
    author:
      - org: W3C
    date: 2025
  SRI:
    title: "Subresource Integrity"
    target: https://www.w3.org/TR/SRI/
    author:
      - org: W3C
    date: 2023
  XMLDSIG:
    title: "XML Signature Syntax and Processing Version 2.0"
    target: https://www.w3.org/TR/xmldsig-core2/
    author:
      - org: W3C
    date: 2015
  ECOJI:
    title: "Ecoji: A base-1024 encoding using emoji"
    target: https://github.com/keith-turner/ecoji
    author:
      - name: K. Turner
    date: 2018
  CREDIBLE-WEB:
    title: "Credible Web Community Group"
    target: https://credweb.org/
    author:
      - org: W3C Credible Web Community Group
    date: 2024
  DEFACTO:
    title: "Decentralized Fact-checking and Provenance Organization (DeFacto) Community Group"
    target: https://www.w3.org/community/defacto/
    author:
      - org: W3C DeFacto Community Group
    date: 2024
  AI-CONTENT-DISCLOSURE:
    title: "AI Content Disclosure Community Group"
    target: https://www.w3.org/community/ai-content-disclosure/
    author:
      - org: W3C AI Content Disclosure Community Group
    date: 2024
  CREDENTIALS-CG:
    title: "Credentials Community Group"
    target: https://www.w3.org/community/credentials/
    author:
      - org: W3C Credentials Community Group
    date: 2024
  ANTIFRAUD-CG:
    title: "Anti-Fraud Community Group"
    target: https://www.w3.org/community/antifraud/
    author:
      - org: W3C Anti-Fraud Community Group
    date: 2024
  ORIGINATOR-PROFILE:
    title: "Originator Profile"
    target: https://originator-profile.org/
    date: 2024

--- abstract

This document specifies the on-the-wire protocol elements of HTMLTrust: a
canonicalization algorithm for HTML text regions, a deterministic signing
payload, encodings for hashes and signatures, an endorsement format, and an
optional HTTP API for federated trust directories. Together these allow
authors to cryptographically attest authorship of arbitrary semantic regions
of an HTML document and allow verifiers to confirm those attestations
without relying on any privileged authority.

This document defines only the wire protocol. The HTML element through which
HTMLTrust is exposed in browsers, its DOM interface, and the user-agent
processing model are defined in a companion W3C Community Group Report,
referenced here as [HTMLTRUST-W3C], and are out of scope for this document.

--- middle

# Introduction

Transport-layer security on the Web certifies the origin that served a
response; it does not certify the author of any particular passage within
that response. As large-scale republication and machine-generated content
have become routine, readers, downstream systems, and aggregators
increasingly lack a reliable means to determine who stands behind a
particular passage of text on a page, or whether that text has been altered
since publication.

HTMLTrust addresses this gap with a single, narrowly-scoped mechanism: a
cryptographic signature, carried in band, over the canonicalized text of a
region of an HTML document, bound to the publication origin and to a
resolvable signer identifier. Verifiers re-derive the canonical text,
recompute the hash, resolve the signer's public key, and verify the
signature, all without any required network call to a trusted third party.

A companion Community Group Report [HTMLTRUST-W3C] defines the HTML element
through which signed regions are expressed in the document, its DOM
interface, and the user-agent processing model. This document defines only
the protocol artifacts that an interoperable implementation must agree on:
the canonicalization algorithm, the signing payload, the encoding of hashes
and signatures, the endorsement document format, and the optional HTTP API
exposed by a federated trust directory.

## Scope

This document specifies:

- The canonicalization algorithm that transforms an HTML subtree into a
  byte string suitable for hashing (Section 4).
- The signing payload binding (Section 5).
- The encoding of hashes and signatures on the wire (Section 6).
- An IANA-style registry of signature and hash algorithms (Section 7).
- Key resolution mechanisms for the signer identifier (Section 8).
- The HTTP API exposed by a federated trust directory (Section 9).
- The endorsement document format (Section 10).
- The verification procedure that a verifier MUST follow (Section 11).

This document does not specify the HTML element, its DOM interface, parsing
behavior, rendering, user-agent UI, or accessibility considerations. Those
are defined in [HTMLTRUST-W3C].

## Related Work and Adjacent Efforts

HTMLTrust composes with rather than replaces several existing web-platform
mechanisms. Subresource Integrity [SRI] provides byte-level integrity for
fetched subresources and does not attest to authorship. Signed HTTP
Exchanges [SXG] sign complete HTTP responses bound to an origin, at response
granularity rather than per-region authorship. C2PA Content Credentials
[C2PA] provides provenance metadata for media assets through sidecars;
HTMLTrust extends an analogous goal to in-document HTML text regions, in
band rather than via sidecars. XML Digital Signatures [XMLDSIG] attempted
full structural signing of XML; its operational fragility across
implementations informs the deliberately narrow semantic-subset signing
specified in Section 4.

DomainKeys Identified Mail [RFC6376] provided the operational template of
separating cryptographic verification from policy-driven trust decision.
JSON Web Signature [RFC7515] and HTTP Message Signatures [RFC9421] are used
as building blocks for endorsement signing (Section 10.2) and directory
submission authentication (Section 9.8) respectively. The W3C Decentralized
Identifiers specification [W3C.did-core] is reused for key resolution
(Section 8.1).

Several active W3C Community Groups address concerns adjacent to HTMLTrust.
The Credible Web Community Group [CREDIBLE-WEB] has produced the
Credibility Signals catalog and hosts research on reputation graphs,
credibility scoring, and originator-profile mechanisms; the Originator
Profile initiative [ORIGINATOR-PROFILE] presented to that group in August
2024 is an independent author-attestation effort whose goals overlap with
this work. The Decentralized Fact-checking and Provenance Organization
Community Group [DEFACTO] researches decentralized provenance for
text-based content, with architectural overlap with the endorsement and
trust-directory model defined in Sections 9 and 10. The AI Content
Disclosure Community Group [AI-CONTENT-DISCLOSURE] is defining structured
syntax for declaring AI-authored content under emerging regulatory regimes;
HTMLTrust's claim namespace, defined in the companion [HTMLTRUST-W3C], is
intended to compose with such disclosure metadata when carried inside a
signed section. The Credentials Community Group [CREDENTIALS-CG] is the
originating community for [W3C.did-core] and the Verifiable Credentials
work, both used as building blocks. The Anti-Fraud Community Group
[ANTIFRAUD-CG] addresses web-platform mitigations for fraudulent content
delivery, an adjacent threat surface to author impersonation.

## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Terminology

The following terms are used throughout this document.

Signer:
: An entity that produces a signature over a signed section. A signer is
  identified by a key identifier (see "key identifier") that resolves to a
  public key.

Verifier:
: An entity that consumes a signed section, re-derives the canonical
  representation, resolves the signer's public key, and validates the
  signature. The reference verifier is typically a user agent, but
  command-line tools, search-engine crawlers, and aggregators are also
  conforming verifiers.

Signed section:
: A region of an HTML document that has been signed under this
  specification. The HTML element that delimits a signed section is the
  HTMLTrust signed section element as defined in [HTMLTRUST-W3C]. Within
  this document, references to "the signed section" refer to the abstract
  region of content and its associated attributes, not to any particular
  parser representation.

Canonical content:
: The deterministic UTF-8 byte string produced by applying the algorithm in
  Section 4 to the signed text and signed semantic attributes of a signed
  section.

Canonical claims:
: The deterministic UTF-8 byte string produced by applying the algorithm in
  Section 4.6 to the in-band claim metadata of a signed section.

Content hash:
: The cryptographic hash of the canonical content, prefixed with a hash
  algorithm identifier per Section 6.

Claims hash:
: The cryptographic hash of the canonical claims, prefixed with a hash
  algorithm identifier per Section 6.

Signing payload:
: The deterministic byte string defined in Section 5 over which the
  signature is computed.

Key identifier:
: An opaque string ("keyid") that identifies a signer. A key identifier is
  resolved to a public key by one of the methods in Section 8.

Trust directory:
: An optional federated service that indexes signed content, stores
  endorsements, serves public keys, and may produce reputation scores. The
  HTTP API is defined in Section 9.

Endorsement:
: A signed JSON document attesting that an endorser holds an opinion about
  a specific content hash at a specific point in time. The format is
  defined in Section 10.

Origin:
: The Web origin at which signed content is canonically published, as
  defined by [RFC6454]: the tuple of scheme, host, and port. HTMLTrust
  serializes origins as described in Section 5.

# Architecture Overview

The HTMLTrust protocol involves four actors:

Signer:
: Produces canonicalized content, computes hashes, constructs the signing
  payload, and signs it with a private key. Typically embedded in a
  publishing pipeline (content management system, static-site generator,
  authoring tool).

Publisher origin:
: Serves the resulting HTML to verifiers over the Web. The publisher
  origin is bound into the signing payload via the legacy-named `domain`
  field (Section 5). The publisher origin and the signer MAY be different
  entities; the origin attests transport, the signer attests authorship.

Verifier:
: Performs the procedure in Section 11. The verifier re-derives canonical
  content, recomputes hashes, resolves the signer's public key, and
  validates the signature. Verification is local except for key
  resolution, which MAY require a network fetch.

Trust directory:
: Optional. Indexes content hashes for discovery, stores endorsements,
  serves public keys for signers who choose directory-based identity, and
  MAY compute reputation scores. No directory is privileged by the
  protocol. A verifier MAY perform full cryptographic verification without
  ever contacting a directory.

The basic data flow is:

1. The signer canonicalizes a content region per Section 4 and computes
   the content hash.
2. The signer collects in-band claim metadata, canonicalizes the claims
   per Section 4.6, and computes the claims hash.
3. The signer constructs the signing payload per Section 5 and signs it
   with the private key corresponding to the signer's key identifier.
4. The signer emits the HTML region annotated with key identifier,
   signature, content hash, and algorithm attributes per [HTMLTRUST-W3C].
5. The publisher origin serves the resulting HTML.
6. A verifier obtains the HTML, extracts the signed section's attributes
   and content, and performs the procedure in Section 11.
7. The verifier MAY consult a trust directory for endorsements,
   reputation, or key resolution, depending on configuration.

# Canonicalization

This section defines the deterministic transformation from an HTML
subtree to a UTF-8 byte string suitable for hashing. A conforming
implementation MUST produce byte-for-byte identical output for inputs
that this section declares equivalent.

## Inputs

The input to canonicalization is a DOM subtree rooted at the signed
section element. For the purposes of this document, the subtree is
treated as the abstract tree defined by the HTML Living Standard parser
applied to the source octets, equivalently as obtained from the live
DOM after parsing and before any script-driven mutation.

A verifier that operates on bytes (for example, a crawler verifying
without instantiating a DOM) MUST produce the same result as a
DOM-aware verifier on the same source octets.

Editor's Note: Authoring tools and verifiers should be aware that
runtime DOM mutation inside a signed section can make rendered-content
verification stale or invalid even when the original server HTML verifies.
Mitigations and an opt-out marker mechanism are under discussion; see
the Open Issues appendix.

## Walk and text extraction

The canonicalizer performs a depth-first, document-order traversal of
the subtree. At each node:

- If the node is a `Text` node, its data contributes to the canonical
  content per Section 4.4.
- If the node is an `Element`, the canonicalizer:
  1. Determines whether the element is included, excluded, or boundary-
     producing per Section 4.3.
  2. If included, emits any signed semantic attribute records for the
     element per Section 4.3.2.
  3. If included, recurses into its children.
  4. If the element produces a block boundary (Section 4.5), emits the
     boundary marker around the recursion result.
- If the node is a `Comment`, `ProcessingInstruction`, or
  `DocumentType`, it is ignored and contributes nothing.

A signed section element MAY itself be a descendant of another signed
section element. The inner element and its subtree are canonicalized
independently; from the outer element's perspective, the inner element
contributes its canonical content as if it were a transparent block-
producing element.

## Element categories

Elements are partitioned into three categories.

### Excluded elements

The following elements and their entire subtrees MUST be excluded from
the canonical content. Their contents do not contribute any bytes.

- `script`
- `style`
- `template`
- `noscript`
- `iframe`
- HTML comments and processing instructions (already excluded by 4.2).

The in-band claim `<meta>` elements (Section 4.6) are also excluded
from the canonical content; they contribute instead to the canonical
claims.

### Included elements

All elements not in Section 4.3.1 are included. Their start and end
tags do not themselves contribute bytes, but they MAY contribute block
boundaries per Section 4.5 and their descendant text nodes contribute
to the canonical content.

The following signed semantic attributes also contribute to the
canonical content when present on an included element:

- `href`
- `src`
- `alt`
- `aria-label`

This first signed-attribute list is intentionally small and is open
for community feedback. Future revisions MAY add attributes to the
list, but verifiers for this revision MUST use exactly the list above.

For each included element, before visiting the element's children, the
canonicalizer examines the signed semantic attributes in the order
listed above. For each present attribute, it appends one attribute
record to the canonical content:

~~~
@attr ":" element-local-name ":" attribute-name ":" normalized-value "\n"
~~~

`element-local-name` and `attribute-name` are ASCII-lowercase names as
exposed by the HTML parser. `normalized-value` for `alt` and
`aria-label` is produced by applying the plain-text normalization in
Section 4.4. `normalized-value` for `href` and `src` is produced by
parsing the attribute value as a URL against the signed document's base
URL and serializing the resulting URL using the Web URL serializer. If
URL parsing fails, verification MUST fail with
"attribute-canonicalization-failed". The serialized value MUST NOT
contain U+000A; if a canonicalizer cannot guarantee this, verification
MUST fail with "attribute-canonicalization-failed".

Editor's Note: The precise expansion list for signed semantic
attributes is expected to evolve. Candidate additions include `title`,
`cite`, image dimension attributes, and ARIA attributes used in name
computation, but this revision deliberately avoids full structural HTML
signing.

### Boundary-producing elements

Block-level elements introduce a paragraph boundary in the canonical
content (see Section 4.5). The set of boundary-producing element names
is exactly:

`address`, `article`, `aside`, `blockquote`, `details`, `dialog`,
`div`, `dl`, `fieldset`, `figcaption`, `figure`, `footer`, `form`,
`h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `header`, `hgroup`, `hr`, `li`,
`main`, `nav`, `ol`, `p`, `pre`, `section`, `table`, `td`, `th`, `tr`,
`ul`.

The element `br` introduces a soft line break (see Section 4.5).

## Text normalization

For each `Text` node included in the walk, its data is normalized as
follows, in order:

1. Apply Unicode Normalization Form NFKC ([UNICODE-NFC]).
2. Strip the formatting characters defined in Section 4.4.2.
3. Apply the whitespace mapping defined in Section 4.4.3.
4. Apply the punctuation normalizations defined in Section 4.4.4.

### Rationale

These normalizations make the canonical form stable under the silent
transformations introduced by content management systems, rich-text
editors, and copy-paste operations across applications (curly versus
straight quotes, em dash versus double hyphen, fullwidth versus
halfwidth forms, and similar). A signer's content remains verifiable
after any such round-trip provided the abstract text is unchanged.

### Stripped formatting characters

The following characters MUST be removed entirely. They carry no
content semantics in any language.

- U+00AD SOFT HYPHEN
- U+200B ZERO WIDTH SPACE
- U+200E LEFT-TO-RIGHT MARK
- U+200F RIGHT-TO-LEFT MARK
- U+2060 WORD JOINER
- U+FEFF BYTE ORDER MARK / ZERO WIDTH NO-BREAK SPACE
- U+034F COMBINING GRAPHEME JOINER
- U+061C ARABIC LETTER MARK
- U+180E MONGOLIAN VOWEL SEPARATOR
- U+0640 ARABIC TATWEEL
- U+FE00..U+FE0F VARIATION SELECTORS 1-16
- U+E0100..U+E01EF VARIATION SELECTORS 17-256
- U+E0001..U+E007F TAG CHARACTERS
- U+202A..U+202E BIDI EMBEDDING CONTROLS
- U+2066..U+2069 BIDI ISOLATE CONTROLS
- U+2061..U+2064 INVISIBLE MATH OPERATORS
- U+FFF9..U+FFFC INTERLINEAR ANNOTATION ANCHORS AND OBJECT REPLACEMENT

The following characters MUST be preserved despite their visual
invisibility. They are semantically significant in major writing
systems.

- U+200C ZERO WIDTH NON-JOINER (semantic in Persian, Kurdish, Syriac).
- U+200D ZERO WIDTH JOINER (semantic in Indic scripts and emoji
  sequences).

### Whitespace

Outside of a `<pre>` element, each of the following Unicode code
points MUST be replaced with U+0020 SPACE:

U+0009, U+000A, U+000B, U+000C, U+000D, U+0085, U+00A0, U+1680,
U+2000..U+200A, U+2028, U+2029, U+202F, U+205F, U+3000.

After replacement, runs of two or more U+0020 SPACE characters MUST
be collapsed to a single U+0020 SPACE. Leading and trailing whitespace
within each block (delimited by Section 4.5 boundaries) MUST be
removed.

Inside a `<pre>` element, the only normalization that applies is
NFKC (Section 4.4) and stripping of the characters in Section 4.4.2.
Whitespace within `<pre>` MUST be preserved verbatim except that
U+000D U+000A and U+000D MUST be converted to U+000A.

### Punctuation normalization

The following character classes are normalized to ASCII. The intent
is hash stability across CMS-driven typographic transformations.

Single quotation marks: each of U+2018, U+2019, U+201A, U+201B,
U+2032, U+2039, U+203A, U+0060, U+00B4 MUST be replaced with U+0027.

Double quotation marks: each of U+201C, U+201D, U+201E, U+201F,
U+2033, U+00AB, U+00BB, U+300C, U+300D, U+300E, U+300F,
U+301D..U+301F, U+FE41..U+FE44 MUST be replaced with U+0022.

Dashes and hyphens: each of U+2010, U+2011, U+2012, U+2013, U+2014,
U+2015, U+2212, U+FE58, U+FE63 MUST be replaced with U+002D.

Ellipsis: each of U+2026, U+FE19 MUST be replaced with the three-byte
sequence U+002E U+002E U+002E.

## Block structure

A boundary-producing element (Section 4.3.3) emits a single U+000A
LINE FEED character after its descendants have contributed their
text. The `br` element emits a single U+000A LINE FEED character at
its position.

After the entire subtree has been walked, the resulting byte sequence
is trimmed: leading and trailing runs of U+000A and U+0020 are
removed, and runs of two or more U+000A in a row are collapsed to a
single U+000A.

The result is a UTF-8 byte string.

## Canonical claims

In-band claim metadata is carried by `<meta>` elements that appear as
direct children of the signed section element, as required by
[HTMLTRUST-W3C]. Claim `<meta>` elements located at greater depth do
not participate.

Every direct child `<meta>` element of a signed section is a claim.
A claim `<meta>` element MUST have both a `name` attribute and a
`content` attribute. If any direct child claim `<meta>` is missing
either attribute, verification MUST fail with "claim-malformed". If
the normalized `name` is the empty string, verification MUST fail with
"claim-malformed".

For each claim `<meta>` element:

1. The `name` attribute value is processed as plain text per
   Section 4.4 (NFKC, formatting strip, whitespace collapse).
2. The `content` attribute value is processed identically.
3. The pair is serialized as

   name `:` content `\n`

   where `:` is U+003A COLON, `\n` is U+000A LINE FEED, and the
   surrounding tokens are the normalized name and content. Neither
   token is further escaped, and neither token contains the literal
   character U+000A after Section 4.4 whitespace normalization.

The resulting `name : content` lines are sorted lexically by the
UTF-8 byte sequence of the normalized `name`. Ties on name MUST NOT
occur; signers MUST NOT emit two direct child claim `<meta>` elements
whose `name` attributes normalize to the same value within a single
signed section, and verifiers MUST fail with "claim-duplicate" if they
encounter such duplicates. The concatenation of the sorted lines is
the canonical claims byte string.

The `signed-at` claim is not special for purposes of the claims hash:
it is included in canonical claims like every other direct child claim
`<meta>`. Section 5 also includes the normalized `signed-at` value as
a separate signing-payload field. This deliberate duplicate binding
makes the timestamp easy for verifiers and directory indexes to extract
without weakening claim integrity.

## Opt-out marker (Editor's Note)

Editor's Note: Common runtime decorations (copy-to-clipboard buttons,
client-side syntax highlighting, lazy-loaded share widgets) frequently
mutate descendants of a signed section after page load. This revision
addresses that problem by verifying the original server HTML snapshot
in the companion W3C processing model. A future revision might add an
author-controlled opt-out marker such as
`data-htmltrust-ignore="true"`, but that attribute has no normative
effect in this revision. Conforming canonicalizers MUST NOT exclude a
subtree solely because it carries that attribute unless operating in an
explicit experimental mode.

# Signing Payload Binding

The signature is computed over the deterministic UTF-8 byte string
formed by joining four fields with a single ASCII colon (U+003A)
between each:

~~~
content-hash ":" claims-hash ":" domain ":" signed-at
~~~

The fields are defined as follows.

content-hash:
: The content hash as defined in Section 6.2, including the
  algorithm prefix and separator (for example,
  `sha256:Zm9vYmFy...`). Verifiers MUST use the literal value
  serialized into the `content-hash` attribute of the signed section
  element.

claims-hash:
: The claims hash, formatted identically to `content-hash`. The
  claims hash is not carried in a separate attribute on the wire; it
  is recomputed by the verifier from the canonical claims byte
  string (Section 4.6) using the algorithm given by the prefix of
  the `content-hash` attribute. The hash algorithm for both
  `content-hash` and `claims-hash` MUST be the same.

domain:
: A legacy field name retained for wire compatibility. Its value is
  the serialized Web origin at which the content is canonically
  published. The serialized origin MUST bind the URL scheme, host, and
  port. It is serialized as `scheme://host[:port]`, with no path,
  query, fragment, or credentials. The host MUST be lowercased, and
  internationalized hostnames MUST be serialized in A-label form. The
  port MUST be omitted when it is the default port for the scheme and
  MUST be included otherwise. For example, `https://example.org` and
  `https://example.org:8443` are distinct origins.

signed-at:
: The value of the `signed-at` claim `<meta>` element, after the
  normalization in Section 4.4 has been applied. The value MUST
  conform to the date-time production of [RFC3339] with the time
  offset given in UTC ("Z").

The fields MUST appear in the order shown. The separator MUST be a
single U+003A COLON. No leading or trailing whitespace is permitted.

## Identity not bound directly

The signer's identifier (`keyid`) is intentionally not included in
the signing payload. The identifier is implicit in key resolution
(Section 8): any attempt to claim a different identifier would
resolve to a different public key, and the signature would fail to
verify. Including the identifier explicitly would add a fragile
string-matching surface without strengthening the cryptographic
binding.

## Why the publisher origin

Binding the signature to the publication origin prevents verbatim
re-publication of signed content with the original signature
preserved. A reader who encounters apparently signed content at a
different origin will see a signature verification failure caused by
the origin mismatch alone, regardless of any other property of the
content. Legitimate re-publication is supported by a separate
wrapper-signing mechanism using a `claim:CanonicalURL` field (see
[HTMLTRUST-W3C]); the wrapper signer attests to a republication, not
to original authorship, and is responsible for the chain.

# Hash and Signature Encoding

## Encoding choice

Binary values on the wire, including hashes, signatures, and raw public
keys embedded in HTMLTrust JSON documents, MUST be encoded as canonical,
unpadded Base64 using the standard Base64 alphabet in Section 4 of
[RFC4648]. This is not base64url: the alphabet includes `+` and `/`,
and does not use `-` or `_`.

Producers MUST emit the shortest canonical unpadded Base64 form:

- no `=` padding characters;
- no whitespace;
- only the characters `A-Z`, `a-z`, `0-9`, `+`, and `/`;
- zero-valued unused pad bits as required by [RFC4648].

Verifiers MUST reject non-canonical Base64 in signed attributes and
signed JSON fields. A verifier determines canonicality by decoding the
value, re-encoding the decoded bytes using the rules above, and
requiring byte-for-byte equality with the original value. Implementations
MAY provide an explicit legacy-tooling mode that accepts padded Base64
or base64url for migration testing, but that mode is non-conforming for
normal verification and MUST be distinguishable from conforming
verification in diagnostics.

Because standard Base64 uses `+` and `/`, HTMLTrust values placed in
URL paths, query strings, or other URL components MUST be
percent-encoded where required by the URL component's grammar. For
example, the `/` character in a content hash path segment is encoded as
`%2F`.

Editor's Note: Hex (familiar from git and TLS tooling) and base32
(case-insensitive and easier to transcribe) remain useful diagnostic
formats, but they are not wire encodings for this revision. Ecoji
[ECOJI] has been proposed; it has been rejected on wire-byte grounds
(32-byte SHA-256 digest is 26 emoji = 104 UTF-8 bytes versus 43
Base64 characters) and is noted here for completeness.

## Content hash and claims hash

A content hash or claims hash is the concatenation of:

1. A hash algorithm identifier from the registry in Section 7.2.
2. A single U+003A COLON.
3. The Base64-encoded, unpadded hash output.

For example, a SHA-256 hash of an empty string is:

~~~
sha256:47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU
~~~

Verifiers MUST reject a content hash whose algorithm identifier is
not in the registry, and MUST reject a content hash whose
Base64-decoded length is not the natural output length of the
identified algorithm (32 bytes for `sha256`, 48 bytes for `sha384`,
64 bytes for `sha512`).

## Signature

The `signature` attribute carries the Base64-encoded, unpadded
output of the signature algorithm given by the `algorithm` attribute.
For algorithms that produce variable-length signatures (for example,
RSA with key sizes other than 2048 bits), the length is determined by
the resolved public key.

For Ed25519 ([RFC8032]), the signature is exactly 64 bytes
(86 Base64 characters).

# Algorithm Registry

This section requests creation of two IANA registries (see Section
13). The initial contents are listed here.

## Signature algorithms

The following identifiers are defined for use in the `algorithm`
attribute of a signed section.

| Identifier | Algorithm | Reference |
|---|---|---|
| `ed25519` | EdDSA over edwards25519 | [RFC8032] |
| `ecdsa-p256` | ECDSA with SHA-256 over secp256r1 | [RFC9110] / FIPS 186-5 |
| `ecdsa-p384` | ECDSA with SHA-384 over secp384r1 | FIPS 186-5 |
| `rsa-pss-sha256` | RSASSA-PSS with SHA-256 and MGF1-SHA-256 | [RFC7515] |
| `rsa-pkcs1-sha256` | RSASSA-PKCS1-v1_5 with SHA-256 | [RFC7515] |

The mandatory-to-implement algorithm for both signers and verifiers
is `ed25519`. A verifier MAY accept additional algorithms; a verifier
MUST treat an `algorithm` value not in its accepted set as an
"algorithm-not-supported" verification failure, not as a generic
failure.

## Hash algorithms

The following identifiers are defined for use in the algorithm prefix
of `content-hash` and `claims-hash`.

| Identifier | Algorithm | Output length |
|---|---|---|
| `sha256` | SHA-256 | 32 bytes |
| `sha384` | SHA-384 | 48 bytes |
| `sha512` | SHA-512 | 64 bytes |

The mandatory-to-implement hash algorithm is `sha256`. The hash
algorithm used for `content-hash` and `claims-hash` within a single
signed section MUST be the same.

## Algorithm agility

A future revision of this specification MAY add identifiers via
expert review (Section 13). Identifiers MUST NOT be removed once
registered; an identifier MAY be marked "deprecated" with normative
text recommending non-use. Verifiers SHOULD refuse to verify under a
deprecated identifier and SHOULD surface the result as an
"algorithm-not-supported" outcome.

# Key Resolution

The `keyid` attribute of a signed section is opaque to the protocol.
This section defines three resolution methods. A verifier MUST
implement at least one and SHOULD implement all three; a signer
SHOULD use the most decentralized method available in its operating
context.

## DID method resolution

A `keyid` whose value begins with `did:` MUST be resolved per the DID
Core specification [W3C.did-core] using the DID method indicated by
the second URI scheme component. The DID document MUST be retrieved,
and the public key MUST be selected from its `verificationMethod`
array.

The verifier MUST select a verification method whose `type` is
compatible with the `algorithm` attribute of the signed section. If
multiple verification methods are present, the verifier MUST prefer a
method whose `id` is referenced from the `assertionMethod` relationship
of the DID document; if no such method exists, the verifier MAY use
any verification method of compatible type.

DID resolution failures (DID document not found, signature on DID
document invalid where the method demands one, expired or revoked
verification method) MUST be reported as "key-resolution-failed"
verification failures.

## Direct HTTPS URL

A `keyid` whose value is an absolute URL with scheme `https` MUST be
resolved by issuing a GET request to that URL. The response MUST
have a media type of `application/htmltrust-key+json` (Section 13)
or `application/jwk+json` per [RFC7517]; verifiers MAY accept
`application/json` for backward compatibility.

The retrieved document MUST be one of:

- A JSON Web Key per [RFC7517], or
- An HTMLTrust key document with the following shape:

  ~~~
  {
    "kid": "<string, optional>",
    "algorithm": "<algorithm identifier>",
    "publicKey": "<Base64-encoded public key bytes>",
    "expires": "<RFC3339 timestamp, optional>",
    "revoked": <boolean, optional>
  }
  ~~~

A `revoked` value of `true` or an `expires` value in the past MUST be
treated as a "key-revoked" verification failure. The verifier MUST
NOT proceed to signature verification in either case.

## Trust directory reference

A `keyid` whose value is an absolute URL pointing at a trust
directory's `/keys/{id}` endpoint (Section 9.6) MUST be resolved by
issuing a GET request to that URL. The response format is identical
to Section 8.2.

The verifier SHOULD consider the trustworthiness of the directory
itself before accepting a key resolved this way; directory-based
identity centralizes a portion of the trust graph in the directory
operator.

## Acceptance policy

A verifier MUST permit configuration of which key-resolution methods
it accepts and SHOULD default to accepting all three. The verifier
MUST NOT privilege any one method over another within its accepted
set; selection is determined by the `keyid` value, not by the
verifier.

# Trust Directory HTTP API

This section defines the HTTP API exposed by an optional federated
trust directory. A directory implementing this API conforms to
[RFC9110] and supports content negotiation and standard cache
directives [RFC9111].

The API shape in this section is normative for conforming trust
directories. Reference implementations and deployed services that
diverge from these endpoints, field names, media types, or verification
requirements need to change to match this specification rather than the
reverse.

A verifier MAY consult zero, one, or multiple directories. The
protocol does not require directory consultation for cryptographic
verification (Section 11.1 through 11.6); only endorsement and
reputation use cases require directory access.

## Base URL and discovery

A directory MUST be reachable at an `https`-scheme base URL. The
endpoints below are relative to that base URL.

A directory SHOULD also expose a discovery document at the
well-known URI [RFC8615] `/.well-known/htmltrust` (Section 9.2).

## GET /.well-known/htmltrust

Returns a JSON metadata document describing the directory's
capabilities. The response media type is
`application/htmltrust-directory+json` (provisional; see Section 13).

~~~
{
  "directory": "https://directory.example/",
  "version": "1",
  "capabilities": {
    "content": true,
    "endorsements": true,
    "keys": true,
    "reputation": true
  },
  "supportedAlgorithms": {
    "signature": ["ed25519", "ecdsa-p256"],
    "hash": ["sha256", "sha384"]
  },
  "contact": "operator@directory.example",
  "termsOfService": "https://directory.example/tos"
}
~~~

The fields `directory`, `version`, `capabilities`, and
`supportedAlgorithms` are REQUIRED. Other fields are OPTIONAL.

JSON members named `domain` in this API carry the serialized origin
value defined for the signing payload in Section 5. The field name is
retained for compatibility with early tooling and MUST NOT be
interpreted as a host-only domain name.

## GET /content/{hash}

Retrieves the directory's record for a specific content hash. The
path parameter is the content hash including the algorithm prefix,
percent-encoded as a single path segment (the colon becomes `%3A`;
any `/` in the Base64 value becomes `%2F`).

A successful response is JSON of the form:

~~~
{
  "contentHash": "sha256:Zm9vYmFy...",
  "firstSeen": "2026-05-15T12:34:56Z",
  "signers": [
    {
      "keyid": "did:web:author.example",
      "signedAt": "2026-05-01T10:30:00Z",
      "domain": "https://author.example",
      "signature": "3q2-7w8NslfJ..."
    }
  ],
  "endorsementCount": 3
}
~~~

A directory that does not have a record for the requested hash MUST
return `404 Not Found`.

## POST /content

Submits a record of a signed content occurrence for indexing. The
request body is JSON of the form:

~~~
{
  "contentHash": "sha256:Zm9vYmFy...",
  "keyid": "did:web:author.example",
  "signedAt": "2026-05-01T10:30:00Z",
  "domain": "https://author.example",
  "signature": "3q2-7w8NslfJ...",
  "sourceURL": "https://author.example/posts/123",
  "claims": [
    {"name": "author", "content": "Alice Example"},
    {"name": "claim:License", "content": "CC-BY-4.0"}
  ]
}
~~~

The submission MUST be authenticated by an HTTP Message Signature
[RFC9421] from a key the directory can resolve. The directory MUST
re-verify the submitted signature against the canonical signing
payload (Section 5) before indexing.

Successful submission returns `201 Created` with a `Location` header
pointing at the resulting `/content/{hash}` URL. Rejected submissions
return `4xx` codes per Section 9.9.

## GET /content/{hash}/endorsements

Lists endorsements stored for a given content hash. The response is a
JSON array of endorsement documents (Section 10), each independently
verifiable by the requester. The directory MUST NOT alter the
endorsement payloads in a manner that invalidates the endorser's
signature.

Pagination, if supported, MUST follow the Web Linking conventions of
[RFC9110] using `Link` headers with `rel="next"`.

## POST /endorsements

Submits a signed endorsement document (Section 10). The directory
MUST:

1. Verify the endorser's signature on the endorsement.
2. Verify that the endorsement's `endorsement` field references a
   content hash for which the directory has a record (or accept new
   content hashes; this is a directory policy choice).
3. Index the endorsement under the content hash for retrieval via
   Section 9.5.

Successful submission returns `201 Created`. Endorsements with
invalid signatures MUST be rejected with `400 Bad Request`.

## GET /keys/{id}

Retrieves a public key document for the given directory-issued key
identifier. The response is a key document conforming to Section 8.2.

Directories that act as convenience registries for less-technical
signers expose keys through this endpoint, and signers reference such
keys by setting `keyid` to the full URL of the endpoint, for example
`https://directory.example/keys/k-abc123`.

## GET /signers/{id}/reputation

Returns a directory-computed reputation score for a signer. The
response is JSON of the form:

~~~
{
  "keyid": "did:web:author.example",
  "score": 0.72,
  "asOf": "2026-05-15T00:00:00Z",
  "components": ["endorsements", "history", "verified-domain"],
  "methodology": "https://directory.example/methodology"
}
~~~

The `score` is a directory-specific value with no protocol-level
semantics; verifiers consume scores from directories that they have
been explicitly configured to trust. Different directories MAY
produce different scores for the same signer.

## Authentication

POST endpoints MUST be authenticated using HTTP Message Signatures
[RFC9421] with a key that the directory can resolve via Section 8.
The signature input MUST cover the `(request-target)`, `host`,
`date`, and `content-digest` components at a minimum.

GET endpoints SHOULD be accessible without authentication to support
public verification. A directory MAY require authentication for
specific endpoints subject to its operational policy; in that case
unauthenticated requests MUST receive `401 Unauthorized` with a
`WWW-Authenticate` header.

## Errors

The directory MUST return errors using the problem-details format
defined in [RFC9110]'s extensions, with media type
`application/problem+json`:

~~~
{
  "type": "https://htmltrust.org/errors/signature-invalid",
  "title": "Signature verification failed",
  "status": 400,
  "detail": "The submitted signature did not verify against the
  canonical signing payload.",
  "contentHash": "sha256:..."
}
~~~

Directories SHOULD apply rate limits per IP, per submitter key, and
per content hash, and SHOULD signal exhaustion with `429 Too Many
Requests` and a `Retry-After` header.

# Endorsement Format

An endorsement is a standalone, signed JSON document attesting to an
endorser's opinion of a specific content hash at a specific moment in
time. Endorsements target content hashes, not signers; an ongoing
opinion of a signer is expressed through directory reputation, not
through a persistent signer-level endorsement artifact.

The structured endorsement format defined in this section is normative.
Conforming directories MUST store, return, and verify endorsement
documents in this shape and MUST NOT replace it with an implementation-
specific flat signature record.

## Document shape

The endorsement document is a JSON object with the following fields.

| Field | Type | Required | Description |
|---|---|---|---|
| `endorser` | string | yes | Key identifier of the endorser, resolved per Section 8. |
| `endorsement` | string | yes | Content hash being endorsed, including algorithm prefix. |
| `signature` | string | yes | Base64-encoded signature over the canonicalized document; see Section 10.2. |
| `algorithm` | string | yes | Signature algorithm identifier from Section 7.1. |
| `timestamp` | string | yes | RFC 3339 UTC timestamp at which the endorsement was issued. |
| `expires` | string | no | RFC 3339 UTC timestamp at which the endorsement ceases to be valid. |
| `claim` | string | no | Free-text human-readable rationale for the endorsement. |
| `revokedBy` | string | no | If present, the endorsement has been superseded by the document with this content hash. |

Additional fields MAY be present and SHOULD be preserved by
directories. Verifiers MUST ignore fields they do not recognize for
purposes of trust decisions, but MUST include them when computing the
signed payload (Section 10.2) so that signature verification
succeeds.

## Canonicalization for signing

The signing payload for an endorsement is the JSON Canonicalization
Scheme [RFC8785] serialization of the endorsement document with the
`signature` field omitted. The endorser signs that byte string using
the algorithm given by `algorithm`. Verifiers reproduce the same
serialization, omit `signature`, and verify using the endorser's
resolved public key.

JSON Canonicalization Scheme is chosen because it is purpose-built
for signed JSON, is widely implemented, and avoids the parser-
divergence problems that have historically plagued ad-hoc JSON
canonicalization.

## Revocation and expiry

An endorsement with an `expires` value in the past MUST be treated
by verifiers as invalid for purposes of any current trust decision.
An endorsement with a `revokedBy` value MUST be treated as
superseded; the verifier MAY retrieve the superseding endorsement
from the same directory and apply its semantics in place.

An endorser MAY publish a revocation endorsement (an endorsement
whose `claim` field names the revoked endorsement's hash and whose
`revokedBy` field references the document being revoked). A
directory that holds both MUST serve both in response to
`GET /content/{hash}/endorsements` so that verifiers can observe the
revocation chain.

## Endorsement of an endorsement

Endorsement documents are themselves content. An endorser MAY in
turn endorse another endorser's document by computing the content
hash of the endorsement (as canonicalized in Section 10.2) and
issuing a new endorsement against that hash. This provides a
mechanism for chained reputation without protocol-level signer
endorsements.

# Verification Procedure

A conforming verifier MUST perform the following steps in order for
each signed section it intends to verify. Steps 11.1 through 11.6
are the cryptographic verification ("layer 1" in [HTMLTRUST-W3C]).
Step 11.7 is the trust decision and is out of scope for this
document; the verifier returns the cryptographic result to the
trust-decision layer for further evaluation.

## Step 1: Extract attributes and content

Obtain the four required attributes `keyid`, `signature`,
`content-hash`, and `algorithm` and the inner content of the signed
section. If any required attribute is missing, the verifier MUST
return an "incomplete" outcome and stop.

## Step 2: Canonicalize content; compute and compare content hash

Apply the canonicalization algorithm of Section 4 to the inner
content. Compute the hash using the algorithm given by the prefix of
the `content-hash` attribute. Compare the computed hash to the
attribute value (excluding the prefix and separator, after Base64
decoding).

If the hashes do not match, the verifier MUST return a
"content-hash-mismatch" failure and stop.

## Step 3: Canonicalize claims; compute claims hash

Apply Section 4.6 to the claim `<meta>` element children of the
signed section. Compute the hash using the same algorithm as Step 2.
Form the claims-hash string per Section 6.2.

## Step 4: Construct signing payload

Construct the byte string defined in Section 5 from `content-hash`
(verbatim from the attribute), the claims hash from Step 3, the
serialized origin of the current document (the legacy-named `domain`
field in Section 5), and the value
of the `signed-at` claim `<meta>` element after normalization
(Section 4.4). If the `signed-at` claim is absent, the verifier MUST
return a "claim-missing" failure and stop.

## Step 5: Resolve keyid

Resolve the `keyid` attribute per Section 8 to obtain a public key
and the algorithm it is suitable for. If resolution fails, the
verifier MUST return a "key-resolution-failed" failure and stop.

If the algorithm associated with the resolved key is incompatible
with the `algorithm` attribute of the signed section, the verifier
MUST return an "algorithm-mismatch" failure and stop.

## Step 6: Verify signature

Verify the Base64-decoded `signature` against the signing payload
from Step 4 using the public key from Step 5 and the algorithm given
by the `algorithm` attribute. If the verification fails for any
reason (invalid signature, malformed signature, algorithm not
supported), the verifier MUST return a corresponding failure and
stop.

If the verification succeeds, the verifier MUST return a "valid"
cryptographic outcome.

## Step 7: Trust decision (out of scope)

The verifier returns the cryptographic outcome to the trust-decision
layer (in browsers, the user agent's trust policy; see
[HTMLTRUST-W3C]). The trust layer composes endorsement,
reputation, and personal-trust-list inputs and MUST NOT alter the
cryptographic outcome.

## Verifier network fetch policy

This section defines a provisional network model for verifier-initiated
fetches. It is expected to be refined as browser, extension, and native
verifier implementations mature.

Remote key documents and trust-directory endpoints MUST be fetched over
HTTPS URLs. Verifiers MUST NOT send cookies, HTTP authentication state,
client certificates, or other ambient credentials on key or directory
fetches by default. A browser verifier MAY send credentials only for a
same-origin source refetch of the document being verified, and only when
that refetch is needed to obtain the original server HTML for the
[HTMLTRUST-W3C] processing model.

Verifier fetches SHOULD send no `Referer` header. If a platform cannot
omit the header, it MUST trim it no less strictly than
`strict-origin-when-cross-origin`.

Web-page JavaScript verifiers are subject to the Fetch CORS model and
therefore require key and directory servers to opt in with appropriate
CORS response headers. Browser extensions, native user agents, crawlers,
and command-line verifiers MAY have broader network authority, but they
SHOULD apply the same credential, referrer, redirect, timeout, and cache
constraints for privacy and interoperability.

Verifiers MAY follow HTTPS-to-HTTPS redirects for key and directory
fetches subject to a small implementation-defined limit. They MUST NOT
follow redirects to non-HTTPS URLs. They SHOULD impose finite timeouts,
SHOULD honor HTTP cache semantics [RFC9111], and SHOULD cap cached key
freshness when no explicit freshness information is present.

Browser verifiers that fetch through the page's fetch context MUST account
for service-worker interception. A service worker on the publisher origin
MAY intercept a same-origin source refetch; service workers on unrelated
origins MUST NOT be allowed to intercept key or directory fetches outside
their normal scope. User agents that provide a privileged verification
path SHOULD bypass page script and extension mutation when preserving the
original response snapshot.

Trust-directory consultation MUST be user opt-in. If a directory fetch,
key fetch, source refetch, CORS check, redirect policy, timeout, cache
validation, or user-permission check fails, the verifier MUST surface a
specific failure outcome such as "key-resolution-failed",
"directory-unavailable", "source-refetch-failed", or
"network-policy-blocked" rather than treating the content as valid.

# Security Considerations

## Threat model

This document considers the following adversaries.

Passive eavesdropper:
: An adversary observing traffic on the network. Out of scope; this
  threat is addressed by TLS [RFC8446], on which HTMLTrust
  cryptographic verification does not directly depend.

Active rewriter:
: An adversary capable of modifying HTML in transit or at a non-
  origin endpoint. HTMLTrust detects any modification of canonical
  text or signed semantic attributes inside a signed section. It does
  not detect modifications to surrounding markup or to non-signed
  regions; verifiers and trust policies MUST present cryptographic
  outcomes per signed section, not per document.

Origin compromise:
: An adversary in control of the publisher origin. Such an adversary
  can serve content under an origin that the signer's binding
  permits. Detection requires the signer to publish content hashes
  to a trust directory or other independent index; the protocol does
  not prevent the attack in isolation.

Key compromise:
: An adversary in possession of a signer's private key. HTMLTrust
  cannot prevent forgery in this case. Mitigations are revocation
  (Section 8.2, `revoked` field) and short-lived keys with
  `expires`.

Replay across origins:
: An adversary copying a signed section from one site to another.
  Prevented by origin binding (Section 5); verification on the new
  origin will fail.

Replay within origin (long-tail):
: An adversary re-publishing old signed content on the same origin
  out of context. Not prevented by the protocol; mitigated by
  external research and by the inclusion of `signed-at` in the
  signing payload, which dates the attestation.

Downgrade:
: An adversary inducing a verifier to use a weak algorithm. Mitigated
  by the verifier's right to refuse algorithms (Section 7.3) and by
  the requirement that `algorithm` mismatch produce a distinct
  failure outcome.

## Deliberate semantic-subset signing trade-off

This revision signs canonical text plus a small list of semantic
attributes (`href`, `src`, `alt`, and `aria-label`). An adversary in
possession of signed material MAY still rewrap it in misleading
block-level markup, alter non-covered attributes, or surround it with
hostile media without invalidating the cryptographic signature. The
HTMLTrust system addresses these residual risks through layered means:

- Origin binding (Section 5) ensures that the signed material appears
  only on the publication origin under the original signature.
- Trust-directory indexing and external research (out of band, but
  enabled by the content hash being globally addressable) catches
  altered surrounding context on mirror sites.
- Future revisions MAY extend hash coverage to more semantic
  attributes, addressing a larger subset of context-swapping attacks.

The deliberate trade-off is implementational simplicity and
cross-implementation stability versus full structural integrity. XML
Digital Signatures [XMLDSIG] is the canonical cautionary tale for
the latter end of that spectrum.

## Claim metadata normalization and duplicate binding

All direct child claim `<meta>` elements participate in the claims hash.
This prevents a metadata sanitizer from silently dropping, reordering, or
renaming visible author claims without invalidating the signature, but it
also means that sanitizers which remove unknown `<meta>` elements inside a
signed section will break verification. Authoring tools SHOULD place only
claims that they intend to sign as direct child `<meta>` elements and
SHOULD keep unrelated machine metadata outside the signed section.

The `signed-at` value is intentionally included twice: once as a normal
claim inside the claims hash and once as an explicit signing-payload
field. The duplicate binding is not ambiguous because both uses consume
the same normalized direct child claim. If the claim is missing,
malformed, or duplicated after name normalization, verification fails
before signature verification. This keeps timestamp extraction simple for
directories and user interfaces while preserving the integrity of the
complete claim set.

## Revocation latency

Revocation under Section 8.2 depends on the verifier re-fetching the
key document. Verifiers cache key documents subject to HTTP cache
semantics [RFC9111]; an aggressive cache may serve stale key data
after a `revoked: true` update. Verifiers SHOULD set a relatively
short maximum cache age for HTMLTrust key documents (recommended:
one hour) and SHOULD honor `Cache-Control: no-cache` directives from
the key-document server.

## Algorithm agility risks

The registry in Section 7 is designed to permit new algorithms
without breaking deployed verifiers. However, a verifier that
accepts the union of all registered algorithms inherits the security
of the weakest. Verifiers SHOULD limit their accepted-algorithm set
to those required by their threat model and SHOULD log or surface
verifications performed under deprecated algorithms.

## Side channels

A verifier MUST NOT distinguish verification failure from
verification success via observable side channels (timing,
network-request differences, console output visible to page
scripts). The user-agent processing model in [HTMLTRUST-W3C]
specifies the channel through which verification outcomes are
exposed; verifiers in non-browser contexts SHOULD follow analogous
discipline.

# Privacy Considerations

## Directory query exposure

Trust-directory queries during endorsement retrieval or reputation
lookup reveal the requesting verifier's IP address, request headers,
and the content hashes it is interested in. A directory operator
that logs queries can derive a fingerprint of the verifier's
reading patterns.

Mitigations:

- Verifiers SHOULD cache directory responses (subject to [RFC9111])
  to reduce repeated identical queries.
- Verifiers MAY batch endorsement requests for multiple content
  hashes encountered in the same document.
- Verifiers SHOULD support a "no directory" mode that limits the
  verifier to local cryptographic verification only.
- Verifiers MAY use HTTP via Tor or another anonymizing transport
  for directory queries; directories SHOULD accept anonymized
  traffic.

## Key resolution exposure

Resolving a `keyid` via the methods of Section 8 reveals the
verifier's interest to the key-hosting server. For directory-hosted
keys, this collapses into Section 12.1. For DID and direct-URL
methods, the exposure is to the signer's chosen identity host.

Signers SHOULD NOT publish key documents from origins that would
draw inferences from key-fetch traffic that would otherwise be
unavailable.

## Endorsement disclosure

An endorsement is intentionally public. Endorsers who do not wish
their endorsement to be public-facing MUST NOT submit it to a
public directory; the protocol does not provide a private-
endorsement mechanism.

# IANA Considerations

This document requests the following IANA actions.

## Media types

The following media types are to be registered in the "Media Types"
registry.

### application/htmltrust-key+json

- Type name: application
- Subtype name: htmltrust-key+json
- Required parameters: none
- Optional parameters: charset (must be `utf-8` if present)
- Encoding considerations: binary
- Security considerations: see Section 11 of this document
- Interoperability considerations: see Section 8.2
- Published specification: this document (Section 8.2)
- Applications that use this media type: HTMLTrust verifiers,
  publishers, and trust directories
- Fragment identifier considerations: none
- Author / change controller: IETF / IESG

### application/htmltrust-endorsement+json

Identical fields as Section 13.1.1, with subtype name
`htmltrust-endorsement+json` and a reference to Section 10.

### application/htmltrust-directory+json

Identical fields as Section 13.1.1, with subtype name
`htmltrust-directory+json` and a reference to Section 9.2.

### application/htmltrust-content+json

Identical fields as Section 13.1.1, with subtype name
`htmltrust-content+json` and a reference to Section 9.3 (the
`/content/{hash}` response format).

## Well-known URI

The suffix `htmltrust` is to be registered in the "Well-Known URIs"
registry per [RFC8615].

- URI suffix: htmltrust
- Change controller: IETF
- Specification document: this document, Section 9.2
- Related information: identifies trust directory discovery
  metadata

## Signature algorithm registry

IANA is requested to establish a new registry titled "HTMLTrust
Signature Algorithms" under a new "HTMLTrust Parameters" group. The
registry is policy "Specification Required" per [RFC8126]; the
initial contents are those of Section 7.1.

Each registration MUST include:

- Identifier (the string used in the `algorithm` attribute)
- Algorithm description
- Reference
- Status: "current" or "deprecated"

## Hash algorithm registry

IANA is requested to establish a new registry titled "HTMLTrust Hash
Algorithms" under the "HTMLTrust Parameters" group. The registry is
policy "Specification Required". The initial contents are those of
Section 7.2.

Each registration MUST include:

- Identifier (the string used as the hash prefix in `content-hash`
  values)
- Algorithm description
- Output length in bytes
- Reference
- Status: "current" or "deprecated"

## HTMLTrust error type prefix

This document does not request an IANA registry for the
`https://htmltrust.org/errors/...` URIs used in problem-details
responses (Section 9.9); those URIs are stewarded by the document
author and the Community Group.

--- back

# Acknowledgements

The author thanks early reviewers of the HTMLTrust whitepaper for
feedback that shaped this draft, and acknowledges the conceptual
debt to DKIM [RFC6376], JSON Web Signature [RFC7515], JSON
Canonicalization Scheme [RFC8785], HTTP Message Signatures
[RFC9421], and Signed HTTP Exchanges [SXG]. The two-layer split of
cryptographic verification from trust evaluation is influenced by
the operational experience of DKIM deployment.

# Test Vectors

TODO: full test vectors will be provided in subsequent revisions and
maintained in the conformance suite at the canonicalization
repository (https://github.com/HTMLTrust/htmltrust-canonicalization).
The structure below is illustrative; values are placeholders.

## Canonical content example

Input HTML (fragment, inner content of a signed section):

~~~ html
<article>
  <h1>Hello, world.</h1>
  <p>This is a   "test"&mdash;with formatting.</p>
</article>
~~~

Canonical content (UTF-8, U+000A shown as `\n`):

~~~
Hello, world.\nThis is a "test"-with formatting.
~~~

Content hash (SHA-256, Base64):

~~~
sha256:TODO-PLACEHOLDER
~~~

## Canonical claims example

Input claim `<meta>` children:

~~~ html
<meta name="author" content="Alice Example">
<meta name="signed-at" content="2026-05-01T10:30:00Z">
<meta name="claim:License" content="CC-BY-4.0">
~~~

Canonical claims (UTF-8, sorted lexically by name):

~~~
author:Alice Example
claim:License:CC-BY-4.0
signed-at:2026-05-01T10:30:00Z
~~~

Claims hash (SHA-256, Base64):

~~~
sha256:TODO-PLACEHOLDER
~~~

## Signing payload example

Serialized origin (`domain` field): `https://author.example`

Signing payload:

~~~
sha256:TODO-PLACEHOLDER:sha256:TODO-PLACEHOLDER:https://author.example:2026-05-01T10:30:00Z
~~~

Ed25519 signature (Base64):

~~~
TODO-PLACEHOLDER
~~~

# Example Directory Exchange

## Submitting a content record

Request:

~~~
POST /content HTTP/1.1
Host: directory.example
Content-Type: application/json
Signature-Input: sig1=("@method" "@target-uri" "content-digest");keyid="did:web:author.example";created=1715000000;alg="ed25519"
Signature: sig1=:TODO:
Content-Digest: sha-256=:TODO:

{
  "contentHash": "sha256:TODO",
  "keyid": "did:web:author.example",
  "signedAt": "2026-05-01T10:30:00Z",
  "domain": "https://author.example",
  "signature": "TODO",
  "sourceURL": "https://author.example/posts/123"
}
~~~

Response:

~~~
HTTP/1.1 201 Created
Location: https://directory.example/content/sha256%3ATODO
Content-Type: application/htmltrust-content+json

{
  "contentHash": "sha256:TODO",
  "firstSeen": "2026-05-15T12:34:56Z",
  "signers": [
    {
      "keyid": "did:web:author.example",
      "signedAt": "2026-05-01T10:30:00Z",
      "domain": "https://author.example",
      "signature": "TODO"
    }
  ],
  "endorsementCount": 0
}
~~~

## Submitting an endorsement

Request body (after canonicalization per Section 10.2 and signing):

~~~
{
  "endorser": "did:web:reviewer.example",
  "endorsement": "sha256:TODO",
  "algorithm": "ed25519",
  "timestamp": "2026-05-10T09:00:00Z",
  "claim": "Verified original publication.",
  "signature": "TODO"
}
~~~

# Open Issues

The following issues are open in this revision and are expected to
be addressed in subsequent revisions or in the companion W3C
Community Group Report.

1. Semantic attribute coverage. This revision signs canonicalized text
   plus the provisional semantic attribute list `href`, `src`, `alt`,
   and `aria-label`. The exact expansion list remains open for
   community feedback. See Section 4.3.2 and the security
   considerations.
2. Runtime DOM mutation. A `data-htmltrust-ignore` opt-out marker
   is reserved but not yet normative. See Section 4.7.
3. Mandatory-to-implement key resolution methods. This revision
   requires verifiers to implement at least one of three methods.
   A future revision may strengthen the requirement, particularly
   around DID methods.
4. Reputation-score interoperability. The `/signers/{id}/reputation`
   endpoint is intentionally directory-specific. A future revision
   may define a small interoperable subset.
