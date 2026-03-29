import { ImageResponse } from 'next/og'

export const runtime = 'edge'
export const alt = 'Minion — BankID Delegation Management'
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

export default async function Image({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params
  const isSv = locale === 'sv'

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #4c1d95 100%)',
          fontFamily: 'sans-serif',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 32 }}>
          <div style={{
            width: 64, height: 64, borderRadius: '50%',
            background: 'rgba(155,111,212,0.3)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 36,
          }}>🛡</div>
          <span style={{ fontSize: 56, fontWeight: 800, color: 'white', letterSpacing: -2 }}>Minion</span>
        </div>
        <div style={{
          fontSize: 32, fontWeight: 600, color: 'white',
          textAlign: 'center', maxWidth: 800, lineHeight: 1.3, marginBottom: 24,
        }}>
          {isSv ? 'Säker fullmaktshantering.' : 'Secure Delegation Management.'}
        </div>
        <div style={{
          fontSize: 24, color: '#c4b5fd',
          textAlign: 'center', maxWidth: 700,
        }}>
          {isSv ? 'Driven av Mobilt BankID' : 'Powered by Swedish BankID'}
        </div>
        <div style={{
          marginTop: 40, paddingLeft: 24, paddingRight: 24, paddingTop: 12, paddingBottom: 12,
          background: 'rgba(155,111,212,0.4)', borderRadius: 100,
          fontSize: 18, color: '#e9d5ff',
        }}>
          {isSv ? 'minion.se' : 'minion.se'}
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  )
}
