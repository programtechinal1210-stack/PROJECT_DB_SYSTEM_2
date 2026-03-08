using System.Threading.Tasks;
using Core.Module.Application.DTOs.Auth;

namespace Core.Module.Application.Interfaces
{
    public interface IAuthenticationService
    {
        Task<AuthResponseDto> LoginAsync(LoginRequestDto request, string ipAddress, string userAgent);
        Task<AuthResponseDto> RefreshTokenAsync(string refreshToken, string ipAddress);
        Task<bool> LogoutAsync(string sessionToken);
        Task<bool> LogoutAllAsync(int userId);
        Task<AuthResponseDto> ChangePasswordAsync(int userId, ChangePasswordDto request);
        Task<bool> ResetPasswordAsync(ResetPasswordDto request);
        Task<bool> ForgotPasswordAsync(ForgotPasswordDto request);
        Task<bool> ValidateTokenAsync(string token);
    }
}