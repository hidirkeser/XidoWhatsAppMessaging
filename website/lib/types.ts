export interface WebProduct {
  id: string
  slug: string
  name: string
  description: string
  features: string[]
  icon: string
  color: string
  sortOrder: number
}

export interface PublicProduct {
  id: string
  name: string
  description: string | null
  productType: 'Individual' | 'Corporate'
  monthlyQuota: number
  priceSEK: number
  features: string[]
  badge: string | null
  sortOrder: number
}

export interface PublicCreditPackage {
  id: string
  name: string
  creditAmount: number
  priceSEK: number
  description: string | null
  badge: string | null
  sortOrder: number
}
