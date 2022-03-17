create table hiv_monthly_reporting
(
patient_id                      int,
zl_emr_id                       varchar(255),
date_enrolled                   datetime,
date_completed                  datetime,
reporting_date                  date,
latest_hiv_note_encounter_id    int,
latest_hiv_visit_date           datetime,
latest_expected_hiv_visit_date  datetime,
hiv_visit_days_late             int,
latest_dispensing_encounter_id  int,
latest_dispensing_date          datetime,
latest_expected_dispensing_date datetime,
dispensing_days_late            int
); 
