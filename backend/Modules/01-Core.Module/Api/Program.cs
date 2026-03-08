// using Microsoft.AspNetCore.Builder;
// using Microsoft.Extensions.DependencyInjection;
// using Microsoft.Extensions.Hosting;
// using Microsoft.Extensions.Logging;
// using Microsoft.EntityFrameworkCore;
// using Serilog;
// using Core.Module;
// using Core.Module.Api.Middleware;
// using Core.Module.Infrastructure.Persistence.DbContext;
// using Core.Module.Infrastructure.Persistence.SeedData;
// using Core.Module.Infrastructure.BackgroundServices;
// using System;

// var builder = WebApplication.CreateBuilder(args);

// // Add Serilog
// builder.Host.UseSerilog((context, config) =>
// {
//     config.ReadFrom.Configuration(context.Configuration)
//           .Enrich.FromLogContext()
//           .WriteTo.Console()
//           .WriteTo.File("logs/core-module-.txt", rollingInterval: RollingInterval.Day);
// });

// // Add services
// builder.Services.AddControllers();
// builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();

// // Add Core Module
// builder.Services.AddCoreModule(builder.Configuration);

// // Add Background Services
// builder.Services.AddHostedService<TokenCleanupService>();

// // Add CORS
// builder.Services.AddCors(options =>
// {
//     options.AddPolicy("AllowFrontend", policy =>
//     {
//         policy.WithOrigins("http://localhost:3000")
//               .AllowAnyMethod()
//               .AllowAnyHeader()
//               .AllowCredentials();
//     });
// });

// var app = builder.Build();

// // Seed database
// using (var scope = app.Services.CreateScope())
// {
//     var services = scope.ServiceProvider;
//     try
//     {
//         var context = services.GetRequiredService<CoreDbContext>();
//         var logger = services.GetRequiredService<ILogger<Program>>();
        
//         await context.Database.MigrateAsync();
//         await CoreDbContextSeed.SeedAsync(context, logger);
//     }
//     catch (Exception ex)
//     {
//         var logger = services.GetRequiredService<ILogger<Program>>();
//         logger.LogError(ex, "An error occurred while seeding the database");
//     }
// }

// // Configure pipeline
// if (app.Environment.IsDevelopment())
// {
//     app.UseSwagger();
//     app.UseSwaggerUI();
// }

// app.UseHttpsRedirection();
// app.UseCors("AllowFrontend");

// app.UseMiddleware<ExceptionHandlingMiddleware>();

// app.UseAuthentication();
// app.UseAuthorization();

// app.MapControllers();

// app.Run();