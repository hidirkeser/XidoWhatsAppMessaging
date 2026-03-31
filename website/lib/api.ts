import type { WebProduct, PublicProduct, PublicCreditPackage } from './types'

const API_BASE = process.env.NEXT_PUBLIC_API_URL || ''

export async function fetchWebProducts(locale: string): Promise<WebProduct[] | null> {
  if (!API_BASE) return null
  try {
    const res = await fetch(`${API_BASE}/api/public/web-products?locale=${locale}`, {
      next: { revalidate: 300 },
    })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}

export async function fetchProducts(locale: string, type?: string): Promise<PublicProduct[] | null> {
  if (!API_BASE) return null
  try {
    const params = new URLSearchParams({ locale })
    if (type) params.set('type', type)
    const res = await fetch(`${API_BASE}/api/public/products?${params}`, {
      next: { revalidate: 300 },
    })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}

export async function fetchCreditPackages(locale: string): Promise<PublicCreditPackage[] | null> {
  if (!API_BASE) return null
  try {
    const res = await fetch(`${API_BASE}/api/public/credit-packages?locale=${locale}`, {
      next: { revalidate: 300 },
    })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}
