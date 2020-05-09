
-- Extracting Device ID, date/time, footfall counter & battery counter
-- from uploaded messages for storage into DynamoDB
SELECT dev_id, metadata.time, payload_fields.footfall, payload_fields.battery FROM '+/devices/+/up'
