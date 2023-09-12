- **epd.sql**: idem condition_occurrence, maar met domain filter voor Measurement, bevatten sowieso geen value's, is enkel toegevoegd voor de volledigheid, bevat momenteel geen Measurement's
- **mzg.sql**: idem condition_occurrence, maar met domain filter voor Measurement, sommigen bevatten een value_as_concept_id, indien gewenst zijn meesten manueel te hermappen naar andere/betere concepten, vb.:
  - MZG_10_D_C7981 | Secondary malignant neoplasm of breast | Condition | ICD10CM  
    -> OMOP voorstel:  
        condition_occurrence: 4314071 | Secondary malignant neoplasm of trunk | Condition | SNOMED  
        + measurement: 35225556 | Metastasis to breast | Measurement | SNOMED  
    -> Beter voorstel:  
        condition_occurrence: 603292 | Secondary malignant neoplasm of breast | Condition | SNOMED, deze code is recenter, dus waarschijnlijk bestond hij nog niet toen OHDSI het gemapt heeft  
  - MZG_10_D_D7210 | "Eosinophilia, unspecified" | Measurement |ICD10CM  
    -> OMOP voorstel:  
        measurement_concept_id: 4216098 | Eosinophil count | Measurement | SNOMED  
        value_as_concept_id: 4084765 | Above reference range | Meas Value | SNOMED  
    -> Beter voorstel:  
        condition_occurrence: 4304002 | Eosinophil count raised | Condition | SNOMED  
- **labo_measurements.sql**:
  - ETL: labo resultaten mappen naar measurements, relatief eenvoudig, wat string parsing voor de waarden en wat wegfilteren van irrelevante rommel (volgt, ini, memo...). Bevat ook link naar specimen via event kolommen voor bloedsoort bij bloedgassen.
  - measurement_concept_id:
    - **labo_mapping_help.sql**: simple query to see some possible anwsers to help in concept mapping (next query)
    - **labo_usagi.sql**:
      - dataset_id_raw_3 in deze query is glims dataset in iconic-guard-317109
      - probeert te automappen, gebruikt hiervoor (glims.)LAB_EXTLABTST uit Hix, bij maken zaten die nog niet in de Hix dataset en werd een aparte upload gebruikt (relatief klein/statisch)
      - gebruikt ook (glims.)code_to_medidoc, twee kolommen gehaald uit een GLIMS-tabel, was ook single shot, gezien nieuwe GLIMS met LOINC-codes zou zijn...
      - gebruikt ook (glims.)medidoc_to_loinc, gebaseerd op gescrapte, verouderde tabellen van de overheid, o.b.v. code in [ReTaM-repo](https://github.com/RADar-AZDelta/OMOP-lab-mappings-ReTaM)
  - value_as_concept_id: antwoorden gemapt naar concepten, vb. negatief en positief
- **body_measurements.sql**:
  - Gewicht, BMI en Lengte uit METINGEN_METINGEN_FLAT view
  - Eenvoudige ETL, 3 LOINC concepten in de concept mapping
- **awell_baselineclinicalform.sql**:
  - Awell vragenlijsten query door/voor Louise, klinische info, geen PREMS/PROMS
  - moeilijkste is wirwar aan Awell tabellen, verder eenvoudig
- **MOC(_longtumor).sql**:
  - Ook eenvoudig, behalve de miserie met hix-tabellen die gejoind moeten worden, naamgeving van de CTE's is slecht, de tweede/derde is gewoon om de datum op te halen als antwoord op een andere vraag. Verder nog wat filtering om de juiste vragenlijst te selecteren. Verdient waarschijnljk een vaste aanpak om alle vragenlijsten op dezelfde manier aan te pakken.
