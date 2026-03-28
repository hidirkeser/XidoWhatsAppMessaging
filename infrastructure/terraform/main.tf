terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "project_name" {
  default = "minion"
}

variable "location" {
  default = "swedencentral"
}

variable "environment" {
  default = "dev"
}

locals {
  resource_prefix = "${var.project_name}-${var.environment}"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "plan-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# App Service (Backend API)
resource "azurerm_linux_web_app" "api" {
  name                = "app-${local.resource_prefix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT"                = var.environment == "prod" ? "Production" : "Development"
    "ConnectionStrings__DefaultConnection"  = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.main.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${var.sql_admin_password};Encrypt=true;TrustServerCertificate=false;"
    "Jwt__Secret"                           = var.jwt_secret
    "Jwt__Issuer"                           = "Minion"
    "Jwt__Audience"                         = "Minion"
    "BankId__BaseUrl"                       = "https://appapi2.test.bankid.com/rp/v6.0/"
  }
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "sql-${local.resource_prefix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "minionadmin"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "main" {
  name      = "MinionDb"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "Basic"
}

# Allow Azure services to access SQL
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# SignalR Service
resource "azurerm_signalr_service" "main" {
  name                = "signalr-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  cors {
    allowed_origins = ["*"]
  }
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "ai-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
}

# Variables (sensitive)
variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

# Outputs
output "api_url" {
  value = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "signalr_connection_string" {
  value     = azurerm_signalr_service.main.primary_connection_string
  sensitive = true
}

output "app_insights_key" {
  value     = azurerm_application_insights.main.instrumentation_key
  sensitive = true
}
