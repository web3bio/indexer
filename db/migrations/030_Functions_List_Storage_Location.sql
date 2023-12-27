-- migrate:up



-------------------------------------------------------------------------------
-- Function: is_list_location_hexstring
-- Description: Validates that the given string is a valid list location
--              hexadecimal string. The string must start with '0x' and contain
--              172 hexadecimal characters. The function uses a regular
--              expression to validate the format.
-- Parameters:
--   - hexstring (TEXT): The hexadecimal string to be validated.
-- Returns: TRUE if the string is valid, FALSE otherwise.
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_list_location_hexstring(hexstring TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql IMMUTABLE
AS $$
BEGIN
    RETURN hexstring ~ '^0x[a-f0-9]{172}$';
END;
$$;



-------------------------------------------------------------------------------
-- Function: decode_list_storage_location
-- Description: Decodes a list storage location string into its components.
--              The list storage location string is composed of:
--              - version (1 byte)
--              - locationType (1 byte)
--              - chainId (32 bytes)
--              - contractAddress (20 bytes)
--              - nonce (32 bytes)
--              The function validates the length of the input string and
--              extracts the components.
-- Parameters:
--   - list_storage_location (TEXT): The list storage location string to be
--                                   decoded.
-- Returns: A table with 'version' (SMALLINT), 'location_type' (SMALLINT),
--          'chain_id' (bigint), 'contract_address' (VARCHAR(42)), and 'nonce'
--          (VARCHAR(42)).
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.decode_list_storage_location(
    list_storage_location VARCHAR(174)
)
RETURNS TABLE(
    version SMALLINT,
    location_type SMALLINT,
    chain_id BIGINT,
    contract_address types.eth_address,
    nonce BIGINT
)
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    hex_data bytea;
    hex_chain_id VARCHAR(66);
    temp_nonce bytea;
BEGIN
    -- Check if the length is valid
    IF NOT public.is_list_location_hexstring(list_storage_location) THEN
        RAISE EXCEPTION 'Invalid list location';
    END IF;

    -- Convert the hex string (excluding '0x') to bytea
    hex_data := DECODE(SUBSTRING(list_storage_location FROM 3), 'hex');

    ----------------------------------------
    -- version
    ----------------------------------------
    version := GET_BYTE(hex_data, 0);
    IF version != 1 THEN
        RAISE EXCEPTION 'Invalid version: % (expected 1)', version;
    END IF;

    ----------------------------------------
    -- location_type
    ----------------------------------------
    location_type := GET_BYTE(hex_data, 1);
    IF location_type != 1 THEN
        RAISE EXCEPTION 'Invalid location type: % (expected 1)', location_type;
    END IF;

    ----------------------------------------
    -- chain_id
    ----------------------------------------

    -- Extract chainId (32 bytes) as hex string and convert to bigint
    hex_chain_id := '0x' || ENCODE(SUBSTRING(hex_data FROM 3 FOR 32), 'hex');
    chain_id := public.convert_hex_to_bigint(hex_chain_id);

    ----------------------------------------
    -- contract_address
    ----------------------------------------

    -- Extract contractAddress (20 bytes to TEXT)
    contract_address := ('0x' || ENCODE(SUBSTRING(hex_data FROM 35 FOR 20), 'hex'))::types.eth_address;

    ----------------------------------------
    -- nonce
    ----------------------------------------

    -- Extract nonce (32 bytes to TEXT)
    temp_nonce := SUBSTRING(hex_data FROM 55 FOR 32);
    nonce := public.convert_hex_to_bigint('0x' || ENCODE(temp_nonce, 'hex'));

    RETURN NEXT;
END;
$$;



-- migrate:down