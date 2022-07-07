WITH cte_icd as (
  select *, ROW_NUMBER() OVER (PARTITION BY mzg_id, mzg_encod, mzg_code ORDER BY from_date desc) row_number 
  from iconic-guard-317109.oazis.icd
), cte_icd_co as (
  select *, ROW_NUMBER() OVER (PARTITION BY mzg_id, mzg_encod, mzg_code, lkp_language ORDER BY from_date desc) row_number 
  from iconic-guard-317109.oazis.icd_co
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
	from iconic-guard-317109.oazis.MKG m
	inner join iconic-guard-317109.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
    left outer join iconic-guard-317109.oazis.icd_id on icd_id.mzg_id = 'D'
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
	from iconic-guard-317109.oazis.MKG m
	inner join iconic-guard-317109.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
	inner join iconic-guard-317109.oazis.NEVEN n on m.formnr = n.formnr
    left outer join iconic-guard-317109.oazis.icd_id on icd_id.mzg_id = 'D'
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
	from iconic-guard-317109.oazis.MKG m
	inner join iconic-guard-317109.hix.OPNAME_OPNAME v on v.INSCHRNR = TRIM(m.opnr)	
	inner join iconic-guard-317109.oazis.INGREEP i on m.formnr = i.formnr
    left outer join iconic-guard-317109.oazis.icd_id on icd_id.mzg_id = 'D'
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
), cte_mzg_unmapped AS (
    SELECT DISTINCT i.*, COALESCE(c.CONCEPT_CODE, co.CONCEPT_CODE) CONCEPT_CODE, m.icd_description
    FROM iconic-guard-317109.oazis.icd i
    LEFT JOIN iconic-guard-317109.omop.concept c
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
    LEFT JOIN iconic-guard-317109.omop.concept co
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
    AND COALESCE(c.CONCEPT_CODE, co.CONCEPT_CODE) IS NULL
)
SELECT 
    CONCAT('MZG_', mzg_encod, '_', mzg_id, '_', TRIM(mzg_code)) AS sourceCode
    ,icd_description AS sourceName
    ,0 AS sourceFrequency
FROM cte_mzg_unmapped
ORDER BY mzg_code, mzg_encod, mzg_id