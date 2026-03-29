'use client'
import { useTranslations } from 'next-intl'
import { useState } from 'react'
import { Mail, MapPin, Clock, CheckCircle } from 'lucide-react'

export default function ContactPage() {
  const t = useTranslations('contact')
  const subjects = t.raw('subjects') as string[]
  const [submitted, setSubmitted] = useState(false)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    await new Promise(r => setTimeout(r, 1000))
    setLoading(false)
    setSubmitted(true)
  }

  return (
    <div className="max-w-5xl mx-auto px-4 py-16">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">{t('title')}</h1>
        <p className="text-lg text-gray-600">{t('subtitle')}</p>
      </div>
      <div className="grid md:grid-cols-5 gap-10">
        {/* Info */}
        <div className="md:col-span-2 space-y-6">
          {[{ icon: Mail, text: t('infoEmail') }, { icon: MapPin, text: t('infoLocation') }, { icon: Clock, text: t('infoResponse') }].map(({ icon: Icon, text }) => (
            <div key={text} className="flex items-start gap-4">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: '#f3eeff' }}>
                <Icon className="w-5 h-5" style={{ color: '#5B2D8E' }} />
              </div>
              <span className="text-gray-600 pt-2 text-sm">{text}</span>
            </div>
          ))}
        </div>

        {/* Form */}
        <div className="md:col-span-3">
          {submitted ? (
            <div className="text-center py-12 bg-green-50 rounded-2xl border border-green-100">
              <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-4" />
              <h2 className="text-xl font-bold text-gray-900 mb-2">{t('successTitle')}</h2>
              <p className="text-gray-600">{t('successText')}</p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('nameLabel')}</label>
                  <input required className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('companyLabel')}</label>
                  <input className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300" />
                </div>
              </div>
              <div className="grid sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('emailLabel')}</label>
                  <input required type="email" className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('phoneLabel')}</label>
                  <input type="tel" className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">{t('subjectLabel')}</label>
                <select required className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300 bg-white">
                  <option value=""></option>
                  {subjects.map(s => <option key={s}>{s}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">{t('messageLabel')}</label>
                <textarea required rows={5} className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300 resize-none" />
              </div>
              <button type="submit" disabled={loading} className="w-full py-3 rounded-xl text-sm font-semibold text-white disabled:opacity-60" style={{ background: 'var(--primary)' }}>
                {loading ? t('sending') : t('submitLabel')}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}
