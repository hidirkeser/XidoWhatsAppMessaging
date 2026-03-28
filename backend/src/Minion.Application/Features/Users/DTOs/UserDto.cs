namespace Minion.Application.Features.Users.DTOs;

public record UserDto(
    Guid Id,
    string PersonalNumber,
    string FirstName,
    string LastName,
    string? Email,
    string? Phone,
    bool IsAdmin,
    bool IsActive,
    DateTime CreatedAt,
    DateTime? LastLoginAt);

public record UserSearchResultDto(
    Guid Id,
    string PersonalNumber,
    string FirstName,
    string LastName,
    string? Email);

public record UpdateProfileRequest(string? Email, string? Phone);
