📋 تقرير المهام - المطور الثالث (Assets + Field Module)

🎫 معلومات أساسية

 
👤 المطور المطور 3 🔧
📦 الوحدات Assets Module + Field Module
🌿 الفرع assets-field-module
🎯 الدور بناء نظام الأصول والمعدات والمواقع الميدانية
🤝 يعتمد على المطور 1 (Core) + المطور 2 (HR)

---

🚀 الخطوة 1: تجهيز قاعدة البيانات

✅ شغّل Docker أولاً

```bash
cd E:\PROJECT_DB_SYSTEM_2\infrastructure\docker
docker-compose up -d
```

✅ تأكد من تشغيل PostgreSQL

```bash
docker ps
# يجب أن ترى postgres, redis, pgadmin
```

✅ شغّل ملفات Bootstrap (مرة واحدة فقط)

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

docker exec -i project_db_postgres psql -U admin -d postgres < bootstrap/01-create-database.sql
docker exec -i project_db_postgres psql -U admin -d project_db < bootstrap/02-create-schemas.sql
docker exec -i project_db_postgres psql -U admin -d project_db < bootstrap/03-create-roles.sql
docker exec -i project_db_postgres psql -U admin -d project_db < bootstrap/04-create-extensions.sql
```

---

📁 الخطوة 2: تشغيل جداول Assets Module

✅ شغّل جداول Assets

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

# أنواع الآلات والموارد
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machine_types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machine_statuses.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/resource_types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/device_types.sql

# الأصول الرئيسية
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machines.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/tools.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/resources.sql

# العلاقات والتشغيل
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machine_resources.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machine_assignments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/tool_assignments.sql

# الصيانة
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/maintenance_records.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/objectives.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Tables/machine_objectives.sql
```

✅ شغّل بيانات Assets الأولية

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/04-assets/001-machine-statuses.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/04-assets/001-resource-types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/04-assets/002-device-types.sql
```

✅ شغّل فهارس Assets

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Indexes/assets_indexes.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Triggers/update_machine_maintenance.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/assets/Triggers/update_tool_status.sql
```

✅ تحقق من التثبيت

```bash
docker exec -it project_db_postgres psql -U admin -d project_db -c "\dt assets.*"
# يجب أن ترى 16 جدول
```

---

📁 الخطوة 3: تشغيل جداول Field Module

✅ شغّل جداول Field (مع PostGIS)

```bash
cd E:\PROJECT_DB_SYSTEM_2\database

# الأنواع الأساسية
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/site_types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/terrain_types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/exploration_phases.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/facility_types.sql

# المواقع الرئيسية
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/locations.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/geological_sites.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/location_facilities.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/facility_properties.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/facility_property_values.sql

# المهام الميدانية
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/tasks.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/task_assignments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/task_dependencies.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/task_comments.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Tables/exploration_materials.sql
```

✅ شغّل بيانات Field الأولية

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/05-field/001-site-types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/05-field/002-terrain-types.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/05-field/003-exploration-phases.sql
docker exec -i project_db_postgres psql -U admin -d project_db < seeds/05-field/004-facility-types.sql
```

✅ شغّل فهارس Field

```bash
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Indexes/field_indexes.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Triggers/check_task_dependencies_trigger.sql
docker exec -i project_db_postgres psql -U admin -d project_db < structure/field/Triggers/update_task_status_trigger.sql
```

✅ تحقق من التثبيت

```bash
docker exec -it project_db_postgres psql -U admin -d project_db -c "\dt field.*"
# يجب أن ترى 15 جدول

