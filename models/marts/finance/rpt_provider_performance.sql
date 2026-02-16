WITH claims AS (

    SELECT * FROM {{ ref('fct_claims') }}
    WHERE claim_status IN ('PAID', 'ADJUSTED')

),

provider_metrics AS (

    SELECT
        rendering_provider_npi,
        COUNT(DISTINCT claim_id) AS total_claims,
        COUNT(DISTINCT patient_id) AS unique_patients,
        SUM(billed_amount) AS total_billed,
        SUM(paid_amount) AS total_paid,
        AVG(paid_amount) AS avg_paid_per_claim,
        AVG(days_to_pay) AS avg_days_to_pay,
        AVG(total_lines) AS avg_lines_per_claim,
        COUNT(DISTINCT primary_diagnosis_code) AS distinct_primary_diagnoses,
        ROUND(
            SUM(paid_amount) / NULLIF(SUM(billed_amount), 0) * 100, 2
        ) AS payment_rate_pct

    FROM claims
    GROUP BY 1

),

ranked AS (

    SELECT
        pm.*,
        dp.provider_name,
        dp.specialty,
        dp.network_status,
        dp.practice_state,
        PERCENT_RANK() OVER (
            ORDER BY pm.total_paid DESC
        ) AS paid_amount_percentile,
        PERCENT_RANK() OVER (
            PARTITION BY dp.specialty
            ORDER BY pm.total_claims DESC
        ) AS specialty_volume_percentile

    FROM provider_metrics AS pm
    INNER JOIN {{ ref('dim_providers') }} AS dp
        ON pm.rendering_provider_npi = dp.provider_npi

)

SELECT * FROM ranked
