// // // using Microsoft.EntityFrameworkCore;
// // // using Microsoft.EntityFrameworkCore.Storage;
// // // using Core.Module.Application.Common.Interfaces;
// // // using Core.Module.Domain.Entities;

// // // namespace Core.Module.Infrastructure.Persistence.DbContext
// // // {
// // //     public class CoreDbContext : Microsoft.EntityFrameworkCore.DbContext, IApplicationDbContext
// // //     {
// // //         private IDbContextTransaction? _currentTransaction;

// // //         public CoreDbContext(DbContextOptions<CoreDbContext> options) 
// // //             : base(options)
// // //         {
// // //         }

// // //         public DbSet<User> Users { get; set; }
// // //         public DbSet<Role> Roles { get; set; }
// // //         public DbSet<Permission> Permissions { get; set; }
// // //         public DbSet<RolePermission> RolePermissions { get; set; }
// // //         public DbSet<UserRole> UserRoles { get; set; }
// // //         public DbSet<UserSession> UserSessions { get; set; }
// // //         public DbSet<LoginAttempt> LoginAttempts { get; set; }
// // //         public DbSet<Domain.Entities.Module> Modules { get; set; }
// // //         public DbSet<PasswordReset> PasswordResets { get; set; }

// // //        protected override void OnModelCreating(ModelBuilder modelBuilder)
// // // {
// // //     modelBuilder.ApplyConfigurationsFromAssembly(GetType().Assembly);
    
// // //     // Configure Email value object
// // //     modelBuilder.Entity<User>(entity =>
// // //     {
// // //         entity.OwnsOne(e => e.Email, email =>
// // //         {
// // //             email.Property(e => e.Value)
// // //                 .HasColumnName("Email")
// // //                 .HasMaxLength(100)
// // //                 .IsRequired();
// // //         });

// // //         // Configure PasswordHash value object
// // //         entity.OwnsOne(e => e.Password, password =>
// // //         {
// // //             password.Property(p => p.Hash)
// // //                 .HasColumnName("PasswordHash")
// // //                 .HasMaxLength(500)
// // //                 .IsRequired();
                
// // //             password.Property(p => p.Salt)
// // //                 .HasColumnName("PasswordSalt")
// // //                 .HasMaxLength(500)
// // //                 .IsRequired();
// // //         });
// // //     });
    
// // //     base.OnModelCreating(modelBuilder);
// // // }

// // //         public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
// // //         {
// // //             return await base.SaveChangesAsync(cancellationToken);
// // //         }

// // //         public async Task BeginTransactionAsync()
// // //         {
// // //             if (_currentTransaction != null)
// // //             {
// // //                 return;
// // //             }

// // //             _currentTransaction = await Database.BeginTransactionAsync();
// // //         }

// // //         public async Task CommitTransactionAsync()
// // //         {
// // //             try
// // //             {
// // //                 await SaveChangesAsync();
// // //                 if (_currentTransaction != null)
// // //                 {
// // //                     await _currentTransaction.CommitAsync();
// // //                 }
// // //             }
// // //             catch
// // //             {
// // //                 await RollbackTransactionAsync();
// // //                 throw;
// // //             }
// // //             finally
// // //             {
// // //                 if (_currentTransaction != null)
// // //                 {
// // //                     await _currentTransaction.DisposeAsync();
// // //                     _currentTransaction = null;
// // //                 }
// // //             }
// // //         }

// // //         public async Task RollbackTransactionAsync()
// // //         {
// // //             try
// // //             {
// // //                 if (_currentTransaction != null)
// // //                 {
// // //                     await _currentTransaction.RollbackAsync();
// // //                 }
// // //             }
// // //             finally
// // //             {
// // //                 if (_currentTransaction != null)
// // //                 {
// // //                     await _currentTransaction.DisposeAsync();
// // //                     _currentTransaction = null;
// // //                 }
// // //             }
// // //         }
// // //     }
// // // }



// // using Microsoft.EntityFrameworkCore;
// // using Microsoft.EntityFrameworkCore.Storage;
// // using Core.Module.Application.Common.Interfaces;
// // using Core.Module.Domain.Entities;

// // namespace Core.Module.Infrastructure.Persistence.DbContext
// // {
// //     public class CoreDbContext : Microsoft.EntityFrameworkCore.DbContext, IApplicationDbContext
// //     {
// //         private IDbContextTransaction? _currentTransaction;

// //         public CoreDbContext(DbContextOptions<CoreDbContext> options) 
// //             : base(options)
// //         {
// //         }

