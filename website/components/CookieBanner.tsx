'use client'
import { useState, useEffect } from 'react'
import { useTranslations } from 'next-intl'
import Link from 'next/link'

export default function CookieBanner() {
  const t = useTranslations('cookie')
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    const accepted = localStorage.getItem('cookie-consent')
    if (!accepted) setVisible(true)
  }, [])

  const accept = () => {
    localStorage.setItem('cookie-consent', '1')
    setVisible(false)
  }

  if (!visible) return null

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 bg-gray-900 text-white px-4 py-3 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-2xl">
      <p className="text-sm text-gray-300 max-w-2xl">{t('text')}</p>
      <div className="flex items-center gap-3 shrink-0">
        <Link href="/en/privacy#cookies" className="text-xs text-gray-400 hover:text-white underline">
          {t('learnMore')}
        </Link>
        <button
          onClick={accept}
          className="px-4 py-1.5 rounded-lg text-sm font-semibold text-white"
          style={{ background: 'var(--primary)' }}
        >
          {t('accept')}
        </button>
      </div>
    </div>
  )
}
