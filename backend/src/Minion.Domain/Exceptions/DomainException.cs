namespace Minion.Domain.Exceptions;

public class DomainException : Exception
{
    public DomainException(string message) : base(message) { }
}

public class InsufficientCreditsException : DomainException
{
    public int Required { get; }
    public int Available { get; }

    public InsufficientCreditsException(int required, int available)
        : base($"Insufficient credits. Required: {required}, Available: {available}")
    {
        Required = required;
        Available = available;
    }
}

public class NotFoundException : DomainException
{
    public NotFoundException(string entityName, object key)
        : base($"{entityName} with key '{key}' was not found.") { }
}

public class ForbiddenException : DomainException
{
    public ForbiddenException(string message = "You do not have permission to perform this action.")
        : base(message) { }
}