// //         public DbSet<User> Users { get; set; }
// //         public DbSet<Role> Roles { get; set; }
// //         public DbSet<Permission> Permissions { get; set; }
// //         public DbSet<RolePermission> RolePermissions { get; set; }
// //         public DbSet<UserRole> UserRoles { get; set; }
// //         public DbSet<UserSession> UserSessions { get; set; }
// //         public DbSet<LoginAttempt> LoginAttempts { get; set; }
// //         public DbSet<Domain.Entities.Module> Modules { get; set; }
// //         public DbSet<PasswordReset> PasswordResets { get; set; }

// //         protected override void OnModelCreating(ModelBuilder modelBuilder)
// //         {
// //             modelBuilder.ApplyConfigurationsFromAssembly(GetType().Assembly);
            
// //             // Configure User entity and its value objects
// //             modelBuilder.Entity<User>(entity =>
// //             {
// //                 // Email value object
// //                 entity.OwnsOne(e => e.Email, email =>
// //                 {
// //                     email.Property(e => e.Value)
// //                         .HasColumnName("Email")
// //                         .HasMaxLength(100)
// //                         .IsRequired();
// //                 });

// //                 // Password value object
// //                 entity.OwnsOne(e => e.Password, password =>
// //                 {
// //                     password.Property(p => p.Hash)
// //                         .HasColumnName("PasswordHash")
// //                         .HasMaxLength(500)
// //                         .IsRequired();
                        
// //                     password.Property(p => p.Salt)
// //                         .HasColumnName("PasswordSalt")
// //                         .HasMaxLength(500)
// //                         .IsRequired();
// //                 });

// //                 // 🔴 RefreshToken value object - جديد
// //                 entity.OwnsOne(e => e.RefreshToken, rt =>
// //                 {
// //                     rt.Property(r => r.Token)
// //                         .HasColumnName("RefreshToken")
// //                         .HasMaxLength(500)
// //                         .IsRequired();

// //                     rt.Property(r => r.Expiry)
// //                         .HasColumnName("RefreshTokenExpiry")
// //                         .IsRequired(true);
// //                 });

// //                 // Indexes
// //                 entity.HasIndex(e => e.Username)
// //                     .IsUnique();
                    
// //                 entity.HasIndex(e => e.Email)
// //                     .IsUnique();
// //             });
            
// //             base.OnModelCreating(modelBuilder);
// //         }

// //         public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
// //         {
// //             return await base.SaveChangesAsync(cancellationToken);
// //         }

// //         public async Task BeginTransactionAsync()
// //         {
// //             if (_currentTransaction != null)
// //             {
// //                 return;
// //             }

// //             _currentTransaction = await Database.BeginTransactionAsync();
// //         }

// //         public async Task CommitTransactionAsync()
// //         {
// //             try
// //             {
// //                 await SaveChangesAsync();
// //                 if (_currentTransaction != null)
// //                 {
// //                     await _currentTransaction.CommitAsync();
// //                 }
// //             }
// //             catch
// //             {
// //                 await RollbackTransactionAsync();
// //                 throw;
// //             }
// //             finally
// //             {
// //                 if (_currentTransaction != null)
// //                 {
// //                     await _currentTransaction.DisposeAsync();
// //                     _currentTransaction = null;
// //                 }
// //             }
// //         }

// //         public async Task RollbackTransactionAsync()
// //         {
// //             try
// //             {
// //                 if (_currentTransaction != null)
// //                 {
// //                     await _currentTransaction.RollbackAsync();
// //                 }
// //             }
// //             finally
// //             {
// //                 if (_currentTransaction != null)
// //                 {
// //                     await _currentTransaction.DisposeAsync();
// //                     _currentTransaction = null;
// //                 }
// //             }
// //         }
// //     }
// // }

// using ModuleEntity = Core.Module.Domain.Entities.Module;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.EntityFrameworkCore.Storage;
// using Core.Module.Application.Common.Interfaces;
// using Core.Module.Domain.Entities;
// using System.Collections.Generic;
// namespace Core.Module.Infrastructure.Persistence.DbContext
// {
//     public class CoreDbContext : Microsoft.EntityFrameworkCore.DbContext, IApplicationDbContext
//     {
//         private IDbContextTransaction? _currentTransaction;

//         public CoreDbContext(DbContextOptions<CoreDbContext> options) 
//             : base(options)
//         {
//         }

