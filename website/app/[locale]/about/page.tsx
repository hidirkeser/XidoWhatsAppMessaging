import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import { Lock, Eye, Zap, Scale } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Om oss' : 'About',
    description: isSv
      ? 'Minions uppdrag är att göra säker, transparent och juridiskt bindande fullmaktshantering tillgänglig för alla i Sverige.'
      : "Minion's mission is to make secure, transparent and legally binding delegation management accessible to everyone in Sweden.",
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/about`,
    },
  }
}

export default function AboutPage() {
  const t = useTranslations('about')
  const values = [
    { icon: Lock, title: t('v1Title'), desc: t('v1Desc') },
    { icon: Eye, title: t('v2Title'), desc: t('v2Desc') },
    { icon: Zap, title: t('v3Title'), desc: t('v3Desc') },
    { icon: Scale, title: t('v4Title'), desc: t('v4Desc') },
  ]
  return (
    <div className="max-w-4xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold text-gray-900 mb-6">{t('title')}</h1>
      <div className="bg-purple-50 border border-purple-100 rounded-2xl p-8 mb-12">
        <h2 className="text-xl font-bold text-purple-800 mb-3">{t('missionTitle')}</h2>
        <p className="text-purple-700 text-lg leading-relaxed italic">"{t('missionText')}"</p>
      </div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">{t('problemTitle')}</h2>
      <div className="space-y-4 mb-12">
        {(['p1', 'p2', 'p3'] as const).map((k) => (
          <p key={k} className="text-gray-600 leading-relaxed">{t(k)}</p>
        ))}
      </div>
      <h2 className="text-2xl font-bold text-gray-900 mb-8">{t('valuesTitle')}</h2>
      <div className="grid sm:grid-cols-2 gap-6">
        {values.map((v) => (
          <div key={v.title} className="bg-white rounded-xl border border-gray-100 p-6 shadow-sm">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ background: '#f3eeff' }}>
              <v.icon className="w-5 h-5" style={{ color: '#5B2D8E' }} />
            </div>
            <h3 className="font-bold text-gray-900 mb-2">{v.title}</h3>
            <p className="text-sm text-gray-600 leading-relaxed">{v.desc}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
