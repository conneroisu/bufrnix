# Bufrnix Documentation

This directory contains the documentation website for Bufrnix, built with [Astro](https://astro.build) and [Starlight](https://starlight.astro.build).

## Development

### Prerequisites

- Node.js 16 or higher
- [Bun](https://bun.sh/) (recommended)

### Getting Started

With Nix (recommended):

```bash
cd doc
nix develop
bun install
bun run dev
```

Without Nix:

```bash
cd doc
npm install
npm run dev
```

The documentation site will be available at http://localhost:4321

### Building

```bash
# With Nix
nix develop
bun run build

# Without Nix
npm run build
```

The built site will be in the `dist` directory.

## Documentation Structure

- `src/content/docs/` - Documentation content (Markdown and MDX files)
- `src/content/docs/guides/` - How-to guides and tutorials
- `src/content/docs/reference/` - API and configuration reference
- `src/styles/` - Custom CSS styles
- `public/` - Static assets like images and favicon
- `astro.config.mjs` - Astro configuration (including navigation)

## Adding Content

1. Create a new Markdown or MDX file in the appropriate directory
2. Add frontmatter with title and description:
   ```md
   ---
   title: Your Page Title
   description: A brief description of the page.
   ---

   # Your Page Title

   Content goes here...
   ```
3. If needed, add the page to the navigation in `astro.config.mjs`

## Deployment

The documentation is automatically deployed when changes are pushed to the main branch.

## Customization

- Site configuration: `astro.config.mjs`
- Custom CSS: `src/styles/custom.css`