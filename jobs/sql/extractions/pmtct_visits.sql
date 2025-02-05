SET sqL_safe_updates = 0;

SET @initial_pmtct_encounter = ENCOUNTER_TYPE('584124b9-1f10-4757-ba09-91fc9075af92');
SET @followup_pmtct_encounter =  ENCOUNTER_TYPE('95e03e7d-9aeb-4a99-bd7a-94e8591ec2c5');

-- drop and create temp pmct visit table
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit;
CREATE TEMPORARY TABLE temp_pmtct_visit (
    visit_id                INT,
    encounter_id            INT,
    patient_id              INT,
    emr_id 					VARCHAR(25),
    visit_date              DATE,
    health_facility         VARCHAR(100),
    date_entered            DATETIME,
    user_entered            VARCHAR(50),
    hiv_test_date           DATE,
    tb_screening_date 		DATE,
    has_provided_contact 	BIT,
    -- hiv_test_result varchar(255),
    -- maternity_clinic_type varchar(100),
    index_asc               INT,
    index_desc              INT
);

INSERT INTO temp_pmtct_visit (visit_id, encounter_id, patient_id, emr_id, date_entered, user_entered)
SELECT visit_id, encounter_id, patient_id, zlemr(patient_id), date_created, username(creator) FROM encounter WHERE encounter_type IN (@initial_pmtct_encounter, @followup_pmtct_encounter) AND voided = 0;

-- visit date
UPDATE temp_pmtct_visit t SET t.visit_date = VISIT_DATE(t.encounter_id);

-- facility where healthcare is received
 UPDATE temp_pmtct_visit t SET t.health_facility = ENCOUNTER_LOCATION_NAME(t.encounter_id);
 
-- Hiv test date
UPDATE  temp_pmtct_visit t SET hiv_test_date = OBS_VALUE_DATETIME(t.encounter_id, 'PIH', 'HIV TEST DATE');

-- contacts
SET @relationship = CONCEPT_FROM_MAPPING('PIH', '13265');
SET @first_name = CONCEPT_FROM_MAPPING('PIH', 'FIRST NAME');
SET @last_name = CONCEPT_FROM_MAPPING('PIH', 'LAST NAME');
SET @phone = CONCEPT_FROM_MAPPING('PIH', 'TELEPHONE NUMBER OF CONTACT');
UPDATE temp_pmtct_visit t SET has_provided_contact = (select 1 from obs o where voided = 0 and o.encounter_id = t.encounter_id and 
o.concept_id in (@relationship, @first_name, @last_name, @phone) group by o.encounter_id); 



-- tb screening date
drop table if exists temp_pmtct_tb_visits;
create table temp_pmtct_tb_visits
(
patient_id INT(11),
encounter_id INT(11),
obs_date DATETIME,
cough_result_concept INT(11),
fever_result_concept INT(11),
weight_loss_result_concept INT(11),
tb_contact_result_concept INT(11),
lymph_pain_result_concept INT(11),
bloody_cough_result_concept INT(11),
dyspnea_result_concept INT(11),
chest_pain_result_concept INT(11),
tb_screening_date DATETIME
);

INSERT INTO temp_pmtct_tb_visits (patient_id, encounter_id)
SELECT patient_id, encounter_id FROM temp_pmtct_visit;

SET @present = CONCEPT_FROM_MAPPING('PIH','11563');
SET @fever_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '11565');
SET @weight_loss_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '11566');
SET @cough_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '11567');
SET @tb_contact_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '11568');
SET @lymph_pain_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '11569');
SET @bloody_cough_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '970');
SET @dyspnea_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '5960');
SET @chest_pain_result_concept_id = CONCEPT_FROM_MAPPING('PIH', '136');

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o on t.encounter_id = o.encounter_id and value_coded in 
(
@fever_result_concept_id,
@weight_loss_result_concept_id,
@cough_result_concept_id,
@tb_contact_result_concept_id,
@lymph_pain_result_concept_id,
@bloody_cough_result_concept_id,
@dyspnea_result_concept_id,
@chest_pain_result_concept_id
)
set t.obs_date = o.obs_datetime;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @fever_result_concept_id
SET fever_result_concept = o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @weight_loss_result_concept_id
SET weight_loss_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @cough_result_concept_id
SET cough_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @tb_contact_result_concept_id
SET tb_contact_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @lymph_pain_result_concept_id
SET lymph_pain_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @bloody_cough_result_concept_id
SET bloody_cough_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @dyspnea_result_concept_id
SET dyspnea_result_concept =o.concept_id;

UPDATE temp_pmtct_tb_visits t
INNER JOIN obs o ON t.encounter_id = o.encounter_id AND o.value_coded = @chest_pain_result_concept_id
SET chest_pain_result_concept = o.concept_id;

UPDATE temp_pmtct_tb_visits t SET tb_screening_date = IF(cough_result_concept = @present, t.obs_date,
  IF(fever_result_concept = @present, t.obs_date,
    IF(weight_loss_result_concept = @present, t.obs_date,
      IF(tb_contact_result_concept = @present, t.obs_date,
        IF(lymph_pain_result_concept = @present, t.obs_date,
          IF(bloody_cough_result_concept = @present, t.obs_date,
            IF(dyspnea_result_concept = @present, t.obs_date,
              IF(chest_pain_result_concept = @present, t.obs_date,
                NULL)))))))); 

UPDATE temp_pmtct_visit t SET tb_screening_date = (select tb_screening_date from temp_pmtct_tb_visits tp where tp.encounter_id = t.encounter_id);

-- index asc
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit_index_asc;
CREATE TEMPORARY TABLE temp_pmtct_visit_index_asc
(
    SELECT
            visit_date,
            visit_id,
            encounter_id,
            patient_id,
			index_asc
    FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_asc,
            visit_date,
            visit_id,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_pmtct_visit,
            (SELECT @r:= 1) AS r,
            (SELECT @u:= 0) AS u
      ORDER BY patient_id, visit_date ASC, visit_id ASC
        ) index_ascending );

-- index desc
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit_index_desc;
CREATE TEMPORARY TABLE temp_pmtct_visit_index_desc
(
    SELECT
            visit_date,
            visit_id,
            encounter_id,
            patient_id,
			index_desc
    FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_desc,
            visit_date,
            visit_id,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_pmtct_visit,
            (SELECT @r:= 1) AS r,
            (SELECT @u:= 0) AS u
      ORDER BY patient_id, visit_date DESC, visit_id DESC
        ) index_descending );
 
UPDATE temp_pmtct_visit t SET t.index_asc = (SELECT index_asc FROM temp_pmtct_visit_index_asc a WHERE t.visit_id = a.visit_id);
UPDATE temp_pmtct_visit t SET t.index_desc = (SELECT index_desc FROM temp_pmtct_visit_index_desc b WHERE t.visit_id = b.visit_id);

SELECT * FROM temp_pmtct_visit ORDER BY patient_id, visit_date, visit_id;