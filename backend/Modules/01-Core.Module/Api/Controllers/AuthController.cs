using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Core.Module.Application.Features.Auth.Commands.Login;
using Core.Module.Application.Features.Auth.Commands.RefreshToken;
using Core.Module.Application.Features.Auth.Commands.Logout;
using Core.Module.Application.Features.Auth.Queries.GetCurrentUser;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly ICurrentUserService _currentUser;

        public AuthController(IMediator mediator, ICurrentUserService currentUser)
        {
            _mediator = mediator;
            _currentUser = currentUser;
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginCommand command)
        {
            command.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            command.UserAgent = Request.Headers["User-Agent"].ToString();

            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenCommand command)
        {
            command.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var command = new LogoutCommand
            {
                SessionToken = Request.Headers["Authorization"].ToString().Replace("Bearer ", ""),
                UserId = _currentUser.UserId.Value
            };

            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpGet("current")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUser()
        {
            var query = new GetCurrentUserQuery();
            var result = await _mediator.Send(query);
            
            if (!result.Succeeded)
                return NotFound(result);

            return Ok(result);
        }

        [HttpGet("check-permission/{permissionCode}")]
        [Authorize]
        public IActionResult CheckPermission(string permissionCode)
        {
            var hasPermission = _currentUser.HasPermission(permissionCode);
            return Ok(new { hasPermission });
        }

        [HttpGet("permissions")]
        [Authorize]
        public IActionResult GetUserPermissions()
        {
            return Ok(_currentUser.Permissions);
        }
    }
}