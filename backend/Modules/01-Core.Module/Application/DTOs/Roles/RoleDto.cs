using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.DTOs.Roles
{
    public class RoleDto : IMapFrom<Role>
    {
        public int Id { get; set; }
        public string RoleName { get; set; }
        public string RoleDescription { get; set; }
        public bool IsSystemRole { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public int UsersCount { get; set; }
        public int PermissionsCount { get; set; }
            public List<PermissionDto>? Permissions { get; set; } // أضف هذه الخاصية
    }

    public class RoleDetailsDto : RoleDto
    {
        public List<UserBasicDto> Users { get; set; }
        public List<PermissionDto> Permissions { get; set; }
    }

    public class RoleBasicDto
    {
        public int Id { get; set; }
        public string RoleName { get; set; }
        public string RoleDescription { get; set; }
    }

    public class UserBasicDto
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public DateTime AssignedAt { get; set; }
    }
}