# تحقق من PostGIS
docker exec -it project_db_postgres psql -U admin -d project_db -c "SELECT postgis_version();"
```

---

✅ الخطوة 4: قائمة المهام البرمجية

📁 المهمة 1: Domain Layer (أيام 1-2)

إنشاء ملفات الكيانات - Assets:

الملف المسار
Machine.cs 04-Assets.Module/Domain/Entities/Machine.cs
Tool.cs 04-Assets.Module/Domain/Entities/Tool.cs
Resource.cs 04-Assets.Module/Domain/Entities/Resource.cs
MaintenanceRecord.cs 04-Assets.Module/Domain/Entities/MaintenanceRecord.cs
MachineAssignment.cs 04-Assets.Module/Domain/Entities/MachineAssignment.cs

إنشاء ملفات الكيانات - Field:

الملف المسار
Location.cs 05-Field.Module/Domain/Entities/Location.cs
GeologicalSite.cs 05-Field.Module/Domain/Entities/GeologicalSite.cs
FieldTask.cs 05-Field.Module/Domain/Entities/FieldTask.cs
TaskAssignment.cs 05-Field.Module/Domain/Entities/TaskAssignment.cs
Facility.cs 05-Field.Module/Domain/Entities/Facility.cs

إنشاء Enums:

الملف القيم
MachineStatus.cs Active, Inactive, Maintenance, Reserved, Scrapped
ToolStatus.cs Available, InUse, Maintenance, Lost, Damaged
LocationStatus.cs Safe, Contested, Dangerous, Restricted
TaskStatus.cs Scheduled, InProgress, Completed, Cancelled
TaskPriority.cs Low, Medium, High, Critical

---

📁 المهمة 2: Infrastructure Layer (أيام 3-4)

إنشاء DbContext والـ Repositories - Assets:

الملف المسار
AssetsDbContext.cs 04-Assets.Module/Infrastructure/Persistence/AssetsDbContext.cs
MachineRepository.cs 04-Assets.Module/Infrastructure/Persistence/Repositories/MachineRepository.cs
ToolRepository.cs 04-Assets.Module/Infrastructure/Persistence/Repositories/ToolRepository.cs
MaintenanceRepository.cs 04-Assets.Module/Infrastructure/Persistence/Repositories/MaintenanceRepository.cs

إنشاء DbContext والـ Repositories - Field:

الملف المسار
FieldDbContext.cs 05-Field.Module/Infrastructure/Persistence/FieldDbContext.cs
LocationRepository.cs 05-Field.Module/Infrastructure/Persistence/Repositories/LocationRepository.cs
TaskRepository.cs 05-Field.Module/Infrastructure/Persistence/Repositories/TaskRepository.cs

---

📁 المهمة 3: Application Layer (أيام 5-8)

إنشاء Commands و Queries - Assets:

الملف الوظيفة
CreateMachineCommand.cs إضافة آلة جديدة
UpdateMachineStatusCommand.cs تحديث حالة آلة
AssignMachineCommand.cs تخصيص آلة لموظف
GetMachinesQuery.cs عرض الآلات مع تصفية
GetMachinesDueForMaintenanceQuery.cs الآلات المستحقة للصيانة
CreateMaintenanceRecordCommand.cs تسجيل صيانة

إنشاء Commands و Queries - Field:

الملف الوظيفة
CreateLocationCommand.cs إضافة موقع جديد
UpdateLocationCommand.cs تعديل بيانات موقع
GetNearbyLocationsQuery.cs البحث عن مواقع قريبة
CreateFieldTaskCommand.cs إنشاء مهمة ميدانية
AssignTaskCommand.cs تخصيص مهمة لموظف
UpdateTaskStatusCommand.cs تحديث حالة مهمة
GetTasksByLocationQuery.cs مهام موقع معين

---

📁 المهمة 4: API Layer (أيام 9-10)

إنشاء Controllers - Assets:

الملف الوظيفة
MachinesController.cs إدارة الآلات (CRUD + حالة + صيانة)
ToolsController.cs إدارة الأدوات
AssetsMasterDataController.cs أنواع الآلات والموارد

إنشاء Controllers - Field:

الملف الوظيفة
LocationsController.cs إدارة المواقع (مع إحداثيات)
FieldTasksController.cs إدارة المهام الميدانية
FieldMasterDataController.cs أنواع المواقع والتضاريس

---

📁 المهمة 5: الخدمات المتخصصة (يوم 11)

إنشاء خدمات خاصة:

الملف الوظيفة
GeoLocationService.cs حساب المسافات، البحث عن مواقع قريبة
MaintenanceScheduler.cs جدولة الصيانة الدورية
MachineAvailabilityService.cs التحقق من توفر الآلات

---

📁 المهمة 6: التكامل مع المطورين الآخرين (يوم 11)

إضافة مرجع إلى Core Module:

```bash
cd E:\PROJECT_DB_SYSTEM_2\backend\Modules\04-Assets.Module
dotnet add reference ../01-Core.Module/Core.Module.csproj

