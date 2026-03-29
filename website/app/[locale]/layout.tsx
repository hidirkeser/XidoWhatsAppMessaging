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
      languages: {
        en: '/en',
        sv: '/sv',
        'x-default': '/en',
      },
    },
    openGraph: {
      siteName: 'Minion',
      type: 'website',
      locale: locale === 'sv' ? 'sv_SE' : 'en_US',
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
