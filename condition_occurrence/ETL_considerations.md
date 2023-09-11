# Important considerations for the ETL-process of the condition_occurrence table

- mzg:
  - condition_concept_id:
    - **Zowel ICD10CM als ICD10**. Bij het automatisch mappen komt D overeen met de diagnostische vocabularia (ICD10CM, ICD10 en ICD9CM) en P met de procedures (ICD10PCS en ICD9Proc), maar let er op dat zowel ICD10CM als ICD10 nodig zijn. De eerste is veel uitgebreider (vb hiërarchie, mapping naar standaard concepten, relaties tussen concepten), maar ontbreekt enkele codes uit de tweede, waardoor het nodig is om via een COALESCE te matchen met een ICD-concept uit de eerste en anders uit de tweede.
    - **ICDO3 zit in Oazis als 9, D**. Oncologische codes uit ICDO3 worden in Oazis opgeslagen als '9' en 'D', m.a.w. de labels om ICD9CM te identificeren hebben ze ervoor gerecycleerd (omdat tegen dat ICD9CM niet langer gebruikt werd)
    - **Automap door join op concept_code, na leestekens verwijderen**. De ICD9/10 strings komen letterlijk voor als concept_code in OMOP, in Oazis zijn de leestekens (punten) verwijderd. Idem voor ICD03, waarbij in Oazis de slash verwijderd is. Deze zitten minder volledig in standaard OMOP; voornamelijk het laatste cijfer (waarbij vb /3 = tumor, /6 = metastase) enkel de versie met een 3 bevat.
    - **mzg_map_new.sql**: query die bovenstaande regels toepast op mzg data uit oazis
    - **mzg_map_from_master.sql**: query die zelfde doet als bovenstaande + join met iconic-guard-317109.master_usagi.mzg_usagi. Deze tabel bevatte het resultaat van bovenstaande query, vervolledigd met manuele mappings, zodat deze niet moeten herdaan worden.
    - **ADD_INFO_SOURCE_CONCEPT_ID bevat ICD concept_id's**. Van de gevonden, meestal niet-standaard ICD-concepten wordt de concept_id opgeslagen in de kolom ADD_INFO_SOURCE_CONCEPT_ID.
  - condition_source_concept_id:
    - **mzg_source_postprocess.py**: script die de mzg_usagi voor condition_concept_id omzet naar die mzg_source_usagi voor condition_source_concept_id. Hier wordt de ADD_INFO_SOURCE_CONCEPT_ID kolom hernoemt naar conceptId.
  - ETL
    - **Filter op Domain = Condition**. De diagnostische (ICD9CM, ICD10CM en ICD10) codes zijn niet allemaal conditions, de procedurele (ICD9Proc, ICD10PCS) zijn niet allemaal procedures, dus in de ETL moet hierop gefilterd worden op het domain en de juiste codes dienen in de juiste tabel te komen (ook measurements en observations). Wanneer er gemapt wordt naar measurements en observations, is er soms ook een MAPS_TO_VALUE relatie in de concept_relationship tabel die nodig is om de record correct te mappen (vb. Personal history of malignant neoplasm of prostate -> concept = History of event, value = 	
Malignant tumor of prostate)
- epd:
  - condition_concept_id:
  - condition_source_concept_id:
- ecg:

- 
