CREATE TABLE datakind_encounter
(
    patient_id         INT,
    encounter_id       INT,
    encounter_datetime DATETIME,
    encounter_type     VARCHAR(255),
    encounter_location TEXT,
    provider           VARCHAR(255),
    date_entered       DATETIME,
    user_entered       VARCHAR(50),
    date_changed       DATETIME,
    obs_count          INT,
    index_asc          INT,
    index_desc         INT
);