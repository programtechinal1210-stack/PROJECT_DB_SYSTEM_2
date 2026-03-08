 
-- =============================================
-- FILE: seeds/03-hr/003-training-courses.sql
-- PURPOSE: إدراج الدورات التدريبية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج الدورات التدريبية
INSERT INTO hr.training_courses (
    course_code,
    course_name_ar,
    course_name_en,
    category,
    duration_days,
    provider,
    is_active
) VALUES
-- دورات تقنية
('CS-101', 'أساسيات الحاسوب', 'Computer Basics', 'تقنية', 3, 'معهد تقني', true),
('CS-201', 'برمجة بايثون', 'Python Programming', 'برمجة', 5, 'أكاديمية برمجة', true),
('CS-301', 'قواعد البيانات', 'Database Management', 'قواعد بيانات', 4, 'معهد تقني', true),
('CS-401', 'أمن المعلومات', 'Cyber Security', 'أمن معلومات', 5, 'مركز أمني', true),
('CS-501', 'الذكاء الاصطناعي', 'Artificial Intelligence', 'تقنية متقدمة', 7, 'أكاديمية متخصصة', true),

-- دورات إدارية
('MG-101', 'مهارات إدارية', 'Management Skills', 'إدارة', 3, 'مركز تدريب إداري', true),
('MG-201', 'إدارة المشاريع', 'Project Management', 'إدارة مشاريع', 5, 'معهد项目管理', true),
('MG-301', 'القيادة الفعالة', 'Effective Leadership', 'قيادة', 4, 'مركز تطوير قيادي', true),
('MG-401', 'إدارة الوقت', 'Time Management', 'تطوير ذاتي', 2, 'مركز تدريب', true),
('MG-501', 'التخطيط الاستراتيجي', 'Strategic Planning', 'تخطيط', 6, 'أكاديمية إستراتيجية', true),

-- دورات مالية
('FN-101', 'أساسيات المحاسبة', 'Accounting Basics', 'مالية', 4, 'معهد مالي', true),
('FN-201', 'التحليل المالي', 'Financial Analysis', 'تحليل مالي', 5, 'مركز مالي', true),
('FN-301', 'إعداد الميزانيات', 'Budgeting', 'تخطيط مالي', 3, 'معهد مالي', true),
('FN-401', 'الرقابة المالية', 'Financial Control', 'رقابة', 4, 'مركز تدقيق', true),

-- دورات موارد بشرية
('HR-101', 'أساسيات الموارد البشرية', 'HR Basics', 'موارد بشرية', 4, 'معهد HR', true),
('HR-201', 'التوظيف والمقابلات', 'Recruitment & Interviews', 'توظيف', 3, 'مركز توظيف', true),
('HR-301', 'تقييم الأداء', 'Performance Evaluation', 'تقييم', 2, 'معهد HR', true),
('HR-401', 'تخطيط المسار الوظيفي', 'Career Path Planning', 'تطوير', 3, 'مركز تدريب', true),

-- دورات لغة
('LG-101', 'اللغة الإنجليزية', 'English Language', 'لغات', 30, 'معهد لغوي', true),
('LG-201', 'مصطلحات تقنية بالإنجليزية', 'Technical English', 'لغات', 15, 'معهد لغوي', true),

-- دورات سلامة
('SF-101', 'السلامة المهنية', 'Occupational Safety', 'سلامة', 2, 'مركز سلامة', true),
('SF-201', 'الإسعافات الأولية', 'First Aid', 'صحة', 2, 'مركز طبي', true),
('SF-301', 'السلامة في المواقع', 'Site Safety', 'سلامة', 3, 'مركز سلامة', true)
ON CONFLICT (course_code) DO UPDATE SET
    course_name_ar = EXCLUDED.course_name_ar,
    course_name_en = EXCLUDED.course_name_en,
    category = EXCLUDED.category,
    duration_days = EXCLUDED.duration_days,
    provider = EXCLUDED.provider;

-- عرض عدد الدورات
SELECT 
    '✅ Training courses seeded' AS status,
    COUNT(*) AS total_courses
FROM hr.training_courses;