import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import { Fingerprint, Shield, Database, Archive, UserCheck } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Säkerhet & Compliance — Minion' : 'Security & Compliance — Minion',
    description: isSv
      ? 'GDPR-kompatibel, BankID-autentisering, 7-årig arkivering enligt svensk lag. Säkraste fullmaktsplattformen i Sverige.'
      : 'GDPR compliant, BankID authentication, 7-year archive per Swedish law. The most secure delegation platform in Sweden.',
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/security`,
    },
  }
}

export default function SecurityPage() {
  const t = useTranslations('security')
  const sections = [
    { icon: Fingerprint, titleKey: 'bankidTitle' as const, bodyKey: 'bankidText' as const, color: '#5B2D8E' },
    { icon: Shield, titleKey: 'gdprTitle' as const, bodyKey: 'gdprText' as const, color: '#2563EB' },
    { icon: Database, titleKey: 'storageTitle' as const, bodyKey: 'storageText' as const, color: '#00A86B' },
    { icon: Archive, titleKey: 'archiveTitle' as const, bodyKey: 'archiveText' as const, color: '#D97706' },
    { icon: UserCheck, titleKey: 'dpoTitle' as const, bodyKey: 'dpoText' as const, color: '#7C3AED' },
  ]
  return (
    <div className="max-w-4xl mx-auto px-4 py-16">
      <div className="text-center mb-14">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">{t('subtitle')}</p>
      </div>
      <div className="space-y-6">
        {sections.map(({ icon: Icon, titleKey, bodyKey, color }) => (
          <div key={titleKey} className="bg-white rounded-2xl border border-gray-100 p-8 shadow-sm flex gap-6">
            <div className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0" style={{ background: `${color}15` }}>
              <Icon className="w-6 h-6" style={{ color }} />
            </div>
            <div>
              <h2 className="text-lg font-bold text-gray-900 mb-2">{t(titleKey)}</h2>
              <p className="text-gray-600 leading-relaxed">{t(bodyKey)}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
