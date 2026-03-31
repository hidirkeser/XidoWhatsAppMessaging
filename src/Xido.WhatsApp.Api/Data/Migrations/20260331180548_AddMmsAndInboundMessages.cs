using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Xido.WhatsApp.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMmsAndInboundMessages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MediaUrl",
                table: "MessageLogs",
                type: "TEXT",
                maxLength: 2048,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "InboundMessages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    FromPhone = table.Column<string>(type: "TEXT", maxLength: 30, nullable: false),
                    SenderName = table.Column<string>(type: "TEXT", maxLength: 200, nullable: true),
                    Body = table.Column<string>(type: "TEXT", maxLength: 4096, nullable: false),
                    MediaUrl = table.Column<string>(type: "TEXT", maxLength: 2048, nullable: true),
                    MediaType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    Provider = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    RawPayload = table.Column<string>(type: "TEXT", nullable: false),
                    ReceivedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InboundMessages", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_InboundMessages_FromPhone",
                table: "InboundMessages",
                column: "FromPhone");

            migrationBuilder.CreateIndex(
                name: "IX_InboundMessages_ReceivedAt",
                table: "InboundMessages",
                column: "ReceivedAt");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "InboundMessages");

            migrationBuilder.DropColumn(
                name: "MediaUrl",
                table: "MessageLogs");
        }
    }
}
