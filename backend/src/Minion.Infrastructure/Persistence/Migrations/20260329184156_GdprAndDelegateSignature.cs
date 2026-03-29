using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Minion.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class GdprAndDelegateSignature : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "GdprConsentAcceptedAt",
                table: "Users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GdprConsentVersion",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "MarketingConsentAccepted",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "DelegateSignOrderRef",
                table: "Delegations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DelegateSignature",
                table: "Delegations",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GdprConsentAcceptedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "GdprConsentVersion",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "MarketingConsentAccepted",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DelegateSignOrderRef",
                table: "Delegations");

            migrationBuilder.DropColumn(
                name: "DelegateSignature",
                table: "Delegations");
        }
    }
}
