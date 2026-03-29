import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import Link from 'next/link'
import { ArrowRight } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'API-integration — Verifiera fullmakter programmatiskt | Minion' : 'API Integration — Verify Delegations Programmatically | Minion',
    description: isSv
      ? "Integrera Minionss Verify API med token/secret-autentisering. Verifiera BankID-signerade fullmakter i realtid via REST."
      : "Integrate Minion's Verify API with token/secret authentication. Verify BankID-signed delegations in real time via REST.",
  }
}

export default function IntegrationPage({ params }: { params: { locale: string } }) {
  const t = useTranslations('integration')

  const curlExample = `curl -X POST https://api.minion.se/api/v1/verify/MIN-K7P2-X9QR \\
  -H "X-Api-Key: your_api_key" \\
  -H "X-Api-Secret: your_secret"`

  const jsonResponse = `{
  "valid": true,
  "delegateName": "Anna Svensson",
  "grantorName": "Erik Lindqvist",
  "organisation": "Nordea AB",
  "operations": ["Contract Signing"],
  "validFrom": "2026-01-01T00:00:00Z",
  "validTo": "2026-12-31T23:59:59Z",
  "verificationCode": "MIN-K7P2-X9QR",
  "isGrantorSigned": true,
  "isDelegateSigned": true
}`

  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-14">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">{t('subtitle')}</p>
      </div>

      {/* Getting started steps */}
      <div className="mb-16">
        <h2 className="text-2xl font-bold text-gray-900 mb-8">{t('howTitle')}</h2>
        <div className="grid sm:grid-cols-4 gap-4">
          {([1, 2, 3, 4] as const).map((n) => (
            <div key={n} className="text-center bg-white rounded-xl border border-gray-100 p-6">
              <div className="w-10 h-10 rounded-full flex items-center justify-center mx-auto mb-3 font-bold text-white text-sm" style={{ background: 'var(--primary)' }}>{n}</div>
              <p className="text-sm text-gray-600 leading-relaxed">{t(`step${n}` as any)}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Code examples */}
      <div className="grid md:grid-cols-2 gap-6 mb-16">
        <div>
          <h3 className="font-semibold text-gray-900 mb-3">{t('exampleTitle')}</h3>
          <pre className="bg-gray-900 text-green-400 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{curlExample}</pre>
        </div>
        <div>
          <h3 className="font-semibold text-gray-900 mb-3">{t('exampleResponse')}</h3>
          <pre className="bg-gray-900 text-blue-300 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{jsonResponse}</pre>
        </div>
      </div>

      {/* CTA */}
      <div className="text-center bg-purple-50 border border-purple-100 rounded-2xl p-10">
        <h2 className="text-2xl font-bold text-gray-900 mb-3">{t('ctaTitle')}</h2>
        <p className="text-gray-600 mb-6">{t('ctaText')}</p>
        <Link href="contact?type=api" className="inline-flex items-center gap-2 px-6 py-3 rounded-xl text-white font-semibold text-sm" style={{ background: 'var(--primary)' }}>
          {t('ctaButton')} <ArrowRight className="w-4 h-4" />
        </Link>
      </div>
    </div>
  )
}
