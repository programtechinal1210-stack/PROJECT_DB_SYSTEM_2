// using BE.API.Middleware;
// using BE.API.Services;

// var builder = WebApplication.CreateBuilder(args);

// // Add services
// builder.Services.AddControllers();

// // أضف هذا السطر - HttpClient Factory
// builder.Services.AddHttpClient();

// // CORS
// builder.Services.AddCors(options =>
// {
//     options.AddPolicy("AllowFrontend", policy =>
//     {
//         policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
//               .AllowAnyMethod()
//               .AllowAnyHeader()
//               .AllowCredentials();
//     });
// });

// // Health checks
// builder.Services.AddHealthChecks();
// builder.Services.AddScoped<HealthService>();
// builder.Services.AddHttpContextAccessor();

// var app = builder.Build();

// // Middleware
// app.UseMiddleware<ExceptionHandlingMiddleware>();
// app.UseMiddleware<CorrelationIdMiddleware>();

// app.UseRouting();
// app.UseCors("AllowFrontend");
// app.UseAuthorization();

// // Map controllers
// app.MapControllers();
// app.MapHealthChecks("/health");

// app.Run();

using BE.API.Middleware;
using BE.API.Services;
using Core.Module; // أضف هذا السطر

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();

// أضف هذا السطر - HttpClient Factory
builder.Services.AddHttpClient();

// Register Core Module - أضف هذا السطر
builder.Services.AddCoreModule(builder.Configuration);

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// Health checks
builder.Services.AddHealthChecks();
builder.Services.AddScoped<HealthService>();
builder.Services.AddHttpContextAccessor();

var app = builder.Build();

// Middleware
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<CorrelationIdMiddleware>();

app.UseRouting();
app.UseCors("AllowFrontend");
app.UseAuthorization();

// Map controllers
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();