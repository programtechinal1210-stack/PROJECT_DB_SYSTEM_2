using System.Threading.Tasks;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.Common.Interfaces
{
    public interface ITokenService
    {
        string GenerateAccessToken(User user);
        string GenerateRefreshToken();
        Task<bool> ValidateAccessTokenAsync(string token);
        Task<int?> GetUserIdFromTokenAsync(string token);
        Task<RefreshTokenInfo> ValidateRefreshTokenAsync(string refreshToken);
    }

    public class RefreshTokenInfo
    {
        public int UserId { get; set; }
        public string Token { get; set; }
        public bool IsValid { get; set; }
    }
}