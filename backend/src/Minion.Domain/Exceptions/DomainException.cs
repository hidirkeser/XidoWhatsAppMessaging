namespace Minion.Domain.Exceptions;

public class DomainException : Exception
{
    public string? ErrorCode { get; }

    public DomainException(string message, string? errorCode = null) : base(message)
    {
        ErrorCode = errorCode;
    }
}

public class ValidationException : DomainException
{
    public IReadOnlyList<ValidationError> Errors { get; }

    public ValidationException(IEnumerable<(string Code, string Message)> failures)
        : base(string.Join("; ", failures.Select(f => f.Message)), "VALIDATION_ERROR")
    {
        Errors = failures.Select(f => new ValidationError(f.Code, f.Message)).ToList();
    }
}

public record ValidationError(string Code, string Message);

public class InsufficientCreditsException : DomainException
{
    public int Required { get; }
    public int Available { get; }

    public InsufficientCreditsException(int required, int available)
        : base($"Insufficient credits. Required: {required}, Available: {available}", "INSUFFICIENT_CREDITS")
    {
        Required = required;
        Available = available;
    }
}

public class NotFoundException : DomainException
{
    public NotFoundException(string entityName, object key)
        : base($"{entityName} with key '{key}' was not found.", "NOT_FOUND") { }
}

public class ForbiddenException : DomainException
{
    public ForbiddenException(string message = "You do not have permission to perform this action.", string errorCode = "FORBIDDEN")
        : base(message, errorCode) { }
}

public class QuotaExhaustedException : DomainException
{
    public int Used { get; }
    public int Limit { get; }

    public QuotaExhaustedException(int used, int limit)
        : base($"Quota exhausted. Used: {used}, Limit: {limit}", "QUOTA_EXHAUSTED")
    {
        Used = used;
        Limit = limit;
    }
}
