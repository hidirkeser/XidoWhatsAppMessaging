using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.CorporateApplications.Commands;
using Minion.Application.Features.CorporateApplications.DTOs;
using Minion.Application.Features.CorporateApplications.Queries;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CorporateController : ControllerBase
{
    private readonly IMediator _mediator;

    public CorporateController(IMediator mediator) => _mediator = mediator;

    // ── OTP ──────────────────────────────────────────────────────────────────

    [HttpPost("otp/send")]
    [AllowAnonymous]
    public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request, CancellationToken ct)
    {
        await _mediator.Send(new SendCorporateOtpCommand(request.Phone), ct);
        return Ok(new { message = "OTP gönderildi." });
    }

    [HttpPost("otp/verify")]
    [AllowAnonymous]
    public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request, CancellationToken ct)
    {
        await _mediator.Send(new VerifyCorporateOtpCommand(request.Phone, request.Code), ct);
        return Ok(new { message = "Telefon doğrulandı." });
    }

    // ── Apply ─────────────────────────────────────────────────────────────────

    [HttpPost("apply")]
    [AllowAnonymous]
    public async Task<IActionResult> Apply([FromBody] SubmitCorporateApplicationRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new SubmitCorporateApplicationCommand(
            request.CompanyName, request.OrgNumber, request.ContactName,
            request.ContactEmail, request.ContactPhone, request.DocumentPaths,
            request.DocumentsJson), ct);

        return Created("", result);
    }

    // ── Resubmit (applicant uploads corrected documents) ────────────────────

    [HttpPost("applications/{id:guid}/resubmit")]
    [AllowAnonymous]
    public async Task<IActionResult> Resubmit(Guid id, [FromBody] ResubmitApplicationRequest request, CancellationToken ct)
    {
        await _mediator.Send(new ResubmitApplicationCommand(id, request.DocumentsJson), ct);
        return Ok(new { message = "Başvuru yeniden gönderildi." });
    }

    // ── Status (applicant checks own application) ─────────────────────────

    [HttpGet("applications/{id:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetStatus(Guid id, CancellationToken ct)
        => Ok(await _mediator.Send(new GetCorporateApplicationByIdQuery(id), ct));
}

[ApiController]
[Route("api/admin/corporate/applications")]
[Authorize(Policy = "AdminOnly")]
public class AdminCorporateController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAuditLogService _audit;

    public AdminCorporateController(IMediator mediator, IAuditLogService audit)
    {
        _mediator = mediator;
        _audit = audit;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] string? status, [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20, CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetCorporateApplicationsQuery(status, page, pageSize), ct));

    [HttpPost("{id:guid}/approve")]
    public async Task<IActionResult> Approve(Guid id, [FromBody] ReviewCorporateApplicationRequest? request, CancellationToken ct)
    {
        await _mediator.Send(new ApproveCorporateApplicationCommand(id, request?.ReviewNote), ct);
        await _audit.LogAsync(AuditAction.CorporateApplicationApprove,
            details: new { ApplicationId = id }, ct: ct);
        return Ok(new { message = "Application approved" });
    }

    [HttpPost("{id:guid}/reject")]
    public async Task<IActionResult> Reject(Guid id, [FromBody] ReviewCorporateApplicationRequest? request, CancellationToken ct)
    {
        await _mediator.Send(new RejectCorporateApplicationCommand(id, request?.ReviewNote), ct);
        await _audit.LogAsync(AuditAction.CorporateApplicationReject,
            details: new { ApplicationId = id }, ct: ct);
        return Ok(new { message = "Application rejected" });
    }

    [HttpPost("{id:guid}/request-documents")]
    public async Task<IActionResult> RequestDocuments(Guid id, [FromBody] RequestDocumentsRequest request, CancellationToken ct)
    {
        await _mediator.Send(new RequestDocumentsCommand(id, request.Note), ct);
        await _audit.LogAsync(AuditAction.CorporateApplicationReject,  // reuse closest audit action
            details: new { ApplicationId = id, Action = "DocumentsRequired" }, ct: ct);
        return Ok(new { message = "Document request sent" });
    }
}
