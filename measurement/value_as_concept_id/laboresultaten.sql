select distinct concat('LABO_',uitslag.BEPCODE, '_',uitslag.UITSLAG) as sourceCode
    , uitslag.UITSLAG as sourceName
    , count(*) as sourceFrequency
    , omschrijving.desc as additionalInfo
from {{project_id}}.{{dataset_id_raw}}.LAB_L_AANVRG aanvraag
inner join {{project_id}}.{{dataset_id_raw}}.LAB_HUIDIGE_UITSLAG uitslag on uitslag.BRONCODE = aanvraag.BRONCODE and uitslag.AANVRAAGNR = aanvraag.AANVRAAGNR
inner join {{project_id}}.{{dataset_id_raw}}.LAB_L_B_OMS omschrijving on omschrijving.BEP = BEPCODE
inner join {{project_id}}.{{dataset_id_raw}}.LAB_LABGROEP labgroep on omschrijving.GROEP = labgroep.GROEP
where (lower(omschrijving.desc) like 'creatinine%' or lower(omschrijving.desc) like '%hemoglob%'
  or lower(omschrijving.desc) like '%neutrof%' or omschrijving.desc like 'GFR%'
  or lower(omschrijving.desc) like '%leuco%' or omschrijving.desc like 'LDH%'
  or lower(omschrijving.desc) like '%bilirubine%' or lower(omschrijving.desc) like '%calcium%'
  or omschrijving.desc like '%CRP%' or omschrijving.desc like '%CEA%'
  or omschrijving.desc like '%NSE%' or lower(omschrijving.desc) like '%throm%'
  or lower(omschrijving.desc) like '%erythroc%' or lower(omschrijving.desc) like '%hematocr%'
  or lower(omschrijving.desc) like '%glucose%' or lower(omschrijving.desc) like '%hba1%') and  (regexp_contains(uitslag.uitslag, '[0-9#]') is false)  
  and not lower(uitslag.uitslag) in ('volgt', 'ini', '<memo>', '-volgt-', '', '.', 'zie opm.')
group by sourceCode, sourceName, additionalInfo
order by sourceName