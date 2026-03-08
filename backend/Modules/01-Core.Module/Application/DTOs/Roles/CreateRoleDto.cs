using System.ComponentModel.DataAnnotations;

namespace Core.Module.Application.DTOs.Roles
{
    public class CreateRoleDto
    {
        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string RoleName { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        public bool IsSystemRole { get; set; }

        public List<int> PermissionIds { get; set; } = new();
    }

    public class UpdateRoleDto
    {
        [Required]
        public int Id { get; set; }

        [StringLength(50, MinimumLength = 3)]
        public string RoleName { get; set; }

        [StringLength(500)]
        public string Description { get; set; }
    }

    public class AssignPermissionsDto
    {
        [Required]
        public int RoleId { get; set; }

        [Required]
        public List<int> PermissionIds { get; set; }
    }

    public class RoleFilterDto
    {
        public string SearchTerm { get; set; }
        public bool? IsSystemRole { get; set; }
        public int? PermissionId { get; set; }
        public string SortBy { get; set; } = "RoleName";
        public bool SortDescending { get; set; }
    }
}