using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Minion.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class WebProductsAndI18nFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Badge",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BadgeSv",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionSv",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FeaturesSv",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameSv",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Badge",
                table: "CreditPackages",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BadgeSv",
                table: "CreditPackages",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionSv",
                table: "CreditPackages",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameSv",
                table: "CreditPackages",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "WebProducts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    Slug = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Icon = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Color = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    NameEn = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    DescriptionEn = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    FeaturesEn = table.Column<string>(type: "jsonb", nullable: false),
                    NameSv = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    DescriptionSv = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    FeaturesSv = table.Column<string>(type: "jsonb", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WebProducts", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_WebProducts_Slug",
                table: "WebProducts",
                column: "Slug",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "WebProducts");

            migrationBuilder.DropColumn(
                name: "Badge",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "BadgeSv",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DescriptionSv",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "FeaturesSv",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "NameSv",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "Badge",
                table: "CreditPackages");

            migrationBuilder.DropColumn(
                name: "BadgeSv",
                table: "CreditPackages");

            migrationBuilder.DropColumn(
                name: "DescriptionSv",
                table: "CreditPackages");

            migrationBuilder.DropColumn(
                name: "NameSv",
                table: "CreditPackages");
        }
    }
}