//         public DbSet<User> Users { get; set; }
//         public DbSet<Role> Roles { get; set; }
//         public DbSet<Permission> Permissions { get; set; }
//         public DbSet<RolePermission> RolePermissions { get; set; }
//         public DbSet<UserRole> UserRoles { get; set; }
//         public DbSet<UserSession> UserSessions { get; set; }
//         public DbSet<LoginAttempt> LoginAttempts { get; set; }
//             public DbSet<PasswordReset> PasswordResets { get; set; }

// public DbSet<ModuleEntity> Modules { get; set; }
//         protected override void OnModelCreating(ModelBuilder modelBuilder)
//         {
//             modelBuilder.ApplyConfigurationsFromAssembly(GetType().Assembly);
            
//             // Configure User entity and its value objects
//             modelBuilder.Entity<User>(entity =>
//             {
//                     entity.ToTable("users", "core");  // ✅ تحديد schema واسم الجدول بحرف صغير

//                 // Username configuration
//                 entity.Property(e => e.Username)
//                     .HasMaxLength(50)
//                     .IsRequired();

//                 entity.HasIndex(e => e.Username)
//                     .IsUnique();

//              //   Email value object
//                 entity.OwnsOne(e => e.Email, email =>
//                 {
//                     email.Property(e => e.Value)
//                         .HasColumnName("Email")
//                         .HasMaxLength(100)
//                         .IsRequired();

//                     email.HasIndex(e => e.Value)
//                         .HasDatabaseName("IX_Users_Email")
//                         .IsUnique();
//                 });

//                 // Password value object
//                 entity.OwnsOne(e => e.Password, password =>
//                 {
//                     password.Property(p => p.Hash)
//                         .HasColumnName("PasswordHash")
//                         .HasMaxLength(500)
//                         .IsRequired();
                        
//                     password.Property(p => p.Salt)
//                         .HasColumnName("PasswordSalt")
//                         .HasMaxLength(500)
//                         .IsRequired();
//                 });

//                 // EmployeeId
//                 entity.Property(e => e.EmployeeId)
//                     .IsRequired(false);

//                 // IsActive
//                 entity.Property(e => e.IsActive)
//                     .IsRequired()
//                     .HasDefaultValue(true);

//                 // LastLogin
//                 entity.Property(e => e.LastLogin)
//                     .IsRequired(false);

//                 // Audit fields
//                 entity.Property(e => e.CreatedAt)
//                     .IsRequired();

//                 entity.Property(e => e.UpdatedAt)
//                     .IsRequired();

//                 entity.Property(e => e.CreatedBy)
//                     .HasMaxLength(100)
//                     .IsRequired();

//                 entity.Property(e => e.UpdatedBy)
//                     .HasMaxLength(100)
//                     .IsRequired();

//                 // 🔴 RefreshToken value object
//                 entity.OwnsOne(e => e.RefreshToken, rt =>
//                 {
//                     rt.Property(r => r.Token)
//                         .HasColumnName("RefreshToken")
//                         .HasMaxLength(500)
//                         .IsRequired(false);  // يمكن أن يكون null للمستخدمين غير المسجلين

//                     rt.Property(r => r.Expiry)
//                         .HasColumnName("RefreshTokenExpiry")
//                         .IsRequired(true);   // ✅ إذا وجد RefreshToken، يجب أن يكون له Expiry
//                 });

//                 // Ignore domain events
//                 entity.Ignore(e => e.DomainEvents);
//             });

//             // Configure Role entity
//             modelBuilder.Entity<Role>(entity =>
//             {
//                     entity.ToTable("roles", "core");

//                 entity.HasKey(e => e.Id);

//                 entity.Property(e => e.RoleName)
//                     .HasMaxLength(50)
//                     .IsRequired();

//                 entity.Property(e => e.Description)
//                     .HasMaxLength(200)
//                     .IsRequired(false);

//                 entity.HasIndex(e => e.RoleName)
//                     .IsUnique();

//                 // Many-to-many with Permissions
//                 entity.HasMany(e => e.RolePermissions)
//                     .WithOne(e => e.Role)
//                     .HasForeignKey(e => e.RoleId)
//                     .OnDelete(DeleteBehavior.Cascade);
//             });

//             // Configure Permission entity
// modelBuilder.Entity<Permission>(entity =>
// {
//         entity.ToTable("permissions", "core");

//     entity.HasKey(e => e.Id);

//     entity.Property(e => e.PermissionCode)
//         .HasMaxLength(100)
//         .IsRequired();

