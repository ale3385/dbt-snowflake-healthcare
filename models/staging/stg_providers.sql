WITH source AS (

    SELECT * FROM {{ source('healthcare_raw', 'providers') }}

),

renamed AS (

    SELECT
        provider_npi,
        TRIM(provider_name) AS provider_name,
        UPPER(TRIM(specialty)) AS specialty,
        UPPER(TRIM(provider_type)) AS provider_type,
        UPPER(TRIM(state)) AS practice_state,
        LPAD(zip_code::VARCHAR, 5, '0') AS practice_zip_code,
        COALESCE(is_accepting_patients, TRUE) AS is_accepting_patients,
        network_status,
        effective_date,
        termination_date,
        _loaded_at

    FROM source
    WHERE provider_npi IS NOT NULL

)

SELECT * FROM renamed
