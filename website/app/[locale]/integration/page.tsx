import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import Link from 'next/link'
import { ArrowRight, Key, Shield, List } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'API-integration — Verifiera och hantera fullmakter programmatiskt' : 'API Integration — Verify and Manage Delegations Programmatically',
    description: isSv
      ? "Integrera Minions API med M2M-autentisering. Verifiera fullmakter, fråga fullmaktslistor och hantera företagsflöden via REST."
      : "Integrate Minion's API with M2M authentication. Verify delegations, query delegation lists and manage corporate workflows via REST.",
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/integration`,
    },
  }
}

export default function IntegrationPage({ params }: { params: { locale: string } }) {
  const t = useTranslations('integration')

  const verifyCurl = `curl -X POST https://api.minion.se/api/v1/verify/MIN-K7P2-X9QR \\
  -H "X-Api-Key: your_api_key" \\
  -H "X-Api-Secret: your_secret"`

  const verifyResponse = `{
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

  const listCurl = `curl -X GET "https://api.minion.se/api/v1/external-delegations?page=1&limit=20" \\
  -H "X-Api-Key: your_api_key" \\
  -H "X-Api-Secret: your_secret"`

  const listResponse = `{
  "items": [
    {
      "id": "d1a2b3c4",
      "verificationCode": "MIN-K7P2-X9QR",
      "delegateName": "Anna Svensson",
      "grantorName": "Erik Lindqvist",
      "status": "Active",
      "validFrom": "2026-01-01",
      "validTo": "2026-12-31"
    }
  ],
  "page": 1,
  "limit": 20,
  "totalCount": 1
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

      {/* M2M Authentication */}
      <div className="mb-16">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#f3eeff' }}>
            <Key className="w-5 h-5" style={{ color: '#5B2D8E' }} />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">{t('authTitle')}</h2>
        </div>
        <p className="text-gray-600 leading-relaxed mb-6">{t('authDesc')}</p>
      </div>

      {/* Verify a Delegation */}
      <div className="mb-16">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#f0fdf4' }}>
            <Shield className="w-5 h-5" style={{ color: '#00A86B' }} />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">{t('verifyTitle')}</h2>
        </div>
        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <h3 className="font-semibold text-gray-900 mb-3">{t('exampleTitle')}</h3>
            <pre className="bg-gray-900 text-green-400 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{verifyCurl}</pre>
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 mb-3">{t('exampleResponse')}</h3>
            <pre className="bg-gray-900 text-blue-300 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{verifyResponse}</pre>
          </div>
        </div>
      </div>

      {/* External Delegations API */}
      <div className="mb-16">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#eff6ff' }}>
            <List className="w-5 h-5" style={{ color: '#2563EB' }} />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">{t('extApiTitle')}</h2>
        </div>
        <p className="text-gray-600 leading-relaxed mb-6">{t('extApiDesc')}</p>
        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <h3 className="font-semibold text-gray-900 mb-3">{t('exampleTitle')}</h3>
            <pre className="bg-gray-900 text-green-400 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{listCurl}</pre>
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 mb-3">{t('exampleResponse')}</h3>
            <pre className="bg-gray-900 text-blue-300 rounded-xl p-5 text-xs overflow-x-auto leading-relaxed">{listResponse}</pre>
          </div>
        </div>
      </div>

      {/* Corporate API */}
      <div className="mb-16 bg-gray-50 rounded-2xl p-8 border border-gray-100">
        <h2 className="text-xl font-bold text-gray-900 mb-3">{t('corpApiTitle')}</h2>
        <p className="text-gray-600 leading-relaxed">{t('corpApiDesc')}</p>
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