//     entity.Property(e => e.PermissionName)
//         .HasMaxLength(100)
//         .IsRequired();

//     entity.Property(e => e.Description)
//         .HasMaxLength(200)
//         .IsRequired(false);

//     entity.HasIndex(e => e.PermissionCode)
//         .IsUnique();

//     // العلاقة مع Module
//     entity.HasOne(e => e.Module)
//         .WithMany(m => m.Permissions)
//         .HasForeignKey(e => e.ModuleId)
//         .OnDelete(DeleteBehavior.Cascade);
// });

//             // Configure RolePermission (many-to-many)
//             modelBuilder.Entity<RolePermission>(entity =>
//             {
//                     entity.ToTable("role_permissions", "core");

//                 entity.HasKey(e => new { e.RoleId, e.PermissionId });

//                 entity.HasOne(e => e.Role)
//                     .WithMany(e => e.RolePermissions)
//                     .HasForeignKey(e => e.RoleId)
//                     .OnDelete(DeleteBehavior.Cascade);

//                 entity.HasOne(e => e.Permission)
//                     .WithMany(e => e.RolePermissions)
//                     .HasForeignKey(e => e.PermissionId)
//                     .OnDelete(DeleteBehavior.Cascade);
//             });

//             // Configure UserRole (many-to-many)
//             modelBuilder.Entity<UserRole>(entity =>
//             {
//                     entity.ToTable("user_roles", "core");

//                 entity.HasKey(e => new { e.UserId, e.RoleId });

//                 entity.Property(e => e.AssignedAt)
//                     .IsRequired();

//                 entity.Property(e => e.AssignedBy)
//                     .IsRequired(false);

//                 entity.HasOne(e => e.User)
//                     .WithMany(e => e.UserRoles)
//                     .HasForeignKey(e => e.UserId)
//                     .OnDelete(DeleteBehavior.Cascade);

//                 entity.HasOne(e => e.Role)
//                     .WithMany(e => e.UserRoles)
//                     .HasForeignKey(e => e.RoleId)
//                     .OnDelete(DeleteBehavior.Cascade);
//             });

//             // Configure UserSession
//             modelBuilder.Entity<UserSession>(entity =>
//             {
//                 entity.HasKey(e => e.Id);

//                 entity.Property(e => e.SessionToken)
//                     .HasMaxLength(500)
//                     .IsRequired();

//                 entity.Property(e => e.RefreshToken)
//                     .HasMaxLength(500)
//                     .IsRequired(false);

//                 entity.Property(e => e.IpAddress)
//                     .HasMaxLength(50)
//                     .IsRequired();

//                 entity.Property(e => e.UserAgent)
//                     .HasMaxLength(500)
//                     .IsRequired(false);

//                 entity.Property(e => e.ExpiresAt)
//                     .IsRequired();

//                 entity.Property(e => e.LastActivityAt)
//                     .IsRequired();

//                 entity.Property(e => e.IsRevoked)
//                     .IsRequired()
//                     .HasDefaultValue(false);

//                 entity.HasIndex(e => e.SessionToken)
//                     .IsUnique();

//                 entity.HasIndex(e => e.RefreshToken)
//                     .IsUnique();

//                 entity.HasOne(e => e.User)
//                     .WithMany(e => e.Sessions)
//                     .HasForeignKey(e => e.UserId)
//                     .OnDelete(DeleteBehavior.Cascade);
//             });

//             // Configure LoginAttempt
//            modelBuilder.Entity<LoginAttempt>(entity =>
// {
//     entity.ToTable("login_attempts", "core");
    
//     entity.HasKey(e => e.Id);
    
//     entity.Property(e => e.Username)
//         .HasColumnName("username")  // ✅ استخدم الحرف الصغير
//         .HasMaxLength(50)
//         .IsRequired();
    
//     entity.Property(e => e.IpAddress)
//         .HasColumnName("ip_address")
//         .HasMaxLength(45);
    
//     entity.Property(e => e.UserAgent)
//         .HasColumnName("user_agent")
//         .HasMaxLength(500);
    
//     entity.Property(e => e.AttemptTime)
//         .HasColumnName("attempt_time")
//         .IsRequired();
    
//     entity.Property(e => e.Success)
//         .HasColumnName("success")
//         .IsRequired();
    
//     entity.Property(e => e.FailureReason)
//         .HasColumnName("failure_reason")
//         .HasMaxLength(200);
    
