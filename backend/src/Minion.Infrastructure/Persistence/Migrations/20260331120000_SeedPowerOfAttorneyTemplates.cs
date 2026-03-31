using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Minion.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedPowerOfAttorneyTemplates : Migration
    {
        private static readonly Guid EnTemplateId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567890");
        private static readonly Guid SvTemplateId = Guid.Parse("b2c3d4e5-f6a7-8901-bcde-f12345678901");

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var now = DateTime.UtcNow;

            // ── English Power of Attorney Template ─────────────────────────
            migrationBuilder.InsertData(
                table: "DelegationDocumentTemplates",
                columns: new[] { "Id", "Language", "LanguageName", "TemplateContent", "Version", "IsActive", "CreatedAt" },
                values: new object[] {
                    EnTemplateId,
                    "en",
                    "English",
                    EnglishTemplate,
                    "1.0",
                    true,
                    now
                });

            // ── Swedish Fullmakt Template ──────────────────────────────────
            migrationBuilder.InsertData(
                table: "DelegationDocumentTemplates",
                columns: new[] { "Id", "Language", "LanguageName", "TemplateContent", "Version", "IsActive", "CreatedAt" },
                values: new object[] {
                    SvTemplateId,
                    "sv",
                    "Svenska",
                    SwedishTemplate,
                    "1.0",
                    true,
                    now
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "DelegationDocumentTemplates",
                keyColumn: "Id",
                keyValue: EnTemplateId);

            migrationBuilder.DeleteData(
                table: "DelegationDocumentTemplates",
                keyColumn: "Id",
                keyValue: SvTemplateId);
        }

        // ════════════════════════════════════════════════════════════════════
        //  TEMPLATES
        // ════════════════════════════════════════════════════════════════════

        private const string EnglishTemplate = @"
<div style=""font-family: 'Segoe UI', Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 40px; color: #1a1a2e;"">

  <!-- Header -->
  <div style=""text-align: center; border-bottom: 3px solid #c5a028; padding-bottom: 20px; margin-bottom: 30px;"">
    <h1 style=""margin: 0; font-size: 28px; color: #1a1a2e; letter-spacing: 2px;"">POWER OF ATTORNEY</h1>
    <p style=""margin: 4px 0 0; font-size: 14px; color: #666;"">Fullmakt</p>
    <p style=""margin: 10px 0 0; font-size: 12px; color: #888;"">
      Drawn up within the framework of Swedish law, in particular the Contracts Act (1915:218)
      and applicable regulations on electronic identification and signing.
    </p>
  </div>

  <!-- Parties -->
  <div style=""background: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 24px;"">
    <h3 style=""margin: 0 0 12px; color: #c5a028; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"">Parties / Parter</h3>

    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""flex: 1; min-width: 250px;"">
        <p style=""margin: 0; font-size: 12px; color: #888; text-transform: uppercase;"">Principal (Grantor) / Fullmaktsgivare</p>
        <p style=""margin: 4px 0 0; font-size: 16px; font-weight: 600;"">{{GrantorName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">ID: {{GrantorPersonalNumber}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Organisation: {{OrganizationName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Org. No: {{OrganizationNumber}}</p>
      </div>
      <div style=""flex: 1; min-width: 250px;"">
        <p style=""margin: 0; font-size: 12px; color: #888; text-transform: uppercase;"">Authorised Representative (Agent) / Fullmaktshavare</p>
        <p style=""margin: 4px 0 0; font-size: 16px; font-weight: 600;"">{{DelegateName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">ID: {{DelegatePersonalNumber}}</p>
      </div>
    </div>
  </div>

  <!-- Section 1: Purpose and Scope -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 1 &ndash; Purpose and Scope / Syfte och omfattning
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      The Principal hereby authorises the Agent to act independently on behalf of and for the account of the Principal
      in the following areas of activity:
    </p>
    <div style=""background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 16px; margin-top: 8px;"">
      <p style=""margin: 0; font-size: 14px; font-weight: 600; color: #1a1a2e;"">{{Operations}}</p>
    </div>
  </div>

  <!-- Section 2: Validity Period -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 2 &ndash; Validity Period / Giltighetstid
    </h3>
    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""background: #f0f7f0; border-radius: 8px; padding: 12px 16px; flex: 1; min-width: 150px;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Valid From / Giltig fr&aring;n</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600; color: #2d6a2d;"">{{ValidFrom}}</p>
      </div>
      <div style=""background: #fff0f0; border-radius: 8px; padding: 12px 16px; flex: 1; min-width: 150px;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Valid Until / Giltig till</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600; color: #a02d2d;"">{{ValidTo}}</p>
      </div>
    </div>
  </div>

  <!-- Section 3: Agent Obligations -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 3 &ndash; Agent&rsquo;s Obligations / Fullmaktshavarens skyldigheter
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">The Agent agrees and undertakes to:</p>
    <ul style=""font-size: 14px; line-height: 1.8; color: #333; padding-left: 20px;"">
      <li>Act in accordance with the interests of the Principal and applicable legislation;</li>
      <li>Inform the Principal regularly of the transactions carried out;</li>
      <li>Not transfer this power of attorney to third parties without the written consent of the Principal.</li>
    </ul>
  </div>

  <!-- Section 4: Revocation -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 4 &ndash; Revocation / &Aring;terkallelse
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      The Principal reserves the right to revoke this power of attorney at any time by written notice addressed to the Agent.
      The revocation shall take effect from the date on which the notice is received by the Agent.
    </p>
  </div>

  <!-- Section 5: Applicable Law -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 5 &ndash; Applicable Law / Till&auml;mplig lag
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      This power of attorney is governed by Swedish law. Disputes arising from this power of attorney shall be resolved
      in the Swedish general courts.
    </p>
  </div>

  <!-- Notes -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      Notes / Anteckningar
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #555; font-style: italic;"">{{Notes}}</p>
  </div>

  <!-- Signatures -->
  <div style=""background: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 24px;"">
    <h3 style=""margin: 0 0 16px; color: #c5a028; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"">
      Signatures / Underskrifter
    </h3>
    <p style=""font-size: 13px; line-height: 1.6; color: #555; margin-bottom: 16px;"">
      By signing with BankID, the signatory verifies their identity in accordance with the
      Anti-Money Laundering and Terrorist Financing Act (2017:630) and the eIDAS Regulation (EU) No 910/2014,
      and accepts all terms and conditions of this power of attorney.
    </p>

    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""flex: 1; min-width: 250px; background: #fff; border-radius: 8px; padding: 16px; border: 1px solid #e0e0e0;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Principal / Fullmaktsgivare</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600;"">{{GrantorName}}</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">BankID Electronic Signature:</p>
        <p style=""margin: 0; font-size: 12px; color: #c5a028; font-style: italic;"">[Automatically applied upon signing]</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">Signature Timestamp:</p>
        <p style=""margin: 0; font-size: 12px; color: #555;"">[Generated upon signing]</p>
      </div>
      <div style=""flex: 1; min-width: 250px; background: #fff; border-radius: 8px; padding: 16px; border: 1px solid #e0e0e0;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Agent / Fullmaktshavare</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600;"">{{DelegateName}}</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">BankID Electronic Signature:</p>
        <p style=""margin: 0; font-size: 12px; color: #c5a028; font-style: italic;"">[Automatically applied upon signing]</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">Signature Timestamp:</p>
        <p style=""margin: 0; font-size: 12px; color: #555;"">[Generated upon signing]</p>
      </div>
    </div>
  </div>

  <!-- QR Verification -->
  <div style=""text-align: center; margin-bottom: 24px; padding: 20px; border: 2px dashed #c5a028; border-radius: 8px;"">
    <p style=""margin: 0 0 8px; font-size: 12px; color: #888; text-transform: uppercase; letter-spacing: 1px;"">Verification / Verifiering</p>
    <p style=""margin: 0 0 4px; font-size: 13px; color: #555;"">Scan the QR code to verify this document</p>
    <p style=""margin: 0 0 4px; font-size: 13px; color: #555;"">Skanna QR-koden f&ouml;r att verifiera detta dokument</p>
    <p style=""margin: 0; font-size: 14px; font-weight: 600; color: #1a1a2e;"">Code: {{VerificationCode}}</p>
    <p style=""margin: 4px 0 0; font-size: 12px; color: #c5a028;"">{{QrCodeUrl}}</p>
  </div>

  <!-- Legal Notice -->
  <div style=""background: #fff8e1; border-radius: 8px; padding: 16px; border-left: 4px solid #c5a028;"">
    <p style=""margin: 0; font-size: 12px; color: #555; line-height: 1.6;"">
      <strong>&#9888;&#65039; Important Notice:</strong> This document has no legal validity until it is signed by both the
      Principal and the Agent with a valid Swedish BankID. The electronic signature and timestamp constitute
      complete evidence of the signature in accordance with applicable Swedish and European Union legislation.
    </p>
    <p style=""margin: 8px 0 0; font-size: 12px; color: #555; line-height: 1.6;"">
      <strong>&#9888;&#65039; Viktig information:</strong> Detta dokument har ingen juridisk giltighet f&ouml;rr&auml;n det har undertecknats
      av b&aring;de fullmaktsgivaren och fullmaktshavaren med ett giltigt svenskt BankID.
    </p>
  </div>

  <!-- Footer -->
  <div style=""text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0;"">
    <p style=""margin: 0; font-size: 11px; color: #999;"">
      Document version: {{DocumentVersion}} &bull; Created: {{CreatedAt}} &bull; Powered by Minion
    </p>
  </div>

</div>";

        private const string SwedishTemplate = @"
<div style=""font-family: 'Segoe UI', Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 40px; color: #1a1a2e;"">

  <!-- Header -->
  <div style=""text-align: center; border-bottom: 3px solid #c5a028; padding-bottom: 20px; margin-bottom: 30px;"">
    <h1 style=""margin: 0; font-size: 28px; color: #1a1a2e; letter-spacing: 2px;"">FULLMAKT</h1>
    <p style=""margin: 4px 0 0; font-size: 14px; color: #666;"">Power of Attorney</p>
    <p style=""margin: 10px 0 0; font-size: 12px; color: #888;"">
      Uppr&auml;ttad inom ramen f&ouml;r svensk r&auml;tt, s&auml;rskilt avtalslagen (1915:218)
      och g&auml;llande regler om elektronisk identifiering och undertecknande.
    </p>
  </div>

  <!-- Parties -->
  <div style=""background: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 24px;"">
    <h3 style=""margin: 0 0 12px; color: #c5a028; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"">Parter / Parties</h3>

    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""flex: 1; min-width: 250px;"">
        <p style=""margin: 0; font-size: 12px; color: #888; text-transform: uppercase;"">Fullmaktsgivare / Principal (Grantor)</p>
        <p style=""margin: 4px 0 0; font-size: 16px; font-weight: 600;"">{{GrantorName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Personnr: {{GrantorPersonalNumber}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Organisation: {{OrganizationName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Org.nr: {{OrganizationNumber}}</p>
      </div>
      <div style=""flex: 1; min-width: 250px;"">
        <p style=""margin: 0; font-size: 12px; color: #888; text-transform: uppercase;"">Fullmaktshavare / Authorised Representative</p>
        <p style=""margin: 4px 0 0; font-size: 16px; font-weight: 600;"">{{DelegateName}}</p>
        <p style=""margin: 2px 0 0; font-size: 13px; color: #555;"">Personnr: {{DelegatePersonalNumber}}</p>
      </div>
    </div>
  </div>

  <!-- Section 1: Purpose and Scope -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 1 &ndash; Syfte och omfattning / Purpose and Scope
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      Fullmaktsgivaren bemyndigar h&auml;rmed fullmaktshavaren att sj&auml;lvst&auml;ndigt agera p&aring; fullmaktsgivarens
      v&auml;gnar och f&ouml;r fullmaktsgivarens r&auml;kning inom f&ouml;ljande verksamhetsomr&aring;den:
    </p>
    <div style=""background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 16px; margin-top: 8px;"">
      <p style=""margin: 0; font-size: 14px; font-weight: 600; color: #1a1a2e;"">{{Operations}}</p>
    </div>
  </div>

  <!-- Section 2: Validity Period -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 2 &ndash; Giltighetstid / Validity Period
    </h3>
    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""background: #f0f7f0; border-radius: 8px; padding: 12px 16px; flex: 1; min-width: 150px;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Giltig fr&aring;n / Valid From</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600; color: #2d6a2d;"">{{ValidFrom}}</p>
      </div>
      <div style=""background: #fff0f0; border-radius: 8px; padding: 12px 16px; flex: 1; min-width: 150px;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Giltig till / Valid Until</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600; color: #a02d2d;"">{{ValidTo}}</p>
      </div>
    </div>
  </div>

  <!-- Section 3: Agent Obligations -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 3 &ndash; Fullmaktshavarens skyldigheter / Agent&rsquo;s Obligations
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">Fullmaktshavaren f&ouml;rbinder sig att:</p>
    <ul style=""font-size: 14px; line-height: 1.8; color: #333; padding-left: 20px;"">
      <li>Agera i enlighet med fullmaktsgivarens intressen och g&auml;llande lagstiftning;</li>
      <li>Regelbundet informera fullmaktsgivaren om genomf&ouml;rda transaktioner;</li>
      <li>Inte &ouml;verf&ouml;ra denna fullmakt till tredje part utan fullmaktsgivarens skriftliga medgivande.</li>
    </ul>
  </div>

  <!-- Section 4: Revocation -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 4 &ndash; &Aring;terkallelse / Revocation
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      Fullmaktsgivaren f&ouml;rbeh&aring;ller sig r&auml;tten att n&auml;r som helst &aring;terkalla denna fullmakt genom skriftligt
      meddelande till fullmaktshavaren. &Aring;terkallelsen tr&auml;der i kraft fr&aring;n den dag meddelandet tas emot
      av fullmaktshavaren.
    </p>
  </div>

  <!-- Section 5: Applicable Law -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      &sect; 5 &ndash; Till&auml;mplig lag / Applicable Law
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #333;"">
      Denna fullmakt lyder under svensk r&auml;tt. Tvister som uppst&aring;r med anledning av denna fullmakt
      ska avg&ouml;ras i allm&auml;n svensk domstol.
    </p>
  </div>

  <!-- Notes -->
  <div style=""margin-bottom: 24px;"">
    <h3 style=""color: #1a1a2e; font-size: 15px; border-left: 4px solid #c5a028; padding-left: 12px;"">
      Anteckningar / Notes
    </h3>
    <p style=""font-size: 14px; line-height: 1.6; color: #555; font-style: italic;"">{{Notes}}</p>
  </div>

  <!-- Signatures -->
  <div style=""background: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 24px;"">
    <h3 style=""margin: 0 0 16px; color: #c5a028; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"">
      Underskrifter / Signatures
    </h3>
    <p style=""font-size: 13px; line-height: 1.6; color: #555; margin-bottom: 16px;"">
      Genom att underteckna med BankID verifierar undertecknaren sin identitet i enlighet med lagen (2017:630)
      om &aring;tg&auml;rder mot penningtv&auml;tt och finansiering av terrorism samt eIDAS-f&ouml;rordningen (EU) nr 910/2014,
      och godk&auml;nner alla villkor i denna fullmakt.
    </p>

    <div style=""display: flex; gap: 20px; flex-wrap: wrap;"">
      <div style=""flex: 1; min-width: 250px; background: #fff; border-radius: 8px; padding: 16px; border: 1px solid #e0e0e0;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Fullmaktsgivare / Principal</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600;"">{{GrantorName}}</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">BankID elektronisk underskrift:</p>
        <p style=""margin: 0; font-size: 12px; color: #c5a028; font-style: italic;"">[Anv&auml;nds automatiskt vid signering]</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">Tidst&auml;mpel:</p>
        <p style=""margin: 0; font-size: 12px; color: #555;"">[Genereras vid signering]</p>
      </div>
      <div style=""flex: 1; min-width: 250px; background: #fff; border-radius: 8px; padding: 16px; border: 1px solid #e0e0e0;"">
        <p style=""margin: 0; font-size: 11px; color: #888; text-transform: uppercase;"">Fullmaktshavare / Agent</p>
        <p style=""margin: 4px 0 0; font-size: 15px; font-weight: 600;"">{{DelegateName}}</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">BankID elektronisk underskrift:</p>
        <p style=""margin: 0; font-size: 12px; color: #c5a028; font-style: italic;"">[Anv&auml;nds automatiskt vid signering]</p>
        <p style=""margin: 8px 0 2px; font-size: 11px; color: #888;"">Tidst&auml;mpel:</p>
        <p style=""margin: 0; font-size: 12px; color: #555;"">[Genereras vid signering]</p>
      </div>
    </div>
  </div>

  <!-- QR Verification -->
  <div style=""text-align: center; margin-bottom: 24px; padding: 20px; border: 2px dashed #c5a028; border-radius: 8px;"">
    <p style=""margin: 0 0 8px; font-size: 12px; color: #888; text-transform: uppercase; letter-spacing: 1px;"">Verifiering / Verification</p>
    <p style=""margin: 0 0 4px; font-size: 13px; color: #555;"">Skanna QR-koden f&ouml;r att verifiera detta dokument</p>
    <p style=""margin: 0 0 4px; font-size: 13px; color: #555;"">Scan the QR code to verify this document</p>
    <p style=""margin: 0; font-size: 14px; font-weight: 600; color: #1a1a2e;"">Kod: {{VerificationCode}}</p>
    <p style=""margin: 4px 0 0; font-size: 12px; color: #c5a028;"">{{QrCodeUrl}}</p>
  </div>

  <!-- Legal Notice -->
  <div style=""background: #fff8e1; border-radius: 8px; padding: 16px; border-left: 4px solid #c5a028;"">
    <p style=""margin: 0; font-size: 12px; color: #555; line-height: 1.6;"">
      <strong>&#9888;&#65039; Viktig information:</strong> Detta dokument har ingen juridisk giltighet f&ouml;rr&auml;n det har undertecknats
      av b&aring;de fullmaktsgivaren och fullmaktshavaren med ett giltigt svenskt BankID. Den elektroniska underskriften
      och tidst&auml;mpeln utg&ouml;r fullst&auml;ndigt bevis i enlighet med g&auml;llande svensk och europeisk lagstiftning.
    </p>
    <p style=""margin: 8px 0 0; font-size: 12px; color: #555; line-height: 1.6;"">
      <strong>&#9888;&#65039; Important Notice:</strong> This document has no legal validity until it is signed by both the
      Principal and the Agent with a valid Swedish BankID.
    </p>
  </div>

  <!-- Footer -->
  <div style=""text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0;"">
    <p style=""margin: 0; font-size: 11px; color: #999;"">
      Dokumentversion: {{DocumentVersion}} &bull; Skapad: {{CreatedAt}} &bull; Powered by Minion
    </p>
  </div>

</div>";
    }
}
