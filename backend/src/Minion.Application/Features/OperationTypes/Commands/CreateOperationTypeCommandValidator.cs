using FluentValidation;

namespace Minion.Application.Features.OperationTypes.Commands;

public class CreateOperationTypeCommandValidator : AbstractValidator<CreateOperationTypeCommand>
{
    public CreateOperationTypeCommandValidator()
    {
        RuleFor(x => x.OrganizationId).NotEmpty()
            .WithErrorCode("ORGANIZATION_REQUIRED")
            .WithMessage("Organization is required.");

        RuleFor(x => x.Name).NotEmpty().MaximumLength(200)
            .WithErrorCode("OPERATION_NAME_REQUIRED")
            .WithMessage("Operation type name is required (max 200 chars).");

        RuleFor(x => x.CreditCost).GreaterThanOrEqualTo(0)
            .WithErrorCode("CREDIT_COST_INVALID")
            .WithMessage("Credit cost must be 0 or more.");
    }
}
