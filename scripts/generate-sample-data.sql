-- PostgreSQL Performance Cookbook Sample Data Generator
-- Creates realistic healthcare data

CREATE OR REPLACE FUNCTION random_last_name() RETURNS TEXT AS $$
DECLARE
    names TEXT[] := ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis'];
    zipf_rand FLOAT;
    idx INTEGER;
BEGIN
    zipf_rand := power(random(), -0.8);
    idx := GREATEST(1, LEAST(array_length(names, 1), ceil(zipf_rand * array_length(names, 1))));
    RETURN names[idx];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_first_name() RETURNS TEXT AS $$
DECLARE
    male_names TEXT[] := ARRAY['James','Robert','John','Michael','David'];
    female_names TEXT[] := ARRAY['Mary','Patricia','Jennifer','Linda','Elizabeth'];
BEGIN
    IF random() > 0.5 THEN RETURN male_names[ceil(random()*5)];
    ELSE RETURN female_names[ceil(random()*5)]; END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_hcpcs_code() RETURNS TEXT AS $$
DECLARE
    common_codes TEXT[] := ARRAY['E1390','E0601','A4604','K0001','E0143'];
BEGIN
    IF random() < 0.8 THEN RETURN common_codes[ceil(random()*5)];
    ELSE RETURN chr(65+floor(random()*26)) || floor(random()*10000)::TEXT; END IF;
END;
$$ LANGUAGE plpgsql;

INSERT INTO patients (first_name, last_name, date_of_birth, ssn_masked, insurance_id, created_at)
SELECT random_first_name(), random_last_name(),
    '1950-01-01'::date + (random()*365*50)::integer,
    'XXX-XX-' || lpad(floor(random()*10000)::text, 4, '0'),
    CASE WHEN random()<0.85 THEN 'INS-'||lpad(floor(random()*1000000)::text, 6, '0') ELSE NULL END,
    '2020-01-01'::timestamp + (random()*365*2||' days')::interval
FROM generate_series(1, 500000);

ALTER TABLE documents ADD COLUMN IF NOT EXISTS metadata JSONB;

INSERT INTO documents (patient_id, doc_type, status, content_text, metadata, created_at)
SELECT ceil(random()*500000),
    CASE floor(random()*4) WHEN 0 THEN 'order'::doc_type WHEN 1 THEN 'note'::doc_type WHEN 2 THEN 'lab'::doc_type ELSE 'imaging'::doc_type END,
    CASE WHEN random()<0.70 THEN 'completed'::doc_status WHEN random()<0.90 THEN 'processing'::doc_status WHEN random()<0.98 THEN 'pending'::doc_status ELSE 'failed'::doc_status END,
    'Medical document content. Diagnosis codes. Treatment notes. ' || repeat('Sample text. ', floor(random()*20+5)::integer),
    json_build_object('priority', CASE WHEN random()<0.05 THEN 'urgent' WHEN random()<0.25 THEN 'high' ELSE 'normal' END, 'provider_id', floor(random()*1000))::jsonb,
    '2020-01-01'::timestamp + (random()*365*2||' days')::interval
FROM generate_series(1, 500000);

INSERT INTO orders (patient_id, document_id, hcpcs_code, description, status, total_amount, created_at)
SELECT ceil(random()*500000), CASE WHEN random()<0.8 THEN ceil(random()*500000) ELSE NULL END,
    random_hcpcs_code(), 'Medical equipment/service', 
    CASE WHEN random()<0.65 THEN 'completed'::doc_status WHEN random()<0.85 THEN 'processing'::doc_status WHEN random()<0.95 THEN 'pending'::doc_status ELSE 'failed'::doc_status END,
    (random()*5000+50)::numeric(10,2), '2020-01-01'::timestamp + (random()*365*2||' days')::interval
FROM generate_series(1, 1000000);

INSERT INTO line_items (order_id, hcpcs_code, quantity, unit_price, created_at)
SELECT ceil(random()*1000000), random_hcpcs_code(),
    CASE WHEN random()<0.7 THEN 1 WHEN random()<0.9 THEN floor(random()*5+2) ELSE floor(random()*20+6) END,
    (random()*500+10)::numeric(8,2), '2020-01-01'::timestamp + (random()*365*2||' days')::interval
FROM generate_series(1, 2000000);

DROP FUNCTION random_last_name();
DROP FUNCTION random_first_name();
DROP FUNCTION random_hcpcs_code();

ANALYZE;
