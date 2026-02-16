WITH patients AS (

    SELECT * FROM {{ ref('stg_patients') }}

),

claim_summary AS (

    SELECT
        patient_id,
        COUNT(DISTINCT claim_id) AS total_claims,
        MIN(service_date_from) AS first_claim_date,
        MAX(service_date_from) AS last_claim_date,
        SUM(paid_amount) AS total_paid_amount

    FROM {{ ref('stg_claims') }}
    WHERE claim_status IN ('PAID', 'ADJUSTED')
    GROUP BY 1

)

SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    p.date_of_birth,
    p.age,
    p.gender,
    p.state,
    p.zip_code,
    p.insurance_plan_id,
    p.enrollment_start_date,
    p.enrollment_end_date,
    p.is_active,
    COALESCE(cs.total_claims, 0) AS total_claims,
    cs.first_claim_date,
    cs.last_claim_date,
    COALESCE(cs.total_paid_amount, 0) AS total_paid_amount,
    CASE
        WHEN cs.total_claims >= 20 THEN 'HIGH'
        WHEN cs.total_claims >= 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS utilization_tier

FROM patients AS p
LEFT JOIN claim_summary AS cs
    ON p.patient_id = cs.patient_id
