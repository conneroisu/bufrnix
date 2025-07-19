// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwindcss from '@tailwindcss/vite';
import astroLlmsTxt from '@4hse/astro-llms-txt';

// https://astro.build/config
export default defineConfig({
  prefetch: true,
  site: 'https://conneroisu.github.io',
  base: 'bufrnix',
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [
    astroLlmsTxt({
      title: 'Bufrnix',
      description: 'Nix-powered Protocol Buffers code generation framework',
      docSet: [
        {
          title: 'Complete Documentation',
          url: '/bufrnix/llms-full.txt',
          include: ['**'],
          description: 'Full documentation including guides, reference materials, and examples for all supported languages'
        }
      ]
    }),
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
            { label: 'Troubleshooting', link: '/guides/troubleshooting/' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'Configuration', link: '/reference/configuration/' },
            { label: 'Language Support', link: '/reference/languages/' },
            { label: 'C Support', link: '/reference/languages/c/' },
            { label: 'C++ Support', link: '/reference/languages/cpp/' },
            { label: 'C# Support', link: '/reference/languages/csharp/' },
            { label: 'Go Support', link: '/reference/languages/go/' },
            { label: 'JavaScript Support', link: '/reference/languages/javascript/' },
            // JVM-like languages
            { label: 'Java Support', link: '/reference/languages/java/' },
            { label: 'Kotlin Support', link: '/reference/languages/kotlin/' },
            { label: 'Scala Support', link: '/reference/languages/scala/' },
            { label: 'PHP Support', link: '/reference/languages/php/' },
            { label: 'Python Support', link: '/reference/languages/python/' },
            { label: 'Swift Support', link: '/reference/languages/swift/' },
            { label: 'SVG Support', link: '/reference/languages/svg/' },
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
