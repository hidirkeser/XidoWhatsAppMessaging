import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'
import { Smartphone, Plug, LayoutDashboard, CheckCircle } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Produkter — Minion' : 'Products — Minion',
    description: isSv
      ? 'Minion App, Verify API och Admin Console — en komplett plattform för digital fullmaktshantering med BankID.'
      : 'Minion App, Verify API and Admin Console — a complete platform for digital delegation management with BankID.',
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/products`,
    },
  }
}

export default function ProductsPage() {
  const t = useTranslations('products')
  const products = [
    { icon: Smartphone, titleKey: 'p1Title' as const, descKey: 'p1Desc' as const, featuresKey: 'p1Features' as const, color: '#5B2D8E' },
    { icon: Plug, titleKey: 'p2Title' as const, descKey: 'p2Desc' as const, featuresKey: 'p2Features' as const, color: '#00A86B' },
    { icon: LayoutDashboard, titleKey: 'p3Title' as const, descKey: 'p3Desc' as const, featuresKey: 'p3Features' as const, color: '#2563EB' },
  ]
  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-14">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">{t('subtitle')}</p>
      </div>
      <div className="grid md:grid-cols-3 gap-8">
        {products.map(({ icon: Icon, titleKey, descKey, featuresKey, color }) => {
          const features = t.raw(featuresKey) as string[]
          return (
            <div key={titleKey} className="bg-white rounded-2xl border border-gray-100 p-8 shadow-sm flex flex-col">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center mb-5" style={{ background: `${color}15` }}>
                <Icon className="w-6 h-6" style={{ color }} />
              </div>
              <h2 className="text-xl font-bold text-gray-900 mb-2">{t(titleKey)}</h2>
              <p className="text-gray-600 text-sm leading-relaxed mb-6">{t(descKey)}</p>
              <ul className="space-y-2 mt-auto">
                {features.map((f, i) => (
                  <li key={i} className="flex items-center gap-2 text-sm text-gray-600">
                    <CheckCircle className="w-4 h-4 shrink-0" style={{ color }} />
                    {f}
                  </li>
                ))}
              </ul>
            </div>
          )
        })}
      </div>
    </div>
  )
}
