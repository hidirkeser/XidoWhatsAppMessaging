using FluentValidation;

namespace Minion.Application.Features.OperationTypes.Commands;

public class CreateOperationTypeCommandValidator : AbstractValidator<CreateOperationTypeCommand>
{
    public CreateOperationTypeCommandValidator()
    {
        RuleFor(x => x.OrganizationId).NotEmpty().WithMessage("Organization is required.");
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200).WithMessage("Operation type name is required (max 200 chars).");
        RuleFor(x => x.CreditCost).GreaterThanOrEqualTo(0).WithMessage("Credit cost must be 0 or more.");
    }
}
