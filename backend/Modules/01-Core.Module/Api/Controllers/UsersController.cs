using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Core.Module.Application.Features.Users.Queries.GetUsers;
using Core.Module.Application.Features.Users.Queries.GetUserById;
using Core.Module.Application.Features.Users.Commands.CreateUser;
using Core.Module.Application.Features.Users.Commands.UpdateUser;
using Core.Module.Application.Features.Users.Commands.DeleteUser;
using Core.Module.Application.Features.Users.Commands.ActivateUser;
using Core.Module.Application.Features.Users.Commands.DeactivateUser;
using Core.Module.Application.Features.Users.Commands.AssignRole;

namespace Core.Module.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IMediator _mediator;

        public UsersController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet]
        public async Task<IActionResult> GetUsers([FromQuery] GetUsersQuery query)
        {
            var result = await _mediator.Send(query);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(int id)
        {
            var query = new GetUserByIdQuery { Id = id };
            var result = await _mediator.Send(query);
            
            if (!result.Succeeded)
                return NotFound(result);

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserCommand command)
        {
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetUserById), new { id = result.Data.Id }, result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserCommand command)
        {
            if (id != command.Id)
                return BadRequest("ID mismatch");

            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var command = new DeleteUserCommand { Id = id };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("{id}/activate")]
        public async Task<IActionResult> ActivateUser(int id)
        {
            var command = new ActivateUserCommand { Id = id };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("{id}/deactivate")]
        public async Task<IActionResult> DeactivateUser(int id)
        {
            var command = new DeactivateUserCommand { Id = id };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("{userId}/roles/{roleId}")]
        public async Task<IActionResult> AssignRole(int userId, int roleId)
        {
            var command = new AssignRoleCommand { UserId = userId, RoleId = roleId };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }
    }
}