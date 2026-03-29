import { getTranslations } from 'next-intl/server'
import { useTranslations } from 'next-intl'
import type { Metadata } from 'next'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const t = await getTranslations({ locale, namespace: 'terms' })
  return {
    title: t('title'),
    alternates: {
      canonical: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://minion.se'}/${locale}/terms`,
    },
  }
}

export default function TermsPage() {
  const t = useTranslations('terms')
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold text-gray-900 mb-2">{t('title')}</h1>
      <p className="text-sm text-gray-500 mb-10">{t('lastUpdated')}</p>
      {[
        ['1. Acceptance', 'By creating an account or using Minion, you agree to these Terms of Service. If you do not agree, do not use the service.'],
        ['2. Service Description', 'Minion provides a digital delegation management platform using Swedish BankID for identity verification and document signing. The service requires a valid Swedish BankID.'],
        ['3. Eligibility', 'You must hold a valid Swedish BankID to use Minion. By registering, you confirm you are the authorised holder of the BankID used.'],
        ['4. Credits', 'Credits are purchased in advance and consumed upon delegation creation. Credits do not expire. Credits are non-refundable once consumed. Credits consumed for delegations that are later revoked or rejected are not refunded.'],
        ['5. API Access', 'API access requires application and admin approval. API keys must be kept confidential. Minion reserves the right to suspend API access for abuse or violation of these terms.'],
        ['6. Acceptable Use', 'You may not use Minion for fraudulent, illegal, or harmful purposes. You may not attempt to circumvent authentication or access others\' delegations without authorisation.'],
        ['7. Data & Privacy', 'Data processing is governed by our Privacy Policy. You retain ownership of your delegation data. We process it to provide the service.'],
        ['8. Liability', 'Minion is provided "as is". We are not liable for indirect damages, loss of business, or consequential losses. Maximum liability is limited to fees paid in the past 3 months.'],
        ['9. Governing Law', 'These terms are governed by Swedish law. Disputes shall be resolved by Stockholm District Court (Stockholms tingsrätt).'],
        ['10. Changes', 'We will notify you of material changes to these terms at least 30 days in advance via email or in-app notification.'],
      ].map(([title, body]) => (
        <div key={title} className="mb-8">
          <h2 className="text-xl font-bold text-gray-900 mb-2">{title}</h2>
          <p className="text-gray-600 leading-relaxed">{body}</p>
        </div>
      ))}
    </div>
  )
}