//     entity.HasIndex(e => new { e.Username, e.AttemptTime })
//         .HasDatabaseName("idx_login_attempts_username_attempt_time");
// });
//             // Configure Module
// modelBuilder.Entity<ModuleEntity>(entity =>            {
//                 entity.HasKey(e => e.Id);

//                 entity.Property(e => e.ModuleCode)
//                     .HasMaxLength(50)
//                     .IsRequired();

//                 entity.Property(e => e.ModuleName)
//                     .HasMaxLength(100)
//                     .IsRequired();

//                 entity.Property(e => e.ModuleDescription)
//                     .HasMaxLength(500)
//                     .IsRequired(false);

//                 entity.Property(e => e.Version)
//                     .HasMaxLength(20)
//                     .IsRequired();

//                 entity.Property(e => e.IsActive)
//                     .IsRequired()
//                     .HasDefaultValue(true);

//                 entity.HasIndex(e => e.ModuleCode)
//                     .IsUnique();
//             });

//             // Configure PasswordReset
//             modelBuilder.Entity<PasswordReset>(entity =>
//             {
//                 entity.HasKey(e => e.Id);

//                 entity.Property(e => e.UserId)
//                     .IsRequired();

//                 entity.Property(e => e.Token)
//                     .HasMaxLength(500)
//                     .IsRequired();

//                 entity.Property(e => e.ExpiresAt)
//                     .IsRequired();

//                 entity.Property(e => e.CreatedAt)
//                     .IsRequired();

//                 entity.Property(e => e.IsUsed)
//                     .IsRequired()
//                     .HasDefaultValue(false);

//                 entity.HasIndex(e => e.Token)
//                     .IsUnique();

//                 entity.HasIndex(e => e.UserId);

//          entity.HasOne(e => e.User)
//     .WithMany()
//     .HasForeignKey(e => e.UserId)
//     .OnDelete(DeleteBehavior.Cascade);
//       });

//             base.OnModelCreating(modelBuilder);
//         }

//         public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
//         {
//             return await base.SaveChangesAsync(cancellationToken);
//         }

//         public async Task BeginTransactionAsync()
//         {
//             if (_currentTransaction != null)
//             {
//                 return;
//             }

//             _currentTransaction = await Database.BeginTransactionAsync();
//         }

//         public async Task CommitTransactionAsync()
//         {
//             try
//             {
//                 await SaveChangesAsync();
//                 if (_currentTransaction != null)
//                 {
//                     await _currentTransaction.CommitAsync();
//                 }
//             }
//             catch
//             {
//                 await RollbackTransactionAsync();
//                 throw;
//             }
//             finally
//             {
//                 if (_currentTransaction != null)
//                 {
//                     await _currentTransaction.DisposeAsync();
//                     _currentTransaction = null;
//                 }
//             }
//         }

//         public async Task RollbackTransactionAsync()
//         {
//             try
//             {
//                 if (_currentTransaction != null)
//                 {
//                     await _currentTransaction.RollbackAsync();
//                 }
//             }
//             finally
//             {
//                 if (_currentTransaction != null)
//                 {
//                     await _currentTransaction.DisposeAsync();
//                     _currentTransaction = null;
//                 }
//             }
//         }
//     }
// }

using ModuleEntity = Core.Module.Domain.Entities.Module;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Entities;
using System.Collections.Generic;

namespace Core.Module.Infrastructure.Persistence.DbContext
{
    public class CoreDbContext : Microsoft.EntityFrameworkCore.DbContext, IApplicationDbContext
    {
        private IDbContextTransaction? _currentTransaction;

