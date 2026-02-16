WITH source AS (

    SELECT * FROM {{ source('healthcare_raw', 'claims') }}

),

renamed AS (

    SELECT
        claim_id,
        patient_id,
        provider_npi AS rendering_provider_npi,
        billing_provider_npi,
        UPPER(TRIM(claim_type)) AS claim_type,
        UPPER(TRIM(claim_status)) AS claim_status,
        service_date_from,
        service_date_to,
        filed_date,
        paid_date,
        billed_amount_cents,
        allowed_amount_cents,
        paid_amount_cents,
        patient_responsibility_cents,
        {{ cents_to_dollars('billed_amount_cents') }} AS billed_amount,
        {{ cents_to_dollars('allowed_amount_cents') }} AS allowed_amount,
        {{ cents_to_dollars('paid_amount_cents') }} AS paid_amount,
        {{ cents_to_dollars('patient_responsibility_cents') }} AS patient_responsibility,
        place_of_service_code,
        UPPER(TRIM(primary_diagnosis_code)) AS primary_diagnosis_code,
        authorization_number,
        _loaded_at

    FROM source
    WHERE claim_id IS NOT NULL

)

SELECT * FROM renamed
