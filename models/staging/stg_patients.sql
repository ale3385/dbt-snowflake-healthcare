WITH source AS (

    SELECT * FROM {{ source('healthcare_raw', 'patients') }}

),

renamed AS (

    SELECT
        patient_id,
        TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        date_of_birth,
        UPPER(TRIM(gender)) AS gender,
        UPPER(TRIM(state)) AS state,
        LPAD(zip_code::VARCHAR, 5, '0') AS zip_code,
        insurance_plan_id,
        enrollment_start_date,
        enrollment_end_date,
        COALESCE(
            enrollment_end_date >= CURRENT_DATE, TRUE
        ) AS is_active,
        DATEDIFF('year', date_of_birth, CURRENT_DATE) AS age,
        _loaded_at

    FROM source
    WHERE patient_id IS NOT NULL

)

SELECT * FROM renamed
