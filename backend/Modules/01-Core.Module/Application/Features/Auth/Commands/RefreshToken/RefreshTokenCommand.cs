using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.DTOs.Auth;

namespace Core.Module.Application.Features.Auth.Commands.RefreshToken
{
    public class RefreshTokenCommand : IRequest<Result<LoginResponse>>
    {
        public string RefreshToken { get; set; } = string.Empty;
    
        public string? IpAddress { get; set; } // أضف هذه}
}}