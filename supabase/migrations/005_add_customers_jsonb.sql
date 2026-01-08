ALTER TABLE appointments 
ADD COLUMN customers JSONB DEFAULT '[]'::jsonb;

UPDATE appointments 
SET customers = jsonb_build_array(
    jsonb_build_object(
        'name', customer_name,
        'phone', customer_phone
    )
)
WHERE customers = '[]'::jsonb OR customers IS NULL;

ALTER TABLE appointments 
ALTER COLUMN customers SET NOT NULL;
