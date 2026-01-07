INSERT INTO users (id, email, display_name, color, is_admin, treatment_types)
SELECT 
    id,
    'admin@kimuu.com',
    '관리자',
    '#FF6B6B',
    true,
    ARRAY['눈썹문신', '입술문신', '애교살']
FROM auth.users 
WHERE email = 'admin@kimuu.com';
