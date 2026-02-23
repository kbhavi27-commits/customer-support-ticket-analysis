-- ============================================
-- Customer Support Ticket Analysis
-- All SQL Scripts
-- Author: Bhavani Kandala
-- ============================================

-- ============================================
-- SCRIPT 1: Create Database & Table
-- ============================================
CREATE DATABASE customer_support;
USE customer_support;

CREATE TABLE support_tickets (
    ticket_id                  INT PRIMARY KEY,
    customer_name              VARCHAR(100),
    customer_email             VARCHAR(100),
    customer_age               INT,
    customer_gender            VARCHAR(20),
    product_purchased          VARCHAR(100),
    date_of_purchase           DATE,
    ticket_type                VARCHAR(50),
    ticket_subject             VARCHAR(100),
    ticket_description         TEXT,
    ticket_status              VARCHAR(50),
    resolution                 TEXT,
    ticket_priority            VARCHAR(20),
    ticket_channel             VARCHAR(30),
    first_response_time        VARCHAR(50),
    time_to_resolution         VARCHAR(50),
    customer_satisfaction      FLOAT,
    resolution_status          VARCHAR(20),
    priority_score             INT
);

-- ============================================
-- SCRIPT 2: KPI 1 — Ticket Volume by Type
-- ============================================
SELECT 
    ticket_type,
    COUNT(ticket_id) AS total_tickets,
    ROUND(COUNT(ticket_id) * 100.0 / (SELECT COUNT(*) FROM support_tickets), 2) AS percentage
FROM support_tickets
GROUP BY ticket_type
ORDER BY total_tickets DESC;

-- ============================================
-- SCRIPT 3: KPI 2 — Ticket Status Distribution
-- ============================================
SELECT 
    ticket_status,
    COUNT(ticket_id) AS ticket_count,
    ROUND(COUNT(ticket_id) * 100.0 / (SELECT COUNT(*) FROM support_tickets), 2) AS percentage
FROM support_tickets
GROUP BY ticket_status
ORDER BY ticket_count DESC;

-- ============================================
-- SCRIPT 4: KPI 3 — Priority Level Breakdown
-- ============================================
SELECT 
    ticket_priority,
    priority_score,
    COUNT(ticket_id) AS ticket_count,
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM support_tickets
GROUP BY ticket_priority, priority_score
ORDER BY priority_score DESC;

-- ============================================
-- SCRIPT 5: High Priority Incident Identification
-- ============================================
SELECT 
    ticket_id,
    customer_name,
    product_purchased,
    ticket_type,
    ticket_subject,
    ticket_priority,
    ticket_status,
    ticket_channel
FROM support_tickets
WHERE ticket_priority IN ('Critical', 'High')
  AND resolution_status = 'Pending'
ORDER BY priority_score DESC
LIMIT 50;

-- ============================================
-- SCRIPT 6: Channel Performance Analysis
-- ============================================
SELECT 
    ticket_channel,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN resolution_status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
    SUM(CASE WHEN resolution_status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    ROUND(
        SUM(CASE WHEN resolution_status = 'Resolved' THEN 1 ELSE 0 END) * 100.0 / COUNT(ticket_id), 2
    ) AS resolution_rate_pct,
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM support_tickets
GROUP BY ticket_channel
ORDER BY resolution_rate_pct DESC;

-- ============================================
-- SCRIPT 7: Product-Wise Ticket Analysis
-- ============================================
SELECT 
    product_purchased,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN ticket_priority = 'Critical' THEN 1 ELSE 0 END) AS critical_tickets,
    SUM(CASE WHEN ticket_priority = 'High' THEN 1 ELSE 0 END) AS high_tickets,
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM support_tickets
GROUP BY product_purchased
ORDER BY total_tickets DESC
LIMIT 15;

-- ============================================
-- SCRIPT 8: Overall KPI Summary
-- ============================================
SELECT
    COUNT(ticket_id)                                                    AS total_tickets,
    SUM(CASE WHEN resolution_status = 'Resolved' THEN 1 ELSE 0 END)    AS total_resolved,
    SUM(CASE WHEN resolution_status = 'Pending' THEN 1 ELSE 0 END)     AS total_pending,
    SUM(CASE WHEN ticket_priority = 'Critical' THEN 1 ELSE 0 END)      AS critical_tickets,
    SUM(CASE WHEN ticket_priority = 'High' THEN 1 ELSE 0 END)          AS high_tickets,
    ROUND(
        SUM(CASE WHEN resolution_status = 'Resolved' THEN 1 ELSE 0 END) * 100.0 / COUNT(ticket_id), 2
    )                                                                   AS overall_resolution_rate_pct,
    ROUND(AVG(CASE WHEN customer_satisfaction > 0 THEN customer_satisfaction END), 2) AS avg_satisfaction
FROM support_tickets;
