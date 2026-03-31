using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Minion.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class DelegationDocumentSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DelegationDocuments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    DelegationId = table.Column<Guid>(type: "uuid", nullable: false),
                    Language = table.Column<string>(type: "character varying(5)", maxLength: 5, nullable: false),
                    RenderedContent = table.Column<string>(type: "text", nullable: false),
                    DocumentVersion = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false, defaultValue: "Draft"),
                    GrantorApprovedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    GrantorSignature = table.Column<string>(type: "text", nullable: true),
                    DelegateApprovedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DelegateSignature = table.Column<string>(type: "text", nullable: true),
                    QrCodeData = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DelegationDocuments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DelegationDocuments_Delegations_DelegationId",
                        column: x => x.DelegationId,
                        principalTable: "Delegations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "DelegationDocumentTemplates",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    Language = table.Column<string>(type: "character varying(5)", maxLength: 5, nullable: false),
                    LanguageName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    TemplateContent = table.Column<string>(type: "text", nullable: false),
                    Version = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DelegationDocumentTemplates", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DelegationDocumentLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    DelegationDocumentId = table.Column<Guid>(type: "uuid", nullable: false),
                    ActorUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    ActorName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Action = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Details = table.Column<string>(type: "text", nullable: true),
                    IpAddress = table.Column<string>(type: "character varying(45)", maxLength: 45, nullable: true),
                    Timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DelegationDocumentLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DelegationDocumentLogs_DelegationDocuments_DelegationDocume~",
                        column: x => x.DelegationDocumentId,
                        principalTable: "DelegationDocuments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocumentLogs_ActorUserId_Timestamp",
                table: "DelegationDocumentLogs",
                columns: new[] { "ActorUserId", "Timestamp" },
                descending: new[] { false, true });

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocumentLogs_DelegationDocumentId",
                table: "DelegationDocumentLogs",
                column: "DelegationDocumentId");

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocumentLogs_Timestamp",
                table: "DelegationDocumentLogs",
                column: "Timestamp",
                descending: new bool[0]);

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocuments_DelegationId",
                table: "DelegationDocuments",
                column: "DelegationId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocuments_Status",
                table: "DelegationDocuments",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_DelegationDocumentTemplates_Language_IsActive",
                table: "DelegationDocumentTemplates",
                columns: new[] { "Language", "IsActive" },
                unique: true,
                filter: "\"IsActive\" = true");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DelegationDocumentLogs");

            migrationBuilder.DropTable(
                name: "DelegationDocumentTemplates");

            migrationBuilder.DropTable(
                name: "DelegationDocuments");
        }
    }
}
