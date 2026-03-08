using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Core.Module.Application.Features.Roles.Queries.GetRoles;
using Core.Module.Application.Features.Roles.Queries.GetRoleById;
using Core.Module.Application.Features.Roles.Commands.CreateRole;
using Core.Module.Application.Features.Roles.Commands.UpdateRole;
using Core.Module.Application.Features.Roles.Commands.DeleteRole;
using Core.Module.Application.Features.Roles.Commands.AssignPermission;

namespace Core.Module.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RolesController : ControllerBase
    {
        private readonly IMediator _mediator;

        public RolesController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet]
        public async Task<IActionResult> GetRoles([FromQuery] GetRolesQuery query)
        {
            var result = await _mediator.Send(query);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetRoleById(int id)
        {
            var query = new GetRoleByIdQuery { Id = id };
            var result = await _mediator.Send(query);
            
            if (!result.Succeeded)
                return NotFound(result);

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> CreateRole([FromBody] CreateRoleCommand command)
        {
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetRoleById), new { id = result.Data.Id }, result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRole(int id, [FromBody] UpdateRoleCommand command)
        {
            if (id != command.Id)
                return BadRequest("ID mismatch");

            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRole(int id)
        {
            var command = new DeleteRoleCommand { Id = id };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("{roleId}/permissions/{permissionId}")]
        public async Task<IActionResult> AssignPermission(int roleId, int permissionId)
        {
            var command = new AssignPermissionCommand { RoleId = roleId, PermissionId = permissionId };
            var result = await _mediator.Send(command);
            
            if (!result.Succeeded)
                return BadRequest(result);

            return Ok(result);
        }
    }
}