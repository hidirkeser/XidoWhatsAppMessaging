import { getRequestConfig } from 'next-intl/server'

export default getRequestConfig(async ({ requestLocale }) => {
  const locale = await requestLocale
  return {
    locale: locale ?? 'sv',
    messages: (await import(`../messages/${locale ?? 'sv'}.json`)).default,
  }
})
