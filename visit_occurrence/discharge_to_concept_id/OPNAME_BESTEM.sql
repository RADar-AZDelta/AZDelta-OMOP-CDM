select 
	ob.code as sourceCode
  	,ob.omschr as sourceName
	,0 as sourceFrequency
from {{project_id}}.{{dataset_id_raw}}.OPNAME_BESTEM ob