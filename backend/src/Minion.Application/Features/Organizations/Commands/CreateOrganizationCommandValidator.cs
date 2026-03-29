using FluentValidation;

namespace Minion.Application.Features.Organizations.Commands;

public class CreateOrganizationCommandValidator : AbstractValidator<CreateOrganizationCommand>
{
    public CreateOrganizationCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200)
            .WithErrorCode("ORG_NAME_REQUIRED")
            .WithMessage("Organization name is required (max 200 chars).");

        RuleFor(x => x.OrgNumber).NotEmpty().MaximumLength(20)
            .WithErrorCode("ORG_NUMBER_REQUIRED")
            .WithMessage("Organization number is required.");

        RuleFor(x => x.ContactEmail)
            .EmailAddress().When(x => !string.IsNullOrEmpty(x.ContactEmail))
            .WithErrorCode("INVALID_EMAIL")
            .WithMessage("Invalid email format.");
    }
}
