using FluentValidation;

namespace Minion.Application.Features.Delegations.Commands;

public class CreateDelegationCommandValidator : AbstractValidator<CreateDelegationCommand>
{
    public CreateDelegationCommandValidator()
    {
        RuleFor(x => x.DelegateUserId).NotEmpty()
            .WithErrorCode("DELEGATE_USER_REQUIRED")
            .WithMessage("Delegate user is required.");

        RuleFor(x => x.OrganizationId).NotEmpty()
            .WithErrorCode("ORGANIZATION_REQUIRED")
            .WithMessage("Organization is required.");

        RuleFor(x => x.OperationTypeIds).NotEmpty()
            .WithErrorCode("OPERATION_TYPES_REQUIRED")
            .WithMessage("At least one operation type is required.");

        RuleFor(x => x.DurationType).NotEmpty()
            .WithErrorCode("DURATION_TYPE_REQUIRED")
            .WithMessage("Duration type is required.");

        When(x => x.DurationType != "range", () =>
        {
            RuleFor(x => x.DurationValue).NotNull().GreaterThan(0)
                .WithErrorCode("DURATION_VALUE_INVALID")
                .WithMessage("Duration value must be greater than 0.");
        });

        When(x => x.DurationType == "range", () =>
        {
            RuleFor(x => x.DateFrom).NotNull()
                .WithErrorCode("START_DATE_REQUIRED")
                .WithMessage("Start date is required for date range.");

            RuleFor(x => x.DateTo).NotNull()
                .WithErrorCode("END_DATE_REQUIRED")
                .WithMessage("End date is required for date range.");

            RuleFor(x => x.DateTo).GreaterThan(x => x.DateFrom)
                .When(x => x.DateFrom.HasValue && x.DateTo.HasValue)
                .WithErrorCode("END_DATE_BEFORE_START")
                .WithMessage("End date must be after start date.");
        });
    }
}
