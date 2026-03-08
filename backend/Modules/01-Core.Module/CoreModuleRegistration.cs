// // using System.Reflection;
// // using MediatR;
// // using FluentValidation;
// // using Microsoft.AspNetCore.Authentication;
// // using Microsoft.EntityFrameworkCore;
// // using Microsoft.Extensions.Configuration;
// // using Microsoft.Extensions.DependencyInjection;
// // using Microsoft.IdentityModel.Tokens;
// // using System.Text;
// // using Microsoft.AspNetCore.Authentication.JwtBearer;

// // using Core.Module.Application.Common.Behaviours;
// // using Core.Module.Application.Common.Interfaces;
// // using Core.Module.Application.Common.Mappings;
// // using Core.Module.Domain.Interfaces;
// // using Core.Module.Infrastructure.Persistence.DbContext;
// // using Core.Module.Infrastructure.Persistence.Repositories;
// // using Core.Module.Infrastructure.Security;
// // using Core.Module.Infrastructure.Cache;
// // using Core.Module.Infrastructure.Services;
// // using Core.Module.Infrastructure.EventBus;
// // namespace Core.Module
// // {
// //     public static class CoreModuleRegistration
// //     {
// //         public static IServiceCollection AddCoreModule(
// //             this IServiceCollection services, 
// //             IConfiguration configuration)
// //         {
// //             // Add MediatR
// //             services.AddMediatR(cfg => {
// //                 cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
// //             });

// //             // Add FluentValidation
// //             services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

// //             // Add AutoMapper
// //             services.AddAutoMapper(typeof(MappingProfile).Assembly);

// //             // Add DbContext
// //             services.AddDbContext<CoreDbContext>(options =>
// //                 options.UseSqlServer(
// //                     configuration.GetConnectionString("DefaultConnection"),
// //                     b => b.MigrationsAssembly(typeof(CoreDbContext).Assembly.FullName)));

// //             services.AddScoped<IApplicationDbContext>(provider => 
// //                 provider.GetService<CoreDbContext>());

// //             // Add Redis Cache
// //             services.AddStackExchangeRedisCache(options =>
// //             {
// //                 options.Configuration = configuration.GetConnectionString("Redis");
// //                 options.InstanceName = "CoreModule";
// //             });

// //             // Add JWT Authentication
// //             var jwtSettings = new JwtSettings();
// //             configuration.Bind("Jwt", jwtSettings);
// //             services.AddSingleton(jwtSettings);

// //             services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
// //                 .AddJwtBearer(options =>
// //                 {
// //                     options.TokenValidationParameters = new TokenValidationParameters
// //                     {
// //                         ValidateIssuer = true,
// //                         ValidateAudience = true,
// //                         ValidateLifetime = true,
// //                         ValidateIssuerSigningKey = true,
// //                         ValidIssuer = jwtSettings.Issuer,
// //                         ValidAudience = jwtSettings.Audience,
// //                         IssuerSigningKey = new SymmetricSecurityKey(
// //                             Encoding.UTF8.GetBytes(jwtSettings.Secret))
// //                     };
// //                 });

// //             // Add HttpContextAccessor
// //             services.AddHttpContextAccessor();

// //             // Register Repositories
// //             services.AddScoped<IUserRepository, UserRepository>();
// //             services.AddScoped<IRoleRepository, RoleRepository>();
// //             services.AddScoped<IPermissionRepository, PermissionRepository>();

// //             // Register Services
// //            // services.AddScoped<ITokenService, JwtService>();
// //             services.AddScoped<ICacheService, RedisCacheService>();
// //             services.AddScoped<IDateTime, DateTimeService>();
// //             services.AddScoped<ICurrentUserService, CurrentUserService>();
// //             services.AddScoped<IEventBus, InMemoryEventBus>();

// //             // Register Pipeline Behaviours
// //             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehaviour<,>));
// //             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehaviour<,>));
// //             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
// //             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(PerformanceBehaviour<,>));
// //             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(TransactionBehaviour<,>));

// //             return services;
// //         }
// //     }
// // }


// using System.Reflection;
// using System.Text;
// using MediatR;
// using FluentValidation;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.Extensions.Configuration;
// using Microsoft.Extensions.DependencyInjection;
// using Microsoft.AspNetCore.Authentication.JwtBearer;
// using Microsoft.IdentityModel.Tokens;

