SET sql_safe_updates = 0;
SET @hiv_intake = (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'c31d306a-40c4-11e7-a919-92ebcb67fe33');
SET @hiv_followup = (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'c31d3312-40c4-11e7-a919-92ebcb67fe33');

DROP TEMPORARY TABLE IF EXISTS temp_hiv_visit;
CREATE TEMPORARY TABLE temp_hiv_visit
(
encounter_id	INT,
patient_id		INT,
emr_id			VARCHAR(25),
pregnant		BIT,
visit_date		DATE,
next_visit_date	DATE,
visit_location	varchar(255)
);

INSERT INTO temp_hiv_visit(patient_id, encounter_id, emr_id, visit_date)
SELECT patient_id, encounter_id, ZLEMR(patient_id),  DATE(encounter_datetime) FROM encounter WHERE voided = 0 AND encounter_type IN (@hiv_intake, @hiv_followup);

DELETE FROM temp_hiv_visit
WHERE
    patient_id IN (SELECT
        a.person_id
    FROM
        person_attribute a
            INNER JOIN
        person_attribute_type t ON a.person_attribute_type_id = t.person_attribute_type_id
            AND a.value = 'true'
            AND t.name = 'Test Patient');

update temp_hiv_visit t set visit_location = location_name(hivEncounterLocationId(encounter_id));           

UPDATE temp_hiv_visit t SET pregnant = (SELECT value_coded FROM obs o WHERE voided = 0 AND concept_id = CONCEPT_FROM_MAPPING("PIH", "PREGNANCY STATUS") AND o.encounter_id = t.encounter_id);

UPDATE temp_hiv_visit t SET next_visit_date = obs_value_datetime(t.encounter_id,'PIH','RETURN VISIT DATE');

SELECT * FROM temp_hiv_visit;
