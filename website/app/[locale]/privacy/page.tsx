import { getTranslations } from 'next-intl/server'
import type { Metadata } from 'next'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const t = await getTranslations({ locale, namespace: 'privacy' })
  return {
    title: t('title'),
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/privacy`,
    },
  }
}

export default async function PrivacyPage() {
  const t = await getTranslations('privacy')
  return (
    <div className="max-w-3xl mx-auto px-4 py-16 prose prose-gray max-w-none">
      <h1 className="text-4xl font-bold text-gray-900 mb-2">{t('title')}</h1>
      <p className="text-sm text-gray-500 mb-10">{t('lastUpdated')}</p>
      {[
        ['Data Controller', 'Minion AB, Stockholm, Sweden. Contact: privacy@minion.se'],
        ['Data We Collect', 'Swedish personal number (personnummer), first name, last name, email address (optional), phone number (optional), delegation history, BankID signature data, device tokens for push notifications, usage logs.'],
        ['Legal Basis', 'Art. 6(1)(b) — contract performance (delegation management); Art. 6(1)(c) — legal obligation (7-year document archiving per Swedish law); Art. 6(1)(a) — consent (marketing communications).'],
        ['Retention Periods', 'Account data: retained for the duration of the account plus 30 days after deletion. Delegation documents (signed PDF/A): 7 years as required by Swedish law. After retention, documents are anonymised. Usage logs: 90 days.'],
        ['Third-Party Processors', 'Finansiell ID-teknik BID AB (BankID authentication and signing); Microsoft Azure (data storage and hosting, EU region); Google Firebase (push notifications).'],
        ['Your Rights', 'Access: export your data via Profile → Export Data. Rectification: update via Profile page. Erasure: request via Profile → Delete Account (legal archive documents are anonymised, not deleted). Portability: data export in JSON format. Objection: contact privacy@minion.se.'],
        ['Cookies', 'We use only a session cookie for authentication and a single localStorage entry for cookie consent preference. No tracking, analytics, or advertising cookies are used.'],
        ['Security', 'Personal numbers are encrypted at rest using AES-256. All data is transmitted using TLS 1.3. Data is stored in Microsoft Azure Sweden Central region.'],
        ['Contact', 'For data protection enquiries: privacy@minion.se. Response within 30 days as required by GDPR Art. 12.'],
      ].map(([title, body]) => (
        <div key={title} className="mb-8">
          <h2 className="text-xl font-bold text-gray-900 mb-2">{title}</h2>
          <p className="text-gray-600 leading-relaxed">{body}</p>
        </div>
      ))}
    </div>
  )
}
