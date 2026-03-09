## 📋 **تقرير المهام - المطور الثاني (HR + Organization Module)**

### 🎫 **معلومات أساسية**

| | |
|------|------|
| **المطور** | المطور 2 👥 |
| **الوحدة** | HR Module + Organization Module |
| **الفرع** | `hr-org-module` |
| **الهدف** | بناء نظام الموظفين والهيكل التنظيمي |

---

## 🚀 **الخطوة 1: تجهيز قاعدة البيانات**

### ✅ **شغّل Docker أولاً**

```bash
cd E:\PROJECT_DB_SYSTEM_2\infrastructure\docker
docker-compose up -d
```

### ✅ **تأكد من تشغيل PostgreSQL**

```bash
docker ps
# يجب أن ترى postgres, redis, pgadmin
```

### ✅ **شغّل ملفات Bootstrap (مرة واحدة فقط)**

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

docker exec -i project_db_postgres psql -U admin -d postgres < bootstrap/01-create-database.sql
docker exec -i project_db_postgres psql -U admin -d project_db < bootstrap/02-create-schemas.sql
docker exec -i project_db_postgres psql -U admin -d project_db < bootstrap/03-create-roles.sql
```

---

## 📁 **الخطوة 2: تشغيل جداول Organization Module**

### ✅ **شغّل جداول Organization**

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/branch_types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/operational_statuses.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/branches.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/branch_closure.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/departments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/sections.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/branch_departments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Tables/branch_department_sections.sql
```

### ✅ **شغّل بيانات Organization الأولية**

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/02-organization/001-departments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/02-organization/002-branches.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/02-organization/003-branch-types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/02-organization/003-sections.sql
```

### ✅ **شغّل فهارس Organization**

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Indexes/organization_indexes.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/organization/Triggers/branch_closure_trigger.sql
```

### ✅ **تحقق من التثبيت**

```bash
docker exec -it project_db_postgres psql -U admin -d project_db -c "\dt organization.*"
# يجب أن ترى 11 جدول
```

---

## 📁 **الخطوة 3: تشغيل جداول HR Module**

### ✅ **شغّل جداول HR**

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/employees.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/attendance.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/qualifications.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/training_courses.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/employee_qualifications.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/employee_training.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/employee_assignments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/job_levels.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Tables/reading_levels.sql
```

### ✅ **شغّل بيانات HR الأولية**

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/03-hr/001-qualification-types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/03-hr/001-qualifications.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/03-hr/002-training-courses.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/03-hr/004-job-levels.sql
```

