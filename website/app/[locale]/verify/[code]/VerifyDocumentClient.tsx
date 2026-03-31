'use client'

import { useTranslations } from 'next-intl'
import { useEffect, useState } from 'react'
import {
  FileText, CheckCircle, XCircle, Clock, Share2,
  Download, MessageCircle, Mail, Loader2, AlertCircle,
  Shield, Building, User, Calendar, ChevronDown, ChevronUp
} from 'lucide-react'

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'https://minion-api-production.up.railway.app/api'

interface DocumentData {
  id: string
  delegationId: string
  language: string
  renderedContent: string
  documentVersion: string
  status: string
  grantorApprovedAt: string | null
  isGrantorSigned: boolean
  delegateApprovedAt: string | null
  isDelegateSigned: boolean
  qrCodeData: string | null
  grantorName: string
  delegateName: string
  organizationName: string
  verificationCode: string
  createdAt: string
}

export default function VerifyDocumentClient({ code, locale }: { code: string; locale: string }) {
  const t = useTranslations('verify')
  const [doc, setDoc] = useState<DocumentData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showDocument, setShowDocument] = useState(false)
  const [shareMode, setShareMode] = useState<'whatsapp' | 'email' | null>(null)
  const [shareForm, setShareForm] = useState({ name: '', phone: '', email: '' })
  const [sharing, setSharing] = useState(false)
  const [shareSuccess, setShareSuccess] = useState(false)

  useEffect(() => {
    fetchDocument()
  }, [code])

  async function fetchDocument() {
    try {
      const res = await fetch(`${API_BASE}/verify/${code}/document`)
      if (!res.ok) throw new Error('Document not found')
      const data = await res.json()
      setDoc(data)
    } catch {
      setError(t('notFound'))
    } finally {
      setLoading(false)
    }
  }

  async function handleShare() {
    if (!shareForm.name) return
    setSharing(true)
    try {
      const body: Record<string, string> = {
        method: shareMode!,
        senderName: shareForm.name,
      }
      if (shareMode === 'whatsapp') body.recipientPhone = shareForm.phone
      if (shareMode === 'email') body.recipientEmail = shareForm.email

      const res = await fetch(`${API_BASE}/verify/${code}/document/share`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      if (!res.ok) throw new Error('Share failed')
      setShareSuccess(true)
      setTimeout(() => { setShareSuccess(false); setShareMode(null) }, 3000)
    } catch {
      alert(t('shareFailed'))
    } finally {
      setSharing(false)
    }
  }

  function handleDownloadPdf() {
    window.open(`${API_BASE}/verify/${code}/document/pdf`, '_blank')
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-amber-600" />
      </div>
    )
  }

  if (error || !doc) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4">
        <div className="text-center max-w-md">
          <AlertCircle className="w-16 h-16 text-red-400 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">{t('notFoundTitle')}</h1>
          <p className="text-gray-600">{error || t('notFound')}</p>
        </div>
      </div>
    )
  }

  const isFullyApproved = doc.status === 'FullyApproved'
  const isSv = locale === 'sv'

  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-2xl mx-auto space-y-6">

        {/* Status Banner */}
        <div className={`rounded-2xl p-6 text-center ${
          isFullyApproved
            ? 'bg-green-50 border border-green-200'
            : 'bg-amber-50 border border-amber-200'
        }`}>
          {isFullyApproved ? (
            <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-3" />
          ) : (
            <Clock className="w-12 h-12 text-amber-500 mx-auto mb-3" />
          )}
          <h1 className="text-2xl font-bold text-gray-900 mb-1">
            {isFullyApproved
              ? (isSv ? 'Fullmakt verifierad' : 'Power of Attorney Verified')
              : (isSv ? 'Fullmakt inväntar signering' : 'Power of Attorney Pending')}
          </h1>
          <p className="text-sm text-gray-600">
            {isSv ? 'Verifieringskod' : 'Verification Code'}: <span className="font-mono font-bold">{doc.verificationCode}</span>
          </p>
        </div>

        {/* Document Details */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="p-6 space-y-4">
            <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
              <FileText className="w-5 h-5 text-amber-600" />
              {isSv ? 'Dokumentdetaljer' : 'Document Details'}
            </h2>

            {/* Parties */}
            <div className="grid sm:grid-cols-2 gap-4">
              <div className="bg-gray-50 rounded-xl p-4">
                <div className="flex items-center gap-2 mb-2">
                  <User className="w-4 h-4 text-gray-400" />
                  <span className="text-xs text-gray-500 uppercase tracking-wide">
                    {isSv ? 'Fullmaktsgivare' : 'Principal (Grantor)'}
                  </span>
                </div>
                <p className="font-semibold text-gray-900">{doc.grantorName}</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-4">
                <div className="flex items-center gap-2 mb-2">
                  <User className="w-4 h-4 text-gray-400" />
                  <span className="text-xs text-gray-500 uppercase tracking-wide">
                    {isSv ? 'Fullmaktshavare' : 'Agent (Representative)'}
                  </span>
                </div>
                <p className="font-semibold text-gray-900">{doc.delegateName}</p>
              </div>
            </div>

            {/* Organization */}
            <div className="bg-gray-50 rounded-xl p-4">
              <div className="flex items-center gap-2 mb-2">
                <Building className="w-4 h-4 text-gray-400" />
                <span className="text-xs text-gray-500 uppercase tracking-wide">
                  {isSv ? 'Organisation' : 'Organisation'}
                </span>
              </div>
              <p className="font-semibold text-gray-900">{doc.organizationName}</p>
            </div>

            {/* Signatures */}
            <div>
              <h3 className="text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                <Shield className="w-4 h-4 text-amber-600" />
                {isSv ? 'BankID-underskrifter' : 'BankID Signatures'}
              </h3>
              <div className="grid sm:grid-cols-2 gap-3">
                <div className={`rounded-xl p-3 border ${
                  doc.isGrantorSigned
                    ? 'bg-green-50 border-green-200'
                    : 'bg-gray-50 border-gray-200'
                }`}>
                  <div className="flex items-center gap-2">
                    {doc.isGrantorSigned
                      ? <CheckCircle className="w-4 h-4 text-green-500" />
                      : <XCircle className="w-4 h-4 text-gray-400" />}
                    <span className="text-sm font-medium">
                      {isSv ? 'Fullmaktsgivare' : 'Principal'}
                    </span>
                  </div>
                  {doc.grantorApprovedAt && (
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(doc.grantorApprovedAt).toLocaleString(locale)}
                    </p>
                  )}
                </div>
                <div className={`rounded-xl p-3 border ${
                  doc.isDelegateSigned
                    ? 'bg-green-50 border-green-200'
                    : 'bg-gray-50 border-gray-200'
                }`}>
                  <div className="flex items-center gap-2">
                    {doc.isDelegateSigned
                      ? <CheckCircle className="w-4 h-4 text-green-500" />
                      : <XCircle className="w-4 h-4 text-gray-400" />}
                    <span className="text-sm font-medium">
                      {isSv ? 'Fullmaktshavare' : 'Agent'}
                    </span>
                  </div>
                  {doc.delegateApprovedAt && (
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(doc.delegateApprovedAt).toLocaleString(locale)}
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* Created at */}
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <Calendar className="w-4 h-4" />
              {isSv ? 'Skapad' : 'Created'}: {new Date(doc.createdAt).toLocaleString(locale)}
              <span className="ml-2 text-xs bg-gray-100 px-2 py-0.5 rounded">v{doc.documentVersion}</span>
            </div>
          </div>

          {/* View Full Document Toggle */}
          <button
            onClick={() => setShowDocument(!showDocument)}
            className="w-full px-6 py-3 flex items-center justify-center gap-2 bg-gray-50 hover:bg-gray-100 transition border-t text-sm font-medium text-gray-700"
          >
            {showDocument ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
            {showDocument
              ? (isSv ? 'Dolj fullständigt dokument' : 'Hide full document')
              : (isSv ? 'Visa fullständigt dokument' : 'View full document')}
          </button>

          {showDocument && (
            <div className="p-6 border-t">
              <div
                className="prose prose-sm max-w-none"
                dangerouslySetInnerHTML={{ __html: doc.renderedContent }}
              />
            </div>
          )}
        </div>

        {/* Action Buttons */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
            <Share2 className="w-4 h-4 text-amber-600" />
            {isSv ? 'Dela dokument' : 'Share Document'}
          </h3>

          <div className="grid sm:grid-cols-3 gap-3">
            <button
              onClick={() => setShareMode(shareMode === 'whatsapp' ? null : 'whatsapp')}
              className={`flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-medium transition ${
                shareMode === 'whatsapp'
                  ? 'bg-green-500 text-white'
                  : 'bg-green-50 text-green-700 hover:bg-green-100'
              }`}
            >
              <MessageCircle className="w-4 h-4" />
              WhatsApp
            </button>

            <button
              onClick={() => setShareMode(shareMode === 'email' ? null : 'email')}
              className={`flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-medium transition ${
                shareMode === 'email'
                  ? 'bg-blue-500 text-white'
                  : 'bg-blue-50 text-blue-700 hover:bg-blue-100'
              }`}
            >
              <Mail className="w-4 h-4" />
              {isSv ? 'E-post' : 'Email'}
            </button>

            <button
              onClick={handleDownloadPdf}
              className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-medium bg-amber-50 text-amber-700 hover:bg-amber-100 transition"
            >
              <Download className="w-4 h-4" />
              PDF
            </button>
          </div>

          {/* Share Form */}
          {shareMode && !shareSuccess && (
            <div className="mt-4 p-4 bg-gray-50 rounded-xl space-y-3">
              <input
                type="text"
                placeholder={isSv ? 'Ditt namn' : 'Your name'}
                value={shareForm.name}
                onChange={e => setShareForm(prev => ({ ...prev, name: e.target.value }))}
                className="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm"
              />

              {shareMode === 'whatsapp' && (
                <input
                  type="tel"
                  placeholder={isSv ? 'Mottagarens telefonnummer (+46...)' : 'Recipient phone (+46...)'}
                  value={shareForm.phone}
                  onChange={e => setShareForm(prev => ({ ...prev, phone: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm"
                />
              )}

              {shareMode === 'email' && (
                <input
                  type="email"
                  placeholder={isSv ? 'Mottagarens e-post' : 'Recipient email'}
                  value={shareForm.email}
                  onChange={e => setShareForm(prev => ({ ...prev, email: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm"
                />
              )}

              <button
                onClick={handleShare}
                disabled={sharing || !shareForm.name}
                className="w-full py-2.5 rounded-lg text-sm font-medium text-white bg-amber-600 hover:bg-amber-700 disabled:opacity-50 transition flex items-center justify-center gap-2"
              >
                {sharing ? <Loader2 className="w-4 h-4 animate-spin" /> : null}
                {isSv ? 'Skicka' : 'Send'}
              </button>
            </div>
          )}

          {shareSuccess && (
            <div className="mt-4 p-4 bg-green-50 rounded-xl text-center">
              <CheckCircle className="w-6 h-6 text-green-500 mx-auto mb-2" />
              <p className="text-sm font-medium text-green-700">
                {isSv ? 'Dokumentet har delats!' : 'Document shared successfully!'}
              </p>
            </div>
          )}
        </div>

        {/* Legal Notice */}
        <div className="bg-amber-50 rounded-2xl p-4 border border-amber-200">
          <p className="text-xs text-amber-800 leading-relaxed">
            {isSv
              ? 'Detta dokument har verifierats via Minions plattform. Elektroniska underskrifter gjorda med BankID har juridisk giltighet enligt svensk lag och eIDAS-forordningen (EU) nr 910/2014.'
              : 'This document has been verified through the Minion platform. Electronic signatures made with BankID have legal validity under Swedish law and the eIDAS Regulation (EU) No 910/2014.'}
          </p>
        </div>

      </div>
    </div>
  )
}
