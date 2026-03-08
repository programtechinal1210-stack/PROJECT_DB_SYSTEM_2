using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Auth.Commands.Logout
{
    public class LogoutCommand : IRequest<Result>
    {
        public string SessionToken { get; set; }
        public int UserId { get; set; }
    }
}