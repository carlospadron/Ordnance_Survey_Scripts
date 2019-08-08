/* Edited from Ordnance Survey Documentation*/
CREATE OR REPLACE VIEW
  os.address
AS (
SELECT
  l.uprn,
  l.sao_text, 
  l.sao_start_number, 
  l.sao_start_suffix, 
  l.sao_end_number, 
  l.sao_end_suffix,
  l.pao_text, 
  l.pao_start_number, 
  l.pao_start_suffix, 
  l.pao_end_number, 
  l.pao_end_suffix,
  s.street_description,
  s.locality,
  b.postcode_locator,
  /*
  Concatenate a single GEOGRAPHIC address line label
  ThIS code takes into account all possible combinations os pao/sao numbers AND suffixes
  */
  CASE WHEN o.organisation != '' THEN o.organISation || ', ' ELSE '' END
  -- Secondary Addressable Information--------------------------------------------------------------------------------------
  || CASE WHEN l.sao_text != '' THEN l.sao_text || ', ' ELSE '' END
  -- CASE statement for different combinations of the sao start numbers (e.g. if no sao start suffix)
  || CASE
  WHEN l.sao_start_number IS NOT NULL AND l.sao_start_suffix = '' AND l.sao_end_number IS NULL
  THEN l.sao_start_number::varchar(4) || ', '
  WHEN l.sao_start_number IS NULL THEN '' ELSE l.sao_start_number::varchar(4) || '' END
  -- CASE statement for different combinations of the sao start suffixes (e.g. if no sao END number)
  || CASE
  WHEN l.sao_start_suffix != '' AND l.sao_end_number IS NULL THEN l.sao_start_suffix || ', '
  WHEN l.sao_start_suffix != '' AND l.sao_end_number IS NOT NULL THEN l.sao_start_suffix ELSE '' END
  -- Add a '-' between the start AND END of the secondary address (e.g. only WHEN sao start AND sao END)
  || CASE
  WHEN l.sao_end_suffix != '' AND l.sao_end_number IS NOT NULL THEN '-'
  WHEN l.sao_start_number IS NOT NULL AND l.sao_end_number IS NOT NULL THEN '-' ELSE '' END
  -- CASE statement for different combinations of the sao END numbers AND sao END suffixes
  || CASE
  WHEN l.sao_end_number IS NOT NULL AND l.sao_end_suffix = '' THEN l.sao_end_number::varchar(4) || ', '
  WHEN l.sao_end_number IS NULL THEN '' ELSE l.sao_end_number::varchar(4) END
  -- pao END suffix
  || CASE WHEN l.sao_end_suffix != '' THEN l.sao_end_suffix || ', ' ELSE '' END
  -- Primary Addressable Information----------------------------------------------------------------------------------------------------------
  || CASE WHEN l.pao_text != '' THEN l.pao_text || ', ' ELSE '' END
  -- CASE statement for different combinations of the pao start numbers (e.g. if no pao start suffix)
  || CASE
  WHEN l.pao_start_number IS NOT NULL AND l.pao_start_suffix = '' AND l.pao_end_number IS NULL
  THEN l.pao_start_number::varchar(4) || ', '
  WHEN l.pao_start_number IS NULL THEN ''
  ELSE l.pao_start_number::varchar(4) || '' END
  -- CASE statement for different combinations of the pao start suffixes (e.g. if no pao END number)
  || CASE
  WHEN l.pao_start_suffix != '' AND l.pao_end_number IS NULL THEN l.pao_start_suffix || ', '
  WHEN l.pao_start_suffix != '' AND l.pao_end_number IS NOT NULL THEN l.pao_start_suffix
  ELSE '' END
  -- Add a '-' between the start AND END of the primary address (e.g. only WHEN pao start AND pao END)
  || CASE
  WHEN l.pao_end_suffix != '' AND l.pao_end_number IS NOT NULL THEN '-'
  WHEN l.pao_start_number IS NOT NULL AND l.pao_end_number IS NOT NULL THEN '-'
  ELSE '' END
  -- CASE statement for different combinations of the pao END numbers AND pao END suffixes
  || CASE
  WHEN l.pao_end_number IS NOT NULL AND l.pao_end_suffix = '' THEN l.pao_end_number::varchar(4) || ', '
  WHEN l.pao_end_number IS NULL THEN ''
  ELSE l.pao_end_number::varchar(4) END
  -- pao END suffix
  || CASE WHEN l.pao_end_suffix != '' THEN l.pao_end_suffix || ', ' ELSE '' END
  -- Street Information-----------------------------------------------------------------------------------------------------------
  || CASE WHEN s.street_description != '' THEN s.street_description || ', ' ELSE '' END
  -- Locality------------------------------------------------------------------------------------------------------------------------
  || CASE WHEN s.locality != '' THEN s.locality ||', ' ELSE '' END
  -- Town--------------------------------------------------------------------------------------------------------------------------
  || CASE WHEN s.town_name != '' THEN s.town_name || ', ' ELSE '' END
  -- Postcode---------------------------------------------------------------------------------------------------------------------
  || CASE WHEN b.postcode_locator != '' THEN b.postcode_locator ELSE '' END
  AS geo_single_address_label
FROM
  os.basiclandpropertyunit AS b, 
  os.streetdescriptiveidentifier AS s,
  os.landpropertyidentifier AS l 
FULL OUTER JOIN 
  os.organisation AS o 
ON 
  l.uprn = o.uprn
WHERE 
  b.uprn = l.uprn
  AND l.usrn = s.usrn
  AND l.language = s.language);
