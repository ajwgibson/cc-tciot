
-- First prototype rule ... extracting Device ID, date/time & the footfall
-- counter from uploaded messages for storage into DynamoDB
SELECT dev_id, metadata.time, payload_fields.footfall FROM '+/devices/+/up'
