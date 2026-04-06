---
title: "HTMLTrust"
description: "Decentralized Trust and Verifiable Content on the Web"
date: 2025-05-12
draft: false
htmltrust:
  sign: true
  claims:
    ContentType: "Information"
    License: "MIT"
    AIAssistance: "Human+AI"
---

<link rel="stylesheet" href="/css/custom.css">

<div class="hero">
  <h1>HTMLTrust</h1>
  <p class="tagline">Decentralized trust and verifiable content on the web</p>
  <div class="cta-buttons">
    <a href="/about/" class="btn primary">Learn More</a>
    <a href="https://github.com/ArcadeLabsInc" class="btn secondary">GitHub</a>
  </div>
</div>

<div style="max-width: 800px; margin: 0 auto 3rem; text-align: center;">
  <h2>Verify Content Authenticity</h2>
  <p>HTMLTrust allows content creators to cryptographically sign regions of web pages and include identity-linked metadata in-band. It's lightweight, browser-compatible, and web-native — designed to scale across publishing workflows, civic media, and knowledge networks.</p>
</div>

<div class="features">
  <div class="feature">
    <div class="feature-icon">🔏</div>
    <h3>Signed Sections</h3>
    <p>Embed cryptographic trust directly into HTML with the proposed <code>&lt;signed-section&gt;</code> element.</p>
  </div>

  <div class="feature">
    <div class="feature-icon">🔗</div>
    <h3>Decentralized Identity</h3>
    <p>Signatures validated using public key infrastructure (PKI) such as DIDs — no central authority required.</p>
  </div>

  <div class="feature">
    <div class="feature-icon">✅</div>
    <h3>Trust Directories</h3>
    <p>Optional federated directories for third-party endorsements, key discovery, and reputation tracking.</p>
  </div>
</div>

<div class="problem">
  <h2>The Problem</h2>
  <p>The web lacks a standardized mechanism for proving who wrote a given piece of content. TLS certifies the domain, but not the author. As AI-generated and republished material becomes ubiquitous, users face increasing difficulty determining what content is trustworthy.</p>

  <div class="problem-grid">
    <div class="problem-item">
      <h4>Content Producers</h4>
      <p>Need to protect their work from theft and misuse</p>
    </div>
    <div class="problem-item">
      <h4>Content Consumers</h4>
      <p>Need to trust the content they read</p>
    </div>
    <div class="problem-item">
      <h4>LLM Builders</h4>
      <p>Need high-quality, human-generated training data — and to respect author preferences</p>
    </div>
    <div class="problem-item">
      <h4>Web Researchers</h4>
      <p>Need to distinguish between human and AI-generated content</p>
    </div>
  </div>
</div>

<div class="get-started">
  <h2>How It Works</h2>
  <div class="code-preview">
    <pre><code>&lt;signed-section keyid="did:web:author.example"
    signature="BASE64_SIG" algorithm="ed25519"
    content-hash="sha256:abc123..."&gt;
  &lt;meta name="author" content="Alice Example"&gt;
  &lt;article&gt;
    &lt;h1&gt;Verifiable Web Content&lt;/h1&gt;
    &lt;p&gt;Content should be provable...&lt;/p&gt;
  &lt;/article&gt;
&lt;/signed-section&gt;</code></pre>
  </div>
  <p>Authors sign content blocks. Browsers verify signatures. Trust directories track reputation. <a href="/architecture/">Learn more →</a></p>
</div>