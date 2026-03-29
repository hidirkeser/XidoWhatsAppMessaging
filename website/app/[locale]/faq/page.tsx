import type { Metadata } from 'next'
import FaqClient from './FaqClient'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Vanliga frågor — Minion' : 'FAQ — Frequently Asked Questions | Minion',
    description: isSv
      ? 'Svar på vanliga frågor om Minion, BankID-fullmakter, krediter, GDPR och API-integration.'
      : 'Answers to common questions about Minion, BankID delegations, credits, GDPR and API integration.',
  }
}

export default function FaqPage() {
  return (
    <>
      <FaqClient />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'FAQPage',
            mainEntity: [
              { '@type': 'Question', name: 'What is Minion?', acceptedAnswer: { '@type': 'Answer', text: 'Minion is a secure delegation management platform powered by Swedish BankID. It allows individuals and organisations to create, sign, and verify legally-binding power of attorney documents digitally.' } },
              { '@type': 'Question', name: 'Who can use Minion?', acceptedAnswer: { '@type': 'Answer', text: 'Anyone with a valid Swedish BankID can use Minion as an individual. Organisations can register to manage delegations across their teams.' } },
              { '@type': 'Question', name: 'What is a delegation?', acceptedAnswer: { '@type': 'Answer', text: 'A delegation is a legally-binding digital power of attorney. It authorises one person (the delegate) to act on behalf of another (the grantor) for specific operations within an organisation.' } },
              { '@type': 'Question', name: 'How does BankID signing work?', acceptedAnswer: { '@type': 'Answer', text: 'Both the grantor and the delegate sign the delegation document using Swedish BankID. This provides non-repudiable, court-admissible proof of consent.' } },
              { '@type': 'Question', name: 'What are credits?', acceptedAnswer: { '@type': 'Answer', text: 'Credits are consumed each time a delegation is created. One credit equals one BankID-signed delegation. Credits never expire.' } },
              { '@type': 'Question', name: 'How do I verify a delegation?', acceptedAnswer: { '@type': 'Answer', text: 'Third parties can verify a delegation by scanning the QR code on the delegation document or by calling the Verify API with the delegation code.' } },
              { '@type': 'Question', name: 'Is Minion GDPR compliant?', acceptedAnswer: { '@type': 'Answer', text: 'Yes. Minion is fully GDPR compliant. All personal data is processed lawfully, users can export or delete their data, and a Data Protection Officer is appointed.' } },
              { '@type': 'Question', name: 'How long are delegations archived?', acceptedAnswer: { '@type': 'Answer', text: 'All signed delegation documents are archived for 7 years in accordance with Swedish law (Lag 2016:561 on electronic identification).' } },
              { '@type': 'Question', name: 'Can I integrate Minion into my own system?', acceptedAnswer: { '@type': 'Answer', text: 'Yes. The Minion Verify API allows organisations to verify delegations programmatically using token/secret key authentication. Apply via the contact form.' } },
              { '@type': 'Question', name: 'What happens when a delegation expires?', acceptedAnswer: { '@type': 'Answer', text: 'Expired delegations are automatically marked as EXPIRED. The delegate can no longer act on behalf of the grantor. Both parties are notified before expiry.' } },
              { '@type': 'Question', name: 'Can I revoke a delegation?', acceptedAnswer: { '@type': 'Answer', text: 'Yes. The grantor can revoke an active delegation at any time. The delegate is notified immediately and access is removed instantly.' } },
              { '@type': 'Question', name: 'Is there a mobile app?', acceptedAnswer: { '@type': 'Answer', text: 'Yes. Minion is available as a mobile app for iOS and Android, as well as a web application. All platforms support BankID authentication.' } },
            ],
          }),
        }}
      />
    </>
  )
}
