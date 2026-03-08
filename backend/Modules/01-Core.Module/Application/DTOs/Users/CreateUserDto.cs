using System.ComponentModel.DataAnnotations;

namespace Core.Module.Application.DTOs.Users
{
    public class CreateUserDto
    {
        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string Username { get; set; }

        [Required]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; }

        [Required]
        [StringLength(100, MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [Required]
        [Compare("Password")]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set; }

        public int? EmployeeId { get; set; }

        public List<int> RoleIds { get; set; } = new();
    }

    public class UpdateUserDto
    {
        [StringLength(50, MinimumLength = 3)]
        public string Username { get; set; }

        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; }

        [StringLength(100, MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [Compare("Password")]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set; }

        public bool? IsActive { get; set; }
    }

    public class AssignRolesDto
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public List<int> RoleIds { get; set; }
    }

    public class UserFilterDto
    {
        public string SearchTerm { get; set; }
        public bool? IsActive { get; set; }
        public int? RoleId { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public string SortBy { get; set; } = "Username";
        public bool SortDescending { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}