        public CoreDbContext(DbContextOptions<CoreDbContext> options) 
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }
        public DbSet<LoginAttempt> LoginAttempts { get; set; }
        public DbSet<PasswordReset> PasswordResets { get; set; }
        public DbSet<ModuleEntity> Modules { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(GetType().Assembly);
            
            // ========== Configure User entity ==========
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("users", "core");
                
                // Primary key
                entity.HasKey(e => e.Id)
                    .HasName("PK_users");
                
                entity.Property(e => e.Id)
                    .HasColumnName("user_id")
                    .UseIdentityAlwaysColumn();

                // Username
                entity.Property(e => e.Username)
                    .HasColumnName("username")
                    .HasMaxLength(50)
                    .IsRequired();

                entity.HasIndex(e => e.Username)
                    .HasDatabaseName("IX_users_username")
                    .IsUnique();

                // Email value object
                entity.OwnsOne(e => e.Email, email =>
                {
                    email.Property(e => e.Value)
                        .HasColumnName("email")
                        .HasMaxLength(100)
                        .IsRequired();

                    email.HasIndex(e => e.Value)
                        .HasDatabaseName("IX_users_email")
                        .IsUnique();
                });

                // Password value object
                entity.OwnsOne(e => e.Password, password =>
                {
                    password.Property(p => p.Hash)
                        .HasColumnName("password_hash")
                        .HasMaxLength(500)
                        .IsRequired();
                        
                    // password.Property(p => p.Salt)
                    //     .HasColumnName("password_salt")
                    //     .HasMaxLength(500)
                    //     .IsRequired();
                });

                // EmployeeId
                entity.Property(e => e.EmployeeId)
                    .HasColumnName("employee_id")
                    .IsRequired(false);

                // IsActive
// UserStatus - لاحظ أن اسم الخاصية في الكود IsActive ولكن في قاعدة البيانات user_status
entity.Property(e => e.IsActive)
    .HasColumnName("user_status")  // ✅ التعديل هنا
    .IsRequired();
    //.HasDefaultValue("active");

                // LastLogin
                entity.Property(e => e.LastLogin)
                    .HasColumnName("last_login")
                    .IsRequired(false);

                // Audit fields
                entity.Property(e => e.CreatedAt)
                    .HasColumnName("created_at")
                    .IsRequired();

                entity.Property(e => e.UpdatedAt)
                    .HasColumnName("updated_at")
                    .IsRequired();

                entity.Property(e => e.CreatedBy)
                    .HasColumnName("created_by")
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(e => e.UpdatedBy)
                    .HasColumnName("updated_by")
                    .HasMaxLength(100)
                    .IsRequired();

                // RefreshToken value object
   // ✅ RefreshToken value object
// RefreshToken value object
entity.OwnsOne(e => e.RefreshToken, rt =>
{
    rt.Property(r => r.Token)
        .HasColumnName("refresh_token")
        .HasMaxLength(500)
        .IsRequired(false);

    rt.Ignore(r => r.Expiry);  // ✅ تجاهل Expiry مؤقتاً
});

                // Ignore domain events
                entity.Ignore(e => e.DomainEvents);
            });

            // ========== Configure Role entity ==========
           // Configure Role entity
