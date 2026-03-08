using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Events;

namespace Core.Module.Application.EventHandlers
{
    public class UserEmailChangedHandler : INotificationHandler<UserEmailChangedEvent>
    {
        private readonly IEmailService _emailService;
        private readonly ILogger<UserEmailChangedHandler> _logger;

        public UserEmailChangedHandler(
            IEmailService emailService,
            ILogger<UserEmailChangedHandler> logger)
        {
            _emailService = emailService;
            _logger = logger;
        }

        public async Task Handle(UserEmailChangedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("Processing email change for user {UserId}: {OldEmail} -> {NewEmail}", 
                    notification.UserId, notification.OldEmail, notification.NewEmail);

                // إرسال إشعار للبريد القديم
                if (!string.IsNullOrEmpty(notification.OldEmail))
                {
                    await _emailService.SendEmailChangedAlertAsync(
                        notification.OldEmail,                    // to
                        notification.UserId.ToString(),           // userId
                        notification.NewEmail,                    // oldEmail? 
                        notification.NewEmail                     // newEmail
                    );
                }

                // إرسال بريد ترحيبي للبريد الجديد
                if (!string.IsNullOrEmpty(notification.NewEmail))
                {
                    await _emailService.SendWelcomeEmailAsync(
                        notification.NewEmail,                    // to
                        notification.UserId.ToString(),           // userId
                        $"User {notification.UserId}"             // username (بديل عن Username)
                    );
                }

                _logger.LogInformation("Email change notifications sent successfully for user {UserId}", 
                    notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email change notifications for user {UserId}", 
                    notification.UserId);
            }
        }
    }
}