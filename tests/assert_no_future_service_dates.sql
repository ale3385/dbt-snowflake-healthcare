SELECT
    claim_id,
    service_date_from

FROM {{ ref('fct_claims') }}

WHERE service_date_from > CURRENT_DATE
