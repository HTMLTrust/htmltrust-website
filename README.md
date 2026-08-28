# HTMLTrust website

This repository builds [htmltrust.org](https://www.htmltrust.org), the public
documentation and project site for HTMLTrust. Hugo renders the content, Hugo
Modules provide the theme and signing partial, and Pagefind creates the local
search index.

## Quick start

Install the tested toolchain before cloning:

- Hugo Extended 0.161.1
- Go 1.25, required for Hugo Modules
- Node.js 22 with npm

Install [Hugo Extended](https://gohugo.io/installation/) 0.161.1 and Go 1.25
for Hugo Modules. Ensure both `hugo` and `go` are on your `PATH`.

Clone and run the site:

```sh
git clone https://github.com/HTMLTrust/htmltrust-website.git
cd htmltrust-website
npm ci --ignore-scripts
npm run dev
```

Open <http://localhost:1313/>. Hugo downloads the pinned Hugo Blox modules on
the first run, so the initial build needs network access.

The `npm ci` command uses the committed `package-lock.json`. It installs the
Tailwind and Pagefind tools used by the build. npm is the repository's package
manager; the `package-lock.json` is the only JavaScript lockfile committed here.

## Build and checks

Build the complete local site, including the search index:

```sh
npm run build
```

The output is in `public/`. To run the two build stages separately:

```sh
npm ci --ignore-scripts
hugo --minify
npx pagefind --site public
```

The build emits a `<signed-section>` placeholder for each page with
`htmltrust.sign: true`. The production workflow then signs those sections and
checks that every signed section has `content-hash`, `signature`, `keyid`, and
`algorithm` attributes. The same checks run in
[.github/workflows/ci.yml](.github/workflows/ci.yml).

There is no separate website unit-test suite. A successful `npm run build`
followed by a Pagefind index under `public/pagefind/` is the local smoke test.
For a CI-equivalent check, install Hugo Extended 0.161.1 and Go 1.25, then run
`npm ci --ignore-scripts`, `hugo --minify`, and `npx pagefind --site public`.

## Signing a production build

Signing requires the Ed25519 private key used by the deployment and the
immutable `htmltrust-hugo` signer revision used in CI. Keep the key outside the
repository. From the repository root:

```sh
npm ci --ignore-scripts
hugo --minify
go install github.com/HTMLTrust/htmltrust-hugo/cmd/htmltrust-sign@d656523d13f7ee90a4f810d91bd575829060ce41
export HTMLTRUST_SIGNING_KEY="$(cat /path/to/ed25519-private-key.pem)"
htmltrust-sign \
  --dir public \
  --keyid did:web:jason-grey.com \
  --domain www.htmltrust.org
```

The key must be a PEM-encoded PKCS#8 Ed25519 private key. The signer rewrites
the generated placeholders in `public/`. Inspect the output before publishing;
the CI signing job is the deployment authority.

## Search

`npm run build` runs Hugo first and Pagefind second. During development, use
the generated site after a build to test search locally:

```sh
npx pagefind --site public
python3 -m http.server 8080 --directory public
```

The search assets live under `public/pagefind/` and are generated output, so
they are ignored by Git.

## Content and drafts

Page content lives under `content/`. The main sections are:

- `/spec/`, the protocol overview
- `/implementation/`, reference implementation details
- `/architecture/`, system design
- `/use-cases/`, deployment scenarios
- `/faq/`, common questions
- `/blog/`, project updates

The draft IETF and W3C documents are published under `content/spec/ietf-draft/`
and `content/spec/w3c-cg/`. Their generated HTML and review reports are kept in
`static/spec/` so readers can download the exact rendered artifacts.

The source of truth for these five published artifacts is the sibling
`htmltrust-spec` checkout. From the website repository, refresh the copies with:

```sh
scripts/sync-spec-artifacts.sh sync
```

Use `--check` in CI or before committing to confirm that the published copies
match the spec checkout without changing files:

```sh
scripts/sync-spec-artifacts.sh --check
```

For a spec checkout elsewhere, pass its path with `--source /path/to/htmltrust-spec`.
The website CI workflow pins the exact spec revision currently published. When
refreshing these files, update that `ref` in the same pull request.

The site wraps signed pages through
`layouts/_partials/htmltrust-signed-section.html`. Set this front matter on a
page to opt in:

```yaml
htmltrust:
  sign: true
  claims:
    content-type: Documentation
    license: CC-BY-4.0
```

## Browser canonicalization asset

`static/canon-test.js` is a zero-dependency browser bundle of
`@htmltrust/canonicalization` v0.2.2. It exposes the stable API as
`globalThis.$canon` and records the version in `globalThis.$canonVersion`. The
source of truth is the canonicalization repository and its v0.2.2 tag:

<https://github.com/HTMLTrust/htmltrust-canonicalization/tree/v0.2.2/javascript>

Regenerate the bundle only when updating that pinned release, then compare its
behavior with the canonicalization repository's JavaScript test suite.

## Working with the other repositories

The website builds on its own. The full HTMLTrust checkout is easiest to keep
under one directory:

```sh
mkdir -p ~/src/htmltrust
cd ~/src/htmltrust
git clone https://github.com/HTMLTrust/htmltrust-canonicalization.git
git clone https://github.com/HTMLTrust/htmltrust-spec.git
git clone https://github.com/HTMLTrust/htmltrust-server-reference.git
git clone https://github.com/HTMLTrust/htmltrust-browser-client.git
git clone https://github.com/HTMLTrust/htmltrust-browser-reference.git
git clone https://github.com/HTMLTrust/htmltrust-cms-reference.git
git clone https://github.com/HTMLTrust/htmltrust-e2e.git
git clone https://github.com/HTMLTrust/htmltrust-website.git
```

The website imports `htmltrust-hugo` and Hugo Blox through Go modules, so sibling
directories are useful for source review and coordinated changes. They are not
required for a normal website build. For the integrated flow, build this site
to `public/`, run the reference server and CMS according to their READMEs, and
use the browser client or browser extension to verify the signed HTML.

## Repository layout

```text
content/                 Markdown pages and front matter
layouts/                 Site overrides and HTMLTrust signing partial
config/_default/         Hugo and Hugo Blox configuration
static/                  Files copied into the published site
assets/                  Theme and JavaScript assets
.github/workflows/ci.yml Build, sign, verify, and deploy workflow
```

See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.
