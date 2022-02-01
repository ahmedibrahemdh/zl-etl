SELECT
    warning_type,
    count(*) as count,
    NOW() as timestamp,
    MAX(flag_for_review) as flag_for_review      -- for now, if any of entries on that warning type are true, set true on aggregrate column
FROM hivmigration_data_warnings
GROUP BY warning_type