// using Core.Module.Application.Common.Behaviours;
// using Core.Module.Application.Common.Interfaces;
// using Core.Module.Application.Interfaces;

// using Core.Module.Application.Common.Mappings;
// using Core.Module.Domain.Interfaces;
// using Core.Module.Infrastructure.Persistence.DbContext;
// using Core.Module.Infrastructure.Persistence.Repositories;
// using Core.Module.Infrastructure.Cache;
// using Core.Module.Infrastructure.Services;
// using Core.Module.Infrastructure.EventBus;
// using Microsoft.Extensions.Logging;
// using Core.Module.Domain.Entities;
// using Core.Module.Domain.ValueObjects;
// namespace Core.Module
// {
//     public static class CoreModuleRegistration
//     {
//         public static IServiceCollection AddCoreModule(
//             this IServiceCollection services, 
//             IConfiguration configuration)
//         {
//             // Add MediatR
//             services.AddMediatR(cfg => {
//                 cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
//             });

//             // Add FluentValidation
//             services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

//             // Add AutoMapper
//             services.AddAutoMapper(typeof(MappingProfile).Assembly);

//             // Add DbContext
//             services.AddDbContext<CoreDbContext>(options =>
//                 options.UseSqlServer(
//                     configuration.GetConnectionString("DefaultConnection"),
//                     b => b.MigrationsAssembly(typeof(CoreDbContext).Assembly.FullName)));

//             services.AddScoped<IApplicationDbContext>(provider => 
//                 provider.GetRequiredService<CoreDbContext>());

//             // Add Redis Cache
//             services.AddStackExchangeRedisCache(options =>
//             {
//                 options.Configuration = configuration.GetConnectionString("Redis") ?? "localhost:6379";
//                 options.InstanceName = "CoreModule";
//             });

//             // Add JWT Authentication
//             var jwtSettings = new JwtSettings();
//             configuration.Bind("Jwt", jwtSettings);
            
//             // Validate JWT settings
//             if (string.IsNullOrEmpty(jwtSettings.Secret))
//                 jwtSettings.Secret = "default-dev-secret-key-min-32-chars-length!";
//             if (string.IsNullOrEmpty(jwtSettings.Issuer))
//                 jwtSettings.Issuer = "localhost";
//             if (string.IsNullOrEmpty(jwtSettings.Audience))
//                 jwtSettings.Audience = "localhost";
            
//             services.AddSingleton(jwtSettings);

//             services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
//                 .AddJwtBearer(options =>
//                 {
//                     options.TokenValidationParameters = new TokenValidationParameters
//                     {
//                         ValidateIssuer = true,
//                         ValidateAudience = true,
//                         ValidateLifetime = true,
//                         ValidateIssuerSigningKey = true,
//                         ValidIssuer = jwtSettings.Issuer,
//                         ValidAudience = jwtSettings.Audience,
//                         IssuerSigningKey = new SymmetricSecurityKey(
//                             Encoding.UTF8.GetBytes(jwtSettings.Secret))
//                     };
//                 });

//             // Add HttpContextAccessor
//             services.AddHttpContextAccessor();

//             // Register Repositories
//             services.AddScoped<IUserRepository, UserRepository>();
//             services.AddScoped<IRoleRepository, RoleRepository>();
//             services.AddScoped<IPermissionRepository, PermissionRepository>();

//             // Register Services
//             services.AddScoped<ICacheService, RedisCacheService>();
//             services.AddScoped<IDateTime, DateTimeService>();
//             services.AddScoped<ICurrentUserService, CurrentUserService>();
//             services.AddScoped<IEventBus, InMemoryEventBus>();

//             // Register Pipeline Behaviours
//             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehaviour<,>));
//             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehaviour<,>));
//             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
//             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(PerformanceBehaviour<,>));
//             services.AddTransient(typeof(IPipelineBehavior<,>), typeof(TransactionBehaviour<,>));

//             return services;
//         }
//     }

//     // JwtSettings class
//     public class JwtSettings
//     {
//         public string Secret { get; set; } = string.Empty;
//         public string Issuer { get; set; } = string.Empty;
//         public string Audience { get; set; } = string.Empty;
//         public int AccessTokenExpirationMinutes { get; set; } = 60;
//         public int RefreshTokenExpirationDays { get; set; } = 7;
//     }
//         // Mock Services for development
//     public class MockEmailService : IEmailService
//     {
//         private readonly ILogger<MockEmailService> _logger;
//         public MockEmailService(ILogger<MockEmailService> logger) => _logger = logger;
        
