-- migrate:up

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

--
-- Name: generate_ulid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.generate_ulid() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  -- Crockford's Base32
  encoding   BYTEA = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  timestamp  BYTEA = E'\\000\\000\\000\\000\\000\\000';
  output     TEXT = '';

  unix_time  BIGINT;
  ulid       BYTEA;
BEGIN
  -- 6 timestamp bytes
  unix_time = (EXTRACT(EPOCH FROM CLOCK_TIMESTAMP()) * 1000)::BIGINT;
  timestamp = SET_BYTE(timestamp, 0, (unix_time >> 40)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 1, (unix_time >> 32)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 2, (unix_time >> 24)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 3, (unix_time >> 16)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 4, (unix_time >> 8)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 5, unix_time::BIT(8)::INTEGER);

  -- 10 entropy bytes
  ulid = timestamp || gen_random_bytes(10);

  -- Encode the timestamp
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 224) >> 5));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 1) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 1) & 7) << 2) | ((GET_BYTE(ulid, 2) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 2) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 2) & 1) << 4) | ((GET_BYTE(ulid, 3) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 3) & 15) << 1) | ((GET_BYTE(ulid, 4) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 4) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 4) & 3) << 3) | ((GET_BYTE(ulid, 5) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 5) & 31)));

  -- Encode the entropy
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 6) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 6) & 7) << 2) | ((GET_BYTE(ulid, 7) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 7) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 7) & 1) << 4) | ((GET_BYTE(ulid, 8) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 8) & 15) << 1) | ((GET_BYTE(ulid, 9) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 9) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 9) & 3) << 3) | ((GET_BYTE(ulid, 10) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 10) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 11) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 11) & 7) << 2) | ((GET_BYTE(ulid, 12) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 12) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 12) & 1) << 4) | ((GET_BYTE(ulid, 13) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 13) & 15) << 1) | ((GET_BYTE(ulid, 14) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 14) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 14) & 3) << 3) | ((GET_BYTE(ulid, 15) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 15) & 31)));

  RETURN output;
END
$$;

--
-- Name: health(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.health() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
   RETURN 'ok';
END;
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.contracts (
    id text DEFAULT public.generate_ulid() NOT NULL,
    chain_id bigint NOT NULL,
    address character varying(42) NOT NULL,
    name character varying(255) NOT NULL,
    owner character varying(42) NOT NULL
);

CREATE TABLE public.account_metadata (
    chain_id bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    address character varying(42) NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);

CREATE TABLE public.list_nfts (
    chain_id bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    token_id bigint NOT NULL,
    owner character varying(42) NOT NULL,
    list_manager character varying(42),
    list_user character varying(42),
    list_storage_location character varying(255),
    list_storage_location_chain_id BIGINT,
    list_storage_location_contract_address character varying(42),
    list_storage_location_nonce bigint
);

CREATE TABLE public.list_metadata (
    chain_id bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    token_id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);

CREATE TABLE public.list_ops (
    id text DEFAULT public.generate_ulid() NOT NULL,
    chain_id bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    nonce bigint NOT NULL,
    op character varying(255) NOT NULL,
    version smallint NOT NULL,
    CHECK (version >= 0 AND version <= 255),
    code smallint NOT NULL,
    CHECK (code >= 0 AND code <= 255),
    data character varying(255) NOT NULL
);

CREATE TABLE public.list_records (
    id text DEFAULT public.generate_ulid() NOT NULL,
    chain_id bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    nonce bigint NOT NULL,
    record character varying(255) NOT NULL,
    version smallint NOT NULL,
    CHECK (version >= 0 AND version <= 255),
    type smallint NOT NULL,
    CHECK (type >= 0 AND type <= 255),
    data character varying(255) NOT NULL
);

--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id text DEFAULT public.generate_ulid() NOT NULL,
    transaction_hash character varying(66) NOT NULL,
    block_number bigint NOT NULL,
    contract_address character varying(42) NOT NULL,
    event_name character varying(255) NOT NULL,
    event_parameters jsonb NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    processed text DEFAULT 'false'::text NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;

--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: idx_block_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_block_number ON public.events USING btree (block_number);


--
-- Name: idx_contract_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contract_address ON public.events USING btree (contract_address);


--
-- Name: idx_event_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_name ON public.events USING btree (event_name);


--
-- Name: idx_transaction_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transaction_hash ON public.events USING btree (transaction_hash);


-- migrate:down

