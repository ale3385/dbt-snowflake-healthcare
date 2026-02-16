WITH source AS (

    SELECT * FROM {{ source('healthcare_raw', 'claim_lines') }}

),

renamed AS (

    SELECT
        claim_line_id,
        claim_id,
        line_number,
        TRIM(procedure_code) AS procedure_code,
        TRIM(procedure_modifier) AS procedure_modifier,
        TRIM(revenue_code) AS revenue_code,
        units,
        billed_amount_cents,
        allowed_amount_cents,
        paid_amount_cents,
        {{ cents_to_dollars('billed_amount_cents') }} AS billed_amount,
        {{ cents_to_dollars('allowed_amount_cents') }} AS allowed_amount,
        {{ cents_to_dollars('paid_amount_cents') }} AS paid_amount,
        UPPER(TRIM(diagnosis_code_1)) AS diagnosis_code_1,
        UPPER(TRIM(diagnosis_code_2)) AS diagnosis_code_2,
        service_date,
        _loaded_at

    FROM source
    WHERE claim_line_id IS NOT NULL

)

SELECT * FROM renamed
