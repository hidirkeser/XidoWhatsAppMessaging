using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Documents.Commands;
using Minion.Application.Features.Documents.DTOs;
using Minion.Application.Features.Documents.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/delegations/{delegationId:guid}/document")]
[Authorize]
public class DocumentsController : ControllerBase
{
    private readonly IMediator _mediator;
    public DocumentsController(IMediator mediator) => _mediator = mediator;

    /// <summary>Generate a document for a delegation.</summary>
    [HttpPost("generate")]
    public async Task<IActionResult> Generate(Guid delegationId, [FromQuery] string language = "tr", CancellationToken ct = default)
    {
        var result = await _mediator.Send(new GenerateDelegationDocumentCommand(delegationId, language), ct);
        return Ok(result);
    }

    /// <summary>Get the document for a delegation.</summary>
    [HttpGet]
    public async Task<IActionResult> Get(Guid delegationId, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetDelegationDocumentQuery(delegationId), ct);
        return Ok(result);
    }

    /// <summary>Approve the document (grantor or delegate, with BankID signature).</summary>
    [HttpPost("approve")]
    public async Task<IActionResult> Approve(Guid delegationId, [FromBody] ApproveDocumentRequest request, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        await _mediator.Send(new ApproveDocumentCommand(delegationId, request.BankIdSignature, ip), ct);
        return Ok(new { message = "Document approved." });
    }

    /// <summary>Reject the document.</summary>
    [HttpPost("reject")]
    public async Task<IActionResult> Reject(Guid delegationId, [FromBody] RejectDocumentRequest request, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        await _mediator.Send(new RejectDocumentCommand(delegationId, request.Reason, ip), ct);
        return Ok(new { message = "Document rejected." });
    }

    /// <summary>Share document with 3rd party (QR, link, or notification).</summary>
    [HttpPost("share")]
    public async Task<IActionResult> Share(Guid delegationId, [FromBody] ShareDocumentRequest request, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _mediator.Send(new ShareDocumentCommand(
            delegationId, request.ShareMethod, request.RecipientPhone, request.RecipientEmail, ip), ct);
        return Ok(result);
    }

    /// <summary>Get document change logs.</summary>
    [HttpGet("logs")]
    public async Task<IActionResult> GetLogs(Guid delegationId, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetDocumentLogsQuery(delegationId), ct);
        return Ok(result);
    }
}

/// <summary>Public endpoints — no auth. Accessed via QR code / verification code.</summary>
[ApiController]
[Route("api/verify/{code}/document")]
public class PublicDocumentController : ControllerBase
{
    private readonly IMediator _mediator;
    public PublicDocumentController(IMediator mediator) => _mediator = mediator;

    /// <summary>View document via QR scan (public, no auth).</summary>
    [HttpGet]
    public async Task<IActionResult> GetByCode(string code, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _mediator.Send(new GetDocumentByVerificationCodeQuery(code, ip), ct);
        return Ok(result);
    }

    /// <summary>3rd party verifies document with BankID (public, no auth).</summary>
    [HttpPost("verify")]
    public async Task<IActionResult> VerifyByThirdParty(
        string code,
        [FromBody] ThirdPartyVerifyRequest request,
        CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        await _mediator.Send(new VerifyDocumentByThirdPartyCommand(
            code, request.VerifierName, request.VerifierPersonalNumber, ip), ct);
        return Ok(new { message = "Document verified by third party." });
    }

    /// <summary>Share document via WhatsApp or Email (public, no auth, rate-limited).</summary>
    [HttpPost("share")]
    public async Task<IActionResult> SharePublic(
        string code,
        [FromBody] PublicShareDocumentRequest request,
        CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        await _mediator.Send(new ShareDocumentPublicCommand(
            code, request.Method, request.RecipientPhone, request.RecipientEmail, request.SenderName, ip), ct);
        return Ok(new { message = "Document shared successfully." });
    }
}

public record ThirdPartyVerifyRequest(string VerifierName, string VerifierPersonalNumber);

public record PublicShareDocumentRequest(
    string Method,           // "whatsapp" or "email"
    string? RecipientPhone,
    string? RecipientEmail,
    string SenderName);
