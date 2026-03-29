import type { Metadata } from 'next'
import ContactClient from './ContactClient'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Kontakt — Minion' : 'Contact — Minion',
    description: isSv
      ? 'Kontakta Minion-teamet för frågor om fullmaktshantering, API-integration eller demo. Vi svarar inom 24 timmar.'
      : 'Contact the Minion team for questions about delegation management, API integration or a demo. We respond within 24 hours.',
  }
}

export default function ContactPage() {
  return <ContactClient />
}
