using FluentValidation;

namespace Minion.Application.Features.Delegations.Commands;

public class CreateDelegationCommandValidator : AbstractValidator<CreateDelegationCommand>
{
    public CreateDelegationCommandValidator()
    {
        RuleFor(x => x.DelegateUserId).NotEmpty().WithMessage("Delegate user is required.");
        RuleFor(x => x.OrganizationId).NotEmpty().WithMessage("Organization is required.");
        RuleFor(x => x.OperationTypeIds).NotEmpty().WithMessage("At least one operation type is required.");
        RuleFor(x => x.DurationType).NotEmpty().WithMessage("Duration type is required.");

        When(x => x.DurationType != "range", () =>
        {
            RuleFor(x => x.DurationValue).NotNull().GreaterThan(0)
                .WithMessage("Duration value must be greater than 0.");
        });

        When(x => x.DurationType == "range", () =>
        {
            RuleFor(x => x.DateFrom).NotNull().WithMessage("Start date is required for date range.");
            RuleFor(x => x.DateTo).NotNull().WithMessage("End date is required for date range.");
            RuleFor(x => x.DateTo).GreaterThan(x => x.DateFrom)
                .When(x => x.DateFrom.HasValue && x.DateTo.HasValue)
                .WithMessage("End date must be after start date.");
        });
    }
}
