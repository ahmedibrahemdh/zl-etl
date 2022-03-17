SET sql_safe_updates = 0;

SET @hiv_program_id = (SELECT program_id FROM program WHERE retired = 0 AND uuid = 'b1cb1fc1-5190-4f7a-af08-48870975dafc');
select name into @HIV_Intake_Name from encounter_type where uuid = 'c31d306a-40c4-11e7-a919-92ebcb67fe33' ;
select name into @HIV_Followup_Name from encounter_type where uuid = 'c31d3312-40c4-11e7-a919-92ebcb67fe33' ;
select name into @HIV_Dispensing_Name from encounter_type where uuid = 'cc1720c9-3e4c-4fa8-a7ec-40eeaad1958c' ;

DROP TEMPORARY TABLE IF EXISTS temp_hiv_patient_programs;
CREATE TEMPORARY TABLE temp_hiv_patient_programs
SELECT patient_id, patient_program_id, date_enrolled, date_completed
FROM patient_program WHERE voided=0 AND program_id = @hiv_program_id;


DROP TEMPORARY TABLE IF EXISTS temp_eom_appts;
CREATE TEMPORARY TABLE temp_eom_appts
(
    patient_id                  INT(11),
    patient_program_id			INT(11),
    date_enrolled				DATETIME,
    date_completed				DATETIME,
    reporting_date				DATE,
	  latest_HIV_note_encounter_id	INT(11),
    latest_HIV_visit_date		DATETIME,
    latest_expected_HIV_visit_date	DATETIME,
	  HIV_visit_days_late			INT,
	  latest_dispensing_encounter_id	INT(11),
    latest_dispensing_date		DATETIME,
    latest_expected_dispensing_date	DATETIME,
	  dispensing_days_late			INT
);

create index eom_patient on temp_eom_appts(patient_id);

call load_end_of_month_dates;

-- insert end of month date rows for each patient for when they are active 
insert into temp_eom_appts (patient_id,patient_program_id,date_enrolled, date_completed, reporting_date)
select * from temp_hiv_patient_programs t
inner join END_OF_MONTH_DATES e 
	on e.reporting_date >= last_day(t.date_enrolled)  
	and (last_day(t.date_completed) >= e.reporting_date or t.date_completed is null)
	and YEAR(e.reporting_date) >= 2020 -- << load rows only for year 2020 and on 
	order by patient_program_id asc, e.reporting_date
	;

-- HIV notes dates/info
update temp_eom_appts t
set latest_HIV_note_encounter_id =
 latestEncBetweenDates(t.patient_id, CONCAT(@hiv_intake_name,',',@hiv_followup_name), null,t.reporting_date);

update temp_eom_appts t
set latest_HIV_visit_date = encounter_date(t.latest_HIV_note_encounter_id);

update temp_eom_appts t
set latest_expected_HIV_visit_date = obs_value_datetime(t.latest_HIV_note_encounter_id,'PIH','5096');

update temp_eom_appts t
set HIV_visit_days_late = DATEDIFF(t.reporting_date ,ifnull(latest_expected_HIV_visit_date,ifnull(latest_HIV_visit_date,date_enrolled)  )); 

-- HIV Dispensing dates/info
update temp_eom_appts t
set latest_dispensing_encounter_id =
 latestEncBetweenDates(t.patient_id, @HIV_Dispensing_Name, null,t.reporting_date);

update temp_eom_appts t
set latest_dispensing_date = encounter_date(t.latest_dispensing_encounter_id);

update temp_eom_appts t
set latest_expected_dispensing_date = obs_value_datetime(t.latest_dispensing_encounter_id,'PIH','5096');

update temp_eom_appts t
set dispensing_days_late = DATEDIFF(t.reporting_date ,ifnull(latest_expected_dispensing_date,ifnull(latest_dispensing_date,date_enrolled)  )); 

SELECT
  	patient_id,
  	zlemr(patient_id),
  	date_enrolled ,
  	date_completed ,
    reporting_date,
	  latest_HIV_note_encounter_id,
    latest_HIV_visit_date,
    latest_expected_HIV_visit_date,
	  HIV_visit_days_late,
	  latest_dispensing_encounter_id,
    latest_dispensing_date,
    latest_expected_dispensing_date,
	  dispensing_days_late
from temp_eom_appts;
