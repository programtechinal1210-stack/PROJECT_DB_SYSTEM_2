using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Roles.Queries.GetRoleById
{
    public class GetRoleByIdQueryHandler : IRequestHandler<GetRoleByIdQuery, Result<RoleDetailDto>>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly ICacheService _cacheService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetRoleByIdQueryHandler> _logger;

        public GetRoleByIdQueryHandler(
            IRoleRepository roleRepository,
            ICacheService cacheService,
            IMapper mapper,
            ILogger<GetRoleByIdQueryHandler> logger)
        {
            _roleRepository = roleRepository;
            _cacheService = cacheService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<RoleDetailDto>> Handle(GetRoleByIdQuery request, CancellationToken cancellationToken)
        {
            try
            {
                // Try cache first
                var cacheKey = $"role_detail_{request.Id}";
                var cachedRole = await _cacheService.GetAsync<RoleDetailDto>(cacheKey, cancellationToken);

                if (cachedRole != null)
                {
                    return Result<RoleDetailDto>.Success(cachedRole);
                }

                var role = await _roleRepository.GetByIdAsync(request.Id);
                if (role == null)
                {
                    return Result<RoleDetailDto>.Failure($"Role with ID {request.Id} not found");
                }

                var roleDto = _mapper.Map<RoleDetailDto>(role);
                
                roleDto.Users = role.UserRoles.Select(ur => new RoleUserDto
                {
                    UserId = ur.UserId,
                    Username = ur.User?.Username,
                    Email = ur.User?.Email,
                    AssignedAt = ur.AssignedAt
                }).ToList();

                roleDto.Permissions = role.Permissions.Select(rp => new RolePermissionDto
                {
                    PermissionId = rp.PermissionId,
                    PermissionCode = rp.Permission?.PermissionCode,
                    PermissionName = rp.Permission?.PermissionName,
                    ModuleName = rp.Permission?.Module?.ModuleName,
                    GrantedAt = rp.GrantedAt
                }).ToList();

                // Cache for 5 minutes
                await _cacheService.SetAsync(cacheKey, roleDto, TimeSpan.FromMinutes(5), cancellationToken);

                return Result<RoleDetailDto>.Success(roleDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting role by ID {RoleId}", request.Id);
                return Result<RoleDetailDto>.Failure("An error occurred while retrieving role");
            }
        }
    }
}