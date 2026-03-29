import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import { FileSignature, QrCode, Bell, ClipboardList, Layers } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Tjänster' : 'Services',
    description: isSv
      ? 'BankID-signering, QR-verifiering, delegationshantering, push-notiser och granskningslogg — allt i en plattform.'
      : 'BankID signing, QR verification, delegation management, push notifications and audit log — all in one platform.',
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/services`,
    },
  }
}

export default function ServicesPage() {
  const t = useTranslations('services')
  const services = [
    { icon: Layers, key: 's1' as const },
    { icon: FileSignature, key: 's2' as const },
    { icon: QrCode, key: 's3' as const },
    { icon: Bell, key: 's4' as const },
    { icon: ClipboardList, key: 's5' as const },
  ]
  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-14">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">{t('subtitle')}</p>
      </div>
      <div className="space-y-6">
        {services.map(({ icon: Icon, key }, i) => (
          <div key={key} className="flex gap-6 bg-white rounded-2xl border border-gray-100 p-8 shadow-sm hover:shadow-md transition-shadow">
            <div className="w-14 h-14 rounded-xl flex items-center justify-center shrink-0" style={{ background: i % 2 === 0 ? '#f3eeff' : '#f0fdf4' }}>
              <Icon className="w-7 h-7" style={{ color: i % 2 === 0 ? '#5B2D8E' : '#00A86B' }} />
            </div>
            <div>
              <h2 className="text-xl font-bold text-gray-900 mb-2">{t(`${key}Title` as any)}</h2>
              <p className="text-gray-600 leading-relaxed">{t(`${key}Desc` as any)}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
