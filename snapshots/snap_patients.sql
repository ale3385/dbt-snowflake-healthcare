{% snapshot snap_patients %}

{{
    config(
        target_schema='snapshots',
        unique_key='patient_id',
        strategy='check',
        check_cols=['insurance_plan_id', 'state', 'zip_code', 'enrollment_end_date'],
        invalidate_hard_deletes=True
    )
}}

SELECT * FROM {{ ref('stg_patients') }}

{% endsnapshot %}
