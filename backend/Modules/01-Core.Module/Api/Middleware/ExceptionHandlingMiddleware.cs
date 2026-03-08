// using System.Net;
// using System.Text.Json;
// using Microsoft.AspNetCore.Http;
// using Microsoft.Extensions.Logging;
// using Core.Module.Application.Common.Exceptions;

// namespace Core.Module.Api.Middleware
// {
//     public class ExceptionHandlingMiddleware
//     {
//         private readonly RequestDelegate _next;
//         private readonly ILogger<ExceptionHandlingMiddleware> _logger;

//         public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
//         {
//             _next = next;
//             _logger = logger;
//         }

//         public async Task InvokeAsync(HttpContext context)
//         {
//             try
//             {
//                 await _next(context);
//             }
//             catch (Exception ex)
//             {
//                 await HandleExceptionAsync(context, ex);
//             }
//         }

//         private async Task HandleExceptionAsync(HttpContext context, Exception exception)
//         {
//             context.Response.ContentType = "application/json";
            
//             var response = new
//             {
//                 Succeeded = false,
//                 Message = "An error occurred",
//                 Errors = new List<string>()
//             };

//             switch (exception)
//             {
//                 case ValidationException validationException:
//                     context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
//                     response = new
//                     {
//                         Succeeded = false,
//                         Message = "Validation failed",
//                         Errors = validationException.Errors.SelectMany(e => e.Value)
//                     };
//                     _logger.LogWarning(validationException, "Validation error");
//                     break;

//                 case NotFoundException notFoundException:
//                     context.Response.StatusCode = (int)HttpStatusCode.NotFound;
//                     response = new
//                     {
//                         Succeeded = false,
//                         Message = notFoundException.Message,
//                         Errors = new List<string>()
//                     };
//                     _logger.LogInformation(notFoundException, "Resource not found");
//                     break;

//                 case UnauthorizedException unauthorizedException:
//                     context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
//                     response = new
//                     {
//                         Succeeded = false,
//                         Message = unauthorizedException.Message ?? "Unauthorized",
//                         Errors = new List<string>()
//                     };
//                     _logger.LogWarning(unauthorizedException, "Unauthorized access");
//                     break;

//                 case ForbiddenAccessException forbiddenException:
//                     context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
//                     response = new
//                     {
//                         Succeeded = false,
//                         Message = forbiddenException.Message ?? "Forbidden",
//                         Errors = new List<string>()
//                     };
//                     _logger.LogWarning(forbiddenException, "Forbidden access");
//                     break;

//                 default:
//                     context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
//                     response = new
//                     {
//                         Succeeded = false,
//                         Message = "An internal server error occurred",
//                         Errors = new List<string>()
//                     };
//                     _logger.LogError(exception, "Unhandled exception");
//                     break;
//             }

//             var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
//             {
//                 PropertyNamingPolicy = JsonNamingPolicy.CamelCase
//             });

//             await context.Response.WriteAsync(jsonResponse);
//         }
//     }
// }


using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Exceptions;

namespace Core.Module.Api.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            
            var response = new
            {
                Succeeded = false,
                Message = "An error occurred",
                Errors = new List<string>()
            };

            switch (exception)
            {
                case ValidationException validationException:
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    response = new
                    {
                        Succeeded = false,
                        Message = "Validation failed",
                        Errors = validationException.Errors.SelectMany(e => e.Value).ToList()
                    };
                    _logger.LogWarning(validationException, "Validation error");
                    break;

                case NotFoundException notFoundException:
                    context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                    response = new
                    {
                        Succeeded = false,
                        Message = notFoundException.Message,
                        Errors = new List<string>()
                    };
                    _logger.LogInformation(notFoundException, "Resource not found");
                    break;

                case UnauthorizedException unauthorizedException:
                    context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    response = new
                    {
                        Succeeded = false,
                        Message = unauthorizedException.Message ?? "Unauthorized",
                        Errors = new List<string>()
                    };
                    _logger.LogWarning(unauthorizedException, "Unauthorized access");
                    break;

                case ForbiddenAccessException forbiddenException:
                    context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
                    response = new
                    {
                        Succeeded = false,
                        Message = forbiddenException.Message ?? "Forbidden",
                        Errors = new List<string>()
                    };
                    _logger.LogWarning(forbiddenException, "Forbidden access");
                    break;

                default:
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    response = new
                    {
                        Succeeded = false,
                        Message = "An internal server error occurred",
                        Errors = new List<string>()
                    };
                    _logger.LogError(exception, "Unhandled exception");
                    break;
            }

            var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });

            await context.Response.WriteAsync(jsonResponse);
        }
    }
}