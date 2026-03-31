'use client'

import Link from 'next/link'
import { useTranslations } from 'next-intl'
import { Shield } from 'lucide-react'

export default function Footer({ locale }: { locale: string }) {
  const t = useTranslations('footer')

  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <div className="flex items-center gap-2 font-bold text-xl text-white mb-3">
              <Shield className="w-5 h-5" style={{ color: '#9B6FD4' }} />
              Minion
            </div>
            <p className="text-sm text-gray-400 leading-relaxed mb-4">{t('tagline')}</p>
            <p className="text-xs text-gray-500">Stockholm, Sweden</p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-white font-semibold text-sm mb-4">{t('colProduct')}</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href={`/${locale}/products`} className="hover:text-white transition-colors">{t('app')}</Link></li>
              <li><Link href={`/${locale}/products`} className="hover:text-white transition-colors">{t('verifyApi')}</Link></li>
              <li><Link href={`/${locale}/pricing`} className="hover:text-white transition-colors">{t('pricingLink')}</Link></li>
              <li><Link href={`/${locale}/security`} className="hover:text-white transition-colors">{t('securityLink')}</Link></li>
              <li><Link href={`/${locale}/integration`} className="hover:text-white transition-colors">{t('integrationLink')}</Link></li>
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="text-white font-semibold text-sm mb-4">{t('colCompany')}</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href={`/${locale}/about`} className="hover:text-white transition-colors">{t('about')}</Link></li>
              <li><Link href={`/${locale}/services`} className="hover:text-white transition-colors">{t('servicesLink')}</Link></li>
              <li><Link href={`/${locale}/contact`} className="hover:text-white transition-colors">{t('contactLink')}</Link></li>
              <li><Link href={`/${locale}/faq`} className="hover:text-white transition-colors">{t('faq', { defaultValue: 'FAQ' })}</Link></li>
              <li><span className="text-gray-600 text-xs">{t('blog')}</span></li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-white font-semibold text-sm mb-4">{t('colLegal')}</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href={`/${locale}/privacy`} className="hover:text-white transition-colors">{t('privacy')}</Link></li>
              <li><Link href={`/${locale}/terms`} className="hover:text-white transition-colors">{t('terms')}</Link></li>
              <li><Link href={`/sitemap.xml`} className="hover:text-white transition-colors">{t('sitemap')}</Link></li>
            </ul>
          </div>
        </div>

        <div className="border-t border-gray-800 pt-6 flex flex-col sm:flex-row justify-between items-center gap-3 text-xs text-gray-500">
          <span>{t('copyright')}</span>
          <span>{t('madeIn')}</span>
          <span className="flex items-center gap-1">
            <span className="inline-block w-2 h-2 rounded-full bg-green-400"></span>
            Powered by BankID
          </span>
        </div>
      </div>
    </footer>
  )
}
