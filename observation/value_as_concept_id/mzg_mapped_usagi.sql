WITH cte_icd as (
  select *, ROW_NUMBER() OVER (PARTITION BY mzg_id, mzg_encod, mzg_code ORDER BY from_date desc) row_number 
  from {{project_id}}.oazis.icd
), cte_icd_co as (
  select *, ROW_NUMBER() OVER (PARTITION BY mzg_id, mzg_encod, mzg_code, lkp_language ORDER BY from_date desc) row_number 
  from {{project_id}}.oazis.icd_co
), cte_mzg as (
	select CONCAT(TRIM(m.formnr), '_', TRIM(m.pat_std)) as id
		,TRIM(v.PATIENTNR) as pat_id
		,TRIM(v.INSCHRNR) as visit_id
		,CAST(m.vandat as DATE) as start_date
		,CAST(m.vanuur as TIME) as start_time
		,CAST(m.totdat as DATE) as end_date
		,CAST(m.totuur as TIME) as end_time
		,TRIM(m.opndok) as dok_id 
		,TRIM(m.hoofddiagnose) as icd_code
		,icd_co.icddesc as icd_description
		,'H' as type
		,m.mzg_encod as icd_version
	from {{project_id}}.oazis.MKG m
	inner join {{project_id}}.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
    left outer join {{project_id}}.oazis.icd_id on icd_id.mzg_id = 'D'
		and icd_id.mzg_encod = m.mzg_encod
		and icd_id.mzg_code = m.hoofddiagnose
	left outer join cte_icd icd on icd.mzg_id = icd_id.mzg_id
		and icd.mzg_encod = icd_id.mzg_encod
		and icd.mzg_code = icd_id.mzg_code
		and icd.row_number = 1
	left outer join cte_icd_co icd_co on icd_co.mzg_id = icd.mzg_id
		and icd_co.mzg_encod = icd.mzg_encod
		and icd_co.mzg_code = icd.mzg_code
		and icd_co.lkp_language = IF(icd.mzg_encod = '9', 'NL', 'USA')
		and icd_co.row_number = 1
	where m.mzg_status >= '66'
		and m.hoofddiagnose not in ('MMMMMM', 'UUUUUU', 'ZZZZZZ')

	union all

	select CONCAT(trim(n.formnr), '_', TRIM(n.pat_std), '_', TRIM(n.nevendiagnose)) as id 
		,TRIM(v.PATIENTNR) as pat_id
		,TRIM(v.INSCHRNR) as visit_id
		,CAST(m.vandat as DATE) as start_date
		,CAST(m.vanuur as TIME) as start_time
		,CAST(m.totdat as DATE) as end_date
		,CAST(m.totuur as TIME) as end_time
		,null as dok_id 
		,TRIM(n.nevendiagnose) as icd_code
		,icd_co.icddesc as icd_description
		,'N' as type
		,m.mzg_encod as icd_version
	from {{project_id}}.oazis.MKG m
	inner join {{project_id}}.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
	inner join {{project_id}}.oazis.NEVEN n on m.formnr = n.formnr
    left outer join {{project_id}}.oazis.icd_id on icd_id.mzg_id = 'D'
		and icd_id.mzg_encod = m.mzg_encod
		and icd_id.mzg_code = m.hoofddiagnose
	left outer join cte_icd icd on icd.mzg_id = icd_id.mzg_id
		and icd.mzg_encod = icd_id.mzg_encod
		and icd.mzg_code = icd_id.mzg_code
		and icd.row_number = 1
	left outer join cte_icd_co icd_co on icd_co.mzg_id = icd.mzg_id
		and icd_co.mzg_encod = icd.mzg_encod
		and icd_co.mzg_code = icd.mzg_code
		and icd_co.lkp_language = IF(icd.mzg_encod = '9', 'NL', 'USA')
		and icd_co.row_number = 1	
	where m.mzg_status >= '66'

	union all

	select CONCAT(TRIM(i.formnr), '_', TRIM(i.pat_std), '_', i.vlgnr) as id 
		,TRIM(v.PATIENTNR) as pat_id
		,TRIM(v.INSCHRNR) as visit_id
		,CAST(m.vandat as DATE) as start_date
		,CAST(m.vanuur as TIME) as start_time
		,CAST(m.totdat as DATE) as end_date
		,CAST(m.totuur as TIME) as end_time
		,TRIM(i.uitvoerder) as dok_id 
		,TRIM(i.ingreep) as icd_code
		,icd_co.icddesc as icd_description
		,'I' as type
		,m.mzg_encod as icd_version
	from {{project_id}}.oazis.MKG m
	inner join {{project_id}}.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
	inner join {{project_id}}.oazis.INGREEP i on m.formnr = i.formnr
    left outer join {{project_id}}.oazis.icd_id on icd_id.mzg_id = 'D'
		and icd_id.mzg_encod = m.mzg_encod
		and icd_id.mzg_code = m.hoofddiagnose
	left outer join cte_icd icd on icd.mzg_id = icd_id.mzg_id
		and icd.mzg_encod = icd_id.mzg_encod
		and icd.mzg_code = icd_id.mzg_code
		and icd.row_number = 1
	left outer join cte_icd_co icd_co on icd_co.mzg_id = icd.mzg_id
		and icd_co.mzg_encod = icd.mzg_encod
		and icd_co.mzg_code = icd.mzg_code
		and icd_co.lkp_language = IF(icd.mzg_encod = '9', 'NL', 'USA')
		and icd_co.row_number = 1	
	where m.mzg_status >= '66'

	order by pat_id, visit_id, icd_code
), cte_mzg_mapped AS (
    SELECT DISTINCT i.*
        , COALESCE(c.CONCEPT_ID, co.CONCEPT_ID) source_CONCEPT_ID
        , COALESCE(c.CONCEPT_NAME, co.CONCEPT_NAME) CONCEPT_NAME
        , COALESCE(c.DOMAIN_ID, co.DOMAIN_ID) DOMAIN_ID
				,m.icd_description
    FROM {{project_id}}.oazis.icd i
    LEFT JOIN {{project_id}}.omop.concept c
        ON TRIM(i.mzg_code) = REGEXP_REPLACE(c.CONCEPT_CODE, r'\W', '')
        AND (
            (i.mzg_encod = '10' AND i.mzg_id = 'D' AND c.VOCABULARY_ID = "ICD10CM")
            OR 
            (i.mzg_encod = '10' AND i.mzg_id = 'P' AND c.VOCABULARY_ID = "ICD10PCS")
            OR 
            (i.mzg_encod = '9' AND i.mzg_id = 'D' AND c.VOCABULARY_ID = "ICD9CM")
            OR 
            (i.mzg_encod = '9' AND i.mzg_id = 'P' AND c.VOCABULARY_ID = "ICD9Proc")
            )
    LEFT JOIN {{project_id}}.omop.concept co
        ON REGEXP_REPLACE(TRIM(i.mzg_code), '[M]', '') = REGEXP_REPLACE(co.CONCEPT_CODE, r'\W', '')
        AND i.mzg_encod = '9' AND i.mzg_id = 'D' AND co.VOCABULARY_ID = "ICDO3"
    RIGHT JOIN cte_mzg m 
        ON TRIM(i.mzg_code) = trim(m.icd_code)
        AND mzg_encod = m.icd_version
        AND i.mzg_id = (
            CASE
                WHEN m.type IN ('H', 'N') THEN 'D' --hoofd en neven diagnose --> diagnose
                WHEN m.type = 'I' THEN 'P' -- ingreep --> procedure
            END
            )
    WHERE TRIM(i.mzg_code) NOT IN ('AAAAAA', 'DDDDDD', 'MMMMMM', 'UUUAAA', 'UUUUUU', 'XXXXXX', 'ZZZ', 'ZZZZZZ')
    AND COALESCE(c.CONCEPT_CODE, co.CONCEPT_CODE) IS NOT NULL
), omop_mapped AS (
    SELECT DISTINCT m.*, sc.CONCEPT_ID
    FROM cte_mzg_mapped m
    LEFT JOIN {{project_id}}.omop.concept_relationship r 
    ON m.source_CONCEPT_ID = r.CONCEPT_ID_1
        AND r.RELATIONSHIP_ID = "Maps to"
    LEFT JOIN {{project_id}}.omop.concept sc  ON r.CONCEPT_ID_2 = sc.CONCEPT_ID
        AND sc.STANDARD_CONCEPT = 'S'
    WHERE sc.CONCEPT_ID IS NOT NULL
)
SELECT
    CONCAT('MZG_', mzg_encod, '_', mzg_id, '_', TRIM(mzg_code)) AS sourceCode
    ,icddesc AS sourceName
    ,0 AS sourceFrequency
    ,CAST(NULL AS STRING) AS sourceAutoAssignedConceptIds
    ,source_CONCEPT_ID AS ADD_INFO_SOURCE_CONCEPT_ID
    ,1 AS matchScore
    ,'APPROVED' AS mappingStatus
    ,'EQUAL' AS equivalence
    ,'etl' AS statusSetBy
    ,UNIX_MILLIS(CURRENT_TIMESTAMP()) as statusSetOn
    ,CONCEPT_ID AS conceptId
    ,CONCEPT_NAME AS conceptName
    ,DOMAIN_ID AS domainId
    ,'MAPS_TO' AS mappingType
    ,'AUTO MAPPED' AS comment
    ,'etl' AS createdBy
    ,UNIX_MILLIS(CURRENT_TIMESTAMP()) as createdOn
    ,cast(null AS string) AS assignedReviewer
FROM omop_mapped
ORDER BY mzg_code, mzg_encod, mzg_id