import type { Metadata } from 'next'
import VerifyDocumentClient from './VerifyDocumentClient'

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params
  const isSv = locale === 'sv'
  return {
    title: isSv ? 'Verifiera fullmakt' : 'Verify Power of Attorney',
    description: isSv
      ? 'Verifiera och visa ett fullmaktsdokument signerat med BankID.'
      : 'Verify and view a power of attorney document signed with BankID.',
  }
}

export default async function VerifyDocumentPage({
  params,
}: {
  params: Promise<{ locale: string; code: string }>
}) {
  const { locale, code } = await params
  return <VerifyDocumentClient code={code} locale={locale} />
}
