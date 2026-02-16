SELECT
    claim_id,
    billed_amount,
    paid_amount

FROM {{ ref('fct_claims') }}

WHERE paid_amount > billed_amount * 1.5
    AND billed_amount > 0
