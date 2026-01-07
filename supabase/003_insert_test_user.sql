INSERT INTO users (id, email, display_name, color, is_admin, treatment_types)
SELECT 
    id,
    'test@test.com',
    '김원장',
    '#4ECDC4',
    false,
    ARRAY['눈썹문신', '입술문신', '애교살']
FROM auth.users 
WHERE email = 'test@test.com';
