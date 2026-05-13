---
title: 'HTMLTrust'
date: 2026-05-13
type: landing

sections:
  # ─────────────────────────────────────────────────────────────────────────────
  # 1. HERO — the pitch
  # ─────────────────────────────────────────────────────────────────────────────
  - block: hero
    content:
      title: 'Cryptographic authorship for the open web'
      text: 'HTMLTrust embeds cryptographic trust directly into HTML. Authors sign blocks of content; browsers verify them locally; trust is a user-controlled, federated decision. Lightweight, browser-native, and standards-aligned.'
      primary_action:
        text: 'Read the spec'
        url: /spec/
        icon: document-text
      secondary_action:
        text: 'GitHub'
        url: https://github.com/HTMLTrust
        icon: code-bracket
      announcement:
        text: 'A proposal for the open web · 2026.'
        link:
          text: 'Read the announcement'
          url: /blog/paper-published/
    design:
      spacing:
        padding: [0, 0, 0, 0]
        margin: [0, 0, 0, 0]
      css_class: ''

  # ─────────────────────────────────────────────────────────────────────────────
  # 2. STATS — quick facts
  # ─────────────────────────────────────────────────────────────────────────────
  - block: stats
    content:
      items:
        - statistic: '0'
          description: |
            Central  
            authorities
        - statistic: '8'
          description: |
            Canonicalization  
            phases
        - statistic: '4+'
          description: |
            Reference  
            implementations
        - statistic: '∞'
          description: |
            Federated  
            trust directories
    design:
      css_class: 'bg-gray-100 dark:bg-gray-800'
      spacing:
        padding: ['2rem', 0, '2rem', 0]

  # ─────────────────────────────────────────────────────────────────────────────
  # 3. THE PROBLEM
  # ─────────────────────────────────────────────────────────────────────────────
  - block: features
    id: problem
    content:
      title: 'The problem'
      text: 'TLS certifies the domain. Nothing on the web certifies the **author**. As generative AI makes plausible-looking text effectively free and content travels faster than corrections, the cost of not being able to verify authorship keeps rising.'
      items:
        - name: 'TLS proves the domain, not the author'
          icon: lock-closed
          description: 'A green padlock means the bytes came from the claimed server. It says nothing about who wrote them.'
        - name: 'AI-generated text is everywhere'
          icon: cpu-chip
          description: 'Plausible-sounding prose is now effectively free. Readers cannot tell human writing from synthetic on the page alone.'
        - name: 'Republishing strips attribution'
          icon: arrow-path
          description: 'Articles are scraped, mirrored, and screenshotted. The original author and the original site routinely get lost.'
        - name: 'Mirror sites travel faster than corrections'
          icon: bolt
          description: 'By the time a piece is updated or retracted, copies have already spread to dozens of other hosts.'
    design:
      layout: grid

  # ─────────────────────────────────────────────────────────────────────────────
  # 4. WHAT WE ARE NOT
  # ─────────────────────────────────────────────────────────────────────────────
  - block: features
    id: not
    content:
      title: 'What HTMLTrust is *not*'
      text: 'Clear scope is half of any good standard. Here is what we are deliberately not doing.'
      items:
        - name: 'Not DRM'
          icon: x-mark
          description: 'We do not restrict access, copying, or display. Content stays open. Signatures are inert metadata.'
        - name: 'Not anti-AI'
          icon: x-mark
          description: 'Signed metadata describes AI involvement; it does not ban it. Authors choose what to disclose.'
        - name: 'Not blockchain'
          icon: x-mark
          description: 'Standard public-key cryptography. No ledger, no tokens, no consensus, no proof-of-anything.'
        - name: 'Not a gatekeeper'
          icon: x-mark
          description: 'No central authority. No verified-checkmark monopoly. Trust is local to each user agent.'
        - name: 'Not a truth oracle'
          icon: x-mark
          description: 'A signature proves *who said it*, not that *it is true*. Trust is a continuum, not a verdict.'
    design:
      layout: grid
      css_class: 'bg-gray-50 dark:bg-gray-900/40'

  # ─────────────────────────────────────────────────────────────────────────────
  # 5. CORE PRINCIPLES
  # ─────────────────────────────────────────────────────────────────────────────
  - block: features
    id: principles
    content:
      title: 'Five principles'
      text: 'A handful of decisions shape everything else.'
      items:
        - name: 'Sign blocks, not pages'
          icon: code-bracket-square
          description: 'A single page can host many signed regions from many different authors. Forums, collaborative articles, mixed editorial content — all work.'
        - name: 'Pluggable identity'
          icon: identification
          description: 'DIDs, key URLs, directory references — implementations must accept multiple methods. No canonical identity provider.'
        - name: 'Client-side trust'
          icon: user-circle
          description: 'The user agent decides. A signature either verifies cryptographically or it does not, but trust is a matter of degree set by the reader.'
        - name: 'Federated directories'
          icon: globe-alt
          description: 'Trust directories are optional, multiple, and never required to verify. Users choose which ones to consult and at what weight.'
        - name: 'Web-native'
          icon: document-check
          description: 'A standard HTML element, graceful fallback in unaware browsers, no plug-in lock-in. Layered on the web as it exists.'
    design:
      layout: grid

  # ─────────────────────────────────────────────────────────────────────────────
  # 6. HOW IT FITS WITH PRIOR ART
  # ─────────────────────────────────────────────────────────────────────────────
  - block: comparison-table
    id: standards
    content:
      subtitle: 'Prior art'
      title: 'How HTMLTrust fits in'
      text: 'HTMLTrust borrows from decades of cryptographic and content-integrity work. It does not replace any of it.'
      competitors:
        - name: 'HTMLTrust'
          tagline: 'HTML blocks'
          is_you: true
          badge: 'this work'
        - name: 'TLS'
          tagline: 'Channel'
        - name: 'DKIM'
          tagline: 'Email'
        - name: 'PGP'
          tagline: 'Identity'
        - name: 'C2PA'
          tagline: 'Media'
      rows:
        - feature: 'Proves authorship of HTML content'
          values: [true, false, false, 'partial', false]
        - feature: 'Web-native (renders in browsers)'
          values: [true, true, false, false, 'partial']
        - feature: 'Block-level granularity'
          values: [true, false, false, false, false]
        - feature: 'No central authority'
          values: [true, false, true, true, true]
        - feature: 'Optional federated reputation'
          values: [true, false, false, false, false]
        - feature: 'Graceful degradation in unaware clients'
          values: [true, 'partial', true, false, 'partial']
    design:
      row_striping: true

  # ─────────────────────────────────────────────────────────────────────────────
  # 7. CTA
  # ─────────────────────────────────────────────────────────────────────────────
  - block: cta-card
    content:
      title: 'Ready to look under the hood?'
      text: 'The spec defines a single new HTML element, four required attributes, an 8-phase canonicalization algorithm, and a federation model for optional trust directories. Reference implementations exist for browsers, CMSes, and trust directory servers.'
      button:
        text: 'Read the spec'
        url: /spec/
    design:
      card:
        css_class: 'bg-primary-700'
        css_style: ''
---
