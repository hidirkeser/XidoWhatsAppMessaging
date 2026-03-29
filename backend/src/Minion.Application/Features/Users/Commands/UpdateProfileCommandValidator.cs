using FluentValidation;

namespace Minion.Application.Features.Users.Commands;

public class UpdateProfileCommandValidator : AbstractValidator<UpdateProfileCommand>
{
    public UpdateProfileCommandValidator()
    {
        RuleFor(x => x.Email)
            .EmailAddress().When(x => !string.IsNullOrEmpty(x.Email))
            .WithErrorCode("INVALID_EMAIL")
            .WithMessage("Invalid email format.");

        RuleFor(x => x.Phone)
            .Matches(@"^\+?[\d\s-]{7,15}$").When(x => !string.IsNullOrEmpty(x.Phone))
            .WithErrorCode("INVALID_PHONE")
            .WithMessage("Invalid phone number format.");
    }
}