//         public Task SendEmailAsync(string to, string subject, string body) 
//         { 
//             _logger.LogInformation($"[MOCK] Email to {to}: {subject}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendEmailConfirmationAsync(string to, string userId, string newEmail) 
//         { 
//             _logger.LogInformation($"[MOCK] Email confirmation to {to} for user {userId}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendEmailChangedAlertAsync(string to, string userId, string newEmail) 
//         { 
//             _logger.LogInformation($"[MOCK] Email changed alert to {to}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendWelcomeEmailAsync(string to, string userId, string username) 
//         { 
//             _logger.LogInformation($"[MOCK] Welcome email to {to}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendAccountDeactivatedEmailAsync(string email, int userId, string reason) 
//         { 
//             _logger.LogInformation($"[MOCK] Deactivation email to {email}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendAccountActivatedEmailAsync(string email, int userId) 
//         { 
//             _logger.LogInformation($"[MOCK] Activation email to {email}"); 
//             return Task.CompletedTask; 
//         }
        
//         public Task SendPasswordChangedEmailAsync(string email, int userId, DateTime changedAt) 
//         { 
//             _logger.LogInformation($"[MOCK] Password changed email to {email}"); 
//             return Task.CompletedTask; 
//         }
//     }

//     public class MockAuditService : IAuditService
//     {
//         private readonly ILogger<MockAuditService> _logger;
//         public MockAuditService(ILogger<MockAuditService> logger) => _logger = logger;
        
//         public Task LogAsync(string entityType, object entityId, string action, string? details = null, CancellationToken cancellationToken = default)
//         { 
//             _logger.LogInformation($"[MOCK AUDIT] {action} on {entityType}:{entityId} - {details}"); 
//             return Task.CompletedTask; 
//         }
//     }

//     public class MockTokenService : ITokenService
//     {
//         private readonly ILogger<MockTokenService> _logger;
//         public MockTokenService(ILogger<MockTokenService> logger) => _logger = logger;
        
//         public string GenerateAccessToken(User user) 
//         { 
//             _logger.LogInformation($"[MOCK] Generating access token for user {user.Id}");
//             return "mock-access-token-" + Guid.NewGuid().ToString(); 
//         }
        
//         public string GenerateRefreshToken() 
//         { 
//             return "mock-refresh-token-" + Guid.NewGuid().ToString(); 
//         }
        
//         public Task<RefreshTokenInfo> ValidateAccessTokenAsync(string token)
//         {
//             return Task.FromResult(new RefreshTokenInfo
//             {
//                 Token = token,
//                 ExpiryDate = DateTime.UtcNow.AddHours(1)
//             });
//         }
        
//         public Task<int?> GetUserIdFromTokenAsync(string token)
//         {
//             return Task.FromResult<int?>(1);
//         }
        
//         public Task<RefreshTokenInfo> ValidateRefreshTokenAsync(string token)
//         {
//             return Task.FromResult(new RefreshTokenInfo
//             {
//                 Token = token,
//                 ExpiryDate = DateTime.UtcNow.AddDays(7)
//             });
//         }
//     }

//     public class MockSessionService : ISessionService
//     {
//         private readonly ILogger<MockSessionService> _logger;
//         public MockSessionService(ILogger<MockSessionService> logger) => _logger = logger;
        
//         public Task TerminateAllUserSessionsAsync(int userId) 
//         { 
//             _logger.LogInformation($"[MOCK] Terminating all sessions for user {userId}");
//             return Task.CompletedTask; 
//         }
        
//         public Task TerminateSessionAsync(string sessionId) 
//         { 
//             _logger.LogInformation($"[MOCK] Terminating session {sessionId}");
//             return Task.CompletedTask; 
//         }
//     }
// }

using System.Reflection;
using System.Text;
using MediatR;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

