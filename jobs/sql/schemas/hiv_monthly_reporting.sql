create table hiv_monthly_reporting
(
	patient_id 						int,
  	zl_emr_id						varchar(255),
  	date_enrolled 					datetime,
  	date_completed 					datetime,
    reporting_date					date,
	latest_HIV_note_encounter_id	int,
    latest_HIV_visit_date			datetime,
    latest_expected_HIV_visit_date	datetime,
	HIV_visit_days_late				int,
	latest_dispensing_encounter_id	int,
    latest_dispensing_date			datetime,
    latest_expected_dispensing_date	datetime,
	dispensing_days_late			int
);
  	


	