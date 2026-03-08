using FluentValidation;

namespace Core.Module.Application.Features.Users.Commands.AssignRole
{
    public class AssignRoleValidator : AbstractValidator<AssignRoleCommand>
    {
        public AssignRoleValidator()
        {
            RuleFor(x => x.UserId)
                .GreaterThan(0).WithMessage("Valid user ID is required");

            RuleFor(x => x.RoleId)
                .GreaterThan(0).WithMessage("Valid role ID is required");
        }
    }
}