using Core.Module.Application.Common.Behaviours;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Interfaces;
using Core.Module.Domain.Entities;
using Core.Module.Domain.ValueObjects;
using Core.Module.Infrastructure.Persistence.DbContext;
using Core.Module.Infrastructure.Persistence.Repositories;
using Core.Module.Infrastructure.Cache;
using Core.Module.Infrastructure.Services;
using Core.Module.Infrastructure.EventBus;
using ServiceRefreshTokenInfo = Core.Module.Application.Common.Interfaces.RefreshTokenInfo;
using DomainRefreshTokenInfo = Core.Module.Domain.ValueObjects.RefreshTokenInfo;
namespace Core.Module
{
    public static class CoreModuleRegistration
    {
        public static IServiceCollection AddCoreModule(
            this IServiceCollection services, 
            IConfiguration configuration)
        {
            // Add MediatR
            services.AddMediatR(cfg => {
                cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
            });

            // Add FluentValidation
            services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

            // Add AutoMapper
            services.AddAutoMapper(typeof(MappingProfile).Assembly);

            // Add DbContext
   // Add DbContext - PostgreSQL
services.AddDbContext<CoreDbContext>(options =>
    options.UseNpgsql(
        configuration.GetConnectionString("DefaultConnection"),
        b => b.MigrationsAssembly(typeof(CoreDbContext).Assembly.FullName)));
            services.AddScoped<IApplicationDbContext>(provider => 
                provider.GetRequiredService<CoreDbContext>());

            // Add Redis Cache
            services.AddStackExchangeRedisCache(options =>
            {
                options.Configuration = configuration.GetConnectionString("Redis") ?? "localhost:6379";
                options.InstanceName = "CoreModule";
            });

            // Add JWT Authentication
            var jwtSettings = new JwtSettings();
            configuration.Bind("Jwt", jwtSettings);
            
            // Validate JWT settings
            if (string.IsNullOrEmpty(jwtSettings.Secret))
                jwtSettings.Secret = "default-dev-secret-key-min-32-chars-length!";
            if (string.IsNullOrEmpty(jwtSettings.Issuer))
                jwtSettings.Issuer = "localhost";
            if (string.IsNullOrEmpty(jwtSettings.Audience))
                jwtSettings.Audience = "localhost";
            
            services.AddSingleton(jwtSettings);

            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = jwtSettings.Issuer,
                        ValidAudience = jwtSettings.Audience,
                        IssuerSigningKey = new SymmetricSecurityKey(
                            Encoding.UTF8.GetBytes(jwtSettings.Secret))
                    };
                });

            // Add HttpContextAccessor
            services.AddHttpContextAccessor();

            // Register Repositories
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IRoleRepository, RoleRepository>();
            services.AddScoped<IPermissionRepository, PermissionRepository>();

            // Register Services
            services.AddScoped<ICacheService, RedisCacheService>();
            services.AddScoped<IDateTime, DateTimeService>();
            services.AddScoped<ICurrentUserService, CurrentUserService>();
            services.AddScoped<IEventBus, InMemoryEventBus>();

            // Register Mock Services (for development)
            services.AddScoped<IEmailService, MockEmailService>();
            services.AddScoped<IAuditService, MockAuditService>();
            services.AddScoped<ITokenService, MockTokenService>();
            services.AddScoped<ISessionService, MockSessionService>();
