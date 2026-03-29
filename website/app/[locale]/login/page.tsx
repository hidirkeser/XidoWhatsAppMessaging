import { redirect } from 'next/navigation'

export default function LoginPage() {
  const appUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://app.minion.se'
  redirect(appUrl)
}

export const dynamic = 'force-dynamic'
