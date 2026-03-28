using FluentValidation;

namespace Minion.Application.Features.Credits.Commands;

public class PurchaseCreditsCommandValidator : AbstractValidator<PurchaseCreditsCommand>
{
    private static readonly string[] ValidProviders = { "swish", "paypal", "klarna" };

    public PurchaseCreditsCommandValidator()
    {
        RuleFor(x => x.CreditPackageId).NotEmpty().WithMessage("Credit package is required.");
        RuleFor(x => x.Provider).NotEmpty()
            .Must(p => ValidProviders.Contains(p.ToLower()))
            .WithMessage("Provider must be one of: Swish, PayPal, Klarna.");
    }
}