### ✅ **شغّل فهارس HR**

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Indexes/hr_indexes.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/hr/Triggers/update_employee_current_assignment.sql
```

### ✅ **تحقق من التثبيت**

```bash
docker exec -it project_db_postgres psql -U admin -d project_db -c "\dt hr.*"
# يجب أن ترى 17 جدول
```

---

## ✅ **الخطوة 4: قائمة المهام البرمجية**

### 📁 **المهمة 1: Domain Layer (أيام 1-2)**

**إنشاء ملفات الكيانات:**

| الملف | المسار |
|-------|--------|
| Branch.cs | `02-Organization.Module/Domain/Entities/Branch.cs` |
| Department.cs | `02-Organization.Module/Domain/Entities/Department.cs` |
| Section.cs | `02-Organization.Module/Domain/Entities/Section.cs` |
| BranchClosure.cs | `02-Organization.Module/Domain/Entities/BranchClosure.cs` |
| Employee.cs | `03-HR.Module/Domain/Entities/Employee.cs` |
| Attendance.cs | `03-HR.Module/Domain/Entities/Attendance.cs` |
| Qualification.cs | `03-HR.Module/Domain/Entities/Qualification.cs` |
| TrainingCourse.cs | `03-HR.Module/Domain/Entities/TrainingCourse.cs` |

**إنشاء Enums:**

| الملف | القيم |
|-------|-------|
| BranchType.cs | `Main, Sub, Field` |
| EmployeeStatus.cs | `Active, OnVacation, Terminated` |
| AttendanceStatus.cs | `Present, Absent, Late, Vacation` |

---

### 📁 **المهمة 2: Infrastructure Layer (أيام 3-4)**

**إنشاء DbContext والـ Repositories:**

| الملف | المسار |
|-------|--------|
| OrganizationDbContext.cs | `02-Organization.Module/Infrastructure/Persistence/OrganizationDbContext.cs` |
| BranchRepository.cs | `02-Organization.Module/Infrastructure/Persistence/Repositories/BranchRepository.cs` |
| HRDbContext.cs | `03-HR.Module/Infrastructure/Persistence/HRDbContext.cs` |
| EmployeeRepository.cs | `03-HR.Module/Infrastructure/Persistence/Repositories/EmployeeRepository.cs` |
| AttendanceRepository.cs | `03-HR.Module/Infrastructure/Persistence/Repositories/AttendanceRepository.cs` |

---

### 📁 **المهمة 3: Application Layer (أيام 5-8)**

**إنشاء Commands و Queries:**

| الملف | الوظيفة |
|-------|---------|
| CreateBranchCommand.cs | إضافة فرع جديد |
| GetBranchHierarchyQuery.cs | عرض الشجرة التنظيمية |
| MoveBranchCommand.cs | نقل فرع إلى أب جديد |
| CreateEmployeeCommand.cs | إضافة موظف جديد |
| UpdateEmployeeCommand.cs | تعديل بيانات موظف |
| GetEmployeesQuery.cs | عرض الموظفين مع بحث وتصفية |
| CheckInCommand.cs | تسجيل حضور |
| CheckOutCommand.cs | تسجيل انصراف |
| GetMonthlyAttendanceQuery.cs | تقرير الحضور الشهري |

---

### 📁 **المهمة 4: API Layer (أيام 9-10)**

**إنشاء Controllers:**

| الملف | الوظيفة |
|-------|---------|
| BranchesController.cs | إدارة الفروع |
| DepartmentsController.cs | إدارة الإدارات |
| EmployeesController.cs | إدارة الموظفين |
| AttendanceController.cs | تسجيل الحضور |

---

### 📁 **المهمة 5: التكامل مع Core (يوم 11)**

**إضافة مرجع إلى Core Module:**

```bash
cd E:\PROJECT_DB_SYSTEM_2\backend\Modules\03-HR.Module
dotnet add reference ../01-Core.Module/Core.Module.csproj
```

**استخدم خدمات Core في الكود:**
- `ICurrentUserService` - لمعرفة المستخدم الحالي وصلاحياته
- `ICacheService` - لتسريع الاستعلامات المتكررة

---

### 📁 **المهمة 6: اختبارات (يوم 12)**

**إنشاء اختبارات:**
- Unit Tests للـ Domain Entities
- Unit Tests للـ Commands
- Integration Tests للـ APIs

---

## ✅ **الخطوة 5: تشغيل الاختبارات**

```bash
cd E:\PROJECT_DB_SYSTEM_2
dotnet test
```

---

## ✅ **الخطوة 6: رفع الكود إلى GitHub**

```bash
cd E:\PROJECT_DB_SYSTEM_2
git checkout hr-org-module
git add .
git commit -m "Complete HR and Organization Modules"
git push origin hr-org-module
```

ثم اذهب إلى GitHub وأنشئ Pull Request إلى فرع `develop`

---

## 📊 **جدول متابعة المهام**

| اليوم | المهام |
|-------|--------|
| يوم 1-2 | إنشاء Domain Entities |
| يوم 3-4 | إنشاء Infrastructure (DbContext + Repositories) |
| يوم 5-6 | إنشاء Commands لـ Organization |
| يوم 7-8 | إنشاء Commands لـ HR |
| يوم 9-10 | إنشاء APIs |
| يوم 11 | التكامل مع Core Module |
| يوم 12 | اختبارات وتسليم |

---

## 🆘 **مساعدة سريعة**

| المشكلة | الحل |
|---------|------|
| قاعدة البيانات لا تعمل | `docker ps` - تأكد أن PostgreSQL شغال |
| الجداول غير موجودة | راجع أوامر تشغيل SQL في الخطوة 2 و 3 |
| لا أجد ICurrentUserService | أضف reference إلى Core Module |
| الاختبارات تفشل | اقرأ الخطأ وحاول مرة أخرى |

---

## 🎯 **التسليمات النهائية**

- [ ] جميع ملفات Domain مكتوبة
- [ ] Repositories تعمل مع قاعدة البيانات
- [ ] APIs تعمل (تستقبل طلبات وترد)
- [ ] التكامل مع Core (ICurrentUserService) يعمل
- [ ] الاختبارات كلها تمر
- [ ] الكود مرفوع على GitHub

---

**✅ هذا التقرير جاهز ويمكن وضعه في ملف `TASKS-Module2.md` داخل مجلد `docs` على GitHub**
