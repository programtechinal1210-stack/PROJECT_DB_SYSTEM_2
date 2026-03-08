FROM postgis/postgis:15-3.4

LABEL maintainer="Project DB System Team"
LABEL version="1.0.0"
LABEL description="PostgreSQL with PostGIS for Project DB System"

# تثبيت أدوات إضافية
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    vim \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مجلد للنسخ الاحتياطية
RUN mkdir -p /backups && chown postgres:postgres /backups

# نسخ سكريبتات التهيئة (ملاحظة: استخدم المجلد الموجود)
COPY ./init-scripts/*.sql /docker-entrypoint-initdb.d/

# إعدادات اللغة العربية
RUN localedef -i ar_SA -c -f UTF-8 -A /usr/share/locale/locale.alias ar_SA.UTF-8 || true
ENV LANG ar_SA.utf8
ENV LC_ALL ar_SA.utf8

# فتح المنفذ
EXPOSE 5432
