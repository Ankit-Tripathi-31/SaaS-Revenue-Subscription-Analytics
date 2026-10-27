-- =====================================================
-- SaaS Revenue & Subscription Analytics
-- Step 5.2: PostgreSQL Table Schema
-- Database: saas_revenue_analytics
-- =====================================================

-- Source tables:
-- 1. plans
-- 2. customers
-- 3. subscriptions
-- 4. subscription_months
-- 5. invoices

-- Table definitions will be added after
-- validating exact source columns and data types.


-- ==========================================================
-- SaaS Revenue & Subscription Analytics
-- Step 5.2: PostgreSQL Table Creation
-- Database: saas_revenue_analytics
-- ==========================================================

-- 1. PLANS
CREATE TABLE IF NOT EXISTS plans (
    plan_id VARCHAR(20) PRIMARY KEY,
    plan_name VARCHAR(150),
    tier VARCHAR(50),
    billing_interval VARCHAR(30),
    list_price_usd NUMERIC(18,2),
    monthly_price_usd NUMERIC(18,2),
    billing_months INTEGER,
    seats_included INTEGER,
    extra_seat_price_usd NUMERIC(18,2),
    is_active VARCHAR(10),
    launched_date DATE
);

-- 2. CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(200),
    country VARCHAR(100),
    region VARCHAR(100),
    industry VARCHAR(100),
    segment VARCHAR(100),
    employees_band VARCHAR(50),
    signup_date DATE,
    acquisition_channel VARCHAR(100),
    cohort_month DATE,
    customer_status VARCHAR(30),
    churn_date DATE
);

-- 3. SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    plan_id VARCHAR(20) NOT NULL,
    start_date DATE,
    end_date DATE,
    subscription_status VARCHAR(30),
    billing_interval VARCHAR(30),
    seats INTEGER,
    discount_pct NUMERIC(10,2),
    mrr_usd NUMERIC(18,2),
    contract_term_months INTEGER,
    auto_renew VARCHAR(10),

    CONSTRAINT fk_subscriptions_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_subscriptions_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(plan_id)
);

-- 4. SUBSCRIPTION MONTHS
CREATE TABLE IF NOT EXISTS subscription_months (
    record_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    subscription_id VARCHAR(20) NOT NULL,
    plan_id VARCHAR(20) NOT NULL,
    period_month DATE,
    month_start_date DATE,
    is_active VARCHAR(10),
    seats INTEGER,
    mrr_usd NUMERIC(18,2),
    previous_mrr_usd NUMERIC(18,2),
    mrr_delta_usd NUMERIC(18,2),
    movement_type VARCHAR(30),
    tenure_months INTEGER,
    cohort_month DATE,
    currency VARCHAR(10),

    CONSTRAINT fk_months_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_months_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id),

    CONSTRAINT fk_months_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(plan_id)
);

-- 5. INVOICES
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    subscription_id VARCHAR(20) NOT NULL,
    invoice_date DATE,
    invoice_month DATE,
    billing_period_start DATE,
    billing_period_end DATE,
    months_covered INTEGER,
    amount_usd NUMERIC(18,2),
    discount_usd NUMERIC(18,2),
    subtotal_usd NUMERIC(18,2),
    tax_usd NUMERIC(18,2),
    total_usd NUMERIC(18,2),
    invoice_status VARCHAR(30),
    payment_method VARCHAR(100),
    days_to_payment NUMERIC(10,2),
    currency VARCHAR(10),

    CONSTRAINT fk_invoices_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_invoices_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
);