cd E:\PROJECT_DB_SYSTEM_2\backend\Modules\05-Field.Module
dotnet add reference ../01-Core.Module/Core.Module.csproj
```

استخدم خدمات Core:

· ICurrentUserService - لمعرفة المستخدم الحالي وصلاحياته
· ICacheService - لتسريع الاستعلامات المتكررة

استخدم خدمات HR (لاحقاً):

· IEmployeeService - لربط المعدات والموظفين
· IBranchService - لربط المواقع بالفروع

---

📁 المهمة 7: اختبارات (يوم 12)

إنشاء اختبارات:

· Unit Tests للـ Domain Entities
· Unit Tests للـ Commands
· Integration Tests للـ APIs
· اختبارات للدوالمكانية (GeoLocationService)

---

✅ الخطوة 5: تشغيل الاختبارات

```bash
cd E:\PROJECT_DB_SYSTEM_2
dotnet test
```

---

✅ الخطوة 6: رفع الكود إلى GitHub

```bash
cd E:\PROJECT_DB_SYSTEM_2
git checkout assets-field-module
git add .
git commit -m "Complete Assets and Field Modules"
git push origin assets-field-module
```

ثم اذهب إلى GitHub وأنشئ Pull Request إلى فرع develop

---

📊 جدول متابعة المهام

الأسبوع المهام
الأسبوع 1 Domain Entities + Infrastructure
الأسبوع 2 Application Layer (Assets)
الأسبوع 3 Application Layer (Field) + APIs
الأسبوع 4 خدمات متخصصة + تكامل + اختبارات

---

✅ قائمة التحقق اليومية

قبل البدء:

· Docker شغال و PostgreSQL متصل
· جداول Assets (16 جدول) موجودة
· جداول Field (15 جدول) موجودة
· PostGIS مفعل

أثناء العمل - Assets:

· أقدر أضيف آلة جديدة
· أقدر أغير حالة آلة
· أقدر أشوف الآلات المستحقة للصيانة
· أقدر أخصص آلة لموظف

أثناء العمل - Field:

· أقدر أضيف موقع بإحداثيات
· أقدر أبحث عن مواقع قريبة
· أقدر أضيف مهمة في موقع
· أقدر أخصص مهمة لموظف

للتسليم:

· كل الاختبارات تمر
· APIs تعمل مع Postman
· الكود مرفوع على GitHub

---

🆘 مساعدة سريعة

المشكلة الحل
قاعدة البيانات لا تعمل docker ps - تأكد أن PostgreSQL شغال
PostGIS غير موجود شغل bootstrap/04-create-extensions.sql
الجداول غير موجودة راجع أوامر تشغيل SQL في الخطوة 2 و 3
الإحداثيات لا تعمل تأكد من تثبيت PostGIS
لا أجد ICurrentUserService أضف reference إلى Core Module

---

🎯 التسليمات النهائية

· جميع ملفات Domain مكتوبة
· Repositories تعمل مع قاعدة البيانات
· APIs تعمل (تستقبل طلبات وترد)
· GeoLocationService يعمل (حساب المسافات)
· التكامل مع Core يعمل
· الاختبارات كلها تمر
· الكود مرفوع على فرع assets-field-module

---

🔗 روابط مهمة

الرابط الوصف
docs/TASKS-Module3.md ملف المهام هذا
database/structure/assets/ ملفات SQL الخاصة بالأصول
database/structure/field/ ملفات SQL الخاصة بالمواقع
04-Assets.Module/ مجلد مشروع Assets
05-Field.Module/ مجلد مشروع Field

---

🎉 تهانينا!

بعد إكمال هذه المهام، ستكون قد بنيت:

· ✅ نظام أصول متكامل (آلات، أدوات، صيانة)
· ✅ نظام مواقع جغرافي (بإحداثيات دقيقة)
· ✅ نظام مهام ميدانية (تخطيط وتنفيذ)
· ✅ خدمات ذكية (بحث عن مواقع قريبة، جدولة صيانة)

بالتوفيق! 🚀
