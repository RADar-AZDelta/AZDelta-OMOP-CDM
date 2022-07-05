SELECT distinct GESLACHT as SourceCode, GESLACHT as SourceTerm, count(GESLACHT) as SourceFrequency
FROM {{project_id}}.{{dataset_id_raw}}.CSZISLIB_ARTS
GROUP BY GESLACHT