'use client'
import { useTranslations } from 'next-intl'
import { useState } from 'react'
import { CheckCircle, ArrowRight } from 'lucide-react'
import Link from 'next/link'
import { useParams } from 'next/navigation'

export default function PricingClient() {
  const t = useTranslations('pricing')
  const params = useParams()
  const locale = params.locale as string
  const [tab, setTab] = useState<'credits' | 'api' | 'subscriptions'>('credits')

  const apiPlans = t.raw('apiPlans') as Array<{ name: string; price: string; quota: string; cta: string }>
  const creditPlans = t.raw('creditPlans') as Array<{ name: string; price: string; credits: string }>
  const subscriptionPlans = t.raw('subscriptionPlans') as Array<{ name: string; price: string; quota: string; type: string }>

  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600">{t('subtitle')}</p>
      </div>

      {/* Tab switcher */}
      <div className="flex justify-center mb-10">
        <div className="inline-flex bg-gray-100 rounded-xl p-1 gap-1">
          {(['credits', 'api', 'subscriptions'] as const).map((tab_) => (
            <button key={tab_} onClick={() => setTab(tab_)}
              className={`px-6 py-2 rounded-lg text-sm font-semibold transition-all ${tab === tab_ ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'}`}>
              {tab_ === 'credits' ? t('tabCredits') : tab_ === 'api' ? t('tabApi') : t('tabSubscriptions')}
            </button>
          ))}
        </div>
      </div>

      {tab === 'credits' && (
        <div>
          <p className="text-center text-sm text-gray-500 mb-8">{t('creditsNote')}</p>
          <div className="grid sm:grid-cols-3 gap-6 max-w-2xl mx-auto">
            {creditPlans.map((p, i) => (
              <div key={p.name} className={`rounded-2xl border p-8 text-center ${i === 1 ? 'border-purple-300 ring-2 ring-purple-100 shadow-lg' : 'border-gray-200'}`}>
                {i === 1 && <div className="text-xs font-bold text-purple-600 uppercase tracking-wider mb-3">Most Popular</div>}
                <div className="text-xl font-bold text-gray-900 mb-2">{p.name}</div>
                <div className="text-4xl font-bold mb-1" style={{ color: 'var(--primary)' }}>{p.price}</div>
                <div className="text-sm text-gray-500 mb-6">{p.credits} {t('creditsUnit')}</div>
                <Link href={`/${locale}/login`} className="block px-4 py-2.5 rounded-xl text-sm font-semibold text-white w-full text-center" style={{ background: 'var(--primary)' }}>
                  {t('getStarted')}
                </Link>
              </div>
            ))}
          </div>
        </div>
      )}

      {tab === 'api' && (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Plan</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">{t('requests')}</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Price</th>
                <th className="py-3 px-4"></th>
              </tr>
            </thead>
            <tbody>
              {apiPlans.map((p, i) => (
                <tr key={p.name} className={`border-b border-gray-100 ${i === 0 ? 'bg-green-50' : ''}`}>
                  <td className="py-4 px-4 font-semibold text-gray-900">{p.name}</td>
                  <td className="py-4 px-4 text-gray-600">{p.quota}</td>
                  <td className="py-4 px-4 font-bold text-gray-900">{p.price}</td>
                  <td className="py-4 px-4">
                    <Link href={i === apiPlans.length - 1 ? `/${locale}/contact?type=api` : `/${locale}/login`}
                      className="inline-flex items-center gap-1 px-4 py-1.5 rounded-lg text-xs font-semibold text-white"
                      style={{ background: i === 0 ? '#00A86B' : 'var(--primary)' }}>
                      {p.cta} <ArrowRight className="w-3 h-3" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'subscriptions' && (
        <div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {subscriptionPlans.map((p, i) => (
              <div key={p.name} className={`rounded-2xl border p-8 text-center ${i === 2 ? 'border-purple-300 ring-2 ring-purple-100 shadow-lg' : 'border-gray-200'}`}>
                <div className="inline-block text-xs font-bold uppercase tracking-wider mb-3 px-2 py-0.5 rounded-full"
                  style={{
                    background: p.type === t('corporateLabel') || p.type === 'Corporate' || p.type === 'Företag' ? '#eff6ff' : '#f0fdf4',
                    color: p.type === t('corporateLabel') || p.type === 'Corporate' || p.type === 'Företag' ? '#2563EB' : '#00A86B',
                  }}>
                  {p.type}
                </div>
                <div className="text-xl font-bold text-gray-900 mb-2">{p.name}</div>
                <div className="text-4xl font-bold mb-1" style={{ color: 'var(--primary)' }}>{p.price}</div>
                <div className="text-sm text-gray-500 mb-6">{p.quota} {t('quotaLabel')}</div>
                <Link href={`/${locale}/login`} className="block px-4 py-2.5 rounded-xl text-sm font-semibold text-white w-full text-center" style={{ background: 'var(--primary)' }}>
                  {t('getStarted')}
                </Link>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* FAQ */}
      <div className="mt-16 bg-gray-50 rounded-2xl p-8">
        <h2 className="text-xl font-bold text-gray-900 mb-6">{t('faqTitle')}</h2>
        <div className="space-y-6">
          {(['1', '2', '3'] as const).map((n) => (
            <div key={n}>
              <h3 className="font-semibold text-gray-900 mb-1">{t(`q${n}` as any)}</h3>
              <p className="text-sm text-gray-600">{t(`a${n}` as any)}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
