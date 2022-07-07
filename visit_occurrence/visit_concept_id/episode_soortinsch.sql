select 
	ei.SOORTINSCH as sourceCode
	,case ei.SOORTINSCH
		when 'D' then 'Daghospitaal'
		when 'K' then 'Opname'
		when 'L' then 'Langdurig Ambulant'
		when 'N' then '?'
		when 'P' then 'Consultatie'
		when 'S' then 'Spoed'
	end as sourceName
	,count(*) as sourceFrequency
from {{project_id}}.{{dataset_id_raw}}.EPISODE_INSCHRIJVING ei
group by ei.SOORTINSCH;