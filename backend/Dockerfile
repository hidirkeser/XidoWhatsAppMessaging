# ─── Build stage ──────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore only the API + its dependencies (skip test projects)
COPY src/Minion.Domain/Minion.Domain.csproj             src/Minion.Domain/
COPY src/Minion.Application/Minion.Application.csproj   src/Minion.Application/
COPY src/Minion.Infrastructure/Minion.Infrastructure.csproj src/Minion.Infrastructure/
COPY src/Minion.Api/Minion.Api.csproj                   src/Minion.Api/
RUN dotnet restore src/Minion.Api/Minion.Api.csproj

# Copy all sources and publish
COPY src/ src/
RUN dotnet publish src/Minion.Api/Minion.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ─── Runtime stage ────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# Non-root user for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

EXPOSE 8080
# ASPNETCORE_ENVIRONMENT is set via Railway environment variables per service
# Production service: ASPNETCORE_ENVIRONMENT=Production
# Staging service:    ASPNETCORE_ENVIRONMENT=Staging

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Use shell form so Railway's $PORT env var is expanded at runtime
CMD ASPNETCORE_URLS=http://+:${PORT:-8080} dotnet Minion.Api.dll
