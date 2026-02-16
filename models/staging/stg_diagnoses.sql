WITH source AS (

    SELECT * FROM {{ source('healthcare_raw', 'diagnoses') }}

),

renamed AS (

    SELECT
        diagnosis_id,
        claim_id,
        UPPER(TRIM(diagnosis_code)) AS diagnosis_code,
        diagnosis_sequence AS diagnosis_position,
        (diagnosis_sequence = 1) AS is_primary,
        UPPER(TRIM(diagnosis_type)) AS diagnosis_type,
        _loaded_at

    FROM source
    WHERE diagnosis_id IS NOT NULL

)

SELECT * FROM renamed
