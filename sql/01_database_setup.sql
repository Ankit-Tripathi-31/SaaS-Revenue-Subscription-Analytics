-- SaaS Revenue & Subscription Analytics
-- Step 5.1: PostgreSQL Database Setup

-- Run this query while connected to:
-- saas_revenue_analytics

SELECT
    current_database() AS database_name,
    current_user AS connected_user,
    version() AS postgresql_version;

-- Basic connection test
SELECT
    1 + 1 AS connection_test;