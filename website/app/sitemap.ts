import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  const base = process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'
  const locales = ['en', 'sv']
  const pages = ['', '/about', '/services', '/products', '/pricing', '/security', '/integration', '/faq', '/contact', '/privacy', '/terms']

  return locales.flatMap((locale) =>
    pages.map((page) => ({
      url: `${base}/${locale}${page}`,
      lastModified: new Date(),
      changeFrequency: page === '' ? 'weekly' : 'monthly',
      priority: page === '' ? 1 : 0.8,
    }))
  ) as MetadataRoute.Sitemap
}
