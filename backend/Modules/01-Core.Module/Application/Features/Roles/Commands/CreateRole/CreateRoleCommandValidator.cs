using FluentValidation;

namespace Core.Module.Application.Features.Roles.Commands.CreateRole
{
    public class CreateRoleCommandValidator : AbstractValidator<CreateRoleCommand>
    {
        public CreateRoleCommandValidator()
        {
            RuleFor(x => x.RoleName)
                .NotEmpty().WithMessage("Role name is required")
                .Length(3, 50).WithMessage("Role name must be between 3 and 50 characters")
                .Matches("^[a-zA-Z0-9 _-]+$").WithMessage("Role name can only contain letters, numbers, spaces, and _-");
        }
    }
}