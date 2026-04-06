# HTMLTrust Website

The public website for the HTMLTrust project, hosted at [htmltrust.org](https://www.htmltrust.org/).

Built with [Hugo](https://gohugo.io/) and the [Ananke](https://github.com/theNewDynamic/gohugo-theme-ananke) theme. Content is automatically signed with HTMLTrust `<signed-section>` elements during the normal Hugo build — no external tools required.

## Prerequisites

- [Hugo](https://gohugo.io/installation/) (extended edition, v0.128.0+)

## Local Development

```sh
git clone https://github.com/ArcadeLabsInc/htmltrust-website.git
cd htmltrust-website
hugo server -D
```

The site will be available at `http://localhost:1313/`. The `-D` flag includes draft posts.

## Build for Production

```sh
hugo --minify
```

Output is written to `public/`. Every page with `htmltrust.sign: true` in its frontmatter automatically gets a `<signed-section>` element with a SHA-256 content hash and claim metadata — computed entirely by Hugo's template engine.

## How Signing Works

Each content page includes HTMLTrust metadata in its frontmatter:

```yaml
htmltrust:
  sign: true
  claims:
    ContentType: "Article"
    License: "MIT"
    AIAssistance: "Human+AI"
```

During `hugo build`, the `htmltrust-signed-section.html` partial:

1. Canonicalizes the page content (strip HTML, collapse whitespace, trim)
2. Computes a SHA-256 hash using Hugo's built-in `sha256` function
3. Outputs a `<signed-section>` element after the article with the hash, author, timestamp, and claims

The generated HTML looks like:

```html
<signed-section content-hash="sha256:abc123..." style="display: block;">
  <meta name="author" content="Jason Grey">
  <meta name="signed-at" content="2025-05-12T10:30:00Z">
  <meta name="claim:ContentType" content="Article">
  <meta name="claim:License" content="MIT">
</signed-section>
```

For full cryptographic signing (adding `signature`, `keyid`, and `algorithm` attributes), see the optional post-build script in the [Hugo CMS integration](https://github.com/ArcadeLabsInc/htmltrust-cms-reference/tree/main/hugo).

## Content Structure

```
content/
├── _index.md              # Homepage
├── about/index.md         # About HTMLTrust
├── architecture/index.md  # System architecture overview
├── faq/index.md           # Frequently asked questions
├── use-cases/index.md     # Real-world application scenarios
└── posts/                 # Blog posts
```

## Project Structure

```
├── hugo.toml                           # Site configuration
├── layouts/
│   ├── _default/single.html            # Override: adds signed-section after content
│   ├── page/single.html                # Override: adds signed-section after content
│   └── partials/
│       ├── head-additions.html         # Injects HTMLTrust meta tags + CSS into <head>
│       ├── htmltrust-meta.html         # Reads htmltrust frontmatter → <meta> tags
│       └── htmltrust-signed-section.html  # Core: computes hash, outputs <signed-section>
├── static/
│   ├── css/custom.css                  # Custom styles (hero, features, signed-section)
│   └── images/architecture1.png        # System architecture diagram
├── content/                            # See "Content Structure" above
└── themes/ananke/                      # Ananke theme (git submodule)
```

## Adding Content

### New page

```sh
hugo new content/my-page/index.md
```

### New blog post

```sh
hugo new content/posts/my-post.md
```

Edit the frontmatter to set `draft: false` when ready to publish, and add `htmltrust.sign: true` to enable signing.

## Theme

The site uses the [Ananke](https://github.com/theNewDynamic/gohugo-theme-ananke) theme, installed as a Git submodule. To update:

```sh
git submodule update --remote themes/ananke
```

## Companion Repositories

| Repository | Description |
|---|---|
| [htmltrust-spec](https://github.com/ArcadeLabsInc/htmltrust-spec) | The HTMLTrust specification and paper |
| [htmltrust-server-reference](https://github.com/ArcadeLabsInc/htmltrust-server-reference) | Reference trust directory API server |
| [htmltrust-browser-reference](https://github.com/ArcadeLabsInc/htmltrust-browser-reference) | Reference browser extension for signature validation |
| [htmltrust-cms-reference](https://github.com/ArcadeLabsInc/htmltrust-cms-reference) | Reference CMS plugins (WordPress, Hugo) |

## License

MIT