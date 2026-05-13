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

```mermaid
flowchart TD
    A((Author)) -->|manage keys| B[Web browser]
    A -->|author content| C[CMS]
    B -->|provide public key| C
    C -->|request signature| B
    C -->|deliver page| P[/"Pages with<br/>signed blocks"/]
    P -->|viewed| Br[Reader's browser]
    P -->|crawled| Cr[Crawler]
    Br -->|verify locally| Val{{Trust score}}
    Cr -->|extract &amp; verify| Re[Researcher]
    C -. publish keys &amp; hashes .-> Dir[(Trust directories)]
    Br -. query reputation .-> Dir
    Re -. flag bad keys .-> Dir
```

## Two layers, kept separate

```mermaid
flowchart TB
    subgraph L1["🔒 Layer 1 — Cryptographic verification (local)"]
        C1[Canonicalize content] --> H1[Hash]
        H1 --> S1[Verify signature against resolved key]
        S1 --> R1{Valid?}
    end
    subgraph L2["⚖️ Layer 2 — Trust decision (user policy)"]
        P1[Trust list] --> D1[Score]
        P2[Endorsements] --> D1
        P3[Directory reputation] --> D1
        D1 --> UI[UI indicator]
    end
    R1 -- "yes" --> L2
    R1 -- "no" --> X[Reject]
```

A signature either verifies cryptographically or it does not — that part is binary, local, and identical across implementations. **Trust** is a matter of degree, and each user agent applies its own policy on top.

## Author flow — signing

```mermaid
sequenceDiagram
    autonumber
    participant A as Author
    participant B as Browser (key holder)
    participant C as CMS
    participant D as Directory (optional)
    A->>C: Write content
    C->>C: Canonicalize text
    C->>C: Compute content-hash + claims-hash
    C->>B: Request signature over payload
    B->>B: Sign with private key
    B-->>C: signature
    C->>C: Embed <signed-section>
    C-->>A: Publish page
    C-->>D: Publish hash + keyid (optional)
```

The private key never leaves the author's browser. The CMS asks the browser to sign a canonical payload, receives the signature, and embeds it in the published HTML.

## Reader flow — verifying

```mermaid
sequenceDiagram
    autonumber
    participant U as Reader's browser
    participant P as Page origin
    participant K as Key resolver
    participant D as Directory (optional)
    U->>P: GET page
    P-->>U: HTML with <signed-section>
    U->>U: Canonicalize text → hash
    U->>K: Resolve keyid
    K-->>U: Public key
    U->>U: Verify signature (local)
    U->>D: Query reputation / endorsements (optional)
    D-->>U: Endorsements + reputation
    U->>U: Apply user trust policy → score
```

Cryptographic verification is offline-capable once the public key is cached. The directory query is optional and only feeds the *trust score*, not the signature check.

## Domain binding

```mermaid
flowchart LR
    O["`author.com
    *signed content*`"] -. "mirror without permission" .-> M[scraper.com]
    M --> X["`❌ Signature
    fails domain bind`"]
    O --> R["`republisher.com
    *wraps with own sig*`"] --> V[✅ Attribution chain]
    style X stroke:#ef4444,color:#ef4444
    style V stroke:#4ade80,color:#4ade80
```

A signature is bound to a publication origin via the canonical payload. Scrapers and mirror sites can copy the bytes, but the signature will not validate at a different origin. Legitimate republishing is supported via a separate mechanism: a republisher wraps the original `<signed-section>` in their own outer signature, preserving the original while adding an attribution chain.

## The directory's role

A trust directory MAY:

- **Index** content hashes and signers for discovery
- **Serve** endorsements submitted by third parties
- **Resolve** keys for authors who don't self-host (`keyid` can point at a directory entry)
- **Surface** reputation signals computed from its own curated trust graph

Federation means **many directories can coexist**, users choose which they trust at the higher level, and verification of a signature never requires contacting one. A directory is a convenience, never an authority.

## Next

- **[Spec details](/spec/)** — element, attributes, canonicalization
- **[Reference implementations](/implementation/)** — what's running today