services.AddScoped<IEmailService, MockEmailService>();
services.AddScoped<IAuditService, MockAuditService>();
services.AddScoped<ITokenService, MockTokenService>();
services.AddScoped<ISessionService, MockSessionService>();
services.AddScoped<INotificationService, MockNotificationService>();
            // Register Pipeline Behaviours
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehaviour<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehaviour<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(PerformanceBehaviour<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(TransactionBehaviour<,>));
            // Register Mock Services (for development)
 // أضف هذا السطر
            return services;
        }
    }

    // JwtSettings class
    public class JwtSettings
    {
        public string Secret { get; set; } = string.Empty;
        public string Issuer { get; set; } = string.Empty;
        public string Audience { get; set; } = string.Empty;
        public int AccessTokenExpirationMinutes { get; set; } = 60;
        public int RefreshTokenExpirationDays { get; set; } = 7;
    }

    // Mock Services for development
    public class MockEmailService : IEmailService
    {
        private readonly ILogger<MockEmailService> _logger;
        public MockEmailService(ILogger<MockEmailService> logger) => _logger = logger;
        
        public Task SendEmailAsync(string to, string subject, string body) 
        { 
            _logger.LogInformation($"[MOCK] Email to {to}: {subject}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendEmailConfirmationAsync(string to, string userId, string newEmail) 
        { 
            _logger.LogInformation($"[MOCK] Email confirmation to {to} for user {userId}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendEmailChangedAlertAsync(string to, string userId, string oldEmail, string newEmail) 
        { 
            _logger.LogInformation($"[MOCK] Email changed alert to {to} from {oldEmail} to {newEmail}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendWelcomeEmailAsync(string to, string userId, string username) 
        { 
            _logger.LogInformation($"[MOCK] Welcome email to {to}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendAccountDeactivatedEmailAsync(string email, int userId, string reason) 
        { 
            _logger.LogInformation($"[MOCK] Deactivation email to {email}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendAccountActivatedEmailAsync(string email, int userId) 
        { 
            _logger.LogInformation($"[MOCK] Activation email to {email}"); 
            return Task.CompletedTask; 
        }
        
        public Task SendPasswordChangedEmailAsync(string email, int userId, DateTime changedAt) 
        { 
            _logger.LogInformation($"[MOCK] Password changed email to {email}"); 
            return Task.CompletedTask; 
        }
    }

    public class MockAuditService : IAuditService
    {
        private readonly ILogger<MockAuditService> _logger;
        public MockAuditService(ILogger<MockAuditService> logger) => _logger = logger;
        
        public Task LogAsync(string entityType, object entityId, string action, string? details = null, CancellationToken cancellationToken = default)
        { 
            _logger.LogInformation($"[MOCK AUDIT] {action} on {entityType}:{entityId} - {details}"); 
            return Task.CompletedTask; 
        }
    }

        public class MockTokenService : ITokenService
    {
        private readonly ILogger<MockTokenService> _logger;
        public MockTokenService(ILogger<MockTokenService> logger) => _logger = logger;
        
        public string GenerateAccessToken(User user) 
        { 
            _logger.LogInformation($"[MOCK] Generating access token for user {user.Id}");
            return "mock-access-token-" + Guid.NewGuid().ToString(); 
        }
        
        public string GenerateRefreshToken() 
        { 
            return "mock-refresh-token-" + Guid.NewGuid().ToString(); 
        }
        
        public Task<bool> ValidateAccessTokenAsync(string token)
        {
            return Task.FromResult(true);
        }
        
        public Task<int?> GetUserIdFromTokenAsync(string token)
        {
            return Task.FromResult<int?>(1);
        }
        
        public Task<ServiceRefreshTokenInfo> ValidateRefreshTokenAsync(string token)
        {
            return Task.FromResult(new ServiceRefreshTokenInfo
            {
                UserId = 1,
                Token = token,
                IsValid = true
            });
        }
    }

    public class MockSessionService : ISessionService
    {
        private readonly ILogger<MockSessionService> _logger;
        public MockSessionService(ILogger<MockSessionService> logger) => _logger = logger;
        
        public Task TerminateAllUserSessionsAsync(int userId) 
        { 
            _logger.LogInformation($"[MOCK] Terminating all sessions for user {userId}");
            return Task.CompletedTask; 
        }
        
        public Task TerminateSessionAsync(string sessionId) 
        { 
            _logger.LogInformation($"[MOCK] Terminating session {sessionId}");
            return Task.CompletedTask; 
        }
    }
        public class MockNotificationService : INotificationService
    {
        private readonly ILogger<MockNotificationService> _logger;
        public MockNotificationService(ILogger<MockNotificationService> logger) => _logger = logger;
        
        public Task SendAsync(string userId, string title, string message, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation($"[MOCK NOTIFICATION] To user {userId}: {title} - {message}");
            return Task.CompletedTask;
        }
        
        public Task SendToRoleAsync(string role, string title, string message, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation($"[MOCK NOTIFICATION] To role {role}: {title} - {message}");
            return Task.CompletedTask;
        }
        
        public Task SendToAllAsync(string title, string message, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation($"[MOCK NOTIFICATION] To all: {title} - {message}");
            return Task.CompletedTask;
        }
        
        public Task SendSecurityAlertAsync(int userId, string message, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation($"[MOCK NOTIFICATION] Security alert to user {userId}: {message}");
            return Task.CompletedTask;
        }
        
        public Task SendPasswordChangedAlertAsync(int userId, DateTime changedAt)
        {
            _logger.LogInformation($"[MOCK NOTIFICATION] Password changed alert to user {userId} at {changedAt}");
            return Task.CompletedTask;
        }
    }
}