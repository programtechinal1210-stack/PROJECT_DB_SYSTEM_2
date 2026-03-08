using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;
namespace Core.Module.Application.Features.Roles.Commands.CreateRole
{using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs.Roles;
    public class CreateRoleCommandHandler : IRequestHandler<CreateRoleCommand, Result<RoleDto>>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly IPermissionRepository _permissionRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly IMapper _mapper;
        private readonly ILogger<CreateRoleCommandHandler> _logger;

        public CreateRoleCommandHandler(
            IRoleRepository roleRepository,
            IPermissionRepository permissionRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            IMapper mapper,
            ILogger<CreateRoleCommandHandler> logger)
        {
            _roleRepository = roleRepository;
            _permissionRepository = permissionRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<RoleDto>> Handle(CreateRoleCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // Check if role exists
                if (await _roleRepository.ExistsByNameAsync(request.RoleName))
                {
                    return Result<RoleDto>.Failure($"Role {request.RoleName} already exists");
                }

                // Create role
                var role = new Role(request.RoleName, request.Description, request.IsSystemRole);
role.SetUpdatedBy(_currentUser.UserId.ToString());

                var createdRole = await _roleRepository.AddAsync(role);

                // Add permissions
                if (request.PermissionIds?.Any() == true)
                {
                    foreach (var permissionId in request.PermissionIds)
                    {
                        var permission = await _permissionRepository.GetByIdAsync(permissionId);
                        if (permission != null)
                        {
                            createdRole.AddPermission(permission, _currentUser.UserId);
                        }
                    }
                    await _roleRepository.UpdateAsync(createdRole);
                }

                // Clear roles cache
                await _cacheService.RemoveAsync("roles_list", cancellationToken);

                _logger.LogInformation("Role {RoleName} created by {CreatorId}", 
                    createdRole.RoleName, _currentUser.UserId);

                var roleDto = _mapper.Map<RoleDto>(createdRole);
                roleDto.UsersCount = 0;
                roleDto.PermissionsCount = createdRole.Permissions.Count;

                return Result<RoleDto>.Success(roleDto, "Role created successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating role {RoleName}", request.RoleName);
                return Result<RoleDto>.Failure("An error occurred while creating role");
            }
        }
    }
}