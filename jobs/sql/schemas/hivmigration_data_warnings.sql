  CREATE TABLE hivmigration_data_warnings (
    id INT PRIMARY KEY,
    openmrs_patient_id INT,
    openmrs_encounter_id INT,
    hiv_emr_encounter_id INT,
    zl_emr_id VARCHAR(255),
    hivemr_v1_id INT,
    hiv_dossier_id VARCHAR(255),
    warning_type VARCHAR(255),
    warning_details TEXT,
    encounter_date DATE,
    field_name VARCHAR(100),
    field_value TEXT,
    flag_for_review BIT
);
