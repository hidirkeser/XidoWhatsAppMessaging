'use client'
import Link from 'next/link'
import { useTranslations } from 'next-intl'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import { Shield, Menu, X } from 'lucide-react'

export default function Header({ locale }: { locale: string }) {
  const t = useTranslations('nav')
  const pathname = usePathname()
  const [open, setOpen] = useState(false)
  const other = locale === 'en' ? 'sv' : 'en'
  const otherLabel = locale === 'en' ? 'SV' : 'EN'
  const switchPath = pathname.replace(`/${locale}`, `/${other}`)

  const links = [
    { href: `/${locale}/services`, label: t('services') },
    { href: `/${locale}/products`, label: t('products') },
    { href: `/${locale}/pricing`, label: t('pricing') },
    { href: `/${locale}/security`, label: t('security') },
    { href: `/${locale}/integration`, label: t('integration') },
    { href: `/${locale}/faq`, label: t('faq') },
    { href: `/${locale}/contact`, label: t('contact') },
  ]

  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-gray-100 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href={`/${locale}`} className="flex items-center gap-2 font-bold text-xl" style={{ color: 'var(--primary)' }}>
            <Shield className="w-6 h-6" style={{ color: 'var(--primary)' }} />
            Minion
          </Link>

          {/* Desktop nav */}
          <nav className="hidden lg:flex items-center gap-6">
            {links.map(l => (
              <Link key={l.href} href={l.href} className="text-sm font-medium text-gray-600 hover:text-purple-700 transition-colors">
                {l.label}
              </Link>
            ))}
          </nav>

          {/* Right side */}
          <div className="hidden lg:flex items-center gap-3">
            <Link href={switchPath} className="text-xs font-semibold px-2 py-1 rounded border border-gray-200 text-gray-600 hover:border-purple-300 transition-colors">
              {otherLabel}
            </Link>
            <Link
              href={`/${locale}/login`}
              className="px-4 py-2 rounded-lg text-sm font-semibold text-white transition-all hover:opacity-90"
              style={{ background: 'var(--primary)' }}
            >
              {t('login')}
            </Link>
          </div>

          {/* Mobile menu button */}
          <button className="lg:hidden p-2 text-gray-600" onClick={() => setOpen(!open)}>
            {open ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>
      </div>

      {/* Mobile nav */}
      {open && (
        <div className="lg:hidden border-t border-gray-100 bg-white px-4 pb-4">
          {links.map(l => (
            <Link key={l.href} href={l.href} className="block py-2 text-sm font-medium text-gray-700" onClick={() => setOpen(false)}>
              {l.label}
            </Link>
          ))}
          <div className="flex items-center gap-3 pt-3 border-t border-gray-100 mt-2">
            <Link href={switchPath} className="text-xs font-semibold px-2 py-1 rounded border border-gray-200 text-gray-600">
              {otherLabel}
            </Link>
            <Link href={`/${locale}/login`} className="px-4 py-2 rounded-lg text-sm font-semibold text-white" style={{ background: 'var(--primary)' }}>
              {t('login')}
            </Link>
          </div>
        </div>
      )}
    </header>
  )
}
