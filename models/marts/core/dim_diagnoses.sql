WITH seed_codes AS (

    SELECT * FROM {{ ref('diagnosis_codes') }}

),

diagnosis_usage AS (

    SELECT
        diagnosis_code,
        COUNT(DISTINCT claim_id) AS claims_with_diagnosis,
        COUNT(*) AS total_occurrences,
        SUM(CASE WHEN is_primary THEN 1 ELSE 0 END) AS times_as_primary

    FROM {{ ref('stg_diagnoses') }}
    GROUP BY 1

)

SELECT
    sc.diagnosis_code,
    sc.description AS diagnosis_description,
    sc.category,
    sc.subcategory,
    sc.is_chronic,
    COALESCE(du.claims_with_diagnosis, 0) AS claims_with_diagnosis,
    COALESCE(du.total_occurrences, 0) AS total_occurrences,
    COALESCE(du.times_as_primary, 0) AS times_as_primary

FROM seed_codes AS sc
LEFT JOIN diagnosis_usage AS du
    ON sc.diagnosis_code = du.diagnosis_code
