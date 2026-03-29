import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { NextIntlClientProvider } from 'next-intl'
import { getMessages, getTranslations } from 'next-intl/server'
import { notFound } from 'next/navigation'
import '../globals.css'
import Header from '@/components/Header'
import Footer from '@/components/Footer'
import CookieBanner from '@/components/CookieBanner'

const inter = Inter({ subsets: ['latin'] })
const locales = ['en', 'sv']

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>
}): Promise<Metadata> {
  const { locale } = await params
  return {
    title: { default: 'Minion — BankID Delegation Management', template: '%s — Minion' },
    description: locale === 'sv'
      ? 'Säker fullmaktshantering driven av Mobilt BankID. Skapa, signera och verifiera juridiskt bindande fullmakter i realtid.'
      : 'Secure delegation management powered by Swedish BankID. Create, sign and verify legally-binding power of attorney documents in real time.',
    metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'),
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}`,
      languages: {
        en: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/en`,
        sv: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/sv`,
        'x-default': `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/en`,
      },
    },
    openGraph: {
      siteName: 'Minion',
      type: 'website',
      locale: locale === 'sv' ? 'sv_SE' : 'en_US',
      url: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}`,
      images: [
        {
          url: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/og-image.png`,
          width: 1200,
          height: 630,
          alt: 'Minion — BankID Delegation Management',
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: locale === 'sv' ? 'Säker fullmaktshantering. Driven av BankID.' : 'Secure Delegation Management. Powered by BankID.',
      description: locale === 'sv'
        ? 'Säker fullmaktshantering driven av Mobilt BankID. Skapa, signera och verifiera juridiskt bindande fullmakter i realtid.'
        : 'Secure delegation management powered by Swedish BankID. Create, sign and verify legally-binding power of attorney documents in real time.',
      images: [`${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/opengraph-image`],
    },
    robots: { index: true, follow: true },
  }
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ locale: string }>
}) {
  const { locale } = await params
  if (!locales.includes(locale)) notFound()
  const messages = await getMessages()

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'Minion',
    url: process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se',
    description: 'Secure BankID-powered delegation management platform for Swedish businesses.',
    foundingLocation: { '@type': 'Place', name: 'Stockholm, Sweden' },
    contactPoint: { '@type': 'ContactPoint', email: 'hello@minion.se', contactType: 'customer service' },
  }

  return (
    <html lang={locale} className={inter.className}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>
        <NextIntlClientProvider messages={messages}>
          <Header locale={locale} />
          <main>{children}</main>
          <Footer locale={locale} />
          <CookieBanner />
        </NextIntlClientProvider>
      </body>
    </html>
  )
}
