using FluentValidation;

namespace Minion.Application.Features.Organizations.Commands;

public class CreateOrganizationCommandValidator : AbstractValidator<CreateOrganizationCommand>
{
    public CreateOrganizationCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200).WithMessage("Organization name is required (max 200 chars).");
        RuleFor(x => x.OrgNumber).NotEmpty().MaximumLength(20).WithMessage("Organization number is required.");
        RuleFor(x => x.ContactEmail)
            .EmailAddress().When(x => !string.IsNullOrEmpty(x.ContactEmail))
            .WithMessage("Invalid email format.");
    }
}
