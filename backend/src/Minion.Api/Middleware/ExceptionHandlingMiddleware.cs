using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;
using Minion.Domain.Exceptions;

namespace Minion.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try { await _next(context); }
        catch (Exception ex) { await HandleExceptionAsync(context, ex); }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        HttpStatusCode statusCode;
        string errorCode;
        string message;
        IReadOnlyList<ValidationError>? validationErrors = null;

        switch (exception)
        {
            case ValidationException ve:
                statusCode = HttpStatusCode.BadRequest;
                errorCode  = "VALIDATION_ERROR";
                message    = ve.Message;
                validationErrors = ve.Errors;
                _logger.LogWarning(ve, "Validation failed: {Message}", ve.Message);
                break;

            case NotFoundException nfe:
                statusCode = HttpStatusCode.NotFound;
                errorCode  = nfe.ErrorCode ?? "NOT_FOUND";
                message    = nfe.Message;
                _logger.LogWarning(nfe, "Not found: {Message}", nfe.Message);
                break;

            case InsufficientCreditsException ice:
                statusCode = HttpStatusCode.PaymentRequired;
                errorCode  = "INSUFFICIENT_CREDITS";
                message    = ice.Message;
                _logger.LogWarning(ice, "Insufficient credits");
                break;

            case QuotaExhaustedException qe:
                statusCode = HttpStatusCode.Forbidden;
                errorCode  = "QUOTA_EXHAUSTED";
                message    = qe.Message;
                _logger.LogWarning(qe, "Quota exhausted");
                break;

            case ForbiddenException fe:
                statusCode = HttpStatusCode.Forbidden;
                errorCode  = fe.ErrorCode ?? "FORBIDDEN";
                message    = fe.Message;
                _logger.LogWarning(fe, "Forbidden: {Message}", fe.Message);
                break;

            case DomainException de:
                statusCode = HttpStatusCode.BadRequest;
                errorCode  = de.ErrorCode ?? "DOMAIN_ERROR";
                message    = de.Message;
                _logger.LogWarning(de, "Domain error: {Message}", de.Message);
                break;

            case UnauthorizedAccessException:
                statusCode = HttpStatusCode.Unauthorized;
                errorCode  = "UNAUTHORIZED";
                message    = "Unauthorized";
                _logger.LogWarning(exception, "Unauthorized access");
                break;

            default:
                statusCode = HttpStatusCode.InternalServerError;
                errorCode  = "INTERNAL_ERROR";
                message    = "An unexpected error occurred";
                _logger.LogError(exception, "Unhandled exception");
                break;
        }

        context.Response.ContentType = "application/json";
        context.Response.StatusCode  = (int)statusCode;

        object response = validationErrors != null
            ? new { errorCode, errors = validationErrors, statusCode = (int)statusCode }
            : new { errorCode, error = message, statusCode = (int)statusCode };

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, JsonOpts));
    }
}
