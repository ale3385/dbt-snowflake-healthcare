{{
    config(
        materialized='incremental',
        unique_key='claim_id',
        incremental_strategy='merge',
        merge_update_columns=['claim_status', 'paid_date', 'paid_amount', 'allowed_amount', 'patient_responsibility', '_loaded_at']
    )
}}

WITH claims AS (

    SELECT * FROM {{ ref('stg_claims') }}

    {% if is_incremental() %}
        WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}

),

claim_lines_agg AS (

    SELECT
        claim_id,
        COUNT(*) AS total_lines,
        SUM(units) AS total_units,
        COUNT(DISTINCT procedure_code) AS distinct_procedures

    FROM {{ ref('stg_claim_lines') }}
    GROUP BY 1

),

diagnosis_agg AS (

    SELECT
        claim_id,
        COUNT(*) AS total_diagnoses,
        MAX(CASE WHEN is_primary THEN diagnosis_code END) AS primary_diagnosis_code

    FROM {{ ref('stg_diagnoses') }}
    GROUP BY 1

)

SELECT
    c.claim_id,
    c.patient_id,
    c.rendering_provider_npi,
    c.billing_provider_npi,
    c.claim_type,
    c.claim_status,
    c.service_date_from,
    c.service_date_to,
    DATEDIFF('day', c.service_date_from, c.service_date_to) + 1 AS service_days,
    c.filed_date,
    c.paid_date,
    DATEDIFF('day', c.filed_date, c.paid_date) AS days_to_pay,
    c.billed_amount,
    c.allowed_amount,
    c.paid_amount,
    c.patient_responsibility,
    c.place_of_service_code,
    COALESCE(da.primary_diagnosis_code, c.primary_diagnosis_code) AS primary_diagnosis_code,
    c.authorization_number,
    COALESCE(cl.total_lines, 0) AS total_lines,
    COALESCE(cl.total_units, 0) AS total_units,
    COALESCE(cl.distinct_procedures, 0) AS distinct_procedures,
    COALESCE(da.total_diagnoses, 0) AS total_diagnoses,
    CASE
        WHEN c.billed_amount > 0
        THEN ROUND(c.paid_amount / c.billed_amount * 100, 2)
    END AS payment_rate_pct,
    c._loaded_at

FROM claims AS c
LEFT JOIN claim_lines_agg AS cl
    ON c.claim_id = cl.claim_id
LEFT JOIN diagnosis_agg AS da
    ON c.claim_id = da.claim_id
