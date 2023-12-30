-- migrate:up
-------------------------------------------------------------------------------
-- Function: handle_contract_event
-- Description: Processes a blockchain event and inserts it into the
--              contract_events table.
-- Parameters:
--   - p_chain_id (BIGINT): The blockchain network identifier.
--   - p_block_number (BIGINT): The block number.
--   - p_transaction_index (SMALLINT): The transaction index.
--   - p_log_index (SMALLINT): The log index.
--   - p_contract_address (VARCHAR(66)): The contract address.
--   - p_event_name (VARCHAR): The name of the event.
--   - p_event_args (JSON): The event arguments as a JSON object.
--   - p_block_hash (VARCHAR(66)): The hash of the block.
--   - p_transaction_hash (VARCHAR(42)): The transaction hash.
-- Returns: VOID
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION public.handle_contract_event (
  p_chain_id BIGINT,
  p_block_number BIGINT,
  p_transaction_index SMALLINT,
  p_log_index SMALLINT,
  p_contract_address VARCHAR(42),
  p_contract_name VARCHAR(255),
  p_event_name VARCHAR(255),
  p_event_args JSON,
  p_block_hash VARCHAR(66),
  p_transaction_hash VARCHAR(66)
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN

    -- if it already exists, raise exception
    IF EXISTS (
        SELECT 1
        FROM public.contract_events
        WHERE chain_id = p_chain_id
        AND block_number = p_block_number
        AND transaction_index = p_transaction_index
        AND log_index = p_log_index
    ) THEN
        RAISE EXCEPTION 'contract event (%, %, %, %) already exists',
            p_chain_id,
            p_block_number,
            p_transaction_index,
            p_log_index;
    END IF;

    -- Insert the event into the contract_events table
    INSERT INTO public.contract_events (
        chain_id,
        block_number,
        transaction_index,
        log_index,
        contract_address,
        event_name,
        event_args,
        block_hash,
        transaction_hash
    ) VALUES (
        p_chain_id,
        p_block_number,
        p_transaction_index,
        p_log_index,
        public.normalize_eth_address(p_contract_address),
        p_event_name,
        p_event_args::JSON,
        public.normalize_eth_block_hash(p_block_hash),
        public.normalize_eth_transaction_hash(p_transaction_hash)
    );

    CASE p_event_name
        WHEN 'ListOp' THEN
            PERFORM public.handle_contract_event__ListOp(
                p_chain_id,
                p_contract_address,
                (p_event_args->>'nonce')::types.efp_list_storage_location_nonce,
                p_event_args->>'op'
            );

        WHEN 'MintStateChange' THEN
            -- skip

        WHEN 'OwnershipTransferred' THEN
            PERFORM public.handle_contract_event__OwnershipTransferred(
                p_chain_id,
                p_contract_address,
                p_contract_name,
                public.normalize_eth_address(p_event_args->>'previousOwner'),
                public.normalize_eth_address(p_event_args->>'newOwner')
            );

        WHEN 'ProxyAdded' THEN
            -- skip

        WHEN 'Transfer' THEN
            PERFORM public.handle_contract_event__Transfer(
                p_chain_id,
                p_contract_address,
                (p_event_args->>'tokenId')::types.efp_list_nft_token_id,
                public.normalize_eth_address(p_event_args->>'from'),
                public.normalize_eth_address(p_event_args->>'to')
            );

        WHEN 'UpdateAccountMetadata' THEN
            PERFORM public.handle_contract_event__UpdateAccountMetadata(
                p_chain_id,
                p_contract_address,
                public.normalize_eth_address(p_event_args->>'addr'),
                p_event_args->>'key',
                (p_event_args->>'value')::types.hexstring
            );

        WHEN 'UpdateListMetadata' THEN
            PERFORM public.handle_contract_event__UpdateListMetadata(
                p_chain_id,
                p_contract_address,
                (p_event_args->>'nonce')::types.efp_list_storage_location_nonce,
                p_event_args->>'key',
                (p_event_args->>'value')::types.hexstring
            );

        WHEN 'UpdateListStorageLocation' THEN
            PERFORM public.handle_contract_event__UpdateListStorageLocation(
                p_chain_id,
                p_contract_address,
                (p_event_args->>'nonce')::types.efp_list_storage_location_nonce,
                p_event_args->>'listStorageLocation'
            );

        ELSE
            RAISE EXCEPTION 'unrecognized event name: %', p_event_name;
    END CASE;
END;
$$;



-- migrate:down
