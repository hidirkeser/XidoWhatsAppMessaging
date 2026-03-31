import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import { FileSignature, QrCode, BellRing, ClipboardList, Layers, Building2, FileText, Globe } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Tjänster' : 'Services',
    description: isSv
      ? 'BankID-signering, QR-verifiering, fullmaktshantering, flerkanaliga notifieringar, företagsregistrering och revisionslogg — allt i en plattform.'
      : 'BankID signing, QR verification, delegation management, multi-channel notifications, corporate onboarding and audit log — all in one platform.',
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/services`,
    },
  }
}

export default function ServicesPage() {
  const t = useTranslations('services')

  const coreServices = [
    { icon: Layers, sKey: 's1' },
    { icon: FileSignature, sKey: 's2' },
    { icon: QrCode, sKey: 's3' },
  ]

  const platformServices = [
    { icon: BellRing, sKey: 's4' },
    { icon: ClipboardList, sKey: 's5' },
    { icon: Building2, sKey: 's6' },
    { icon: FileText, sKey: 's7' },
    { icon: Globe, sKey: 's8' },
  ]

  const renderCard = (Icon: typeof Layers, sKey: string, i: number) => (
    <div key={sKey} className="flex gap-6 bg-white rounded-2xl border border-gray-100 p-8 shadow-sm hover:shadow-md transition-shadow">
      <div className="w-14 h-14 rounded-xl flex items-center justify-center shrink-0" style={{ background: i % 2 === 0 ? '#f3eeff' : '#f0fdf4' }}>
        <Icon className="w-7 h-7" style={{ color: i % 2 === 0 ? '#5B2D8E' : '#00A86B' }} />
      </div>
      <div>
        <h2 className="text-xl font-bold text-gray-900 mb-2">{t(`${sKey}Title` as any)}</h2>
        <p className="text-gray-600 leading-relaxed">{t(`${sKey}Desc` as any)}</p>
      </div>
    </div>
  )

  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-14">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">{t('subtitle')}</p>
      </div>

      {/* Core Delegation Services */}
      <div className="mb-12">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">{t('coreTitle')}</h2>
        <div className="space-y-6">
          {coreServices.map(({ icon, sKey }, i) => renderCard(icon, sKey, i))}
        </div>
      </div>

      {/* Platform Services */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-6">{t('platformTitle')}</h2>
        <div className="space-y-6">
          {platformServices.map(({ icon, sKey }, i) => renderCard(icon, sKey, i))}
        </div>
      </div>
    </div>
  )
}
