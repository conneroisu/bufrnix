// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://bufrnix.github.io',
  integrations: [
    starlight({
      title: 'Bufrnix',
      description: 'Nix powered Protocol Buffers with developer tooling',
      logo: {
        src: './public/favicon.svg',
        alt: 'Bufrnix Logo'
      },
      social: [
        { label: 'GitHub', icon: 'github', href: 'https://github.com/conneroisu/bufrnix' },
      ],
      sidebar: [
        {
          label: 'Start Here',
          items: [
            { label: 'Introduction', link: '/' },
          ],
        },
        {
          label: 'Guides',
          items: [
            { label: 'Getting Started', link: '/guides/getting-started/' },
            { label: 'Example Projects', link: '/guides/examples/' },
            { label: 'Contributing', link: '/guides/contributing/' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'Configuration', link: '/reference/configuration/' },
            { label: 'Language Support', link: '/reference/languages/' },
          ],
        },
      ],
    }),
  ],
  image: {
    service: {
      entrypoint: 'astro/assets/services/noop'
    }
  }
});