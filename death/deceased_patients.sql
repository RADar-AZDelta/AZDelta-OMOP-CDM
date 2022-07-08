select 
  pp.PATIENTNR as person_id
  ,CAST(pp.OVERLDAT as DATE) as death_date
  ,DATETIME(
    CAST(pp.OVERLDAT as DATE), 
      CASE
        WHEN REGEXP_CONTAINS(pp.OVERLTIJD, r'^[0-9]{2}:[0-9]{2}:[0-9]{2}$') THEN PARSE_TIME('%H:%M:%S', pp.OVERLTIJD)
        WHEN REGEXP_CONTAINS(pp.OVERLTIJD, r'^[0-9]{2}:[0-9]{2}$') THEN PARSE_TIME('%H:%M', pp.OVERLTIJD)
        ELSE TIME(0, 0, 0)
    END
  ) as death_datetime
  ,'ADMINISTRATION_RECORD' as death_type_concept_id
  ,cast(null as string) as cause_concept_id
  ,cast(null as string) as cause_source_value
  ,cast(null as int) as cause_source_concept_id
from iconic-guard-317109.hix.PATIENT_PATIENT pp
where pp.OVERLEDEN = true