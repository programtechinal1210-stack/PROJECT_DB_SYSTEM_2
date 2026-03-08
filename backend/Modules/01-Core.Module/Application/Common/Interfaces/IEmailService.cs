namespace Core.Module.Application.Common.Interfaces
{
    public interface IEmailService
    {
        Task SendEmailAsync(string to, string subject, string body);
        Task SendEmailConfirmationAsync(string to, string userId, string newEmail);
            Task SendEmailChangedAlertAsync(string to, string userId, string oldEmail, string newEmail); // أضف هذه
        Task SendWelcomeEmailAsync(string to, string userId, string username); // أضف هذه
        Task SendAccountDeactivatedEmailAsync(string email, int userId, string reason);
    Task SendAccountActivatedEmailAsync(string email, int userId); // أضف هذه
Task SendPasswordChangedEmailAsync(string email, int userId, DateTime changedAt);
    }
}