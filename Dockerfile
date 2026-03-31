# ── Build stage ──────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Xido.WhatsApp.sln .
COPY src/Xido.WhatsApp.Api/Xido.WhatsApp.Api.csproj src/Xido.WhatsApp.Api/

RUN dotnet restore Xido.WhatsApp.sln

COPY . .
RUN dotnet publish src/Xido.WhatsApp.Api/Xido.WhatsApp.Api.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser  --system --uid 1001 --ingroup appgroup appuser

# SQLite DB directory
RUN mkdir -p /app/data && chown appuser:appgroup /app/data

COPY --from=build /app/publish .
RUN chown -R appuser:appgroup /app

USER appuser

ENV ASPNETCORE_URLS=http://+:$PORT
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ConnectionStrings__DefaultConnection="Data Source=/app/data/xido_whatsapp.db"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:${PORT:-8080}/health || exit 1

ENTRYPOINT ["dotnet", "Xido.WhatsApp.Api.dll"]
