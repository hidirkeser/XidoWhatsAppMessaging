import { useTranslations } from 'next-intl'
import { getTranslations } from 'next-intl/server'
import Link from 'next/link'
import type { Metadata } from 'next'
import { Fingerprint, QrCode, Plug, ArrowRight, CheckCircle } from 'lucide-react'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const t = await getTranslations({ locale, namespace: 'home' })
  return {
    title: `${t('heroTitle')} ${t('heroTitleAccent')}`,
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}`,
    },
  }
}

export default function HomePage() {
  const t = useTranslations('home')
  const tn = useTranslations('nav')

  const features = [
    { icon: Fingerprint, title: t('feature1Title'), desc: t('feature1Desc'), color: '#5B2D8E' },
    { icon: QrCode, title: t('feature2Title'), desc: t('feature2Desc'), color: '#00A86B' },
    { icon: Plug, title: t('feature3Title'), desc: t('feature3Desc'), color: '#2563EB' },
  ]

  const steps = [
    { n: '01', title: t('step1Title'), desc: t('step1Desc') },
    { n: '02', title: t('step2Title'), desc: t('step2Desc') },
    { n: '03', title: t('step3Title'), desc: t('step3Desc') },
    { n: '04', title: t('step4Title'), desc: t('step4Desc') },
  ]

  return (
    <>
      {/* Hero */}
      <section className="gradient-hero py-20 md:py-28 px-4">
        <div className="max-w-7xl mx-auto grid md:grid-cols-2 gap-12 items-center">
          <div>
            <div className="inline-flex items-center gap-2 bg-purple-50 border border-purple-200 rounded-full px-3 py-1 text-xs font-medium text-purple-700 mb-6">
              <span className="w-2 h-2 rounded-full bg-green-400 inline-block"></span>
              Powered by Swedish BankID
            </div>
            <h1 className="text-4xl md:text-5xl font-bold leading-tight text-gray-900 mb-4">
              {t('heroTitle')}<br />
              <span style={{ color: 'var(--primary)' }}>{t('heroTitleAccent')}</span>
            </h1>
            <p className="text-lg text-gray-600 mb-8 leading-relaxed max-w-lg">{t('heroSubtitle')}</p>
            <div className="flex flex-col sm:flex-row gap-3">
              <Link
                href="#pricing"
                className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-xl text-white font-semibold text-sm transition-all hover:opacity-90"
                style={{ background: 'var(--primary)' }}
              >
                {t('ctaPrimary')} <ArrowRight className="w-4 h-4" />
              </Link>
              <Link
                href="#how"
                className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-xl text-gray-700 font-semibold text-sm border border-gray-200 hover:border-purple-300 transition-all"
              >
                {t('ctaSecondary')}
              </Link>
            </div>
          </div>

          {/* Visual placeholder */}
          <div className="hidden md:block">
            <div className="bg-white rounded-2xl shadow-xl border border-gray-100 p-6 max-w-sm mx-auto">
              <div className="flex items-center gap-3 mb-4 pb-4 border-b border-gray-100">
                <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                  <Fingerprint className="w-5 h-5 text-purple-700" />
                </div>
                <div>
                  <div className="text-sm font-semibold text-gray-800">Delegation Created</div>
                  <div className="text-xs text-gray-500">Signed with BankID</div>
                </div>
                <span className="ml-auto text-xs bg-green-100 text-green-700 font-semibold px-2 py-0.5 rounded-full">Active</span>
              </div>
              {['Contract Signing', 'Financial Access', 'HR Representation'].map((op, i) => (
                <div key={i} className="flex items-center gap-2 py-1.5">
                  <CheckCircle className="w-4 h-4 text-green-500 shrink-0" />
                  <span className="text-sm text-gray-600">{op}</span>
                </div>
              ))}
              <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
                <div className="w-16 h-16 bg-gray-100 rounded-lg flex items-center justify-center">
                  <QrCode className="w-8 h-8 text-gray-400" />
                </div>
                <div className="text-right">
                  <div className="text-xs text-gray-500">Verification code</div>
                  <div className="text-sm font-mono font-bold text-gray-800">MIN-K7P2-X9QR</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Trust bar */}
      <section className="bg-gray-50 border-y border-gray-100 py-5 px-4">
        <div className="max-w-7xl mx-auto flex flex-wrap items-center justify-center gap-8">
          <span className="text-xs font-medium text-gray-400 uppercase tracking-wider">{t('trustLabel')}</span>
          <span className="flex items-center gap-2 text-sm font-semibold text-gray-600">
            <Fingerprint className="w-4 h-4 text-purple-600" /> BankID Certified
          </span>
          <span className="flex items-center gap-2 text-sm font-semibold text-gray-600">
            <CheckCircle className="w-4 h-4 text-green-500" /> GDPR Compliant
          </span>
          <span className="flex items-center gap-2 text-sm font-semibold text-gray-600">
            <CheckCircle className="w-4 h-4 text-blue-500" /> EU Data Storage
          </span>
          <span className="flex items-center gap-2 text-sm font-semibold text-gray-600">
            <CheckCircle className="w-4 h-4 text-orange-500" /> 7-Year Archive
          </span>
        </div>
      </section>

      {/* Features */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="grid md:grid-cols-3 gap-8">
            {features.map((f) => (
              <div key={f.title} className="bg-white rounded-2xl border border-gray-100 p-8 shadow-sm hover:shadow-md transition-shadow">
                <div className="w-12 h-12 rounded-xl flex items-center justify-center mb-5" style={{ background: `${f.color}15` }}>
                  <f.icon className="w-6 h-6" style={{ color: f.color }} />
                </div>
                <h3 className="font-bold text-lg text-gray-900 mb-2">{f.title}</h3>
                <p className="text-gray-600 text-sm leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how" className="py-20 px-4 bg-gray-50">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center text-gray-900 mb-14">{t('howTitle')}</h2>
          <div className="grid sm:grid-cols-2 md:grid-cols-4 gap-6">
            {steps.map((s) => (
              <div key={s.n} className="text-center">
                <div className="w-14 h-14 rounded-2xl flex items-center justify-center mx-auto mb-4 text-xl font-bold text-white" style={{ background: 'var(--primary)' }}>
                  {s.n}
                </div>
                <h3 className="font-bold text-gray-900 mb-2">{s.title}</h3>
                <p className="text-sm text-gray-600 leading-relaxed">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing teaser */}
      <section id="pricing" className="py-20 px-4">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">{t('pricingTeaser')}</h2>
          <div className="grid sm:grid-cols-3 gap-6 mt-12 max-w-3xl mx-auto">
            {[{ name: 'Starter', credits: '10', price: '99 SEK' }, { name: 'Pro', credits: '50', price: '399 SEK' }, { name: 'Business', credits: '200', price: '1,299 SEK' }].map((p, i) => (
              <div key={p.name} className={`rounded-2xl border p-6 ${i === 1 ? 'border-purple-300 shadow-lg ring-2 ring-purple-100' : 'border-gray-200'}`}>
                <div className="font-bold text-lg text-gray-900 mb-1">{p.name}</div>
                <div className="text-3xl font-bold mb-1" style={{ color: 'var(--primary)' }}>{p.price}</div>
                <div className="text-sm text-gray-500 mb-4">{p.credits} credits</div>
              </div>
            ))}
          </div>
          <Link href="pricing" className="inline-flex items-center gap-2 mt-8 px-6 py-3 rounded-xl text-white font-semibold text-sm" style={{ background: 'var(--primary)' }}>
            {t('viewAllPlans')} <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </section>
    </>
  )
}
