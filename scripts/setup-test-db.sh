#!/bin/bash
set -e

echo "Setting up PostgreSQL performance cookbook test database..."

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -p 5432 -U postgres; do
    echo "Waiting for PostgreSQL to start..."
    sleep 2
done

# Connect to PostgreSQL and run setup
psql -h localhost -p 5432 -U postgres -d performance_cookbook << SQL

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS line_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

-- Create enum types
DROP TYPE IF EXISTS doc_status CASCADE;
CREATE TYPE doc_status AS ENUM ('pending', 'processing', 'completed', 'failed');

DROP TYPE IF EXISTS doc_type CASCADE;
CREATE TYPE doc_type AS ENUM ('order', 'note', 'lab', 'imaging');

-- Create patients table
CREATE TABLE patients (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    ssn_masked VARCHAR(11) NOT NULL, -- XXX-XX-1234 format
    insurance_id VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create documents table
CREATE TABLE documents (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id),
    doc_type doc_type NOT NULL,
    status doc_status NOT NULL DEFAULT 'pending',
    content_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create orders table
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id),
    document_id BIGINT REFERENCES documents(id),
    hcpcs_code VARCHAR(10) NOT NULL,
    description TEXT NOT NULL,
    status doc_status NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create line_items table
CREATE TABLE line_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    hcpcs_code VARCHAR(10) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(8,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create basic indexes
CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_patients_dob ON patients(date_of_birth);
CREATE INDEX idx_documents_patient_id ON documents(patient_id);
CREATE INDEX idx_documents_created_at ON documents(created_at);
CREATE INDEX idx_orders_patient_id ON orders(patient_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_line_items_order_id ON line_items(order_id);

-- Run the data generation script
\i /docker-entrypoint-initdb.d/generate-sample-data.sql

-- Show table counts
SELECT 
    schemaname,
    tablename,
    n_tup_ins as rows_inserted,
    n_tup_upd as rows_updated,
    n_tup_del as rows_deleted
FROM pg_stat_user_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

ANALYZE;

ECHO 'Database setup complete! Run EXPLAIN ANALYZE on your queries to see performance.'

SQL

echo "Test database setup completed successfully!"
