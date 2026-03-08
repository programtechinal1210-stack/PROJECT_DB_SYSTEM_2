 
# تشغيل جميع المايجريشنز بالترتيب
psql -U project_user -d project_db_system -f migrations/migrations-journal.sql
psql -U project_user -d project_db_system -f migrations/1.0.0/001-initial-core-tables.sql
psql -U project_user -d project_db_system -f migrations/1.0.0/002-initial-organization-tables.sql
psql -U project_user -d project_db_system -f migrations/1.0.0/003-initial-hr-tables.sql
psql -U project_user -d project_db_system -f migrations/1.0.0/004-initial-assets-tables.sql
psql -U project_user -d project_db_system -f migrations/1.0.0/005-initial-field-tables.sql