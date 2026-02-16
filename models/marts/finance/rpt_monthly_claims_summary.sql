WITH claims AS (

    SELECT * FROM {{ ref('fct_claims') }}
    WHERE claim_status IN ('PAID', 'ADJUSTED')

),

monthly AS (

    SELECT
        DATE_TRUNC('month', service_date_from) AS service_month,
        claim_type,
        COUNT(DISTINCT claim_id) AS total_claims,
        COUNT(DISTINCT patient_id) AS unique_patients,
        COUNT(DISTINCT rendering_provider_npi) AS unique_providers,
        SUM(billed_amount) AS total_billed,
        SUM(allowed_amount) AS total_allowed,
        SUM(paid_amount) AS total_paid,
        SUM(patient_responsibility) AS total_patient_responsibility,
        AVG(paid_amount) AS avg_paid_per_claim,
        AVG(days_to_pay) AS avg_days_to_pay,
        ROUND(
            SUM(paid_amount) / NULLIF(SUM(billed_amount), 0) * 100, 2
        ) AS overall_payment_rate_pct

    FROM claims
    GROUP BY 1, 2

)

SELECT
    service_month,
    claim_type,
    total_claims,
    unique_patients,
    unique_providers,
    total_billed,
    total_allowed,
    total_paid,
    total_patient_responsibility,
    avg_paid_per_claim,
    avg_days_to_pay,
    overall_payment_rate_pct,
    SUM(total_paid) OVER (
        PARTITION BY claim_type
        ORDER BY service_month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_paid_ytd

FROM monthly