modelBuilder.Entity<Role>(entity =>
{
    entity.ToTable("roles", "core");
    
    entity.HasKey(e => e.Id)
        .HasName("roles_pkey");
    
    entity.Property(e => e.Id)
        .HasColumnName("role_id")
        .UseIdentityAlwaysColumn();

    entity.Property(e => e.RoleCode)
        .HasColumnName("role_code")
        .HasMaxLength(50)
        .IsRequired();

    entity.HasIndex(e => e.RoleCode)
        .HasDatabaseName("roles_role_code_key")
        .IsUnique();

    entity.Property(e => e.RoleNameAr)
        .HasColumnName("role_name_ar")  // ✅
        .HasMaxLength(100)
        .IsRequired();

    entity.Property(e => e.RoleNameEn)
        .HasColumnName("role_name_en")  // ✅
        .HasMaxLength(100)
        .IsRequired(false);

    entity.Property(e => e.RoleDescription)
        .HasColumnName("role_description")  // ✅
        .HasColumnType("text")
        .IsRequired(false);

    entity.Property(e => e.IsSystemRole)
        .HasColumnName("is_system_role")  // ✅
        .IsRequired()
        .HasDefaultValue(false);

    entity.Property(e => e.SortOrder)
        .HasColumnName("sort_order")  // ✅
        .IsRequired()
        .HasDefaultValue(0);

    // Audit fields
    entity.Property(e => e.CreatedAt)
        .HasColumnName("created_at")  // ✅
        .IsRequired();

    entity.Property(e => e.UpdatedAt)
        .HasColumnName("updated_at")  // ✅
        .IsRequired(false);

    entity.Property(e => e.CreatedBy)
        .HasColumnName("created_by")  // ✅
        .IsRequired(false);

    entity.Property(e => e.UpdatedBy)
        .HasColumnName("updated_by")  // ✅
        .IsRequired(false);

    // تجاهل الخاصية المساعدة RoleName
    entity.Ignore(e => e.RoleName);
});

            // ========== Configure Permission entity ==========
            modelBuilder.Entity<Permission>(entity =>
            {
                entity.ToTable("permissions", "core");

                entity.HasKey(e => e.Id)
                    .HasName("PK_permissions");
                
                entity.Property(e => e.Id)
                    .HasColumnName("permission_id")
                    .UseIdentityAlwaysColumn();

                entity.Property(e => e.PermissionCode)
                    .HasColumnName("permission_code")
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(e => e.PermissionName)
                    .HasColumnName("permission_name")
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(e => e.Description)
                    .HasColumnName("description")
                    .HasMaxLength(200)
                    .IsRequired(false);

                entity.Property(e => e.ModuleId)
                    .HasColumnName("module_id")
                    .IsRequired();

                entity.HasIndex(e => e.PermissionCode)
                    .HasDatabaseName("IX_permissions_permission_code")
                    .IsUnique();

                // العلاقة مع Module
                entity.HasOne(e => e.Module)
                    .WithMany(m => m.Permissions)
                    .HasForeignKey(e => e.ModuleId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ========== Configure RolePermission (many-to-many) ==========
            modelBuilder.Entity<RolePermission>(entity =>
            {
                entity.ToTable("role_permissions", "core");

                entity.HasKey(e => new { e.RoleId, e.PermissionId })
                    .HasName("PK_role_permissions");

                entity.Property(e => e.RoleId)
                    .HasColumnName("role_id");
                
                entity.Property(e => e.PermissionId)
                    .HasColumnName("permission_id");
                
                entity.Property(e => e.GrantedBy)
                    .HasColumnName("granted_by");
                
                entity.Property(e => e.GrantedAt)
                    .HasColumnName("granted_at");

                entity.HasOne(e => e.Role)
                    .WithMany(e => e.RolePermissions)
                    .HasForeignKey(e => e.RoleId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.Permission)
                    .WithMany(e => e.RolePermissions)
                    .HasForeignKey(e => e.PermissionId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ========== Configure UserRole (many-to-many) ==========
            modelBuilder.Entity<UserRole>(entity =>
            {
                entity.ToTable("user_roles", "core");

                entity.HasKey(e => new { e.UserId, e.RoleId })
                    .HasName("PK_user_roles");

                entity.Property(e => e.UserId)
                    .HasColumnName("user_id");
                
                entity.Property(e => e.RoleId)
                    .HasColumnName("role_id");
                
                entity.Property(e => e.AssignedAt)
                    .HasColumnName("assigned_at")
                    .IsRequired();

                entity.Property(e => e.AssignedBy)
                    .HasColumnName("assigned_by")
                    .IsRequired(false);

                entity.HasOne(e => e.User)
                    .WithMany(e => e.UserRoles)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.Role)
                    .WithMany(e => e.UserRoles)
                    .HasForeignKey(e => e.RoleId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ========== Configure UserSession ==========
            modelBuilder.Entity<UserSession>(entity =>
            {
                entity.ToTable("user_sessions", "core");

                entity.HasKey(e => e.Id)
                    .HasName("PK_user_sessions");
                
                entity.Property(e => e.Id)
                    .HasColumnName("session_id")
                    .UseIdentityAlwaysColumn();

                entity.Property(e => e.UserId)
                    .HasColumnName("user_id")
                    .IsRequired();

                entity.Property(e => e.SessionToken)
                    .HasColumnName("session_token")
                    .HasMaxLength(500)
                    .IsRequired();

                entity.Property(e => e.RefreshToken)
                    .HasColumnName("refresh_token")
                    .HasMaxLength(500)
                    .IsRequired(false);

                entity.Property(e => e.IpAddress)
                    .HasColumnName("ip_address")
                    .HasMaxLength(50)
                    .IsRequired();

                entity.Property(e => e.UserAgent)
                    .HasColumnName("user_agent")
                    .HasMaxLength(500)
                    .IsRequired(false);

                entity.Property(e => e.ExpiresAt)
                    .HasColumnName("expires_at")
                    .IsRequired();

                entity.Property(e => e.LastActivityAt)
                    .HasColumnName("last_activity_at")
                    .IsRequired();

                entity.Property(e => e.IsRevoked)
                    .HasColumnName("is_revoked")
                    .IsRequired()
                    .HasDefaultValue(false);

                entity.HasIndex(e => e.SessionToken)
                    .HasDatabaseName("IX_user_sessions_session_token")
                    .IsUnique();

                entity.HasIndex(e => e.RefreshToken)
                    .HasDatabaseName("IX_user_sessions_refresh_token")
                    .IsUnique();

                entity.HasOne(e => e.User)
                    .WithMany(e => e.Sessions)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ========== Configure LoginAttempt ==========
            modelBuilder.Entity<LoginAttempt>(entity =>
            {
                entity.ToTable("login_attempts", "core");
                
                entity.HasKey(e => e.Id)
                    .HasName("PK_login_attempts");
                
                entity.Property(e => e.Id)
                    .HasColumnName("attempt_id")
                    .UseIdentityAlwaysColumn();
                
                entity.Property(e => e.Username)
                    .HasColumnName("username")
                    .HasMaxLength(50)
                    .IsRequired();
                
                entity.Property(e => e.IpAddress)
                    .HasColumnName("ip_address")
                    .HasMaxLength(45);
                
                entity.Property(e => e.UserAgent)
                    .HasColumnName("user_agent")
                    .HasMaxLength(500);
                
                entity.Property(e => e.AttemptTime)
                    .HasColumnName("attempt_time")
                    .IsRequired();
                
                entity.Property(e => e.Success)
                    .HasColumnName("success")
                    .IsRequired();
                
                entity.Property(e => e.FailureReason)
                    .HasColumnName("failure_reason")
                    .HasMaxLength(200);
                
                entity.HasIndex(e => new { e.Username, e.AttemptTime })
                    .HasDatabaseName("idx_login_attempts_username_attempt_time");
            });

            // ========== Configure Module ==========
            modelBuilder.Entity<ModuleEntity>(entity =>
            {
                entity.ToTable("modules", "core");
                
                entity.HasKey(e => e.Id)
                    .HasName("PK_modules");
                
                entity.Property(e => e.Id)
                    .HasColumnName("module_id")
                    .UseIdentityAlwaysColumn();

                entity.Property(e => e.ModuleCode)
                    .HasColumnName("module_code")
                    .HasMaxLength(50)
                    .IsRequired();

                entity.Property(e => e.ModuleName)
                    .HasColumnName("module_name")
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(e => e.ModuleDescription)
                    .HasColumnName("description")
                    .HasMaxLength(500)
                    .IsRequired(false);

                entity.Property(e => e.Version)
                    .HasColumnName("version")
                    .HasMaxLength(20)
                    .IsRequired();

                entity.Property(e => e.IsActive)
                    .HasColumnName("is_active")
                    .IsRequired()
                    .HasDefaultValue(true);

                entity.HasIndex(e => e.ModuleCode)
                    .HasDatabaseName("IX_modules_module_code")
                    .IsUnique();

                // Permissions relationship
                entity.HasMany(e => e.Permissions)
                    .WithOne(e => e.Module)
                    .HasForeignKey(e => e.ModuleId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ========== Configure PasswordReset ==========
            modelBuilder.Entity<PasswordReset>(entity =>
            {
                entity.ToTable("password_resets", "core");

                entity.HasKey(e => e.Id)
                    .HasName("PK_password_resets");
                
                entity.Property(e => e.Id)
                    .HasColumnName("reset_id")
                    .UseIdentityAlwaysColumn();

                entity.Property(e => e.UserId)
                    .HasColumnName("user_id")
                    .IsRequired();

                entity.Property(e => e.Token)
                    .HasColumnName("token")
                    .HasMaxLength(500)
                    .IsRequired();

                entity.Property(e => e.ExpiresAt)
                    .HasColumnName("expires_at")
                    .IsRequired();

                entity.Property(e => e.CreatedAt)
                    .HasColumnName("created_at")
                    .IsRequired();

                entity.Property(e => e.IsUsed)
                    .HasColumnName("is_used")
                    .IsRequired()
                    .HasDefaultValue(false);

                entity.HasIndex(e => e.Token)
                    .HasDatabaseName("IX_password_resets_token")
                    .IsUnique();

                entity.HasIndex(e => e.UserId)
                    .HasDatabaseName("IX_password_resets_user_id");

                entity.HasOne<User>()
                    .WithMany()
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            base.OnModelCreating(modelBuilder);
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return await base.SaveChangesAsync(cancellationToken);
        }

        public async Task BeginTransactionAsync()
        {
            if (_currentTransaction != null)
            {
                return;
            }

            _currentTransaction = await Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            try
            {
                await SaveChangesAsync();
                if (_currentTransaction != null)
                {
                    await _currentTransaction.CommitAsync();
                }
            }
            catch
            {
                await RollbackTransactionAsync();
                throw;
            }
            finally
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.DisposeAsync();
                    _currentTransaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            try
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.RollbackAsync();
                }
            }
            finally
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.DisposeAsync();
                    _currentTransaction = null;
                }
            }
        }
    }
}