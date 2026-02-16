WITH providers AS (

    SELECT * FROM {{ ref('stg_providers') }}

),

claim_metrics AS (

    SELECT
        rendering_provider_npi,
        COUNT(DISTINCT claim_id) AS total_claims_rendered,
        COUNT(DISTINCT patient_id) AS unique_patients,
        SUM(paid_amount) AS total_paid_amount,
        AVG(paid_amount) AS avg_paid_per_claim

    FROM {{ ref('stg_claims') }}
    WHERE claim_status IN ('PAID', 'ADJUSTED')
    GROUP BY 1

)

SELECT
    p.provider_npi,
    p.provider_name,
    p.specialty,
    p.provider_type,
    p.practice_state,
    p.practice_zip_code,
    p.is_accepting_patients,
    p.network_status,
    p.effective_date,
    p.termination_date,
    COALESCE(
        p.termination_date >= CURRENT_DATE, TRUE
    ) AS is_active,
    COALESCE(cm.total_claims_rendered, 0) AS total_claims_rendered,
    COALESCE(cm.unique_patients, 0) AS unique_patients,
    COALESCE(cm.total_paid_amount, 0) AS total_paid_amount,
    cm.avg_paid_per_claim

FROM providers AS p
LEFT JOIN claim_metrics AS cm
    ON p.provider_npi = cm.rendering_provider_npi
