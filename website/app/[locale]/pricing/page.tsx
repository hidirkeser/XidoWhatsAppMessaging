import type { Metadata } from 'next'
import PricingClient from './PricingClient'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Priser — BankID-delegationskrediter | Minion' : 'Pricing — BankID Delegation Credits | Minion',
    description: isSv
      ? 'Transparenta priser utan dolda avgifter. Köp krediter för BankID-signerade fullmakter. Starter från 149 kr/mån.'
      : 'Transparent pricing with no hidden fees. Purchase credits for BankID-signed delegations. Starter from €13/month.',
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/pricing`,
    },
  }
}

export default function PricingPage() {
  return (
    <>
      <PricingClient />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'FAQPage',
            mainEntity: [
              {
                '@type': 'Question',
                name: 'What is a credit?',
                acceptedAnswer: { '@type': 'Answer', text: 'One credit covers one BankID-signed delegation. Credits never expire.' },
              },
              {
                '@type': 'Question',
                name: 'Can I change plans?',
                acceptedAnswer: { '@type': 'Answer', text: 'Yes, you can upgrade or downgrade your plan at any time. Credits roll over.' },
              },
              {
                '@type': 'Question',
                name: 'Is VAT included?',
                acceptedAnswer: { '@type': 'Answer', text: 'Prices shown exclude VAT. Swedish VAT (25%) applies to Swedish customers.' },
              },
            ],
          }),
        }}
      />
    </>
  )
}
