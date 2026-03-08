 
#!/bin/bash
# =============================================
# FILE: scripts/wait-for-it.sh
# PURPOSE: انتظار اتصال قاعدة البيانات
# =============================================

set -e

host="$1"
port="$2"
shift 2
cmd="$@"

until PGPASSWORD=$DB_PASSWORD psql -h "$host" -p "$port" -U "project_user" -d "project_db_system" -c '\q' 2>/dev/null; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up - executing command"
exec $cmd