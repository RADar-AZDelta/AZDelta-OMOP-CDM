# Important considerations for the procedure_occurrence table

- mzg:
  - Concept mapping: Idem usagi-files als bij condition_occurrence
  - ETL: Gelijkaardig als condition_occurrence, maar filter op domain = Procedure
- longkanker_procedures:
  - Enkele longprocedures uit hix.OK_OKINFO, eenvoudige concept mapping en ETL
- rontgen:
  - Mappen van beeldvormingsprocedures van Borst en Prostaat als structured report bestaat, eenvoudige concept mapping en ETL. rontgen_find_codes_with_structured_reports.sql is er enkel om gemakkelijk te vinden welke procedures een structured report hebben om zo gericht te kunnen mappen.
