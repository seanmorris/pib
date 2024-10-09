--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8 (Debian 15.8-0+deb12u1)

-- Started on 2024-09-23 16:55:43 EDT

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

-- DROP DATABASE drupal;
--
-- TOC entry 4099 (class 1262 OID 16384)
-- Name: drupal; Type: DATABASE; Schema: -; Owner: -
--

-- CREATE DATABASE drupal WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


-- \connect drupal

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
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

DROP SCHEMA public cascade;
CREATE SCHEMA public;

--
-- TOC entry 4100 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 284 (class 1255 OID 16397)
-- Name: concat(anynonarray, anynonarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.concat(anynonarray, anynonarray) RETURNS text
    LANGUAGE sql
    AS $_$SELECT CAST($1 AS text) || CAST($2 AS text);$_$;


--
-- TOC entry 282 (class 1255 OID 16399)
-- Name: concat(anynonarray, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.concat(anynonarray, text) RETURNS text
    LANGUAGE sql
    AS $_$SELECT CAST($1 AS text) || $2;$_$;


--
-- TOC entry 281 (class 1255 OID 16398)
-- Name: concat(text, anynonarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.concat(text, anynonarray) RETURNS text
    LANGUAGE sql
    AS $_$SELECT $1 || CAST($2 AS text);$_$;


--
-- TOC entry 283 (class 1255 OID 16400)
-- Name: concat(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.concat(text, text) RETURNS text
    LANGUAGE sql
    AS $_$SELECT $1 || $2;$_$;


--
-- TOC entry 286 (class 1255 OID 16393)
-- Name: greatest(numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."greatest"(numeric, numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$SELECT CASE WHEN (($1 > $2) OR ($2 IS NULL)) THEN $1 ELSE $2 END;$_$;


--
-- TOC entry 285 (class 1255 OID 16394)
-- Name: greatest(numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."greatest"(numeric, numeric, numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$SELECT greatest($1, greatest($2, $3));$_$;


--
-- TOC entry 279 (class 1255 OID 16395)
-- Name: rand(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rand() RETURNS double precision
    LANGUAGE sql
    AS $$SELECT random();$$;


--
-- TOC entry 280 (class 1255 OID 16396)
-- Name: substring_index(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.substring_index(text, text, integer) RETURNS text
    LANGUAGE sql
    AS $_$SELECT array_to_string((string_to_array($1, $2)) [1:$3], $2);$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16409)
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actions (
    aid character varying(255) DEFAULT '0'::character varying NOT NULL,
    type character varying(32) DEFAULT ''::character varying NOT NULL,
    callback character varying(255) DEFAULT ''::character varying NOT NULL,
    parameters bytea NOT NULL,
    label character varying(255) DEFAULT '0'::character varying NOT NULL
);


--
-- TOC entry 4101 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.actions IS 'Stores action information.';


--
-- TOC entry 4102 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN actions.aid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actions.aid IS 'Primary Key: Unique actions ID.';


--
-- TOC entry 4103 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN actions.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actions.type IS 'The object that that action acts on (node, user, comment, system or custom types.)';


--
-- TOC entry 4104 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN actions.callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actions.callback IS 'The callback function that executes when the action runs.';


--
-- TOC entry 4105 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN actions.parameters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actions.parameters IS 'Parameters to be passed to the callback function.';


--
-- TOC entry 4106 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN actions.label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actions.label IS 'Label of the action.';


--
-- TOC entry 249 (class 1259 OID 16760)
-- Name: authmap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authmap (
    aid integer NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    authname character varying(128) DEFAULT ''::character varying NOT NULL,
    module character varying(128) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT authmap_aid_check CHECK ((aid >= 0))
);


--
-- TOC entry 4107 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE authmap; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.authmap IS 'Stores distributed authentication mapping.';


--
-- TOC entry 4108 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN authmap.aid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.authmap.aid IS 'Primary Key: Unique authmap ID.';


--
-- TOC entry 4109 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN authmap.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.authmap.uid IS 'User''s users.uid.';


--
-- TOC entry 4110 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN authmap.authname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.authmap.authname IS 'Unique authentication name.';


--
-- TOC entry 4111 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN authmap.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.authmap.module IS 'Module which is controlling the authentication.';


--
-- TOC entry 248 (class 1259 OID 16759)
-- Name: authmap_aid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authmap_aid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4112 (class 0 OID 0)
-- Dependencies: 248
-- Name: authmap_aid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authmap_aid_seq OWNED BY public.authmap.aid;


--
-- TOC entry 216 (class 1259 OID 16420)
-- Name: batch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.batch (
    bid bigint NOT NULL,
    token character varying(64) NOT NULL,
    "timestamp" integer NOT NULL,
    batch bytea,
    CONSTRAINT batch_bid_check CHECK ((bid >= 0))
);


--
-- TOC entry 4113 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE batch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.batch IS 'Stores details about batches (processes that run in multiple HTTP requests).';


--
-- TOC entry 4114 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN batch.bid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.batch.bid IS 'Primary Key: Unique batch ID.';


--
-- TOC entry 4115 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN batch.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.batch.token IS 'A string token generated against the current user''s session id and the batch id, used to ensure that only the user who submitted the batch can effectively access it.';


--
-- TOC entry 4116 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN batch."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.batch."timestamp" IS 'A Unix timestamp indicating when this batch was submitted for processing. Stale batches are purged at cron time.';


--
-- TOC entry 4117 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN batch.batch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.batch.batch IS 'A serialized array containing the processing data for the batch.';


--
-- TOC entry 272 (class 1259 OID 17034)
-- Name: block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.block (
    bid integer NOT NULL,
    module character varying(64) DEFAULT ''::character varying NOT NULL,
    delta character varying(32) DEFAULT '0'::character varying NOT NULL,
    theme character varying(64) DEFAULT ''::character varying NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    region character varying(64) DEFAULT ''::character varying NOT NULL,
    custom smallint DEFAULT 0 NOT NULL,
    visibility smallint DEFAULT 0 NOT NULL,
    pages text NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    cache smallint DEFAULT 1 NOT NULL
);


--
-- TOC entry 4118 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE block; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.block IS 'Stores block settings, such as region and visibility settings.';


--
-- TOC entry 4119 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.bid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.bid IS 'Primary Key: Unique block ID.';


--
-- TOC entry 4120 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.module IS 'The module from which the block originates; for example, ''user'' for the Who''s Online block, and ''block'' for any custom blocks.';


--
-- TOC entry 4121 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.delta IS 'Unique ID for block within a module.';


--
-- TOC entry 4122 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.theme; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.theme IS 'The theme under which the block settings apply.';


--
-- TOC entry 4123 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.status IS 'Block enabled status. (1 = enabled, 0 = disabled)';


--
-- TOC entry 4124 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.weight IS 'Block weight within region.';


--
-- TOC entry 4125 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.region; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.region IS 'Theme region within which the block is set.';


--
-- TOC entry 4126 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.custom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.custom IS 'Flag to indicate how users may control visibility of the block. (0 = Users cannot control, 1 = On by default, but can be hidden, 2 = Hidden by default, but can be shown)';


--
-- TOC entry 4127 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.visibility; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.visibility IS 'Flag to indicate how to show blocks on pages. (0 = Show on all pages except listed pages, 1 = Show only on listed pages, 2 = Use custom PHP code to determine visibility)';


--
-- TOC entry 4128 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.pages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.pages IS 'Contents of the "Pages" block; contains either a list of paths on which to include/exclude the block or PHP code, depending on "visibility" setting.';


--
-- TOC entry 4129 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.title IS 'Custom title for the block. (Empty string will use block default title, <none> will remove the title, text will cause block to use specified title.)';


--
-- TOC entry 4130 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN block.cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.cache IS 'Binary flag to indicate block cache mode. (-2: Custom cache, -1: Do not cache, 1: Cache per role, 2: Cache per user, 4: Cache per page, 8: Block cache global) See DRUPAL_CACHE_* constants in ../includes/common.inc for more detailed information.';


--
-- TOC entry 271 (class 1259 OID 17033)
-- Name: block_bid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.block_bid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4131 (class 0 OID 0)
-- Dependencies: 271
-- Name: block_bid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.block_bid_seq OWNED BY public.block.bid;


--
-- TOC entry 275 (class 1259 OID 17063)
-- Name: block_custom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.block_custom (
    bid integer NOT NULL,
    body text,
    info character varying(128) DEFAULT ''::character varying NOT NULL,
    format character varying(255),
    CONSTRAINT block_custom_bid_check CHECK ((bid >= 0))
);


--
-- TOC entry 4132 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE block_custom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.block_custom IS 'Stores contents of custom-made blocks.';


--
-- TOC entry 4133 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN block_custom.bid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_custom.bid IS 'The block''s block.bid.';


--
-- TOC entry 4134 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN block_custom.body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_custom.body IS 'Block contents.';


--
-- TOC entry 4135 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN block_custom.info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_custom.info IS 'Block description.';


--
-- TOC entry 4136 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN block_custom.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_custom.format IS 'The filter_format.format of the block body.';


--
-- TOC entry 274 (class 1259 OID 17062)
-- Name: block_custom_bid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.block_custom_bid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4137 (class 0 OID 0)
-- Dependencies: 274
-- Name: block_custom_bid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.block_custom_bid_seq OWNED BY public.block_custom.bid;


--
-- TOC entry 261 (class 1259 OID 16926)
-- Name: block_node_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.block_node_type (
    module character varying(64) NOT NULL,
    delta character varying(32) NOT NULL,
    type character varying(32) NOT NULL
);


--
-- TOC entry 4138 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE block_node_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.block_node_type IS 'Sets up display criteria for blocks based on content types';


--
-- TOC entry 4139 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN block_node_type.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_node_type.module IS 'The block''s origin module, from block.module.';


--
-- TOC entry 4140 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN block_node_type.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_node_type.delta IS 'The block''s unique delta within module, from block.delta.';


--
-- TOC entry 4141 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN block_node_type.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_node_type.type IS 'The machine-readable name of this type from node_type.type.';


--
-- TOC entry 273 (class 1259 OID 17055)
-- Name: block_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.block_role (
    module character varying(64) NOT NULL,
    delta character varying(32) NOT NULL,
    rid bigint NOT NULL,
    CONSTRAINT block_role_rid_check CHECK ((rid >= 0))
);


--
-- TOC entry 4142 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE block_role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.block_role IS 'Sets up access permissions for blocks based on user roles';


--
-- TOC entry 4143 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN block_role.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_role.module IS 'The block''s origin module, from block.module.';


--
-- TOC entry 4144 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN block_role.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_role.delta IS 'The block''s unique delta within module, from block.delta.';


--
-- TOC entry 4145 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN block_role.rid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block_role.rid IS 'The user''s role ID from users_roles.rid.';


--
-- TOC entry 218 (class 1259 OID 16430)
-- Name: blocked_ips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocked_ips (
    iid integer NOT NULL,
    ip character varying(40) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT blocked_ips_iid_check CHECK ((iid >= 0))
);


--
-- TOC entry 4146 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE blocked_ips; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.blocked_ips IS 'Stores blocked IP addresses.';


--
-- TOC entry 4147 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN blocked_ips.iid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.blocked_ips.iid IS 'Primary Key: unique ID for IP addresses.';


--
-- TOC entry 4148 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN blocked_ips.ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.blocked_ips.ip IS 'IP address';


--
-- TOC entry 217 (class 1259 OID 16429)
-- Name: blocked_ips_iid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocked_ips_iid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4149 (class 0 OID 0)
-- Dependencies: 217
-- Name: blocked_ips_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocked_ips_iid_seq OWNED BY public.blocked_ips.iid;


--
-- TOC entry 219 (class 1259 OID 16439)
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4150 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache IS 'Generic cache table for caching things not separated out into their own tables. Contributed modules may also use this to store cached items.';


--
-- TOC entry 4151 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN cache.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4152 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN cache.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache.data IS 'A collection of data to cache.';


--
-- TOC entry 4153 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN cache.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4154 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN cache.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4155 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN cache.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 276 (class 1259 OID 17075)
-- Name: cache_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_block (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4156 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE cache_block; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_block IS 'Cache table for the Block module to store already built blocks, identified by module, delta, and various contexts which may change the block, such as theme, locale, and caching mode defined for the block.';


--
-- TOC entry 4157 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN cache_block.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_block.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4158 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN cache_block.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_block.data IS 'A collection of data to cache.';


--
-- TOC entry 4159 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN cache_block.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_block.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4160 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN cache_block.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_block.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4161 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN cache_block.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_block.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 220 (class 1259 OID 16451)
-- Name: cache_bootstrap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_bootstrap (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4162 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE cache_bootstrap; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_bootstrap IS 'Cache table for data required to bootstrap Drupal, may be routed to a shared memory cache.';


--
-- TOC entry 4163 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN cache_bootstrap.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_bootstrap.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4164 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN cache_bootstrap.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_bootstrap.data IS 'A collection of data to cache.';


--
-- TOC entry 4165 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN cache_bootstrap.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_bootstrap.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4166 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN cache_bootstrap.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_bootstrap.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4167 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN cache_bootstrap.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_bootstrap.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 270 (class 1259 OID 17021)
-- Name: cache_field; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_field (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4168 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE cache_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_field IS 'Cache table for the Field module to store already built field information.';


--
-- TOC entry 4169 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN cache_field.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_field.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4170 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN cache_field.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_field.data IS 'A collection of data to cache.';


--
-- TOC entry 4171 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN cache_field.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_field.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4172 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN cache_field.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_field.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4173 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN cache_field.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_field.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 265 (class 1259 OID 16969)
-- Name: cache_filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_filter (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4174 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE cache_filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_filter IS 'Cache table for the Filter module to store already filtered pieces of text, identified by text format and hash of the text.';


--
-- TOC entry 4175 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN cache_filter.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_filter.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4176 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN cache_filter.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_filter.data IS 'A collection of data to cache.';


--
-- TOC entry 4177 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN cache_filter.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_filter.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4178 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN cache_filter.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_filter.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4179 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN cache_filter.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_filter.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 221 (class 1259 OID 16463)
-- Name: cache_form; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_form (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4180 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE cache_form; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_form IS 'Cache table for the form system to store recently built forms and their storage data, to be used in subsequent page requests.';


--
-- TOC entry 4181 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN cache_form.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_form.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4182 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN cache_form.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_form.data IS 'A collection of data to cache.';


--
-- TOC entry 4183 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN cache_form.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_form.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4184 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN cache_form.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_form.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4185 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN cache_form.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_form.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 223 (class 1259 OID 16487)
-- Name: cache_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_menu (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4186 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE cache_menu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_menu IS 'Cache table for the menu system to store router information as well as generated link trees for various menu/page/user combinations.';


--
-- TOC entry 4187 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cache_menu.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_menu.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4188 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cache_menu.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_menu.data IS 'A collection of data to cache.';


--
-- TOC entry 4189 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cache_menu.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_menu.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4190 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cache_menu.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_menu.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4191 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cache_menu.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_menu.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 222 (class 1259 OID 16475)
-- Name: cache_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_page (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4192 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE cache_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_page IS 'Cache table used to store compressed pages for anonymous users, if page caching is enabled.';


--
-- TOC entry 4193 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN cache_page.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_page.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4194 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN cache_page.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_page.data IS 'A collection of data to cache.';


--
-- TOC entry 4195 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN cache_page.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_page.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4196 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN cache_page.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_page.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4197 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN cache_page.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_page.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 224 (class 1259 OID 16499)
-- Name: cache_path; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_path (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4198 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE cache_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cache_path IS 'Cache table for path alias lookup.';


--
-- TOC entry 4199 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN cache_path.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_path.cid IS 'Primary Key: Unique cache ID.';


--
-- TOC entry 4200 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN cache_path.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_path.data IS 'A collection of data to cache.';


--
-- TOC entry 4201 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN cache_path.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_path.expire IS 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.';


--
-- TOC entry 4202 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN cache_path.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_path.created IS 'A Unix timestamp indicating when the cache entry was created.';


--
-- TOC entry 4203 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN cache_path.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cache_path.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- TOC entry 228 (class 1259 OID 16529)
-- Name: date_format_locale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_format_locale (
    format character varying(100) NOT NULL,
    type character varying(64) NOT NULL,
    language character varying(12) NOT NULL
);


--
-- TOC entry 4204 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE date_format_locale; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_format_locale IS 'Stores configured date formats for each locale.';


--
-- TOC entry 4205 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN date_format_locale.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_locale.format IS 'The date format string.';


--
-- TOC entry 4206 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN date_format_locale.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_locale.type IS 'The date format type, e.g. medium.';


--
-- TOC entry 4207 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN date_format_locale.language; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_locale.language IS 'A languages.language for this format to be used with.';


--
-- TOC entry 225 (class 1259 OID 16511)
-- Name: date_format_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_format_type (
    type character varying(64) NOT NULL,
    title character varying(255) NOT NULL,
    locked smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4208 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE date_format_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_format_type IS 'Stores configured date format types.';


--
-- TOC entry 4209 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN date_format_type.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_type.type IS 'The date format type, e.g. medium.';


--
-- TOC entry 4210 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN date_format_type.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_type.title IS 'The human readable name of the format type.';


--
-- TOC entry 4211 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN date_format_type.locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_format_type.locked IS 'Whether or not this is a system provided format.';


--
-- TOC entry 227 (class 1259 OID 16519)
-- Name: date_formats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_formats (
    dfid integer NOT NULL,
    format character varying(100) NOT NULL,
    type character varying(64) NOT NULL,
    locked smallint DEFAULT 0 NOT NULL,
    CONSTRAINT date_formats_dfid_check CHECK ((dfid >= 0))
);


--
-- TOC entry 4212 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE date_formats; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_formats IS 'Stores configured date formats.';


--
-- TOC entry 4213 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN date_formats.dfid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_formats.dfid IS 'The date format identifier.';


--
-- TOC entry 4214 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN date_formats.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_formats.format IS 'The date format string.';


--
-- TOC entry 4215 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN date_formats.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_formats.type IS 'The date format type, e.g. medium.';


--
-- TOC entry 4216 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN date_formats.locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.date_formats.locked IS 'Whether or not this format can be modified.';


--
-- TOC entry 226 (class 1259 OID 16518)
-- Name: date_formats_dfid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.date_formats_dfid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4217 (class 0 OID 0)
-- Dependencies: 226
-- Name: date_formats_dfid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.date_formats_dfid_seq OWNED BY public.date_formats.dfid;


--
-- TOC entry 267 (class 1259 OID 16982)
-- Name: field_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_config (
    id integer NOT NULL,
    field_name character varying(32) NOT NULL,
    type character varying(128) NOT NULL,
    module character varying(128) DEFAULT ''::character varying NOT NULL,
    active smallint DEFAULT 0 NOT NULL,
    storage_type character varying(128) NOT NULL,
    storage_module character varying(128) DEFAULT ''::character varying NOT NULL,
    storage_active smallint DEFAULT 0 NOT NULL,
    locked smallint DEFAULT 0 NOT NULL,
    data bytea NOT NULL,
    cardinality smallint DEFAULT 0 NOT NULL,
    translatable smallint DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4218 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.id IS 'The primary identifier for a field';


--
-- TOC entry 4219 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.field_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.field_name IS 'The name of this field. Non-deleted field names are unique, but multiple deleted fields can have the same name.';


--
-- TOC entry 4220 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.type IS 'The type of this field.';


--
-- TOC entry 4221 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.module IS 'The module that implements the field type.';


--
-- TOC entry 4222 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.active IS 'Boolean indicating whether the module that implements the field type is enabled.';


--
-- TOC entry 4223 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.storage_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.storage_type IS 'The storage backend for the field.';


--
-- TOC entry 4224 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.storage_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.storage_module IS 'The module that implements the storage backend.';


--
-- TOC entry 4225 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.storage_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.storage_active IS 'Boolean indicating whether the module that implements the storage backend is enabled.';


--
-- TOC entry 4226 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.locked IS '@TODO';


--
-- TOC entry 4227 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN field_config.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config.data IS 'Serialized data containing the field properties that do not warrant a dedicated column.';


--
-- TOC entry 266 (class 1259 OID 16981)
-- Name: field_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.field_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4228 (class 0 OID 0)
-- Dependencies: 266
-- Name: field_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.field_config_id_seq OWNED BY public.field_config.id;


--
-- TOC entry 269 (class 1259 OID 17007)
-- Name: field_config_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_config_instance (
    id integer NOT NULL,
    field_id integer NOT NULL,
    field_name character varying(32) DEFAULT ''::character varying NOT NULL,
    entity_type character varying(32) DEFAULT ''::character varying NOT NULL,
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    data bytea NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- TOC entry 4229 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN field_config_instance.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config_instance.id IS 'The primary identifier for a field instance';


--
-- TOC entry 4230 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN field_config_instance.field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.field_config_instance.field_id IS 'The identifier of the field attached by this instance';


--
-- TOC entry 268 (class 1259 OID 17006)
-- Name: field_config_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.field_config_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4231 (class 0 OID 0)
-- Dependencies: 268
-- Name: field_config_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.field_config_instance_id_seq OWNED BY public.field_config_instance.id;


--
-- TOC entry 230 (class 1259 OID 16535)
-- Name: file_managed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_managed (
    fid integer NOT NULL,
    uid bigint DEFAULT 0 NOT NULL,
    filename character varying(255) DEFAULT ''::character varying NOT NULL,
    uri character varying(255) DEFAULT ''::character varying NOT NULL,
    filemime character varying(255) DEFAULT ''::character varying NOT NULL,
    filesize bigint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT file_managed_fid_check CHECK ((fid >= 0)),
    CONSTRAINT file_managed_filesize_check CHECK ((filesize >= 0)),
    CONSTRAINT file_managed_timestamp_check CHECK (("timestamp" >= 0)),
    CONSTRAINT file_managed_uid_check CHECK ((uid >= 0))
);


--
-- TOC entry 4232 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE file_managed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.file_managed IS 'Stores information for uploaded files.';


--
-- TOC entry 4233 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.fid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.fid IS 'File ID.';


--
-- TOC entry 4234 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.uid IS 'The users.uid of the user who is associated with the file.';


--
-- TOC entry 4235 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.filename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.filename IS 'Name of the file with no path components. This may differ from the basename of the URI if the file is renamed to avoid overwriting an existing file.';


--
-- TOC entry 4236 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.uri; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.uri IS 'The URI to access the file (either local or remote).';


--
-- TOC entry 4237 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.filemime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.filemime IS 'The file''s MIME type.';


--
-- TOC entry 4238 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.filesize; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.filesize IS 'The size of the file in bytes.';


--
-- TOC entry 4239 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed.status IS 'A field indicating the status of the file. Two status are defined in core: temporary (0) and permanent (1). Temporary files older than DRUPAL_MAXIMUM_TEMP_FILE_AGE will be removed during a cron run.';


--
-- TOC entry 4240 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN file_managed."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_managed."timestamp" IS 'UNIX timestamp for when the file was added.';


--
-- TOC entry 229 (class 1259 OID 16534)
-- Name: file_managed_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_managed_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4241 (class 0 OID 0)
-- Dependencies: 229
-- Name: file_managed_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_managed_fid_seq OWNED BY public.file_managed.fid;


--
-- TOC entry 231 (class 1259 OID 16559)
-- Name: file_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_usage (
    fid bigint NOT NULL,
    module character varying(255) DEFAULT ''::character varying NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    id bigint DEFAULT 0 NOT NULL,
    count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT file_usage_count_check CHECK ((count >= 0)),
    CONSTRAINT file_usage_fid_check CHECK ((fid >= 0)),
    CONSTRAINT file_usage_id_check CHECK ((id >= 0))
);


--
-- TOC entry 4242 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE file_usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.file_usage IS 'Track where a file is used.';


--
-- TOC entry 4243 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN file_usage.fid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_usage.fid IS 'File ID.';


--
-- TOC entry 4244 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN file_usage.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_usage.module IS 'The name of the module that is using the file.';


--
-- TOC entry 4245 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN file_usage.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_usage.type IS 'The name of the object type in which the file is used.';


--
-- TOC entry 4246 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN file_usage.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_usage.id IS 'The primary key of the object using the file.';


--
-- TOC entry 4247 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN file_usage.count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_usage.count IS 'The number of times this file is used by this object.';


--
-- TOC entry 263 (class 1259 OID 16942)
-- Name: filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter (
    format character varying(255) NOT NULL,
    module character varying(64) DEFAULT ''::character varying NOT NULL,
    name character varying(32) DEFAULT ''::character varying NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    settings bytea
);


--
-- TOC entry 4248 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.filter IS 'Table that maps filters (HTML corrector) to text formats (Filtered HTML).';


--
-- TOC entry 4249 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.format IS 'Foreign key: The filter_format.format to which this filter is assigned.';


--
-- TOC entry 4250 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.module IS 'The origin module of the filter.';


--
-- TOC entry 4251 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.name IS 'Name of the filter being referenced.';


--
-- TOC entry 4252 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.weight IS 'Weight of filter within format.';


--
-- TOC entry 4253 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.status IS 'Filter enabled status. (1 = enabled, 0 = disabled)';


--
-- TOC entry 4254 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN filter.settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter.settings IS 'A serialized array of name value pairs that store the filter settings for the specific format.';


--
-- TOC entry 264 (class 1259 OID 16954)
-- Name: filter_format; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_format (
    format character varying(255) NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    cache smallint DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    CONSTRAINT filter_format_status_check CHECK ((status >= 0))
);


--
-- TOC entry 4255 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE filter_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.filter_format IS 'Stores text formats: custom groupings of filters, such as Filtered HTML.';


--
-- TOC entry 4256 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN filter_format.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter_format.format IS 'Primary Key: Unique machine name of the format.';


--
-- TOC entry 4257 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN filter_format.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter_format.name IS 'Name of the text format (Filtered HTML).';


--
-- TOC entry 4258 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN filter_format.cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter_format.cache IS 'Flag to indicate whether format is cacheable. (1 = cacheable, 0 = not cacheable)';


--
-- TOC entry 4259 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN filter_format.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter_format.status IS 'The status of the text format. (1 = enabled, 0 = disabled)';


--
-- TOC entry 4260 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN filter_format.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filter_format.weight IS 'Weight of text format to use when listing.';


--
-- TOC entry 233 (class 1259 OID 16575)
-- Name: flood; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flood (
    fid integer NOT NULL,
    event character varying(64) DEFAULT ''::character varying NOT NULL,
    identifier character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    expiration integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 4261 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE flood; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.flood IS 'Flood controls the threshold of events, such as the number of contact attempts.';


--
-- TOC entry 4262 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN flood.fid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flood.fid IS 'Unique flood event ID.';


--
-- TOC entry 4263 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN flood.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flood.event IS 'Name of event (e.g. contact).';


--
-- TOC entry 4264 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN flood.identifier; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flood.identifier IS 'Identifier of the visitor, such as an IP address or hostname.';


--
-- TOC entry 4265 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN flood."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flood."timestamp" IS 'Timestamp of the event.';


--
-- TOC entry 4266 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN flood.expiration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flood.expiration IS 'Expiration timestamp. Expired events are purged on cron run.';


--
-- TOC entry 232 (class 1259 OID 16574)
-- Name: flood_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flood_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4267 (class 0 OID 0)
-- Dependencies: 232
-- Name: flood_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flood_fid_seq OWNED BY public.flood.fid;


--
-- TOC entry 262 (class 1259 OID 16932)
-- Name: history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history (
    uid integer DEFAULT 0 NOT NULL,
    nid bigint DEFAULT 0 NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    CONSTRAINT history_nid_check CHECK ((nid >= 0))
);


--
-- TOC entry 4268 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.history IS 'A record of which users have read which nodes.';


--
-- TOC entry 4269 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN history.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.history.uid IS 'The users.uid that read the node nid.';


--
-- TOC entry 4270 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN history.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.history.nid IS 'The node.nid that was read.';


--
-- TOC entry 4271 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN history."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.history."timestamp" IS 'The Unix timestamp at which the read occurred.';


--
-- TOC entry 236 (class 1259 OID 16615)
-- Name: menu_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_links (
    menu_name character varying(32) DEFAULT ''::character varying NOT NULL,
    mlid integer NOT NULL,
    plid bigint DEFAULT 0 NOT NULL,
    link_path character varying(255) DEFAULT ''::character varying NOT NULL,
    router_path character varying(255) DEFAULT ''::character varying NOT NULL,
    link_title character varying(255) DEFAULT ''::character varying NOT NULL,
    options bytea,
    module character varying(255) DEFAULT 'system'::character varying NOT NULL,
    hidden smallint DEFAULT 0 NOT NULL,
    external smallint DEFAULT 0 NOT NULL,
    has_children smallint DEFAULT 0 NOT NULL,
    expanded smallint DEFAULT 0 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    depth smallint DEFAULT 0 NOT NULL,
    customized smallint DEFAULT 0 NOT NULL,
    p1 bigint DEFAULT 0 NOT NULL,
    p2 bigint DEFAULT 0 NOT NULL,
    p3 bigint DEFAULT 0 NOT NULL,
    p4 bigint DEFAULT 0 NOT NULL,
    p5 bigint DEFAULT 0 NOT NULL,
    p6 bigint DEFAULT 0 NOT NULL,
    p7 bigint DEFAULT 0 NOT NULL,
    p8 bigint DEFAULT 0 NOT NULL,
    p9 bigint DEFAULT 0 NOT NULL,
    updated smallint DEFAULT 0 NOT NULL,
    CONSTRAINT menu_links_mlid_check CHECK ((mlid >= 0)),
    CONSTRAINT menu_links_p1_check CHECK ((p1 >= 0)),
    CONSTRAINT menu_links_p2_check CHECK ((p2 >= 0)),
    CONSTRAINT menu_links_p3_check CHECK ((p3 >= 0)),
    CONSTRAINT menu_links_p4_check CHECK ((p4 >= 0)),
    CONSTRAINT menu_links_p5_check CHECK ((p5 >= 0)),
    CONSTRAINT menu_links_p6_check CHECK ((p6 >= 0)),
    CONSTRAINT menu_links_p7_check CHECK ((p7 >= 0)),
    CONSTRAINT menu_links_p8_check CHECK ((p8 >= 0)),
    CONSTRAINT menu_links_p9_check CHECK ((p9 >= 0)),
    CONSTRAINT menu_links_plid_check CHECK ((plid >= 0))
);


--
-- TOC entry 4272 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE menu_links; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.menu_links IS 'Contains the individual links within a menu.';


--
-- TOC entry 4273 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.menu_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.menu_name IS 'The menu name. All links with the same menu name (such as ''navigation'') are part of the same menu.';


--
-- TOC entry 4274 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.mlid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.mlid IS 'The menu link ID (mlid) is the integer primary key.';


--
-- TOC entry 4275 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.plid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.plid IS 'The parent link ID (plid) is the mlid of the link above in the hierarchy, or zero if the link is at the top level in its menu.';


--
-- TOC entry 4276 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.link_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.link_path IS 'The Drupal path or external path this link points to.';


--
-- TOC entry 4277 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.router_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.router_path IS 'For links corresponding to a Drupal path (external = 0), this connects the link to a menu_router.path for joins.';


--
-- TOC entry 4278 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.link_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.link_title IS 'The text displayed for the link, which may be modified by a title callback stored in menu_router.';


--
-- TOC entry 4279 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.options IS 'A serialized array of options to be passed to the url() or l() function, such as a query string or HTML attributes.';


--
-- TOC entry 4280 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.module IS 'The name of the module that generated this link.';


--
-- TOC entry 4281 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.hidden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.hidden IS 'A flag for whether the link should be rendered in menus. (1 = a disabled menu item that may be shown on admin screens, -1 = a menu callback, 0 = a normal, visible link)';


--
-- TOC entry 4282 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.external; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.external IS 'A flag to indicate if the link points to a full URL starting with a protocol,::text like http:// (1 = external, 0 = internal).';


--
-- TOC entry 4283 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.has_children; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.has_children IS 'Flag indicating whether any links have this link as a parent (1 = children exist, 0 = no children).';


--
-- TOC entry 4284 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.expanded; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.expanded IS 'Flag for whether this link should be rendered as expanded in menus - expanded links always have their child links displayed, instead of only when the link is in the active trail (1 = expanded, 0 = not expanded)';


--
-- TOC entry 4285 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.weight IS 'Link weight among links in the same menu at the same depth.';


--
-- TOC entry 4286 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.depth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.depth IS 'The depth relative to the top level. A link with plid == 0 will have depth == 1.';


--
-- TOC entry 4287 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.customized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.customized IS 'A flag to indicate that the user has manually created or edited the link (1 = customized, 0 = not customized).';


--
-- TOC entry 4288 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p1 IS 'The first mlid in the materialized path. If N = depth, then pN must equal the mlid. If depth > 1 then p(N-1) must equal the plid. All pX where X > depth must equal zero. The columns p1 .. p9 are also called the parents.';


--
-- TOC entry 4289 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p2 IS 'The second mlid in the materialized path. See p1.';


--
-- TOC entry 4290 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p3; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p3 IS 'The third mlid in the materialized path. See p1.';


--
-- TOC entry 4291 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p4; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p4 IS 'The fourth mlid in the materialized path. See p1.';


--
-- TOC entry 4292 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p5; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p5 IS 'The fifth mlid in the materialized path. See p1.';


--
-- TOC entry 4293 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p6; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p6 IS 'The sixth mlid in the materialized path. See p1.';


--
-- TOC entry 4294 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p7; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p7 IS 'The seventh mlid in the materialized path. See p1.';


--
-- TOC entry 4295 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p8; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p8 IS 'The eighth mlid in the materialized path. See p1.';


--
-- TOC entry 4296 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.p9; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.p9 IS 'The ninth mlid in the materialized path. See p1.';


--
-- TOC entry 4297 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN menu_links.updated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_links.updated IS 'Flag that indicates that this link was generated during the update from Drupal 5.';


--
-- TOC entry 235 (class 1259 OID 16614)
-- Name: menu_links_mlid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_links_mlid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4298 (class 0 OID 0)
-- Dependencies: 235
-- Name: menu_links_mlid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_links_mlid_seq OWNED BY public.menu_links.mlid;


--
-- TOC entry 234 (class 1259 OID 16587)
-- Name: menu_router; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_router (
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    load_functions bytea NOT NULL,
    to_arg_functions bytea NOT NULL,
    access_callback character varying(255) DEFAULT ''::character varying NOT NULL,
    access_arguments bytea,
    page_callback character varying(255) DEFAULT ''::character varying NOT NULL,
    page_arguments bytea,
    delivery_callback character varying(255) DEFAULT ''::character varying NOT NULL,
    fit integer DEFAULT 0 NOT NULL,
    number_parts smallint DEFAULT 0 NOT NULL,
    context integer DEFAULT 0 NOT NULL,
    tab_parent character varying(255) DEFAULT ''::character varying NOT NULL,
    tab_root character varying(255) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    title_callback character varying(255) DEFAULT ''::character varying NOT NULL,
    title_arguments character varying(255) DEFAULT ''::character varying NOT NULL,
    theme_callback character varying(255) DEFAULT ''::character varying NOT NULL,
    theme_arguments character varying(255) DEFAULT ''::character varying NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    description text NOT NULL,
    "position" character varying(255) DEFAULT ''::character varying NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    include_file text
);


--
-- TOC entry 4299 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE menu_router; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.menu_router IS 'Maps paths to various callbacks (access, page and title)';


--
-- TOC entry 4300 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.path IS 'Primary Key: the Drupal path this entry describes';


--
-- TOC entry 4301 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.load_functions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.load_functions IS 'A serialized array of function names (like node_load) to be called to load an object corresponding to a part of the current path.';


--
-- TOC entry 4302 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.to_arg_functions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.to_arg_functions IS 'A serialized array of function names (like user_uid_optional_to_arg) to be called to replace a part of the router path with another string.';


--
-- TOC entry 4303 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.access_callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.access_callback IS 'The callback which determines the access to this router path. Defaults to user_access.';


--
-- TOC entry 4304 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.access_arguments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.access_arguments IS 'A serialized array of arguments for the access callback.';


--
-- TOC entry 4305 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.page_callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.page_callback IS 'The name of the function that renders the page.';


--
-- TOC entry 4306 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.page_arguments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.page_arguments IS 'A serialized array of arguments for the page callback.';


--
-- TOC entry 4307 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.delivery_callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.delivery_callback IS 'The name of the function that sends the result of the page_callback function to the browser.';


--
-- TOC entry 4308 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.fit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.fit IS 'A numeric representation of how specific the path is.';


--
-- TOC entry 4309 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.number_parts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.number_parts IS 'Number of parts in this router path.';


--
-- TOC entry 4310 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.context IS 'Only for local tasks (tabs) - the context of a local task to control its placement.';


--
-- TOC entry 4311 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.tab_parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.tab_parent IS 'Only for local tasks (tabs) - the router path of the parent page (which may also be a local task).';


--
-- TOC entry 4312 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.tab_root; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.tab_root IS 'Router path of the closest non-tab parent page. For pages that are not local tasks, this will be the same as the path.';


--
-- TOC entry 4313 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.title IS 'The title for the current page, or the title for the tab if this is a local task.';


--
-- TOC entry 4314 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.title_callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.title_callback IS 'A function which will alter the title. Defaults to t()';


--
-- TOC entry 4315 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.title_arguments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.title_arguments IS 'A serialized array of arguments for the title callback. If empty, the title will be used as the sole argument for the title callback.';


--
-- TOC entry 4316 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.theme_callback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.theme_callback IS 'A function which returns the name of the theme that will be used to render this page. If left empty, the default theme will be used.';


--
-- TOC entry 4317 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.theme_arguments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.theme_arguments IS 'A serialized array of arguments for the theme callback.';


--
-- TOC entry 4318 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.type IS 'Numeric representation of the type of the menu item,::text like MENU_LOCAL_TASK.';


--
-- TOC entry 4319 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.description IS 'A description of this item.';


--
-- TOC entry 4320 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router."position" IS 'The position of the block (left or right) on the system administration page for this item.';


--
-- TOC entry 4321 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.weight IS 'Weight of the element. Lighter weights are higher up, heavier weights go down.';


--
-- TOC entry 4322 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN menu_router.include_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_router.include_file IS 'The file to include for this element, usually the page callback function lives in this file.';


--
-- TOC entry 256 (class 1259 OID 16841)
-- Name: node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.node (
    nid integer NOT NULL,
    vid bigint,
    type character varying(32) DEFAULT ''::character varying NOT NULL,
    language character varying(12) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    changed integer DEFAULT 0 NOT NULL,
    comment integer DEFAULT 0 NOT NULL,
    promote integer DEFAULT 0 NOT NULL,
    sticky integer DEFAULT 0 NOT NULL,
    tnid bigint DEFAULT 0 NOT NULL,
    translate integer DEFAULT 0 NOT NULL,
    CONSTRAINT node_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_tnid_check CHECK ((tnid >= 0)),
    CONSTRAINT node_vid_check CHECK ((vid >= 0))
);


--
-- TOC entry 4323 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE node; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.node IS 'The base table for nodes.';


--
-- TOC entry 4324 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.nid IS 'The primary identifier for a node.';


--
-- TOC entry 4325 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.vid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.vid IS 'The current node_revision.vid version identifier.';


--
-- TOC entry 4326 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.type IS 'The node_type.type of this node.';


--
-- TOC entry 4327 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.language; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.language IS 'The languages.language of this node.';


--
-- TOC entry 4328 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.title IS 'The title of this node, always treated as non-markup plain text.';


--
-- TOC entry 4329 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.uid IS 'The users.uid that owns this node; initially, this is the user that created it.';


--
-- TOC entry 4330 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.status IS 'Boolean indicating whether the node is published (visible to non-administrators).';


--
-- TOC entry 4331 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.created IS 'The Unix timestamp when the node was created.';


--
-- TOC entry 4332 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.changed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.changed IS 'The Unix timestamp when the node was most recently saved.';


--
-- TOC entry 4333 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.comment IS 'Whether comments are allowed on this node: 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- TOC entry 4334 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.promote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.promote IS 'Boolean indicating whether the node should be displayed on the front page.';


--
-- TOC entry 4335 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.sticky; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.sticky IS 'Boolean indicating whether the node should be displayed at the top of lists in which it appears.';


--
-- TOC entry 4336 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.tnid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.tnid IS 'The translation set id for this node, which equals the node id of the source post in each set.';


--
-- TOC entry 4337 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN node.translate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node.translate IS 'A boolean indicating whether this translation page needs to be updated.';


--
-- TOC entry 257 (class 1259 OID 16874)
-- Name: node_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.node_access (
    nid bigint DEFAULT 0 NOT NULL,
    gid bigint DEFAULT 0 NOT NULL,
    realm character varying(255) DEFAULT ''::character varying NOT NULL,
    grant_view integer DEFAULT 0 NOT NULL,
    grant_update integer DEFAULT 0 NOT NULL,
    grant_delete integer DEFAULT 0 NOT NULL,
    CONSTRAINT node_access_gid_check CHECK ((gid >= 0)),
    CONSTRAINT node_access_grant_delete_check CHECK ((grant_delete >= 0)),
    CONSTRAINT node_access_grant_update_check CHECK ((grant_update >= 0)),
    CONSTRAINT node_access_grant_view_check CHECK ((grant_view >= 0)),
    CONSTRAINT node_access_nid_check CHECK ((nid >= 0))
);


--
-- TOC entry 4338 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE node_access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.node_access IS 'Identifies which realm/grant pairs a user must possess in order to view, update, or delete specific nodes.';


--
-- TOC entry 4339 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.nid IS 'The node.nid this record affects.';


--
-- TOC entry 4340 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.gid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.gid IS 'The grant ID a user must possess in the specified realm to gain this row''s privileges on the node.';


--
-- TOC entry 4341 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.realm; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.realm IS 'The realm in which the user must possess the grant ID. Each node access node can define one or more realms.';


--
-- TOC entry 4342 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.grant_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.grant_view IS 'Boolean indicating whether a user with the realm/grant pair can view this node.';


--
-- TOC entry 4343 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.grant_update; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.grant_update IS 'Boolean indicating whether a user with the realm/grant pair can edit this node.';


--
-- TOC entry 4344 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN node_access.grant_delete; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_access.grant_delete IS 'Boolean indicating whether a user with the realm/grant pair can delete this node.';


--
-- TOC entry 255 (class 1259 OID 16840)
-- Name: node_nid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.node_nid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4345 (class 0 OID 0)
-- Dependencies: 255
-- Name: node_nid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.node_nid_seq OWNED BY public.node.nid;


--
-- TOC entry 259 (class 1259 OID 16891)
-- Name: node_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.node_revision (
    nid bigint DEFAULT 0 NOT NULL,
    vid integer NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    log text NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    comment integer DEFAULT 0 NOT NULL,
    promote integer DEFAULT 0 NOT NULL,
    sticky integer DEFAULT 0 NOT NULL,
    CONSTRAINT node_revision_nid_check CHECK ((nid >= 0)),
    CONSTRAINT node_revision_vid_check CHECK ((vid >= 0))
);


--
-- TOC entry 4346 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE node_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.node_revision IS 'Stores information about each saved version of a node.';


--
-- TOC entry 4347 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.nid IS 'The node this version belongs to.';


--
-- TOC entry 4348 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.vid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.vid IS 'The primary identifier for this version.';


--
-- TOC entry 4349 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.uid IS 'The users.uid that created this version.';


--
-- TOC entry 4350 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.title IS 'The title of this version.';


--
-- TOC entry 4351 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.log IS 'The log entry explaining the changes in this version.';


--
-- TOC entry 4352 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision."timestamp" IS 'A Unix timestamp indicating when this version was created.';


--
-- TOC entry 4353 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.status IS 'Boolean indicating whether the node (at the time of this revision) is published (visible to non-administrators).';


--
-- TOC entry 4354 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.comment IS 'Whether comments are allowed on this node (at the time of this revision): 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- TOC entry 4355 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.promote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.promote IS 'Boolean indicating whether the node (at the time of this revision) should be displayed on the front page.';


--
-- TOC entry 4356 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN node_revision.sticky; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_revision.sticky IS 'Boolean indicating whether the node (at the time of this revision) should be displayed at the top of lists in which it appears.';


--
-- TOC entry 258 (class 1259 OID 16890)
-- Name: node_revision_vid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.node_revision_vid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4357 (class 0 OID 0)
-- Dependencies: 258
-- Name: node_revision_vid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.node_revision_vid_seq OWNED BY public.node_revision.vid;


--
-- TOC entry 260 (class 1259 OID 16911)
-- Name: node_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.node_type (
    type character varying(32) NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    base character varying(255) NOT NULL,
    module character varying(255) NOT NULL,
    description text NOT NULL,
    help text NOT NULL,
    has_title integer NOT NULL,
    title_label character varying(255) DEFAULT ''::character varying NOT NULL,
    custom smallint DEFAULT 0 NOT NULL,
    modified smallint DEFAULT 0 NOT NULL,
    locked smallint DEFAULT 0 NOT NULL,
    disabled smallint DEFAULT 0 NOT NULL,
    orig_type character varying(255) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT node_type_has_title_check CHECK ((has_title >= 0))
);


--
-- TOC entry 4358 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE node_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.node_type IS 'Stores information about all defined node types.';


--
-- TOC entry 4359 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.type IS 'The machine-readable name of this type.';


--
-- TOC entry 4360 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.name IS 'The human-readable name of this type.';


--
-- TOC entry 4361 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.base; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.base IS 'The base string used to construct callbacks corresponding to this node type.';


--
-- TOC entry 4362 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.module IS 'The module defining this node type.';


--
-- TOC entry 4363 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.description IS 'A brief description of this type.';


--
-- TOC entry 4364 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.help; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.help IS 'Help information shown to the user when creating a node of this type.';


--
-- TOC entry 4365 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.has_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.has_title IS 'Boolean indicating whether this type uses the node.title field.';


--
-- TOC entry 4366 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.title_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.title_label IS 'The label displayed for the title field on the edit form.';


--
-- TOC entry 4367 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.custom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.custom IS 'A boolean indicating whether this type is defined by a module (FALSE) or by a user via Add content type (TRUE).';


--
-- TOC entry 4368 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.modified; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.modified IS 'A boolean indicating whether this type has been modified by an administrator; currently not used in any way.';


--
-- TOC entry 4369 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.locked IS 'A boolean indicating whether the administrator can change the machine name of this type.';


--
-- TOC entry 4370 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.disabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.disabled IS 'A boolean indicating whether the node type is disabled.';


--
-- TOC entry 4371 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN node_type.orig_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.node_type.orig_type IS 'The original machine-readable name of this node type. This may be different from the current type name if the locked field is 0.';


--
-- TOC entry 238 (class 1259 OID 16662)
-- Name: queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.queue (
    item_id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    CONSTRAINT queue_item_id_check CHECK ((item_id >= 0))
);


--
-- TOC entry 4372 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.queue IS 'Stores items in queues.';


--
-- TOC entry 4373 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN queue.item_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.queue.item_id IS 'Primary Key: Unique item ID.';


--
-- TOC entry 4374 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN queue.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.queue.name IS 'The queue name.';


--
-- TOC entry 4375 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN queue.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.queue.data IS 'The arbitrary data for the item.';


--
-- TOC entry 4376 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN queue.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.queue.expire IS 'Timestamp when the claim lease expires on the item.';


--
-- TOC entry 4377 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN queue.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.queue.created IS 'Timestamp when the item was created.';


--
-- TOC entry 237 (class 1259 OID 16661)
-- Name: queue_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.queue_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4378 (class 0 OID 0)
-- Dependencies: 237
-- Name: queue_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.queue_item_id_seq OWNED BY public.queue.item_id;


--
-- TOC entry 239 (class 1259 OID 16676)
-- Name: registry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registry (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    type character varying(9) DEFAULT ''::character varying NOT NULL,
    filename character varying(255) NOT NULL,
    module character varying(255) DEFAULT ''::character varying NOT NULL,
    weight integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 4379 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE registry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.registry IS 'Each record is a function, class, or interface name and the file it is in.';


--
-- TOC entry 4380 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN registry.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry.name IS 'The name of the function, class, or interface.';


--
-- TOC entry 4381 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN registry.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry.type IS 'Either function or class or interface.';


--
-- TOC entry 4382 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN registry.filename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry.filename IS 'Name of the file.';


--
-- TOC entry 4383 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN registry.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry.module IS 'Name of the module the file belongs to.';


--
-- TOC entry 4384 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN registry.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry.weight IS 'The order in which this module''s hooks should be invoked relative to other modules. Equal-weighted modules are ordered by name.';


--
-- TOC entry 240 (class 1259 OID 16688)
-- Name: registry_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registry_file (
    filename character varying(255) NOT NULL,
    hash character varying(64) NOT NULL
);


--
-- TOC entry 4385 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE registry_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.registry_file IS 'Files parsed to build the registry.';


--
-- TOC entry 4386 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN registry_file.filename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry_file.filename IS 'Path to the file.';


--
-- TOC entry 4387 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN registry_file.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registry_file.hash IS 'sha-256 hash of the file''s contents when last parsed.';


--
-- TOC entry 252 (class 1259 OID 16783)
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    rid integer NOT NULL,
    name character varying(64) DEFAULT ''::character varying NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    CONSTRAINT role_rid_check CHECK ((rid >= 0))
);


--
-- TOC entry 4388 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.role IS 'Stores user roles.';


--
-- TOC entry 4389 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN role.rid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role.rid IS 'Primary Key: Unique role ID.';


--
-- TOC entry 4390 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN role.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role.name IS 'Unique role name.';


--
-- TOC entry 4391 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN role.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role.weight IS 'The weight of this role in listings and the user interface.';


--
-- TOC entry 250 (class 1259 OID 16773)
-- Name: role_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permission (
    rid bigint NOT NULL,
    permission character varying(128) DEFAULT ''::character varying NOT NULL,
    module character varying(255) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT role_permission_rid_check CHECK ((rid >= 0))
);


--
-- TOC entry 4392 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE role_permission; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.role_permission IS 'Stores the permissions assigned to user roles.';


--
-- TOC entry 4393 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN role_permission.rid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role_permission.rid IS 'Foreign Key: role.rid.';


--
-- TOC entry 4394 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN role_permission.permission; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role_permission.permission IS 'A single permission granted to the role identified by rid.';


--
-- TOC entry 4395 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN role_permission.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.role_permission.module IS 'The module declaring the permission.';


--
-- TOC entry 251 (class 1259 OID 16782)
-- Name: role_rid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_rid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4396 (class 0 OID 0)
-- Dependencies: 251
-- Name: role_rid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_rid_seq OWNED BY public.role.rid;


--
-- TOC entry 241 (class 1259 OID 16693)
-- Name: semaphore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.semaphore (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value character varying(255) DEFAULT ''::character varying NOT NULL,
    expire double precision NOT NULL
);


--
-- TOC entry 4397 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE semaphore; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.semaphore IS 'Table for holding semaphores, locks, flags, etc. that cannot be stored as Drupal variables since they must not be cached.';


--
-- TOC entry 4398 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN semaphore.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.semaphore.name IS 'Primary Key: Unique name.';


--
-- TOC entry 4399 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN semaphore.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.semaphore.value IS 'A value for the semaphore.';


--
-- TOC entry 4400 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN semaphore.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.semaphore.expire IS 'A Unix timestamp with microseconds indicating when the semaphore should expire.';


--
-- TOC entry 243 (class 1259 OID 16705)
-- Name: sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequences (
    value integer NOT NULL,
    CONSTRAINT sequences_value_check CHECK ((value >= 0))
);


--
-- TOC entry 4401 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE sequences; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sequences IS 'Stores IDs.';


--
-- TOC entry 4402 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN sequences.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sequences.value IS 'The value of the sequence.';


--
-- TOC entry 242 (class 1259 OID 16704)
-- Name: sequences_value_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequences_value_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4403 (class 0 OID 0)
-- Dependencies: 242
-- Name: sequences_value_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sequences_value_seq OWNED BY public.sequences.value;


--
-- TOC entry 244 (class 1259 OID 16712)
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    uid bigint NOT NULL,
    sid character varying(128) NOT NULL,
    ssid character varying(128) DEFAULT ''::character varying NOT NULL,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    cache integer DEFAULT 0 NOT NULL,
    session bytea,
    CONSTRAINT sessions_uid_check CHECK ((uid >= 0))
);


--
-- TOC entry 4404 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sessions IS 'Drupal''s session handlers read and write into the sessions table. Each record represents a user session, either anonymous or authenticated.';


--
-- TOC entry 4405 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.uid IS 'The users.uid corresponding to a session, or 0 for anonymous user.';


--
-- TOC entry 4406 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.sid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.sid IS 'A session ID. The value is generated by Drupal''s session handlers.';


--
-- TOC entry 4407 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.ssid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.ssid IS 'Secure session ID. The value is generated by Drupal''s session handlers.';


--
-- TOC entry 4408 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.hostname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.hostname IS 'The IP address that last used this session ID (sid).';


--
-- TOC entry 4409 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions."timestamp" IS 'The Unix timestamp when this session last requested a page. Old records are purged by PHP automatically.';


--
-- TOC entry 4410 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.cache IS 'The time of this user''s last post. This is used when the site has specified a minimum_cache_lifetime. See cache_get().';


--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN sessions.session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sessions.session IS 'The serialized contents of $_SESSION, an array of name/value pairs that persists across page requests by this session ID. Drupal loads $_SESSION from here at the start of each request and saves it at the end.';


--
-- TOC entry 245 (class 1259 OID 16727)
-- Name: system; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system (
    filename character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    type character varying(12) DEFAULT ''::character varying NOT NULL,
    owner character varying(255) DEFAULT ''::character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    bootstrap integer DEFAULT 0 NOT NULL,
    schema_version smallint DEFAULT '-1'::integer NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    info bytea
);


--
-- TOC entry 4412 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE system; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system IS 'A list of all modules, themes, and theme engines that are or have been installed in Drupal''s file system.';


--
-- TOC entry 4413 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.filename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.filename IS 'The path of the primary file for this item, relative to the Drupal root; e.g. modules/node/node.module.';


--
-- TOC entry 4414 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.name IS 'The name of the item; e.g. node.';


--
-- TOC entry 4415 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.type IS 'The type of the item, either module, theme, or theme_engine.';


--
-- TOC entry 4416 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.owner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.owner IS 'A theme''s ''parent'' . Can be either a theme or an engine.';


--
-- TOC entry 4417 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.status IS 'Boolean indicating whether or not this item is enabled.';


--
-- TOC entry 4418 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.bootstrap; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.bootstrap IS 'Boolean indicating whether this module is loaded during Drupal''s early bootstrapping phase (e.g. even before the page cache is consulted).';


--
-- TOC entry 4419 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.schema_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.schema_version IS 'The module''s database schema version number. -1 if the module is not installed (its tables do not exist); 0 or the largest N of the module''s hook_update_N() function that has either been run or existed when the module was first installed.';


--
-- TOC entry 4420 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.weight IS 'The order in which this module''s hooks should be invoked relative to other modules. Equal-weighted modules are ordered by name.';


--
-- TOC entry 4421 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN system.info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system.info IS 'A serialized array containing information from the module''s .info file; keys can include name, description, package, version, core, dependencies, and php.';


--
-- TOC entry 247 (class 1259 OID 16745)
-- Name: url_alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.url_alias (
    pid integer NOT NULL,
    source character varying(255) DEFAULT ''::character varying NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL,
    language character varying(12) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT url_alias_pid_check CHECK ((pid >= 0))
);


--
-- TOC entry 4422 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE url_alias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.url_alias IS 'A list of URL aliases for Drupal paths; a user may visit either the source or destination path.';


--
-- TOC entry 4423 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN url_alias.pid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.url_alias.pid IS 'A unique path alias identifier.';


--
-- TOC entry 4424 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN url_alias.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.url_alias.source IS 'The Drupal path this alias is for; e.g. node/12.';


--
-- TOC entry 4425 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN url_alias.alias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.url_alias.alias IS 'The alias for this path; e.g. title-of-the-story.';


--
-- TOC entry 4426 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN url_alias.language; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.url_alias.language IS 'The language this alias is for; if ''und'', the alias will be used for unknown languages. Each Drupal path can have an alias for each supported language.';


--
-- TOC entry 246 (class 1259 OID 16744)
-- Name: url_alias_pid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.url_alias_pid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4427 (class 0 OID 0)
-- Dependencies: 246
-- Name: url_alias_pid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.url_alias_pid_seq OWNED BY public.url_alias.pid;


--
-- TOC entry 253 (class 1259 OID 16795)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    uid bigint DEFAULT 0 NOT NULL,
    name character varying(60) DEFAULT ''::character varying NOT NULL,
    pass character varying(128) DEFAULT ''::character varying NOT NULL,
    mail character varying(254) DEFAULT ''::character varying,
    theme character varying(255) DEFAULT ''::character varying NOT NULL,
    signature character varying(255) DEFAULT ''::character varying NOT NULL,
    signature_format character varying(255),
    created integer DEFAULT 0 NOT NULL,
    changed integer DEFAULT 0 NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    login integer DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    timezone character varying(32),
    language character varying(12) DEFAULT ''::character varying NOT NULL,
    picture integer DEFAULT 0 NOT NULL,
    init character varying(254) DEFAULT ''::character varying,
    data bytea,
    CONSTRAINT users_uid_check CHECK ((uid >= 0))
);


--
-- TOC entry 4428 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users IS 'Stores user data.';


--
-- TOC entry 4429 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.uid IS 'Primary Key: Unique user ID.';


--
-- TOC entry 4430 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.name IS 'Unique user name.';


--
-- TOC entry 4431 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.pass; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.pass IS 'User''s password (hashed).';


--
-- TOC entry 4432 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.mail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.mail IS 'User''s e-mail address.';


--
-- TOC entry 4433 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.theme; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.theme IS 'User''s default theme.';


--
-- TOC entry 4434 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.signature; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.signature IS 'User''s signature.';


--
-- TOC entry 4435 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.signature_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.signature_format IS 'The filter_format.format of the signature.';


--
-- TOC entry 4436 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.created IS 'Timestamp for when user was created.';


--
-- TOC entry 4437 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.changed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.changed IS 'Timestamp for when user was changed.';


--
-- TOC entry 4438 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.access IS 'Timestamp for previous time user accessed the site.';


--
-- TOC entry 4439 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.login IS 'Timestamp for user''s last login.';


--
-- TOC entry 4440 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.status IS 'Whether the user is active(1) or blocked(0).';


--
-- TOC entry 4441 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.timezone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.timezone IS 'User''s time zone.';


--
-- TOC entry 4442 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.language; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.language IS 'User''s default language.';


--
-- TOC entry 4443 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.picture; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.picture IS 'Foreign key: file_managed.fid of user''s picture.';


--
-- TOC entry 4444 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.init; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.init IS 'E-mail address used for initial account creation.';


--
-- TOC entry 4445 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN users.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.data IS 'A serialized array of name value pairs that are related to the user. Any form values posted during user edit are stored and are loaded into the $user object during user_load(). Use of this field is discouraged and it will likely disappear in a future version of Drupal.';


--
-- TOC entry 254 (class 1259 OID 16824)
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_roles (
    uid bigint DEFAULT 0 NOT NULL,
    rid bigint DEFAULT 0 NOT NULL,
    CONSTRAINT users_roles_rid_check CHECK ((rid >= 0)),
    CONSTRAINT users_roles_uid_check CHECK ((uid >= 0))
);


--
-- TOC entry 4446 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE users_roles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users_roles IS 'Maps users to roles.';


--
-- TOC entry 4447 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN users_roles.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_roles.uid IS 'Primary Key: users.uid for user.';


--
-- TOC entry 4448 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN users_roles.rid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_roles.rid IS 'Primary Key: role.rid for role.';


--
-- TOC entry 214 (class 1259 OID 16401)
-- Name: variable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variable (
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea NOT NULL
);


--
-- TOC entry 4449 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE variable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.variable IS 'Named variable/value pairs created by Drupal core or any other module or theme. All variables are cached in memory at the start of every Drupal request so developers should not be careless about what is stored here.';


--
-- TOC entry 4450 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN variable.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.variable.name IS 'The name of the variable.';


--
-- TOC entry 4451 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN variable.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.variable.value IS 'The value of the variable.';


--
-- TOC entry 278 (class 1259 OID 17088)
-- Name: watchdog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.watchdog (
    wid integer NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    variables bytea NOT NULL,
    severity integer DEFAULT 0 NOT NULL,
    link character varying(255) DEFAULT ''::character varying,
    location text NOT NULL,
    referer text,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    CONSTRAINT watchdog_severity_check CHECK ((severity >= 0))
);


--
-- TOC entry 4452 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE watchdog; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.watchdog IS 'Table that contains logs of all system events.';


--
-- TOC entry 4453 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.wid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.wid IS 'Primary Key: Unique watchdog event ID.';


--
-- TOC entry 4454 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.uid IS 'The users.uid of the user who triggered the event.';


--
-- TOC entry 4455 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.type IS 'Type of log message, for example "user" or "page not found."';


--
-- TOC entry 4456 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.message IS 'Text of log message to be passed into the t() function.';


--
-- TOC entry 4457 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.variables; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.variables IS 'Serialized array of variables that match the message string and that is passed into the t() function.';


--
-- TOC entry 4458 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.severity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.severity IS 'The severity level of the event; ranges from 0 (Emergency) to 7 (Debug)';


--
-- TOC entry 4459 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.link; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.link IS 'Link to view the result of the event.';


--
-- TOC entry 4460 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.location IS 'URL of the origin of the event.';


--
-- TOC entry 4461 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.referer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.referer IS 'URL of referring page.';


--
-- TOC entry 4462 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog.hostname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog.hostname IS 'Hostname of the user who triggered the event.';


--
-- TOC entry 4463 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN watchdog."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watchdog."timestamp" IS 'Unix timestamp of when event occurred.';


--
-- TOC entry 277 (class 1259 OID 17087)
-- Name: watchdog_wid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.watchdog_wid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4464 (class 0 OID 0)
-- Dependencies: 277
-- Name: watchdog_wid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.watchdog_wid_seq OWNED BY public.watchdog.wid;


--
-- TOC entry 3530 (class 2604 OID 16763)
-- Name: authmap aid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authmap ALTER COLUMN aid SET DEFAULT nextval('public.authmap_aid_seq'::regclass);


--
-- TOC entry 3623 (class 2604 OID 17037)
-- Name: block bid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block ALTER COLUMN bid SET DEFAULT nextval('public.block_bid_seq'::regclass);


--
-- TOC entry 3634 (class 2604 OID 17066)
-- Name: block_custom bid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block_custom ALTER COLUMN bid SET DEFAULT nextval('public.block_custom_bid_seq'::regclass);


--
-- TOC entry 3416 (class 2604 OID 16433)
-- Name: blocked_ips iid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips ALTER COLUMN iid SET DEFAULT nextval('public.blocked_ips_iid_seq'::regclass);


--
-- TOC entry 3443 (class 2604 OID 16522)
-- Name: date_formats dfid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_formats ALTER COLUMN dfid SET DEFAULT nextval('public.date_formats_dfid_seq'::regclass);


--
-- TOC entry 3605 (class 2604 OID 16985)
-- Name: field_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_config ALTER COLUMN id SET DEFAULT nextval('public.field_config_id_seq'::regclass);


--
-- TOC entry 3614 (class 2604 OID 17010)
-- Name: field_config_instance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_config_instance ALTER COLUMN id SET DEFAULT nextval('public.field_config_instance_id_seq'::regclass);


--
-- TOC entry 3445 (class 2604 OID 16538)
-- Name: file_managed fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_managed ALTER COLUMN fid SET DEFAULT nextval('public.file_managed_fid_seq'::regclass);


--
-- TOC entry 3457 (class 2604 OID 16578)
-- Name: flood fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flood ALTER COLUMN fid SET DEFAULT nextval('public.flood_fid_seq'::regclass);


--
-- TOC entry 3480 (class 2604 OID 16619)
-- Name: menu_links mlid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_links ALTER COLUMN mlid SET DEFAULT nextval('public.menu_links_mlid_seq'::regclass);


--
-- TOC entry 3555 (class 2604 OID 16844)
-- Name: node nid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node ALTER COLUMN nid SET DEFAULT nextval('public.node_nid_seq'::regclass);


--
-- TOC entry 3575 (class 2604 OID 16895)
-- Name: node_revision vid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node_revision ALTER COLUMN vid SET DEFAULT nextval('public.node_revision_vid_seq'::regclass);


--
-- TOC entry 3503 (class 2604 OID 16665)
-- Name: queue item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queue ALTER COLUMN item_id SET DEFAULT nextval('public.queue_item_id_seq'::regclass);


--
-- TOC entry 3536 (class 2604 OID 16786)
-- Name: role rid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role ALTER COLUMN rid SET DEFAULT nextval('public.role_rid_seq'::regclass);


--
-- TOC entry 3513 (class 2604 OID 16708)
-- Name: sequences value; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences ALTER COLUMN value SET DEFAULT nextval('public.sequences_value_seq'::regclass);


--
-- TOC entry 3526 (class 2604 OID 16748)
-- Name: url_alias pid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_alias ALTER COLUMN pid SET DEFAULT nextval('public.url_alias_pid_seq'::regclass);


--
-- TOC entry 3640 (class 2604 OID 17091)
-- Name: watchdog wid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchdog ALTER COLUMN wid SET DEFAULT nextval('public.watchdog_wid_seq'::regclass);


--
-- TOC entry 4030 (class 0 OID 16409)
-- Dependencies: 215
-- Data for Name: actions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.actions VALUES ('node_publish_action', 'node', 'node_publish_action', '\x', 'Publish content');
INSERT INTO public.actions VALUES ('node_unpublish_action', 'node', 'node_unpublish_action', '\x', 'Unpublish content');
INSERT INTO public.actions VALUES ('node_make_sticky_action', 'node', 'node_make_sticky_action', '\x', 'Make content sticky');
INSERT INTO public.actions VALUES ('node_make_unsticky_action', 'node', 'node_make_unsticky_action', '\x', 'Make content unsticky');
INSERT INTO public.actions VALUES ('node_promote_action', 'node', 'node_promote_action', '\x', 'Promote content to front page');
INSERT INTO public.actions VALUES ('node_unpromote_action', 'node', 'node_unpromote_action', '\x', 'Remove content from front page');
INSERT INTO public.actions VALUES ('node_save_action', 'node', 'node_save_action', '\x', 'Save content');
INSERT INTO public.actions VALUES ('system_block_ip_action', 'user', 'system_block_ip_action', '\x', 'Ban IP address of current user');
INSERT INTO public.actions VALUES ('user_block_user_action', 'user', 'user_block_user_action', '\x', 'Block current user');
INSERT INTO public.actions VALUES ('user_unblock_user_action', 'user', 'user_unblock_user_action', '\x', 'Unblock current user');


--
-- TOC entry 4064 (class 0 OID 16760)
-- Dependencies: 249
-- Data for Name: authmap; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4031 (class 0 OID 16420)
-- Dependencies: 216
-- Data for Name: batch; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4087 (class 0 OID 17034)
-- Dependencies: 272
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.block VALUES (1, 'system', 'main', 'bartik', 1, 0, 'content', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (2, 'user', 'login', 'bartik', 1, 0, 'sidebar_first', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (3, 'system', 'navigation', 'bartik', 1, 0, 'sidebar_first', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (4, 'system', 'management', 'bartik', 1, 1, 'sidebar_first', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (5, 'system', 'help', 'bartik', 1, 0, 'help', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (6, 'node', 'syndicate', 'bartik', 0, 0, '-1', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (7, 'node', 'recent', 'bartik', 0, 0, '-1', 0, 0, '', '', 1);
INSERT INTO public.block VALUES (8, 'system', 'powered-by', 'bartik', 0, 10, '-1', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (9, 'system', 'user-menu', 'bartik', 0, 0, '-1', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (10, 'system', 'main-menu', 'bartik', 0, 0, '-1', 0, 0, '', '', -1);
INSERT INTO public.block VALUES (11, 'user', 'new', 'bartik', 0, 0, '-1', 0, 0, '', '', 1);
INSERT INTO public.block VALUES (12, 'user', 'online', 'bartik', 0, 0, '-1', 0, 0, '', '', -1);


--
-- TOC entry 4090 (class 0 OID 17063)
-- Dependencies: 275
-- Data for Name: block_custom; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4076 (class 0 OID 16926)
-- Dependencies: 261
-- Data for Name: block_node_type; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4088 (class 0 OID 17055)
-- Dependencies: 273
-- Data for Name: block_role; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4033 (class 0 OID 16430)
-- Dependencies: 218
-- Data for Name: blocked_ips; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4034 (class 0 OID 16439)
-- Dependencies: 219
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cache VALUES ('node_types:en', '\x4f3a383a22737464436c617373223a323a7b733a353a227479706573223b613a303a7b7d733a353a226e616d6573223b613a303a7b7d7d', 0, 1727123502, 1);
INSERT INTO public.cache VALUES ('theme_registry:build:modules', '\x613a3130303a7b733a31323a22757365725f70696374757265223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a226163636f756e74223b4e3b7d733a383a2274656d706c617465223b733a32353a226d6f64756c65732f757365722f757365722d70696374757265223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33323a2274656d706c6174655f70726570726f636573735f757365725f70696374757265223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31323a22757365725f70726f66696c65223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a32353a226d6f64756c65732f757365722f757365722d70726f66696c65223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33323a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c65223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a32313a22757365725f70726f66696c655f63617465676f7279223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a383a2274656d706c617465223b733a33343a226d6f64756c65732f757365722f757365722d70726f66696c652d63617465676f7279223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a34313a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c655f63617465676f7279223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31373a22757365725f70726f66696c655f6974656d223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a383a2274656d706c617465223b733a33303a226d6f64756c65732f757365722f757365722d70726f66696c652d6974656d223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33373a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c655f6974656d223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a393a22757365725f6c697374223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a353a227573657273223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a31353a227468656d655f757365725f6c697374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32323a22757365725f61646d696e5f7065726d697373696f6e73223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32383a227468656d655f757365725f61646d696e5f7065726d697373696f6e73223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31363a22757365725f61646d696e5f726f6c6573223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32323a227468656d655f757365725f61646d696e5f726f6c6573223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32373a22757365725f7065726d697373696f6e5f6465736372697074696f6e223b613a383a7b733a393a227661726961626c6573223b613a323a7b733a31353a227065726d697373696f6e5f6974656d223b4e3b733a343a2268696465223b4e3b7d733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a33333a227468656d655f757365725f7065726d697373696f6e5f6465736372697074696f6e223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31343a22757365725f7369676e6174757265223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a393a227369676e6174757265223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32303a227468656d655f757365725f7369676e6174757265223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a2268746d6c223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f73797374656d2f68746d6c223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f68746d6c223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f68746d6c223b7d7d733a343a2270616765223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f73797374656d2f70616765223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f70616765223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f70616765223b7d7d733a363a22726567696f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a32313a226d6f64756c65732f73797374656d2f726567696f6e223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32363a2274656d706c6174655f70726570726f636573735f726567696f6e223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31353a227374617475735f6d65737361676573223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a22646973706c6179223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f7374617475735f6d65737361676573223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a226c696e6b223b613a363a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a343a2270617468223b4e3b733a373a226f7074696f6e73223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a226c696e6b73223b613a363a7b733a393a227661726961626c6573223b613a333a7b733a353a226c696e6b73223b4e3b733a31303a2261747472696275746573223b613a313a7b733a353a22636c617373223b613a313a7b693a303b733a353a226c696e6b73223b7d7d733a373a2268656164696e67223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f6c696e6b73223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a22696d616765223b613a363a7b733a393a227661726961626c6573223b613a363a7b733a343a2270617468223b4e3b733a353a227769647468223b4e3b733a363a22686569676874223b4e3b733a333a22616c74223b733a303a22223b733a353a227469746c65223b4e3b733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f696d616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a2262726561646372756d62223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a31303a2262726561646372756d62223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f62726561646372756d62223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a2268656c70223b613a363a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f68656c70223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a227461626c65223b613a363a7b733a393a227661726961626c6573223b613a383a7b733a363a22686561646572223b4e3b733a363a22666f6f746572223b4e3b733a343a22726f7773223b4e3b733a31303a2261747472696275746573223b613a303a7b7d733a373a2263617074696f6e223b4e3b733a393a22636f6c67726f757073223b613a303a7b7d733a363a22737469636b79223b623a313b733a353a22656d707479223b733a303a22223b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f7461626c65223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a227461626c65736f72745f696e64696361746f72223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a353a227374796c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f7461626c65736f72745f696e64696361746f72223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a226d61726b223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a343a2274797065223b693a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f6d61726b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a226974656d5f6c697374223b613a363a7b733a393a227661726961626c6573223b613a343a7b733a353a226974656d73223b613a303a7b7d733a353a227469746c65223b4e3b733a343a2274797065223b733a323a22756c223b733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6974656d5f6c697374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31343a226d6f72655f68656c705f6c696e6b223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a333a2275726c223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32303a227468656d655f6d6f72655f68656c705f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a22666565645f69636f6e223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a333a2275726c223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f666565645f69636f6e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a226d6f72655f6c696e6b223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a333a2275726c223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d6f72655f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a22757365726e616d65223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a226163636f756e74223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f757365726e616d65223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32383a2274656d706c6174655f70726570726f636573735f757365726e616d65223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32353a2274656d706c6174655f70726f636573735f757365726e616d65223b7d7d733a31323a2270726f67726573735f626172223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a373a2270657263656e74223b4e3b733a373a226d657373616765223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f70726f67726573735f626172223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31313a22696e64656e746174696f6e223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a343a2273697a65223b693a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f696e64656e746174696f6e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a2268746d6c5f746167223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f68746d6c5f746167223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31363a226d61696e74656e616e63655f70616765223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a373a22636f6e74656e74223b4e3b733a31333a2273686f775f6d65737361676573223b623a313b7d733a383a2274656d706c617465223b733a33313a226d6f64756c65732f73797374656d2f6d61696e74656e616e63652d70616765223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33363a2274656d706c6174655f70726570726f636573735f6d61696e74656e616e63655f70616765223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a33333a2274656d706c6174655f70726f636573735f6d61696e74656e616e63655f70616765223b7d7d733a31313a227570646174655f70616765223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a373a22636f6e74656e74223b4e3b733a31333a2273686f775f6d65737361676573223b623a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f7570646174655f70616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31323a22696e7374616c6c5f70616765223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f696e7374616c6c5f70616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a227461736b5f6c697374223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a353a226974656d73223b4e3b733a363a22616374697665223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f7461736b5f6c697374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31373a22617574686f72697a655f6d657373616765223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a373a226d657373616765223b4e3b733a373a2273756363657373223b623a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f617574686f72697a655f6d657373616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31363a22617574686f72697a655f7265706f7274223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a383a226d65737361676573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32323a227468656d655f617574686f72697a655f7265706f7274223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a227061676572223b613a363a7b733a393a227661726961626c6573223b613a343a7b733a343a2274616773223b613a303a7b7d733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d733a383a227175616e74697479223b693a393b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f7061676572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31313a2270616765725f6669727374223b613a363a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f70616765725f6669727374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31343a2270616765725f70726576696f7573223b613a363a7b733a393a227661726961626c6573223b613a343a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a383a22696e74657276616c223b693a313b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32303a227468656d655f70616765725f70726576696f7573223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a2270616765725f6e657874223b613a363a7b733a393a227661726961626c6573223b613a343a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a383a22696e74657276616c223b693a313b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6e657874223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a2270616765725f6c617374223b613a363a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6c617374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a2270616765725f6c696e6b223b613a363a7b733a393a227661726961626c6573223b613a353a7b733a343a2274657874223b4e3b733a383a22706167655f6e6577223b4e3b733a373a22656c656d656e74223b4e3b733a31303a22706172616d6574657273223b613a303a7b7d733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a226d656e755f6c696e6b223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d656e755f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a226d656e755f74726565223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a2274726565223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d656e755f74726565223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32393a2274656d706c6174655f70726570726f636573735f6d656e755f74726565223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31353a226d656e755f6c6f63616c5f7461736b223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f6d656e755f6c6f63616c5f7461736b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31373a226d656e755f6c6f63616c5f616374696f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6d656e755f6c6f63616c5f616374696f6e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31363a226d656e755f6c6f63616c5f7461736b73223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a373a227072696d617279223b613a303a7b7d733a393a227365636f6e64617279223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32323a227468656d655f6d656e755f6c6f63616c5f7461736b73223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a363a2273656c656374223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f73656c656374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a226669656c64736574223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f6669656c64736574223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a22726164696f223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f726164696f223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a363a22726164696f73223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f726164696f73223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a2264617465223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f64617465223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31353a226578706f7365645f66696c74657273223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f6578706f7365645f66696c74657273223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a22636865636b626f78223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f636865636b626f78223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a22636865636b626f786573223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f636865636b626f786573223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a363a22627574746f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f627574746f6e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31323a22696d6167655f627574746f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f696d6167655f627574746f6e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a363a2268696464656e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f68696464656e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a22746578746669656c64223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f746578746669656c64223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a22666f726d223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f666f726d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a227465787461726561223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f7465787461726561223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a383a2270617373776f7264223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f70617373776f7264223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a2266696c65223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f66696c65223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31313a227461626c6573656c656374223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f7461626c6573656c656374223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31323a22666f726d5f656c656d656e74223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f666f726d5f656c656d656e74223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32303a22666f726d5f72657175697265645f6d61726b6572223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32363a227468656d655f666f726d5f72657175697265645f6d61726b6572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31383a22666f726d5f656c656d656e745f6c6162656c223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f666f726d5f656c656d656e745f6c6162656c223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31333a22766572746963616c5f74616273223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31393a227468656d655f766572746963616c5f74616273223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a393a22636f6e7461696e6572223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f636f6e7461696e6572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31383a2273797374656d5f7468656d65735f70616765223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a31323a227468656d655f67726f757073223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f73797374656d5f7468656d65735f70616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32303a2273797374656d5f73657474696e67735f666f726d223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32363a227468656d655f73797374656d5f73657474696e67735f666f726d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31323a22636f6e6669726d5f666f726d223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f636f6e6669726d5f666f726d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32333a2273797374656d5f6d6f64756c65735f6669656c64736574223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32393a227468656d655f73797374656d5f6d6f64756c65735f6669656c64736574223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32373a2273797374656d5f6d6f64756c65735f696e636f6d70617469626c65223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a373a226d657373616765223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33333a227468656d655f73797374656d5f6d6f64756c65735f696e636f6d70617469626c65223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32343a2273797374656d5f6d6f64756c65735f756e696e7374616c6c223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33303a227468656d655f73797374656d5f6d6f64756c65735f756e696e7374616c6c223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31333a227374617475735f7265706f7274223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a31323a22726571756972656d656e7473223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31393a227468656d655f7374617475735f7265706f7274223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31303a2261646d696e5f70616765223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a363a22626c6f636b73223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f61646d696e5f70616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31313a2261646d696e5f626c6f636b223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a353a22626c6f636b223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f61646d696e5f626c6f636b223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a2261646d696e5f626c6f636b5f636f6e74656e74223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f61646d696e5f626c6f636b5f636f6e74656e74223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31383a2273797374656d5f61646d696e5f696e646578223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a31303a226d656e755f6974656d73223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f73797374656d5f61646d696e5f696e646578223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31373a2273797374656d5f706f77657265645f6279223b613a363a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f73797374656d5f706f77657265645f6279223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a2273797374656d5f636f6d706163745f6c696e6b223b613a363a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f73797374656d5f636f6d706163745f6c696e6b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32353a2273797374656d5f646174655f74696d655f73657474696e6773223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33313a227468656d655f73797374656d5f646174655f74696d655f73657474696e6773223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a343a226e6f6465223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a31373a226d6f64756c65732f6e6f64652f6e6f6465223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f6e6f6465223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31373a226e6f64655f7365617263685f61646d696e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6e6f64655f7365617263685f61646d696e223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31333a226e6f64655f6164645f6c697374223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2266696c65223b733a31343a226e6f64652e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a31393a227468656d655f6e6f64655f6164645f6c697374223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f6e6f64652f6e6f64652e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31323a226e6f64655f70726576696577223b613a383a7b733a393a227661726961626c6573223b613a313a7b733a343a226e6f6465223b4e3b7d733a343a2266696c65223b733a31343a226e6f64652e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a31383a227468656d655f6e6f64655f70726576696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f6e6f64652f6e6f64652e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a226e6f64655f61646d696e5f6f76657276696577223b613a383a7b733a393a227661726961626c6573223b613a323a7b733a343a226e616d65223b4e3b733a343a2274797065223b4e3b7d733a343a2266696c65223b733a31373a22636f6e74656e745f74797065732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32353a227468656d655f6e6f64655f61646d696e5f6f76657276696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a33303a226d6f64756c65732f6e6f64652f636f6e74656e745f74797065732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31373a226e6f64655f726563656e745f626c6f636b223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a353a226e6f646573223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6e6f64655f726563656e745f626c6f636b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a226e6f64655f726563656e745f636f6e74656e74223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a343a226e6f6465223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32353a227468656d655f6e6f64655f726563656e745f636f6e74656e74223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32313a2266696c7465725f61646d696e5f6f76657276696577223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2266696c7465722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32373a227468656d655f66696c7465725f61646d696e5f6f76657276696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a33323a2266696c7465725f61646d696e5f666f726d61745f66696c7465725f6f72646572223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2266696c65223b733a31363a2266696c7465722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a33383a227468656d655f66696c7465725f61646d696e5f666f726d61745f66696c7465725f6f72646572223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31313a2266696c7465725f74697073223b613a383a7b733a393a227661726961626c6573223b613a323a7b733a343a2274697073223b4e3b733a343a226c6f6e67223b623a303b7d733a343a2266696c65223b733a31363a2266696c7465722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a31373a227468656d655f66696c7465725f74697073223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31393a22746578745f666f726d61745f77726170706572223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32353a227468656d655f746578745f666f726d61745f77726170706572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a32313a2266696c7465725f746970735f6d6f72655f696e666f223b613a363a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32373a227468656d655f66696c7465725f746970735f6d6f72655f696e666f223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31373a2266696c7465725f67756964656c696e6573223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a363a22666f726d6174223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32333a227468656d655f66696c7465725f67756964656c696e6573223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a226669656c64223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f6669656c64223b733a383a2266756e6374696f6e223b733a31313a227468656d655f6669656c64223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32353a2274656d706c6174655f70726570726f636573735f6669656c64223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32323a2274656d706c6174655f70726f636573735f6669656c64223b7d7d733a32353a226669656c645f6d756c7469706c655f76616c75655f666f726d223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f6669656c64223b733a383a2266756e6374696f6e223b733a33313a227468656d655f6669656c645f6d756c7469706c655f76616c75655f666f726d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a31333a2264626c6f675f6d657373616765223b613a383a7b733a393a227661726961626c6573223b613a323a7b733a353a226576656e74223b4e3b733a343a226c696e6b223b623a303b7d733a343a2266696c65223b733a31353a2264626c6f672e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f64626c6f67223b733a383a2266756e6374696f6e223b733a31393a227468656d655f64626c6f675f6d657373616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a32393a226d6f64756c65732f64626c6f672f64626c6f672e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a303a7b7d733a31373a2270726f636573732066756e6374696f6e73223b613a303a7b7d7d733a353a22626c6f636b223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f626c6f636b2f626c6f636b223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f626c6f636b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32353a2274656d706c6174655f70726570726f636573735f626c6f636b223b693a323b733a32333a2273797374656d5f70726570726f636573735f626c6f636b223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a32343a22626c6f636b5f61646d696e5f646973706c61795f666f726d223b613a383a7b733a383a2274656d706c617465223b733a33383a226d6f64756c65732f626c6f636b2f626c6f636b2d61646d696e2d646973706c61792d666f726d223b733a343a2266696c65223b733a31353a22626c6f636b2e61646d696e2e696e63223b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f626c6f636b223b733a383a22696e636c75646573223b613a313a7b693a303b733a32393a226d6f64756c65732f626c6f636b2f626c6f636b2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a34343a2274656d706c6174655f70726570726f636573735f626c6f636b5f61646d696e5f646973706c61795f666f726d223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d7d', 0, 1727123505, 1);
INSERT INTO public.cache VALUES ('theme_registry:bartik', '\x613a3130313a7b733a393a226d656e755f74726565223b613a353a7b733a383a2266756e6374696f6e223b733a31363a2262617274696b5f6d656e755f74726565223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a31343a2272656e64657220656c656d656e74223b733a343a2274726565223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32393a2274656d706c6174655f70726570726f636573735f6d656e755f74726565223b7d7d733a33303a226669656c645f5f7461786f6e6f6d795f7465726d5f7265666572656e6365223b613a353a7b733a383a2266756e6374696f6e223b733a33373a2262617274696b5f6669656c645f5f7461786f6e6f6d795f7465726d5f7265666572656e6365223b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a393a226261736520686f6f6b223b733a353a226669656c64223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b7d733a343a226e6f6465223b613a373a7b733a383a2274656d706c617465223b733a343a226e6f6465223b733a343a2270617468223b733a32333a227468656d65732f62617274696b2f74656d706c61746573223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f6e6f6465223b693a323b733a32323a2262617274696b5f70726570726f636573735f6e6f6465223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31363a226d61696e74656e616e63655f70616765223b613a373a7b733a383a2274656d706c617465223b733a31363a226d61696e74656e616e63652d70616765223b733a343a2270617468223b733a32333a227468656d65732f62617274696b2f74656d706c61746573223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a393a227661726961626c6573223b613a323a7b733a373a22636f6e74656e74223b4e3b733a31333a2273686f775f6d65737361676573223b623a313b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33363a2274656d706c6174655f70726570726f636573735f6d61696e74656e616e63655f70616765223b693a323b733a33343a2262617274696b5f70726570726f636573735f6d61696e74656e616e63655f70616765223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a33333a2274656d706c6174655f70726f636573735f6d61696e74656e616e63655f70616765223b693a323b733a33313a2262617274696b5f70726f636573735f6d61696e74656e616e63655f70616765223b7d7d733a343a2270616765223b613a373a7b733a383a2274656d706c617465223b733a343a2270616765223b733a343a2270617468223b733a32333a227468656d65732f62617274696b2f74656d706c61746573223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f70616765223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f70616765223b693a323b733a31393a2262617274696b5f70726f636573735f70616765223b7d7d733a31323a22757365725f70696374757265223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a226163636f756e74223b4e3b7d733a383a2274656d706c617465223b733a32353a226d6f64756c65732f757365722f757365722d70696374757265223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33323a2274656d706c6174655f70726570726f636573735f757365725f70696374757265223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31323a22757365725f70726f66696c65223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a32353a226d6f64756c65732f757365722f757365722d70726f66696c65223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33323a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c65223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a32313a22757365725f70726f66696c655f63617465676f7279223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a383a2274656d706c617465223b733a33343a226d6f64756c65732f757365722f757365722d70726f66696c652d63617465676f7279223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a34313a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c655f63617465676f7279223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31373a22757365725f70726f66696c655f6974656d223b613a383a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a383a2274656d706c617465223b733a33303a226d6f64756c65732f757365722f757365722d70726f66696c652d6974656d223b733a343a2266696c65223b733a31343a22757365722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e70616765732e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a33373a2274656d706c6174655f70726570726f636573735f757365725f70726f66696c655f6974656d223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a393a22757365725f6c697374223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a353a227573657273223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a31353a227468656d655f757365725f6c697374223b7d733a32323a22757365725f61646d696e5f7065726d697373696f6e73223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32383a227468656d655f757365725f61646d696e5f7065726d697373696f6e73223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d7d733a31363a22757365725f61646d696e5f726f6c6573223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32323a227468656d655f757365725f61646d696e5f726f6c6573223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d7d733a32373a22757365725f7065726d697373696f6e5f6465736372697074696f6e223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a31353a227065726d697373696f6e5f6974656d223b4e3b733a343a2268696465223b4e3b7d733a343a2266696c65223b733a31343a22757365722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a33333a227468656d655f757365725f7065726d697373696f6e5f6465736372697074696f6e223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f757365722f757365722e61646d696e2e696e63223b7d7d733a31343a22757365725f7369676e6174757265223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a393a227369676e6174757265223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f75736572223b733a383a2266756e6374696f6e223b733a32303a227468656d655f757365725f7369676e6174757265223b7d733a343a2268746d6c223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f73797374656d2f68746d6c223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f68746d6c223b693a323b733a32323a2262617274696b5f70726570726f636573735f68746d6c223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f68746d6c223b693a323b733a31393a2262617274696b5f70726f636573735f68746d6c223b7d7d733a363a22726567696f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a32313a226d6f64756c65732f73797374656d2f726567696f6e223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32363a2274656d706c6174655f70726570726f636573735f726567696f6e223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31353a227374617475735f6d65737361676573223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a373a22646973706c6179223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f7374617475735f6d65737361676573223b7d733a343a226c696e6b223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a343a2270617468223b4e3b733a373a226f7074696f6e73223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f6c696e6b223b7d733a353a226c696e6b73223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a353a226c696e6b73223b4e3b733a31303a2261747472696275746573223b613a313a7b733a353a22636c617373223b613a313a7b693a303b733a353a226c696e6b73223b7d7d733a373a2268656164696e67223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f6c696e6b73223b7d733a353a22696d616765223b613a343a7b733a393a227661726961626c6573223b613a363a7b733a343a2270617468223b4e3b733a353a227769647468223b4e3b733a363a22686569676874223b4e3b733a333a22616c74223b733a303a22223b733a353a227469746c65223b4e3b733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f696d616765223b7d733a31303a2262726561646372756d62223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a31303a2262726561646372756d62223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f62726561646372756d62223b7d733a343a2268656c70223b613a343a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f68656c70223b7d733a353a227461626c65223b613a343a7b733a393a227661726961626c6573223b613a383a7b733a363a22686561646572223b4e3b733a363a22666f6f746572223b4e3b733a343a22726f7773223b4e3b733a31303a2261747472696275746573223b613a303a7b7d733a373a2263617074696f6e223b4e3b733a393a22636f6c67726f757073223b613a303a7b7d733a363a22737469636b79223b623a313b733a353a22656d707479223b733a303a22223b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f7461626c65223b7d733a31393a227461626c65736f72745f696e64696361746f72223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a353a227374796c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f7461626c65736f72745f696e64696361746f72223b7d733a343a226d61726b223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a343a2274797065223b693a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f6d61726b223b7d733a393a226974656d5f6c697374223b613a343a7b733a393a227661726961626c6573223b613a343a7b733a353a226974656d73223b613a303a7b7d733a353a227469746c65223b4e3b733a343a2274797065223b733a323a22756c223b733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6974656d5f6c697374223b7d733a31343a226d6f72655f68656c705f6c696e6b223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a333a2275726c223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32303a227468656d655f6d6f72655f68656c705f6c696e6b223b7d733a393a22666565645f69636f6e223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a333a2275726c223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f666565645f69636f6e223b7d733a393a226d6f72655f6c696e6b223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a333a2275726c223b4e3b733a353a227469746c65223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d6f72655f6c696e6b223b7d733a383a22757365726e616d65223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a226163636f756e74223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f757365726e616d65223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32383a2274656d706c6174655f70726570726f636573735f757365726e616d65223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32353a2274656d706c6174655f70726f636573735f757365726e616d65223b7d7d733a31323a2270726f67726573735f626172223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a373a2270657263656e74223b4e3b733a373a226d657373616765223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f70726f67726573735f626172223b7d733a31313a22696e64656e746174696f6e223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a343a2273697a65223b693a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f696e64656e746174696f6e223b7d733a383a2268746d6c5f746167223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f68746d6c5f746167223b7d733a31313a227570646174655f70616765223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a373a22636f6e74656e74223b4e3b733a31333a2273686f775f6d65737361676573223b623a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f7570646174655f70616765223b7d733a31323a22696e7374616c6c5f70616765223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f696e7374616c6c5f70616765223b7d733a393a227461736b5f6c697374223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a353a226974656d73223b4e3b733a363a22616374697665223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f7461736b5f6c697374223b7d733a31373a22617574686f72697a655f6d657373616765223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a373a226d657373616765223b4e3b733a373a2273756363657373223b623a313b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f617574686f72697a655f6d657373616765223b7d733a31363a22617574686f72697a655f7265706f7274223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a383a226d65737361676573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32323a227468656d655f617574686f72697a655f7265706f7274223b7d733a353a227061676572223b613a343a7b733a393a227661726961626c6573223b613a343a7b733a343a2274616773223b613a303a7b7d733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d733a383a227175616e74697479223b693a393b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f7061676572223b7d733a31313a2270616765725f6669727374223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f70616765725f6669727374223b7d733a31343a2270616765725f70726576696f7573223b613a343a7b733a393a227661726961626c6573223b613a343a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a383a22696e74657276616c223b693a313b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32303a227468656d655f70616765725f70726576696f7573223b7d733a31303a2270616765725f6e657874223b613a343a7b733a393a227661726961626c6573223b613a343a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a383a22696e74657276616c223b693a313b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6e657874223b7d733a31303a2270616765725f6c617374223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a373a22656c656d656e74223b693a303b733a31303a22706172616d6574657273223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6c617374223b7d733a31303a2270616765725f6c696e6b223b613a343a7b733a393a227661726961626c6573223b613a353a7b733a343a2274657874223b4e3b733a383a22706167655f6e6577223b4e3b733a373a22656c656d656e74223b4e3b733a31303a22706172616d6574657273223b613a303a7b7d733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f70616765725f6c696e6b223b7d733a393a226d656e755f6c696e6b223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d656e755f6c696e6b223b7d733a31353a226d656e755f6c6f63616c5f7461736b223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f6d656e755f6c6f63616c5f7461736b223b7d733a31373a226d656e755f6c6f63616c5f616374696f6e223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6d656e755f6c6f63616c5f616374696f6e223b7d733a31363a226d656e755f6c6f63616c5f7461736b73223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a373a227072696d617279223b613a303a7b7d733a393a227365636f6e64617279223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32323a227468656d655f6d656e755f6c6f63616c5f7461736b73223b7d733a363a2273656c656374223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f73656c656374223b7d733a383a226669656c64736574223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f6669656c64736574223b7d733a353a22726164696f223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f726164696f223b7d733a363a22726164696f73223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f726164696f73223b7d733a343a2264617465223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f64617465223b7d733a31353a226578706f7365645f66696c74657273223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f6578706f7365645f66696c74657273223b7d733a383a22636865636b626f78223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f636865636b626f78223b7d733a31303a22636865636b626f786573223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f636865636b626f786573223b7d733a363a22627574746f6e223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f627574746f6e223b7d733a31323a22696d6167655f627574746f6e223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f696d6167655f627574746f6e223b7d733a363a2268696464656e223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31323a227468656d655f68696464656e223b7d733a393a22746578746669656c64223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f746578746669656c64223b7d733a343a22666f726d223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f666f726d223b7d733a383a227465787461726561223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f7465787461726561223b7d733a383a2270617373776f7264223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f70617373776f7264223b7d733a343a2266696c65223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f66696c65223b7d733a31313a227461626c6573656c656374223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f7461626c6573656c656374223b7d733a31323a22666f726d5f656c656d656e74223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f666f726d5f656c656d656e74223b7d733a32303a22666f726d5f72657175697265645f6d61726b6572223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32363a227468656d655f666f726d5f72657175697265645f6d61726b6572223b7d733a31383a22666f726d5f656c656d656e745f6c6162656c223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f666f726d5f656c656d656e745f6c6162656c223b7d733a31333a22766572746963616c5f74616273223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31393a227468656d655f766572746963616c5f74616273223b7d733a393a22636f6e7461696e6572223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f636f6e7461696e6572223b7d733a31383a2273797374656d5f7468656d65735f70616765223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a31323a227468656d655f67726f757073223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f73797374656d5f7468656d65735f70616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a32303a2273797374656d5f73657474696e67735f666f726d223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32363a227468656d655f73797374656d5f73657474696e67735f666f726d223b7d733a31323a22636f6e6669726d5f666f726d223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31383a227468656d655f636f6e6669726d5f666f726d223b7d733a32333a2273797374656d5f6d6f64756c65735f6669656c64736574223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32393a227468656d655f73797374656d5f6d6f64756c65735f6669656c64736574223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a32373a2273797374656d5f6d6f64756c65735f696e636f6d70617469626c65223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a226d657373616765223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33333a227468656d655f73797374656d5f6d6f64756c65735f696e636f6d70617469626c65223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a32343a2273797374656d5f6d6f64756c65735f756e696e7374616c6c223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33303a227468656d655f73797374656d5f6d6f64756c65735f756e696e7374616c6c223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31333a227374617475735f7265706f7274223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a31323a22726571756972656d656e7473223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31393a227468656d655f7374617475735f7265706f7274223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31303a2261646d696e5f70616765223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a363a22626c6f636b73223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f61646d696e5f70616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31313a2261646d696e5f626c6f636b223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a353a22626c6f636b223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31373a227468656d655f61646d696e5f626c6f636b223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31393a2261646d696e5f626c6f636b5f636f6e74656e74223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f61646d696e5f626c6f636b5f636f6e74656e74223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31383a2273797374656d5f61646d696e5f696e646578223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a31303a226d656e755f6974656d73223b4e3b7d733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32343a227468656d655f73797374656d5f61646d696e5f696e646578223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31373a2273797374656d5f706f77657265645f6279223b613a343a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32333a227468656d655f73797374656d5f706f77657265645f6279223b7d733a31393a2273797374656d5f636f6d706163745f6c696e6b223b613a343a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32353a227468656d655f73797374656d5f636f6d706163745f6c696e6b223b7d733a32353a2273797374656d5f646174655f74696d655f73657474696e6773223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2273797374656d2e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a33313a227468656d655f73797374656d5f646174655f74696d655f73657474696e6773223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f73797374656d2f73797374656d2e61646d696e2e696e63223b7d7d733a31373a226e6f64655f7365617263685f61646d696e223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6e6f64655f7365617263685f61646d696e223b7d733a31333a226e6f64655f6164645f6c697374223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a373a22636f6e74656e74223b4e3b7d733a343a2266696c65223b733a31343a226e6f64652e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a31393a227468656d655f6e6f64655f6164645f6c697374223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f6e6f64652f6e6f64652e70616765732e696e63223b7d7d733a31323a226e6f64655f70726576696577223b613a363a7b733a393a227661726961626c6573223b613a313a7b733a343a226e6f6465223b4e3b7d733a343a2266696c65223b733a31343a226e6f64652e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a31383a227468656d655f6e6f64655f70726576696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a32373a226d6f64756c65732f6e6f64652f6e6f64652e70616765732e696e63223b7d7d733a31393a226e6f64655f61646d696e5f6f76657276696577223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a343a226e616d65223b4e3b733a343a2274797065223b4e3b7d733a343a2266696c65223b733a31373a22636f6e74656e745f74797065732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32353a227468656d655f6e6f64655f61646d696e5f6f76657276696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a33303a226d6f64756c65732f6e6f64652f636f6e74656e745f74797065732e696e63223b7d7d733a31373a226e6f64655f726563656e745f626c6f636b223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a353a226e6f646573223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32333a227468656d655f6e6f64655f726563656e745f626c6f636b223b7d733a31393a226e6f64655f726563656e745f636f6e74656e74223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a343a226e6f6465223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31323a226d6f64756c65732f6e6f6465223b733a383a2266756e6374696f6e223b733a32353a227468656d655f6e6f64655f726563656e745f636f6e74656e74223b7d733a32313a2266696c7465725f61646d696e5f6f76657276696577223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2266696c65223b733a31363a2266696c7465722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32373a227468656d655f66696c7465725f61646d696e5f6f76657276696577223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e61646d696e2e696e63223b7d7d733a33323a2266696c7465725f61646d696e5f666f726d61745f66696c7465725f6f72646572223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2266696c65223b733a31363a2266696c7465722e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a33383a227468656d655f66696c7465725f61646d696e5f666f726d61745f66696c7465725f6f72646572223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e61646d696e2e696e63223b7d7d733a31313a2266696c7465725f74697073223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a343a2274697073223b4e3b733a343a226c6f6e67223b623a303b7d733a343a2266696c65223b733a31363a2266696c7465722e70616765732e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a31373a227468656d655f66696c7465725f74697073223b733a383a22696e636c75646573223b613a313a7b693a303b733a33313a226d6f64756c65732f66696c7465722f66696c7465722e70616765732e696e63223b7d7d733a31393a22746578745f666f726d61745f77726170706572223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32353a227468656d655f746578745f666f726d61745f77726170706572223b7d733a32313a2266696c7465725f746970735f6d6f72655f696e666f223b613a343a7b733a393a227661726961626c6573223b613a303a7b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32373a227468656d655f66696c7465725f746970735f6d6f72655f696e666f223b7d733a31373a2266696c7465725f67756964656c696e6573223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a363a22666f726d6174223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f66696c746572223b733a383a2266756e6374696f6e223b733a32333a227468656d655f66696c7465725f67756964656c696e6573223b7d733a353a226669656c64223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f6669656c64223b733a383a2266756e6374696f6e223b733a31313a227468656d655f6669656c64223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32353a2274656d706c6174655f70726570726f636573735f6669656c64223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32323a2274656d706c6174655f70726f636573735f6669656c64223b7d7d733a32353a226669656c645f6d756c7469706c655f76616c75655f666f726d223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f6669656c64223b733a383a2266756e6374696f6e223b733a33313a227468656d655f6669656c645f6d756c7469706c655f76616c75655f666f726d223b7d733a31333a2264626c6f675f6d657373616765223b613a363a7b733a393a227661726961626c6573223b613a323a7b733a353a226576656e74223b4e3b733a343a226c696e6b223b623a303b7d733a343a2266696c65223b733a31353a2264626c6f672e61646d696e2e696e63223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f64626c6f67223b733a383a2266756e6374696f6e223b733a31393a227468656d655f64626c6f675f6d657373616765223b733a383a22696e636c75646573223b613a313a7b693a303b733a32393a226d6f64756c65732f64626c6f672f64626c6f672e61646d696e2e696e63223b7d7d733a353a22626c6f636b223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f626c6f636b2f626c6f636b223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a343a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32353a2274656d706c6174655f70726570726f636573735f626c6f636b223b693a323b733a32333a2273797374656d5f70726570726f636573735f626c6f636b223b693a333b733a32333a2262617274696b5f70726570726f636573735f626c6f636b223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a32343a22626c6f636b5f61646d696e5f646973706c61795f666f726d223b613a383a7b733a383a2274656d706c617465223b733a33383a226d6f64756c65732f626c6f636b2f626c6f636b2d61646d696e2d646973706c61792d666f726d223b733a343a2266696c65223b733a31353a22626c6f636b2e61646d696e2e696e63223b733a31343a2272656e64657220656c656d656e74223b733a343a22666f726d223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a226d6f64756c65732f626c6f636b223b733a383a22696e636c75646573223b613a313a7b693a303b733a32393a226d6f64756c65732f626c6f636b2f626c6f636b2e61646d696e2e696e63223b7d733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a34343a2274656d706c6174655f70726570726f636573735f626c6f636b5f61646d696e5f646973706c61795f666f726d223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d7d', 0, 1727123505, 1);
INSERT INTO public.cache VALUES ('theme_registry:runtime:bartik', '\x613a3130313a7b733a393a226d656e755f74726565223b613a353a7b733a383a2266756e6374696f6e223b733a31363a2262617274696b5f6d656e755f74726565223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a31343a2272656e64657220656c656d656e74223b733a343a2274726565223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a313a7b693a303b733a32393a2274656d706c6174655f70726570726f636573735f6d656e755f74726565223b7d7d733a33303a226669656c645f5f7461786f6e6f6d795f7465726d5f7265666572656e6365223b4e3b733a343a226e6f6465223b4e3b733a31363a226d61696e74656e616e63655f70616765223b4e3b733a343a2270616765223b613a373a7b733a383a2274656d706c617465223b733a343a2270616765223b733a343a2270617468223b733a32333a227468656d65732f62617274696b2f74656d706c61746573223b733a343a2274797065223b733a31323a227468656d655f656e67696e65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f70616765223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f70616765223b693a323b733a31393a2262617274696b5f70726f636573735f70616765223b7d7d733a31323a22757365725f70696374757265223b4e3b733a31323a22757365725f70726f66696c65223b4e3b733a32313a22757365725f70726f66696c655f63617465676f7279223b4e3b733a31373a22757365725f70726f66696c655f6974656d223b4e3b733a393a22757365725f6c697374223b4e3b733a32323a22757365725f61646d696e5f7065726d697373696f6e73223b4e3b733a31363a22757365725f61646d696e5f726f6c6573223b4e3b733a32373a22757365725f7065726d697373696f6e5f6465736372697074696f6e223b4e3b733a31343a22757365725f7369676e6174757265223b4e3b733a343a2268746d6c223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a343a2270616765223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f73797374656d2f68746d6c223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32343a2274656d706c6174655f70726570726f636573735f68746d6c223b693a323b733a32323a2262617274696b5f70726570726f636573735f68746d6c223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a333a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b693a313b733a32313a2274656d706c6174655f70726f636573735f68746d6c223b693a323b733a31393a2262617274696b5f70726f636573735f68746d6c223b7d7d733a363a22726567696f6e223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a32313a226d6f64756c65732f73797374656d2f726567696f6e223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a323a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32363a2274656d706c6174655f70726570726f636573735f726567696f6e223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a31353a227374617475735f6d65737361676573223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a373a22646973706c6179223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32313a227468656d655f7374617475735f6d65737361676573223b7d733a343a226c696e6b223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a343a2274657874223b4e3b733a343a2270617468223b4e3b733a373a226f7074696f6e73223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31303a227468656d655f6c696e6b223b7d733a353a226c696e6b73223b613a343a7b733a393a227661726961626c6573223b613a333a7b733a353a226c696e6b73223b4e3b733a31303a2261747472696275746573223b613a313a7b733a353a22636c617373223b613a313a7b693a303b733a353a226c696e6b73223b7d7d733a373a2268656164696e67223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31313a227468656d655f6c696e6b73223b7d733a353a22696d616765223b4e3b733a31303a2262726561646372756d62223b613a343a7b733a393a227661726961626c6573223b613a313a7b733a31303a2262726561646372756d62223b4e3b7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31363a227468656d655f62726561646372756d62223b7d733a343a2268656c70223b4e3b733a353a227461626c65223b4e3b733a31393a227461626c65736f72745f696e64696361746f72223b4e3b733a343a226d61726b223b4e3b733a393a226974656d5f6c697374223b613a343a7b733a393a227661726961626c6573223b613a343a7b733a353a226974656d73223b613a303a7b7d733a353a227469746c65223b4e3b733a343a2274797065223b733a323a22756c223b733a31303a2261747472696275746573223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6974656d5f6c697374223b7d733a31343a226d6f72655f68656c705f6c696e6b223b4e3b733a393a22666565645f69636f6e223b4e3b733a393a226d6f72655f6c696e6b223b4e3b733a383a22757365726e616d65223b4e3b733a31323a2270726f67726573735f626172223b4e3b733a31313a22696e64656e746174696f6e223b4e3b733a383a2268746d6c5f746167223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31343a227468656d655f68746d6c5f746167223b7d733a31313a227570646174655f70616765223b4e3b733a31323a22696e7374616c6c5f70616765223b4e3b733a393a227461736b5f6c697374223b4e3b733a31373a22617574686f72697a655f6d657373616765223b4e3b733a31363a22617574686f72697a655f7265706f7274223b4e3b733a353a227061676572223b4e3b733a31313a2270616765725f6669727374223b4e3b733a31343a2270616765725f70726576696f7573223b4e3b733a31303a2270616765725f6e657874223b4e3b733a31303a2270616765725f6c617374223b4e3b733a31303a2270616765725f6c696e6b223b4e3b733a393a226d656e755f6c696e6b223b613a343a7b733a31343a2272656e64657220656c656d656e74223b733a373a22656c656d656e74223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a31353a227468656d655f6d656e755f6c696e6b223b7d733a31353a226d656e755f6c6f63616c5f7461736b223b4e3b733a31373a226d656e755f6c6f63616c5f616374696f6e223b4e3b733a31363a226d656e755f6c6f63616c5f7461736b73223b613a343a7b733a393a227661726961626c6573223b613a323a7b733a373a227072696d617279223b613a303a7b7d733a393a227365636f6e64617279223b613a303a7b7d7d733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31343a226d6f64756c65732f73797374656d223b733a383a2266756e6374696f6e223b733a32323a227468656d655f6d656e755f6c6f63616c5f7461736b73223b7d733a363a2273656c656374223b4e3b733a383a226669656c64736574223b4e3b733a353a22726164696f223b4e3b733a363a22726164696f73223b4e3b733a343a2264617465223b4e3b733a31353a226578706f7365645f66696c74657273223b4e3b733a383a22636865636b626f78223b4e3b733a31303a22636865636b626f786573223b4e3b733a363a22627574746f6e223b4e3b733a31323a22696d6167655f627574746f6e223b4e3b733a363a2268696464656e223b4e3b733a393a22746578746669656c64223b4e3b733a343a22666f726d223b4e3b733a383a227465787461726561223b4e3b733a383a2270617373776f7264223b4e3b733a343a2266696c65223b4e3b733a31313a227461626c6573656c656374223b4e3b733a31323a22666f726d5f656c656d656e74223b4e3b733a32303a22666f726d5f72657175697265645f6d61726b6572223b4e3b733a31383a22666f726d5f656c656d656e745f6c6162656c223b4e3b733a31333a22766572746963616c5f74616273223b4e3b733a393a22636f6e7461696e6572223b4e3b733a31383a2273797374656d5f7468656d65735f70616765223b4e3b733a32303a2273797374656d5f73657474696e67735f666f726d223b4e3b733a31323a22636f6e6669726d5f666f726d223b4e3b733a32333a2273797374656d5f6d6f64756c65735f6669656c64736574223b4e3b733a32373a2273797374656d5f6d6f64756c65735f696e636f6d70617469626c65223b4e3b733a32343a2273797374656d5f6d6f64756c65735f756e696e7374616c6c223b4e3b733a31333a227374617475735f7265706f7274223b4e3b733a31303a2261646d696e5f70616765223b4e3b733a31313a2261646d696e5f626c6f636b223b4e3b733a31393a2261646d696e5f626c6f636b5f636f6e74656e74223b4e3b733a31383a2273797374656d5f61646d696e5f696e646578223b4e3b733a31373a2273797374656d5f706f77657265645f6279223b4e3b733a31393a2273797374656d5f636f6d706163745f6c696e6b223b4e3b733a32353a2273797374656d5f646174655f74696d655f73657474696e6773223b4e3b733a31373a226e6f64655f7365617263685f61646d696e223b4e3b733a31333a226e6f64655f6164645f6c697374223b4e3b733a31323a226e6f64655f70726576696577223b4e3b733a31393a226e6f64655f61646d696e5f6f76657276696577223b4e3b733a31373a226e6f64655f726563656e745f626c6f636b223b4e3b733a31393a226e6f64655f726563656e745f636f6e74656e74223b4e3b733a32313a2266696c7465725f61646d696e5f6f76657276696577223b4e3b733a33323a2266696c7465725f61646d696e5f666f726d61745f66696c7465725f6f72646572223b4e3b733a31313a2266696c7465725f74697073223b4e3b733a31393a22746578745f666f726d61745f77726170706572223b4e3b733a32313a2266696c7465725f746970735f6d6f72655f696e666f223b4e3b733a31373a2266696c7465725f67756964656c696e6573223b4e3b733a353a226669656c64223b4e3b733a32353a226669656c645f6d756c7469706c655f76616c75655f666f726d223b4e3b733a31333a2264626c6f675f6d657373616765223b4e3b733a353a22626c6f636b223b613a363a7b733a31343a2272656e64657220656c656d656e74223b733a383a22656c656d656e7473223b733a383a2274656d706c617465223b733a31393a226d6f64756c65732f626c6f636b2f626c6f636b223b733a343a2274797065223b733a363a226d6f64756c65223b733a31303a227468656d652070617468223b733a31333a227468656d65732f62617274696b223b733a32303a2270726570726f636573732066756e6374696f6e73223b613a343a7b693a303b733a31393a2274656d706c6174655f70726570726f63657373223b693a313b733a32353a2274656d706c6174655f70726570726f636573735f626c6f636b223b693a323b733a32333a2273797374656d5f70726570726f636573735f626c6f636b223b693a333b733a32333a2262617274696b5f70726570726f636573735f626c6f636b223b7d733a31373a2270726f636573732066756e6374696f6e73223b613a313a7b693a303b733a31363a2274656d706c6174655f70726f63657373223b7d7d733a32343a22626c6f636b5f61646d696e5f646973706c61795f666f726d223b4e3b7d', 0, 1727123505, 1);


--
-- TOC entry 4091 (class 0 OID 17075)
-- Dependencies: 276
-- Data for Name: cache_block; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4035 (class 0 OID 16451)
-- Dependencies: 220
-- Data for Name: cache_bootstrap; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cache_bootstrap VALUES ('bootstrap_modules', '\x613a313a7b733a353a2264626c6f67223b4f3a383a22737464436c617373223a323a7b733a343a226e616d65223b733a353a2264626c6f67223b733a383a2266696c656e616d65223b733a32363a226d6f64756c65732f64626c6f672f64626c6f672e6d6f64756c65223b7d7d', 0, 1727123502, 1);
INSERT INTO public.cache_bootstrap VALUES ('system_list', '\x613a333a7b733a31343a226d6f64756c655f656e61626c6564223b613a31303a7b733a353a22626c6f636b223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32363a226d6f64756c65732f626c6f636b2f626c6f636b2e6d6f64756c65223b733a343a226e616d65223b733a353a22626c6f636b223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303039223b733a363a22776569676874223b733a323a222d35223b733a343a22696e666f223b613a31333a7b733a343a226e616d65223b733a353a22426c6f636b223b733a31313a226465736372697074696f6e223b733a3134303a22436f6e74726f6c73207468652076697375616c206275696c64696e6720626c6f636b732061207061676520697320636f6e737472756374656420776974682e20426c6f636b732061726520626f786573206f6620636f6e74656e742072656e646572656420696e746f20616e20617265612c206f7220726567696f6e2c206f6620612077656220706167652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a22626c6f636b2e74657374223b7d733a393a22636f6e666967757265223b733a32313a2261646d696e2f7374727563747572652f626c6f636b223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a353a2264626c6f67223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32363a226d6f64756c65732f64626c6f672f64626c6f672e6d6f64756c65223b733a343a226e616d65223b733a353a2264626c6f67223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2231223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303033223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31323a7b733a343a226e616d65223b733a31363a224461746162617365206c6f6767696e67223b733a31313a226465736372697074696f6e223b733a34373a224c6f677320616e64207265636f7264732073797374656d206576656e747320746f207468652064617461626173652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a2264626c6f672e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a353a226669656c64223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32363a226d6f64756c65732f6669656c642f6669656c642e6d6f64756c65223b733a343a226e616d65223b733a353a226669656c64223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303034223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31343a7b733a343a226e616d65223b733a353a224669656c64223b733a31313a226465736372697074696f6e223b733a35373a224669656c642041504920746f20616464206669656c647320746f20656e746974696573206c696b65206e6f64657320616e642075736572732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a343a7b693a303b733a31323a226669656c642e6d6f64756c65223b693a313b733a31363a226669656c642e6174746163682e696e63223b693a323b733a32303a226669656c642e696e666f2e636c6173732e696e63223b693a333b733a31363a2274657374732f6669656c642e74657374223b7d733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a31373a226669656c645f73716c5f73746f72616765223b7d733a383a227265717569726564223b623a313b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31353a227468656d652f6669656c642e637373223b733a32393a226d6f64756c65732f6669656c642f7468656d652f6669656c642e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a31373a226669656c645f73716c5f73746f72616765223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a36343a226d6f64756c65732f6669656c642f6d6f64756c65732f6669656c645f73716c5f73746f726167652f6669656c645f73716c5f73746f726167652e6d6f64756c65223b733a343a226e616d65223b733a31373a226669656c645f73716c5f73746f72616765223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303032223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31333a7b733a343a226e616d65223b733a31373a224669656c642053514c2073746f72616765223b733a31313a226465736372697074696f6e223b733a33373a2253746f726573206669656c64206461746120696e20616e2053514c2064617461626173652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a32323a226669656c645f73716c5f73746f726167652e74657374223b7d733a383a227265717569726564223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a363a2266696c746572223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32383a226d6f64756c65732f66696c7465722f66696c7465722e6d6f64756c65223b733a343a226e616d65223b733a363a2266696c746572223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303130223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31343a7b733a343a226e616d65223b733a363a2246696c746572223b733a31313a226465736372697074696f6e223b733a34333a2246696c7465727320636f6e74656e7420696e207072657061726174696f6e20666f7220646973706c61792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a2266696c7465722e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a32383a2261646d696e2f636f6e6669672f636f6e74656e742f666f726d617473223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a343a226e6f6465223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32343a226d6f64756c65732f6e6f64652f6e6f64652e6d6f64756c65223b733a343a226e616d65223b733a343a226e6f6465223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303136223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31353a7b733a343a226e616d65223b733a343a224e6f6465223b733a31313a226465736372697074696f6e223b733a36363a22416c6c6f777320636f6e74656e7420746f206265207375626d697474656420746f20746865207369746520616e6420646973706c61796564206f6e2070616765732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a323a7b693a303b733a31313a226e6f64652e6d6f64756c65223b693a313b733a393a226e6f64652e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a32313a2261646d696e2f7374727563747572652f7479706573223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a226e6f64652e637373223b733a32313a226d6f64756c65732f6e6f64652f6e6f64652e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a363a2273797374656d223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32383a226d6f64756c65732f73797374656d2f73797374656d2e6d6f64756c65223b733a343a226e616d65223b733a363a2273797374656d223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303835223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31343a7b733a343a226e616d65223b733a363a2253797374656d223b733a31313a226465736372697074696f6e223b733a35343a2248616e646c65732067656e6572616c207369746520636f6e66696775726174696f6e20666f722061646d696e6973747261746f72732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a363a7b693a303b733a31393a2273797374656d2e61726368697665722e696e63223b693a313b733a31353a2273797374656d2e6d61696c2e696e63223b693a323b733a31363a2273797374656d2e71756575652e696e63223b693a333b733a31343a2273797374656d2e7461722e696e63223b693a343b733a31383a2273797374656d2e757064617465722e696e63223b693a353b733a31313a2273797374656d2e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a31393a2261646d696e2f636f6e6669672f73797374656d223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a343a2274657874223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a33383a226d6f64756c65732f6669656c642f6d6f64756c65732f746578742f746578742e6d6f64756c65223b733a343a226e616d65223b733a343a2274657874223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303030223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31333a7b733a343a226e616d65223b733a343a2254657874223b733a31313a226465736372697074696f6e223b733a33323a22446566696e65732073696d706c652074657874206669656c642074797065732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a393a22746578742e74657374223b7d733a383a227265717569726564223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a343a2275736572223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a32343a226d6f64756c65732f757365722f757365722e6d6f64756c65223b733a343a226e616d65223b733a343a2275736572223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a343a2237303230223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31353a7b733a343a226e616d65223b733a343a2255736572223b733a31313a226465736372697074696f6e223b733a34373a224d616e6167657320746865207573657220726567697374726174696f6e20616e64206c6f67696e2073797374656d2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a323a7b693a303b733a31313a22757365722e6d6f64756c65223b693a313b733a393a22757365722e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a31393a2261646d696e2f636f6e6669672f70656f706c65223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a22757365722e637373223b733a32313a226d6f64756c65732f757365722f757365722e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d7d733a373a226d696e696d616c223b4f3a383a22737464436c617373223a393a7b733a383a2266696c656e616d65223b733a33323a2270726f66696c65732f6d696e696d616c2f6d696e696d616c2e70726f66696c65223b733a343a226e616d65223b733a373a226d696e696d616c223b733a343a2274797065223b733a363a226d6f64756c65223b733a353a226f776e6572223b733a303a22223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a313a2230223b733a363a22776569676874223b733a343a2231303030223b733a343a22696e666f223b613a31353a7b733a343a226e616d65223b733a373a224d696e696d616c223b733a31313a226465736372697074696f6e223b733a33383a2253746172742077697468206f6e6c79206120666577206d6f64756c657320656e61626c65642e223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a323a7b693a303b733a353a22626c6f636b223b693a313b733a353a2264626c6f67223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a373a227061636b616765223b733a353a224f74686572223b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b733a363a2268696464656e223b623a313b733a383a227265717569726564223b623a313b733a31373a22646973747269627574696f6e5f6e616d65223b733a363a2244727570616c223b7d7d7d733a353a227468656d65223b613a343a7b733a363a2262617274696b223b4f3a383a22737464436c617373223a31303a7b733a383a2266696c656e616d65223b733a32353a227468656d65732f62617274696b2f62617274696b2e696e666f223b733a343a226e616d65223b733a363a2262617274696b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a363a2242617274696b223b733a31313a226465736372697074696f6e223b733a34383a224120666c657869626c652c207265636f6c6f7261626c65207468656d652077697468206d616e7920726567696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a373a22726567696f6e73223b613a31373a7b733a363a22686561646572223b733a363a22486561646572223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a383a226665617475726564223b733a383a224665617475726564223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a31333a22736964656261725f6669727374223b733a31333a2253696465626172206669727374223b733a31343a22736964656261725f7365636f6e64223b733a31343a2253696465626172207365636f6e64223b733a31343a2274726970747963685f6669727374223b733a31343a225472697074796368206669727374223b733a31353a2274726970747963685f6d6964646c65223b733a31353a225472697074796368206d6964646c65223b733a31333a2274726970747963685f6c617374223b733a31333a225472697074796368206c617374223b733a31383a22666f6f7465725f6669727374636f6c756d6e223b733a31393a22466f6f74657220666972737420636f6c756d6e223b733a31393a22666f6f7465725f7365636f6e64636f6c756d6e223b733a32303a22466f6f746572207365636f6e6420636f6c756d6e223b733a31383a22666f6f7465725f7468697264636f6c756d6e223b733a31393a22466f6f74657220746869726420636f6c756d6e223b733a31393a22666f6f7465725f666f75727468636f6c756d6e223b733a32303a22466f6f74657220666f7572746820636f6c756d6e223b733a363a22666f6f746572223b733a363a22466f6f746572223b7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2230223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32383a227468656d65732f62617274696b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b7d733a373a226761726c616e64223b4f3a383a22737464436c617373223a31303a7b733a383a2266696c656e616d65223b733a32373a227468656d65732f6761726c616e642f6761726c616e642e696e666f223b733a343a226e616d65223b733a373a226761726c616e64223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a373a224761726c616e64223b733a31313a226465736372697074696f6e223b733a3131313a2241206d756c74692d636f6c756d6e207468656d652077686963682063616e20626520636f6e6669677572656420746f206d6f6469667920636f6c6f727320616e6420737769746368206265747765656e20666978656420616e6420666c756964207769647468206c61796f7574732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a31333a226761726c616e645f7769647468223b733a353a22666c756964223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32393a227468656d65732f6761726c616e642f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b7d733a353a22736576656e223b4f3a383a22737464436c617373223a31303a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f736576656e2f736576656e2e696e666f223b733a343a226e616d65223b733a353a22736576656e223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a353a22536576656e223b733a31313a226465736372697074696f6e223b733a36353a22412073696d706c65206f6e652d636f6c756d6e2c207461626c656c6573732c20666c7569642077696474682061646d696e697374726174696f6e207468656d652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2231223b7d733a373a22726567696f6e73223b613a353a7b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31333a22736964656261725f6669727374223b733a31333a2246697273742073696465626172223b7d733a31343a22726567696f6e735f68696464656e223b613a333a7b693a303b733a31333a22736964656261725f6669727374223b693a313b733a383a22706167655f746f70223b693a323b733a31313a22706167655f626f74746f6d223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f736576656e2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b7d733a353a22737461726b223b4f3a383a22737464436c617373223a31303a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f737461726b2f737461726b2e696e666f223b733a343a226e616d65223b733a353a22737461726b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31363a7b733a343a226e616d65223b733a353a22537461726b223b733a31313a226465736372697074696f6e223b733a3230383a2254686973207468656d652064656d6f6e737472617465732044727570616c27732064656661756c742048544d4c206d61726b757020616e6420435353207374796c65732e20546f206c6561726e20686f7720746f206275696c6420796f7572206f776e207468656d6520616e64206f766572726964652044727570616c27732064656661756c7420636f64652c2073656520746865203c6120687265663d22687474703a2f2f64727570616c2e6f72672f7468656d652d6775696465223e5468656d696e672047756964653c2f613e2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f737461726b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b7d7d733a393a2266696c657061746873223b613a31313a7b693a303b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a353a22626c6f636b223b733a383a2266696c6570617468223b733a32363a226d6f64756c65732f626c6f636b2f626c6f636b2e6d6f64756c65223b7d693a313b613a333a7b733a343a2274797065223b733a353a227468656d65223b733a343a226e616d65223b733a363a2262617274696b223b733a383a2266696c6570617468223b733a32353a227468656d65732f62617274696b2f62617274696b2e696e666f223b7d693a323b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a353a2264626c6f67223b733a383a2266696c6570617468223b733a32363a226d6f64756c65732f64626c6f672f64626c6f672e6d6f64756c65223b7d693a333b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a353a226669656c64223b733a383a2266696c6570617468223b733a32363a226d6f64756c65732f6669656c642f6669656c642e6d6f64756c65223b7d693a343b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a31373a226669656c645f73716c5f73746f72616765223b733a383a2266696c6570617468223b733a36343a226d6f64756c65732f6669656c642f6d6f64756c65732f6669656c645f73716c5f73746f726167652f6669656c645f73716c5f73746f726167652e6d6f64756c65223b7d693a353b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a363a2266696c746572223b733a383a2266696c6570617468223b733a32383a226d6f64756c65732f66696c7465722f66696c7465722e6d6f64756c65223b7d693a363b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a343a226e6f6465223b733a383a2266696c6570617468223b733a32343a226d6f64756c65732f6e6f64652f6e6f64652e6d6f64756c65223b7d693a373b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a363a2273797374656d223b733a383a2266696c6570617468223b733a32383a226d6f64756c65732f73797374656d2f73797374656d2e6d6f64756c65223b7d693a383b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a343a2274657874223b733a383a2266696c6570617468223b733a33383a226d6f64756c65732f6669656c642f6d6f64756c65732f746578742f746578742e6d6f64756c65223b7d693a393b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a343a2275736572223b733a383a2266696c6570617468223b733a32343a226d6f64756c65732f757365722f757365722e6d6f64756c65223b7d693a31303b613a333a7b733a343a2274797065223b733a363a226d6f64756c65223b733a343a226e616d65223b733a373a226d696e696d616c223b733a383a2266696c6570617468223b733a33323a2270726f66696c65732f6d696e696d616c2f6d696e696d616c2e70726f66696c65223b7d7d7d', 0, 1727123502, 1);
INSERT INTO public.cache_bootstrap VALUES ('hook_info', '\x613a343a7b733a31303a22746f6b656e5f696e666f223b613a313a7b733a353a2267726f7570223b733a363a22746f6b656e73223b7d733a31363a22746f6b656e5f696e666f5f616c746572223b613a313a7b733a353a2267726f7570223b733a363a22746f6b656e73223b7d733a363a22746f6b656e73223b613a313a7b733a353a2267726f7570223b733a363a22746f6b656e73223b7d733a31323a22746f6b656e735f616c746572223b613a313a7b733a353a2267726f7570223b733a363a22746f6b656e73223b7d7d', 0, 1727123502, 1);
INSERT INTO public.cache_bootstrap VALUES ('variables', '\x613a31393a7b733a31333a227468656d655f64656661756c74223b733a363a2262617274696b223b733a383a2263726f6e5f6b6579223b733a34333a224a3441587a346170432d3143582d51796657614e314c4132765f424a33726c6833655f49623550424c6b6f223b733a31393a2266696c655f74656d706f726172795f70617468223b733a343a222f746d70223b733a32303a22706174685f616c6961735f77686974656c697374223b613a303a7b7d733a31383a2264727570616c5f707269766174655f6b6579223b733a34333a2236397277483639724c5a3559646f416d6549563363576b434e4666733455457a3952506d302d64356f5677223b733a32323a2266696c7465725f66616c6c6261636b5f666f726d6174223b733a31303a22706c61696e5f74657874223b733a31333a22757365725f7265676973746572223b693a323b733a393a22736974655f6e616d65223b733a31343a2262726f777365722064727570616c223b733a393a22736974655f6d61696c223b733a31373a2261646d696e406578616d706c652e636f6d223b733a32313a22646174655f64656661756c745f74696d657a6f6e65223b733a31363a22416d65726963612f4e65775f596f726b223b733a32303a22736974655f64656661756c745f636f756e747279223b733a323a225553223b733a393a22636c65616e5f75726c223b733a313a2231223b733a31323a22696e7374616c6c5f74696d65223b693a313732373132333530323b733a31393a226373735f6a735f71756572795f737472696e67223b733a363a22736b61393075223b733a31353a22696e7374616c6c5f70726f66696c65223b733a373a226d696e696d616c223b733a393a2263726f6e5f6c617374223b693a313732373132333530323b733a31323a22696e7374616c6c5f7461736b223b733a343a22646f6e65223b733a31303a226d656e755f6d61736b73223b613a32303a7b693a303b693a3132353b693a313b693a3132313b693a323b693a36333b693a333b693a36323b693a343b693a36313b693a353b693a36303b693a363b693a34343b693a373b693a33313b693a383b693a33303b693a393b693a32343b693a31303b693a32313b693a31313b693a31353b693a31323b693a31343b693a31333b693a31313b693a31343b693a373b693a31353b693a363b693a31363b693a353b693a31373b693a333b693a31383b693a323b693a31393b693a313b7d733a31333a226d656e755f657870616e646564223b613a303a7b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_bootstrap VALUES ('lookup_cache', '\x613a343a7b733a33303a226344727570616c44656661756c74456e74697479436f6e74726f6c6c6572223b733a31393a22696e636c756465732f656e746974792e696e63223b733a31393a2263506167657244656661756c745f706773716c223b623a303b733a31393a2269506167657244656661756c745f706773716c223b623a303b733a31393a2274506167657244656661756c745f706773716c223b623a303b7d', 0, 1727123505, 1);
INSERT INTO public.cache_bootstrap VALUES ('module_implements', '\x613a34373a7b733a31353a2273747265616d5f7772617070657273223b613a313a7b733a363a2273797374656d223b623a303b7d733a32333a226d6f64756c655f696d706c656d656e74735f616c746572223b613a303a7b7d733a32313a2273747265616d5f77726170706572735f616c746572223b613a303a7b7d733a31373a2275726c5f696e626f756e645f616c746572223b613a303a7b7d733a31323a22637573746f6d5f7468656d65223b613a313a7b733a363a2273797374656d223b623a303b7d733a31313a2261646d696e5f7061746873223b613a343a7b733a353a22626c6f636b223b623a303b733a343a226e6f6465223b623a303b733a363a2273797374656d223b623a303b733a343a2275736572223b623a303b7d733a31373a2261646d696e5f70617468735f616c746572223b613a303a7b7d733a343a226d656e75223b613a363a7b733a353a22626c6f636b223b623a303b733a353a2264626c6f67223b623a303b733a363a2266696c746572223b623a303b733a343a226e6f6465223b623a303b733a363a2273797374656d223b623a303b733a343a2275736572223b623a303b7d733a393a226e6f64655f696e666f223b613a303a7b7d733a31313a2271756572795f616c746572223b613a303a7b7d733a32343a2271756572795f7472616e736c617461626c655f616c746572223b613a303a7b7d733a32383a2271756572795f6e6f64655f747970655f6163636573735f616c746572223b613a303a7b7d733a31353a22757365725f63617465676f72696573223b613a313a7b733a343a2275736572223b623a303b7d733a31303a226d656e755f616c746572223b613a303a7b7d733a31353a226d656e755f6c696e6b5f616c746572223b613a313a7b733a343a2275736572223b623a303b7d733a31393a226d656e755f6765745f6974656d5f616c746572223b613a303a7b7d733a31383a2275726c5f6f7574626f756e645f616c746572223b613a303a7b7d733a31333a226c6962726172795f616c746572223b613a303a7b7d733a343a22696e6974223b613a323a7b733a353a2264626c6f67223b623a303b733a363a2273797374656d223b623a303b7d733a32323a226d656e755f736974655f7374617475735f616c746572223b613a313a7b733a343a2275736572223b623a303b7d733a32383a22706167655f64656c69766572795f63616c6c6261636b5f616c746572223b613a303a7b7d733a343a2265786974223b613a303a7b7d733a31373a2271756572795f70616765725f616c746572223b613a303a7b7d733a32333a2271756572795f6e6f64655f6163636573735f616c746572223b613a313a7b733a343a226e6f6465223b623a303b7d733a353a227468656d65223b613a373a7b733a353a22626c6f636b223b623a303b733a353a2264626c6f67223b623a303b733a353a226669656c64223b623a303b733a363a2266696c746572223b623a303b733a343a226e6f6465223b623a303b733a363a2273797374656d223b623a303b733a343a2275736572223b623a303b7d733a32303a227468656d655f72656769737472795f616c746572223b613a303a7b7d733a31323a22656c656d656e745f696e666f223b613a333a7b733a363a2266696c746572223b623a303b733a363a2273797374656d223b623a303b733a343a2275736572223b623a303b7d733a31383a22656c656d656e745f696e666f5f616c746572223b613a303a7b7d733a31303a22706167655f6275696c64223b613a313a7b733a353a22626c6f636b223b623a303b7d733a32323a2271756572795f626c6f636b5f6c6f61645f616c746572223b613a303a7b7d733a31363a22626c6f636b5f6c6973745f616c746572223b613a323a7b733a353a22626c6f636b223b623a303b733a343a226e6f6465223b623a303b7d733a31313a226e6f64655f6772616e7473223b613a303a7b7d733a32323a226d656e755f6c6f63616c5f7461736b735f616c746572223b613a313a7b733a343a226e6f6465223b623a303b7d733a343a2268656c70223b613a393a7b733a353a22626c6f636b223b623a303b733a353a2264626c6f67223b623a303b733a353a226669656c64223b623a303b733a31373a226669656c645f73716c5f73746f72616765223b623a303b733a363a2266696c746572223b623a303b733a343a226e6f6465223b623a303b733a363a2273797374656d223b623a303b733a343a2274657874223b623a303b733a343a2275736572223b623a303b7d733a31363a22626c6f636b5f766965775f616c746572223b613a303a7b7d733a32383a22626c6f636b5f766965775f73797374656d5f68656c705f616c746572223b613a303a7b7d733a32383a22626c6f636b5f766965775f73797374656d5f6d61696e5f616c746572223b613a303a7b7d733a33323a2271756572795f7072656665727265645f6d656e755f6c696e6b735f616c746572223b613a303a7b7d733a33343a22626c6f636b5f766965775f73797374656d5f6e617669676174696f6e5f616c746572223b613a303a7b7d733a32373a22626c6f636b5f766965775f757365725f6c6f67696e5f616c746572223b613a303a7b7d733a33343a22626c6f636b5f766965775f73797374656d5f6d616e6167656d656e745f616c746572223b613a303a7b7d733a31303a22706167655f616c746572223b613a313a7b733a363a2273797374656d223b623a303b7d733a31343a2266696c655f75726c5f616c746572223b613a303a7b7d733a32363a227472616e736c617465645f6d656e755f6c696e6b5f616c746572223b613a313a7b733a343a2275736572223b623a303b7d733a383a226a735f616c746572223b613a303a7b7d733a31353a2268746d6c5f686561645f616c746572223b613a303a7b7d733a393a226373735f616c746572223b613a303a7b7d7d', 0, 1727123505, 1);


--
-- TOC entry 4085 (class 0 OID 17021)
-- Dependencies: 270
-- Data for Name: cache_field; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4080 (class 0 OID 16969)
-- Dependencies: 265
-- Data for Name: cache_filter; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4036 (class 0 OID 16463)
-- Dependencies: 221
-- Data for Name: cache_form; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4038 (class 0 OID 16487)
-- Dependencies: 223
-- Data for Name: cache_menu; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cache_menu VALUES ('local_tasks:node', '\x613a313a7b693a303b613a32333a7b733a343a2270617468223b733a343a226e6f6465223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31313a22757365725f616363657373223b733a31363a226163636573735f617267756d656e7473223b733a33323a22613a313a7b693a303b733a31343a2261636365737320636f6e74656e74223b7d223b733a31333a22706167655f63616c6c6261636b223b733a31373a226e6f64655f706167655f64656661756c74223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a333a22666974223b733a313a2231223b733a31323a226e756d6265725f7061727473223b733a313a2231223b733a373a22636f6e74657874223b733a313a2230223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a343a226e6f6465223b733a353a227469746c65223b733a303a22223b733a31343a227469746c655f63616c6c6261636b223b733a313a2274223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2230223b733a31313a226465736372697074696f6e223b733a303a22223b733a383a22706f736974696f6e223b733a303a22223b733a363a22776569676874223b733a313a2230223b733a31323a22696e636c7564655f66696c65223b733a303a22223b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:navigation:page:node:en:1:0', '\x613a343a7b733a393a226d696e5f6465707468223b693a313b733a393a226d61785f6465707468223b4e3b733a383a22657870616e646564223b613a313a7b693a303b693a303b7d733a31323a226163746976655f747261696c223b613a313a7b693a303b693a303b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:navigation:tree-data:en:9bd1605e2280833450478f9083b7f8714c2fa28f1012455e2744e5af1a13eec5', '\x613a323a7b733a343a2274726565223b613a343a7b693a333b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a31303a226e617669676174696f6e223b733a343a226d6c6964223b733a313a2233223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a31313a2266696c7465722f74697073223b733a31313a22726f757465725f70617468223b733a31313a2266696c7465722f74697073223b733a31303a226c696e6b5f7469746c65223b733a31323a22436f6d706f73652074697073223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2231223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2231223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a313a2230223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a313a2233223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a313a2231223b733a31363a226163636573735f617267756d656e7473223b733a363a22613a303a7b7d223b733a31333a22706167655f63616c6c6261636b223b733a31363a2266696c7465725f746970735f6c6f6e67223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a31313a2266696c7465722f74697073223b733a353a227469746c65223b733a31323a22436f6d706f73652074697073223b733a31343a227469746c655f63616c6c6261636b223b733a313a2274223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a323a223230223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d693a343b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a31303a226e617669676174696f6e223b733a343a226d6c6964223b733a313a2234223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a363a226e6f64652f25223b733a31313a22726f757465725f70617468223b733a363a226e6f64652f25223b733a31303a226c696e6b5f7469746c65223b733a303a22223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2230223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a313a2230223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a313a2234223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a32363a22613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31313a226e6f64655f616363657373223b733a31363a226163636573735f617267756d656e7473223b733a32393a22613a323a7b693a303b733a343a2276696577223b693a313b693a313b7d223b733a31333a22706167655f63616c6c6261636b223b733a31343a226e6f64655f706167655f76696577223b733a31343a22706167655f617267756d656e7473223b733a31343a22613a313a7b693a303b693a313b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a363a226e6f64652f25223b733a353a227469746c65223b733a303a22223b733a31343a227469746c655f63616c6c6261636b223b733a31353a226e6f64655f706167655f7469746c65223b733a31353a227469746c655f617267756d656e7473223b733a31343a22613a313a7b693a303b693a313b7d223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d693a353b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a31303a226e617669676174696f6e223b733a343a226d6c6964223b733a313a2235223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a383a226e6f64652f616464223b733a31313a22726f757465725f70617468223b733a383a226e6f64652f616464223b733a31303a226c696e6b5f7469746c65223b733a31313a2241646420636f6e74656e74223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2230223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a313a2230223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a313a2235223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31363a225f6e6f64655f6164645f616363657373223b733a31363a226163636573735f617267756d656e7473223b733a363a22613a303a7b7d223b733a31333a22706167655f63616c6c6261636b223b733a31333a226e6f64655f6164645f70616765223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a383a226e6f64652f616464223b733a353a227469746c65223b733a31313a2241646420636f6e74656e74223b733a31343a227469746c655f63616c6c6261636b223b733a313a2274223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d693a31343b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a31303a226e617669676174696f6e223b733a343a226d6c6964223b733a323a223134223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a363a22757365722f25223b733a31313a22726f757465725f70617468223b733a363a22757365722f25223b733a31303a226c696e6b5f7469746c65223b733a31303a224d79206163636f756e74223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2231223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a313a2230223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a323a223134223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a32363a22613a313a7b693a313b733a393a22757365725f6c6f6164223b7d223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31363a22757365725f766965775f616363657373223b733a31363a226163636573735f617267756d656e7473223b733a31343a22613a313a7b693a303b693a313b7d223b733a31333a22706167655f63616c6c6261636b223b733a31343a22757365725f766965775f70616765223b733a31343a22706167655f617267756d656e7473223b733a31343a22613a313a7b693a303b693a313b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a363a22757365722f25223b733a353a227469746c65223b733a31303a224d79206163636f756e74223b733a31343a227469746c655f63616c6c6261636b223b733a31353a22757365725f706167655f7469746c65223b733a31353a227469746c655f617267756d656e7473223b733a31343a22613a313a7b693a303b693a313b7d223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d7d733a31303a226e6f64655f6c696e6b73223b613a303a7b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:management:page:node:en:1:0', '\x613a343a7b733a393a226d696e5f6465707468223b693a313b733a393a226d61785f6465707468223b4e3b733a383a22657870616e646564223b613a313a7b693a303b693a303b7d733a31323a226163746976655f747261696c223b613a313a7b693a303b693a303b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:management:tree-data:en:9bd1605e2280833450478f9083b7f8714c2fa28f1012455e2744e5af1a13eec5', '\x613a323a7b733a343a2274726565223b613a313a7b693a313b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a31303a226d616e6167656d656e74223b733a343a226d6c6964223b733a313a2231223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a353a2261646d696e223b733a31313a22726f757465725f70617468223b733a353a2261646d696e223b733a31303a226c696e6b5f7469746c65223b733a31343a2241646d696e697374726174696f6e223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2231223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a313a2239223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a313a2231223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31313a22757365725f616363657373223b733a31363a226163636573735f617267756d656e7473223b733a34353a22613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d223b733a31333a22706167655f63616c6c6261636b223b733a32383a2273797374656d5f61646d696e5f6d656e755f626c6f636b5f70616765223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a353a2261646d696e223b733a353a227469746c65223b733a31343a2241646d696e697374726174696f6e223b733a31343a227469746c655f63616c6c6261636b223b733a313a2274223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d7d733a31303a226e6f64655f6c696e6b73223b613a303a7b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:main-menu:page:node:en:1:1', '\x613a343a7b733a393a226d696e5f6465707468223b693a313b733a393a226d61785f6465707468223b693a313b733a383a22657870616e646564223b613a313a7b693a303b693a303b7d733a31323a226163746976655f747261696c223b613a313a7b693a303b693a303b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:main-menu:tree-data:en:9ec01ec58bf82a695e4acd636af283e0585fe8cd8a6e54eb140188a3e284ab1c', '\x613a323a7b733a343a2274726565223b613a303a7b7d733a31303a226e6f64655f6c696e6b73223b613a303a7b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:user-menu:page:node:en:1:1', '\x613a343a7b733a393a226d696e5f6465707468223b693a313b733a393a226d61785f6465707468223b693a313b733a383a22657870616e646564223b613a313a7b693a303b693a303b7d733a31323a226163746976655f747261696c223b613a313a7b693a303b693a303b7d7d', 0, 1727123505, 1);
INSERT INTO public.cache_menu VALUES ('links:user-menu:tree-data:en:9ec01ec58bf82a695e4acd636af283e0585fe8cd8a6e54eb140188a3e284ab1c', '\x613a323a7b733a343a2274726565223b613a323a7b693a323b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a393a22757365722d6d656e75223b733a343a226d6c6964223b733a313a2232223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a343a2275736572223b733a31313a22726f757465725f70617468223b733a343a2275736572223b733a31303a226c696e6b5f7469746c65223b733a31323a2255736572206163636f756e74223b733a373a226f7074696f6e73223b733a32323a22613a313a7b733a353a22616c746572223b623a313b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2230223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a333a222d3130223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a313a2232223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a313a2231223b733a31363a226163636573735f617267756d656e7473223b733a363a22613a303a7b7d223b733a31333a22706167655f63616c6c6261636b223b733a393a22757365725f70616765223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a343a2275736572223b733a353a227469746c65223b733a31323a2255736572206163636f756e74223b733a31343a227469746c655f63616c6c6261636b223b733a31353a22757365725f6d656e755f7469746c65223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d693a31323b613a323a7b733a343a226c696e6b223b613a34323a7b733a393a226d656e755f6e616d65223b733a393a22757365722d6d656e75223b733a343a226d6c6964223b733a323a223132223b733a343a22706c6964223b733a313a2230223b733a393a226c696e6b5f70617468223b733a31313a22757365722f6c6f676f7574223b733a31313a22726f757465725f70617468223b733a31313a22757365722f6c6f676f7574223b733a31303a226c696e6b5f7469746c65223b733a373a224c6f67206f7574223b733a373a226f7074696f6e73223b733a363a22613a303a7b7d223b733a363a226d6f64756c65223b733a363a2273797374656d223b733a363a2268696464656e223b733a313a2230223b733a383a2265787465726e616c223b733a313a2230223b733a31323a226861735f6368696c6472656e223b733a313a2230223b733a383a22657870616e646564223b733a313a2230223b733a363a22776569676874223b733a323a223130223b733a353a226465707468223b733a313a2231223b733a31303a22637573746f6d697a6564223b733a313a2230223b733a323a227031223b733a323a223132223b733a323a227032223b733a313a2230223b733a323a227033223b733a313a2230223b733a323a227034223b733a313a2230223b733a323a227035223b733a313a2230223b733a323a227036223b733a313a2230223b733a323a227037223b733a313a2230223b733a323a227038223b733a313a2230223b733a323a227039223b733a313a2230223b733a373a2275706461746564223b733a313a2230223b733a31343a226c6f61645f66756e6374696f6e73223b733a303a22223b733a31363a22746f5f6172675f66756e6374696f6e73223b733a303a22223b733a31353a226163636573735f63616c6c6261636b223b733a31373a22757365725f69735f6c6f676765645f696e223b733a31363a226163636573735f617267756d656e7473223b733a363a22613a303a7b7d223b733a31333a22706167655f63616c6c6261636b223b733a31313a22757365725f6c6f676f7574223b733a31343a22706167655f617267756d656e7473223b733a363a22613a303a7b7d223b733a31373a2264656c69766572795f63616c6c6261636b223b733a303a22223b733a31303a227461625f706172656e74223b733a303a22223b733a383a227461625f726f6f74223b733a31313a22757365722f6c6f676f7574223b733a353a227469746c65223b733a373a224c6f67206f7574223b733a31343a227469746c655f63616c6c6261636b223b733a313a2274223b733a31353a227469746c655f617267756d656e7473223b733a303a22223b733a31343a227468656d655f63616c6c6261636b223b733a303a22223b733a31353a227468656d655f617267756d656e7473223b733a363a22613a303a7b7d223b733a343a2274797065223b733a313a2236223b733a31313a226465736372697074696f6e223b733a303a22223b733a31353a22696e5f6163746976655f747261696c223b623a303b7d733a353a2262656c6f77223b613a303a7b7d7d7d733a31303a226e6f64655f6c696e6b73223b613a303a7b7d7d', 0, 1727123505, 1);


--
-- TOC entry 4037 (class 0 OID 16475)
-- Dependencies: 222
-- Data for Name: cache_page; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4039 (class 0 OID 16499)
-- Dependencies: 224
-- Data for Name: cache_path; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4043 (class 0 OID 16529)
-- Dependencies: 228
-- Data for Name: date_format_locale; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4040 (class 0 OID 16511)
-- Dependencies: 225
-- Data for Name: date_format_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.date_format_type VALUES ('long', 'Long', 1);
INSERT INTO public.date_format_type VALUES ('medium', 'Medium', 1);
INSERT INTO public.date_format_type VALUES ('short', 'Short', 1);


--
-- TOC entry 4042 (class 0 OID 16519)
-- Dependencies: 227
-- Data for Name: date_formats; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.date_formats VALUES (1, 'm/d/Y - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (2, 'd/m/Y - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (3, 'Y/m/d - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (4, 'd.m.Y - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (5, 'Y-m-d H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (6, 'm/d/Y - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (7, 'd/m/Y - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (8, 'Y/m/d - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (9, 'M j Y - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (10, 'j M Y - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (11, 'Y M j - H:i', 'short', 1);
INSERT INTO public.date_formats VALUES (12, 'M j Y - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (13, 'j M Y - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (14, 'Y M j - g:ia', 'short', 1);
INSERT INTO public.date_formats VALUES (15, 'D, m/d/Y - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (16, 'D, d/m/Y - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (17, 'D, Y/m/d - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (18, 'D, Y-m-d H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (19, 'F j, Y - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (20, 'j F, Y - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (21, 'Y, F j - H:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (22, 'D, m/d/Y - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (23, 'D, d/m/Y - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (24, 'D, Y/m/d - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (25, 'F j, Y - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (26, 'j F Y - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (27, 'Y, F j - g:ia', 'medium', 1);
INSERT INTO public.date_formats VALUES (28, 'j. F Y - G:i', 'medium', 1);
INSERT INTO public.date_formats VALUES (29, 'l, F j, Y - H:i', 'long', 1);
INSERT INTO public.date_formats VALUES (30, 'l, j F, Y - H:i', 'long', 1);
INSERT INTO public.date_formats VALUES (31, 'l, Y,  F j - H:i', 'long', 1);
INSERT INTO public.date_formats VALUES (32, 'l, F j, Y - g:ia', 'long', 1);
INSERT INTO public.date_formats VALUES (33, 'l, j F Y - g:ia', 'long', 1);
INSERT INTO public.date_formats VALUES (34, 'l, Y,  F j - g:ia', 'long', 1);
INSERT INTO public.date_formats VALUES (35, 'l, j. F Y - G:i', 'long', 1);


--
-- TOC entry 4082 (class 0 OID 16982)
-- Dependencies: 267
-- Data for Name: field_config; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4084 (class 0 OID 17007)
-- Dependencies: 269
-- Data for Name: field_config_instance; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4045 (class 0 OID 16535)
-- Dependencies: 230
-- Data for Name: file_managed; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4046 (class 0 OID 16559)
-- Dependencies: 231
-- Data for Name: file_usage; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4078 (class 0 OID 16942)
-- Dependencies: 263
-- Data for Name: filter; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.filter VALUES ('plain_text', 'filter', 'filter_url', 1, 1, '\x613a313a7b733a31373a2266696c7465725f75726c5f6c656e677468223b693a37323b7d');
INSERT INTO public.filter VALUES ('plain_text', 'filter', 'filter_autop', 2, 1, '\x613a303a7b7d');
INSERT INTO public.filter VALUES ('plain_text', 'filter', 'filter_htmlcorrector', 10, 0, '\x613a303a7b7d');
INSERT INTO public.filter VALUES ('plain_text', 'filter', 'filter_html_escape', 0, 1, '\x613a303a7b7d');
INSERT INTO public.filter VALUES ('plain_text', 'filter', 'filter_html', -10, 0, '\x613a333a7b733a31323a22616c6c6f7765645f68746d6c223b733a37343a223c613e203c656d3e203c7374726f6e673e203c636974653e203c626c6f636b71756f74653e203c636f64653e203c756c3e203c6f6c3e203c6c693e203c646c3e203c64743e203c64643e223b733a31363a2266696c7465725f68746d6c5f68656c70223b693a313b733a32303a2266696c7465725f68746d6c5f6e6f666f6c6c6f77223b693a303b7d');


--
-- TOC entry 4079 (class 0 OID 16954)
-- Dependencies: 264
-- Data for Name: filter_format; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.filter_format VALUES ('plain_text', 'Plain text', 1, 1, 10);


--
-- TOC entry 4048 (class 0 OID 16575)
-- Dependencies: 233
-- Data for Name: flood; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4077 (class 0 OID 16932)
-- Dependencies: 262
-- Data for Name: history; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4051 (class 0 OID 16615)
-- Dependencies: 236
-- Data for Name: menu_links; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.menu_links VALUES ('navigation', 5, 0, 'node/add', 'node/add', 'Add content', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 1, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('user-menu', 9, 2, 'user/register', 'user/register', 'Create new account', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 2, 0, 2, 9, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 10, 1, 'admin/index', 'admin/index', 'Index', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -18, 2, 0, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('user-menu', 11, 2, 'user/login', 'user/login', 'Log in', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 2, 0, 2, 11, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('user-menu', 12, 0, 'user/logout', 'user/logout', 'Log out', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 10, 1, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('user-menu', 17, 2, 'user/password', 'user/password', 'Request new password', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 2, 0, 2, 17, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('user-menu', 2, 0, 'user', 'user', 'User account', '\x613a313a7b733a353a22616c746572223b623a313b7d', 'system', 0, 0, 0, 0, -10, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 19, 1, 'admin/tasks', 'admin/tasks', 'Tasks', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -20, 2, 0, 1, 19, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 1, 0, 'admin', 'admin', 'Administration', '\x613a303a7b7d', 'system', 0, 0, 1, 0, 9, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 20, 3, 'filter/tips/%', 'filter/tips/%', 'Compose tips', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 2, 0, 3, 20, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 3, 0, 'filter/tips', 'filter/tips', 'Compose tips', '\x613a303a7b7d', 'system', 1, 0, 1, 0, 0, 1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 21, 15, 'admin/people/create', 'admin/people/create', 'Add user', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 3, 0, 1, 15, 21, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 24, 8, 'admin/content/node', 'admin/content/node', 'Content', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 3, 0, 1, 8, 24, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 8, 1, 'admin/content', 'admin/content', 'Content', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a32343a2246696e6420616e64206d616e61676520636f6e74656e742e223b7d7d', 'system', 0, 0, 0, 0, -10, 2, 0, 1, 8, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 18, 1, 'admin/structure', 'admin/structure', 'Structure', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34353a2241646d696e697374657220626c6f636b732c20636f6e74656e742074797065732c206d656e75732c206574632e223b7d7d', 'system', 0, 0, 1, 0, -8, 2, 0, 1, 18, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 27, 4, 'node/%/delete', 'node/%/delete', 'Delete', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 1, 2, 0, 4, 27, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 30, 4, 'node/%/edit', 'node/%/edit', 'Edit', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 2, 0, 4, 30, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 32, 15, 'admin/people/people', 'admin/people/people', 'List', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a35303a2246696e6420616e64206d616e6167652070656f706c6520696e746572616374696e67207769746820796f757220736974652e223b7d7d', 'system', -1, 0, 0, 0, -10, 3, 0, 1, 15, 32, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 33, 6, 'admin/appearance/list', 'admin/appearance/list', 'List', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33313a2253656c65637420616e6420636f6e66696775726520796f7572207468656d65223b7d7d', 'system', -1, 0, 0, 0, -1, 3, 0, 1, 6, 33, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 15, 1, 'admin/people', 'admin/people', 'People', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34353a224d616e6167652075736572206163636f756e74732c20726f6c65732c20616e64207065726d697373696f6e732e223b7d7d', 'system', 0, 0, 0, 0, -4, 2, 0, 1, 15, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 37, 16, 'admin/reports/dblog', 'admin/reports/dblog', 'Recent log messages', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34333a2256696577206576656e74732074686174206861766520726563656e746c79206265656e206c6f676765642e223b7d7d', 'system', 0, 0, 0, 0, -1, 3, 0, 1, 16, 37, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 6, 1, 'admin/appearance', 'admin/appearance', 'Appearance', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33333a2253656c65637420616e6420636f6e66696775726520796f7572207468656d65732e223b7d7d', 'system', 0, 0, 0, 0, -6, 2, 0, 1, 6, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 42, 16, 'admin/reports/status', 'admin/reports/status', 'Status report', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a37343a22476574206120737461747573207265706f72742061626f757420796f757220736974652773206f7065726174696f6e20616e6420616e792064657465637465642070726f626c656d732e223b7d7d', 'system', 0, 0, 0, 0, -60, 3, 0, 1, 16, 42, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 44, 16, 'admin/reports/access-denied', 'admin/reports/access-denied', 'Top ''access denied'' errors', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33353a225669657720276163636573732064656e69656427206572726f7273202834303373292e223b7d7d', 'system', 0, 0, 0, 0, 0, 3, 0, 1, 16, 44, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 45, 16, 'admin/reports/page-not-found', 'admin/reports/page-not-found', 'Top ''page not found'' errors', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33363a2256696577202770616765206e6f7420666f756e6427206572726f7273202834303473292e223b7d7d', 'system', 0, 0, 0, 0, 0, 3, 0, 1, 16, 45, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 13, 1, 'admin/modules', 'admin/modules', 'Modules', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a32363a22457874656e6420736974652066756e6374696f6e616c6974792e223b7d7d', 'system', 0, 0, 0, 0, -2, 2, 0, 1, 13, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 47, 7, 'admin/config/user-interface', 'admin/config/user-interface', 'User interface', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33383a22546f6f6c73207468617420656e68616e636520746865207573657220696e746572666163652e223b7d7d', 'system', 0, 0, 0, 0, -15, 3, 0, 1, 7, 47, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 48, 4, 'node/%/view', 'node/%/view', 'View', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 2, 0, 4, 48, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 4, 0, 'node/%', 'node/%', '', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 49, 14, 'user/%/view', 'user/%/view', 'View', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 2, 0, 14, 49, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 14, 0, 'user/%', 'user/%', 'My account', '\x613a303a7b7d', 'system', 0, 0, 1, 0, 0, 1, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 51, 7, 'admin/config/workflow', 'admin/config/workflow', 'Workflow', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34333a22436f6e74656e7420776f726b666c6f772c20656469746f7269616c20776f726b666c6f7720746f6f6c732e223b7d7d', 'system', 0, 0, 0, 0, 5, 3, 0, 1, 7, 51, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 7, 1, 'admin/config', 'admin/config', 'Configuration', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a32303a2241646d696e69737465722073657474696e67732e223b7d7d', 'system', 0, 0, 1, 0, 0, 2, 0, 1, 7, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 54, 22, 'admin/structure/block/add', 'admin/structure/block/add', 'Add block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 18, 22, 54, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 55, 26, 'admin/structure/types/add', 'admin/structure/types/add', 'Add content type', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 18, 26, 55, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 56, 41, 'admin/appearance/settings/bartik', 'admin/appearance/settings/bartik', 'Bartik', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 6, 41, 56, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 57, 40, 'admin/config/search/clean-urls', 'admin/config/search/clean-urls', 'Clean URLs', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34333a22456e61626c65206f722064697361626c6520636c65616e2055524c7320666f7220796f757220736974652e223b7d7d', 'system', 0, 0, 0, 0, 5, 4, 0, 1, 7, 40, 57, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 40, 7, 'admin/config/search', 'admin/config/search', 'Search and metadata', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33363a224c6f63616c2073697465207365617263682c206d6574616461746120616e642053454f2e223b7d7d', 'system', 0, 0, 1, 0, -10, 3, 0, 1, 7, 40, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 58, 43, 'admin/config/system/cron', 'admin/config/system/cron', 'Cron', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34303a224d616e616765206175746f6d617469632073697465206d61696e74656e616e6365207461736b732e223b7d7d', 'system', 0, 0, 0, 0, 20, 4, 0, 1, 7, 43, 58, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 60, 16, 'admin/reports/event/%', 'admin/reports/event/%', 'Details', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 3, 0, 1, 16, 60, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 16, 1, 'admin/reports', 'admin/reports', 'Reports', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33343a2256696577207265706f7274732c20757064617465732c20616e64206572726f72732e223b7d7d', 'system', 0, 0, 1, 0, 5, 2, 0, 1, 16, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 61, 34, 'admin/config/media/file-system', 'admin/config/media/file-system', 'File system', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a36383a2254656c6c2044727570616c20776865726520746f2073746f72652075706c6f616465642066696c657320616e6420686f772074686579206172652061636365737365642e223b7d7d', 'system', 0, 0, 0, 0, -10, 4, 0, 1, 7, 34, 61, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 62, 41, 'admin/appearance/settings/garland', 'admin/appearance/settings/garland', 'Garland', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 6, 41, 62, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 63, 41, 'admin/appearance/settings/global', 'admin/appearance/settings/global', 'Global settings', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -1, 4, 0, 1, 6, 41, 63, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 35, 7, 'admin/config/people', 'admin/config/people', 'People', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a32343a22436f6e6669677572652075736572206163636f756e74732e223b7d7d', 'system', 0, 0, 1, 0, -20, 3, 0, 1, 7, 35, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 65, 34, 'admin/config/media/image-toolkit', 'admin/config/media/image-toolkit', 'Image toolkit', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a37343a2243686f6f736520776869636820696d61676520746f6f6c6b697420746f2075736520696620796f75206861766520696e7374616c6c6564206f7074696f6e616c20746f6f6c6b6974732e223b7d7d', 'system', 0, 0, 0, 0, 20, 4, 0, 1, 7, 34, 65, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 34, 7, 'admin/config/media', 'admin/config/media', 'Media', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a31323a224d6564696120746f6f6c732e223b7d7d', 'system', 0, 0, 1, 0, -10, 3, 0, 1, 7, 34, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 66, 26, 'admin/structure/types/list', 'admin/structure/types/list', 'List', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 4, 0, 1, 18, 26, 66, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 67, 31, 'admin/modules/list/confirm', 'admin/modules/list/confirm', 'List', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 13, 31, 67, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 31, 13, 'admin/modules/list', 'admin/modules/list', 'List', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 3, 0, 1, 13, 31, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 68, 28, 'admin/config/development/logging', 'admin/config/development/logging', 'Logging and errors', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3135343a2253657474696e677320666f72206c6f6767696e6720616e6420616c65727473206d6f64756c65732e20566172696f7573206d6f64756c65732063616e20726f7574652044727570616c27732073797374656d206576656e747320746f20646966666572656e742064657374696e6174696f6e732c2073756368206173207379736c6f672c2064617461626173652c20656d61696c2c206574632e223b7d7d', 'system', 0, 0, 0, 0, -15, 4, 0, 1, 7, 28, 68, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 69, 28, 'admin/config/development/maintenance', 'admin/config/development/maintenance', 'Maintenance mode', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a36323a2254616b65207468652073697465206f66666c696e6520666f72206d61696e74656e616e6365206f72206272696e67206974206261636b206f6e6c696e652e223b7d7d', 'system', 0, 0, 0, 0, -10, 4, 0, 1, 7, 28, 69, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 70, 28, 'admin/config/development/performance', 'admin/config/development/performance', 'Performance', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3130313a22456e61626c65206f722064697361626c6520706167652063616368696e6720666f7220616e6f6e796d6f757320757365727320616e64207365742043535320616e64204a532062616e647769647468206f7074696d697a6174696f6e206f7074696f6e732e223b7d7d', 'system', 0, 0, 0, 0, -20, 4, 0, 1, 7, 28, 70, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 28, 7, 'admin/config/development', 'admin/config/development', 'Development', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a31383a22446576656c6f706d656e7420746f6f6c732e223b7d7d', 'system', 0, 0, 1, 0, -10, 3, 0, 1, 7, 28, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 71, 36, 'admin/people/permissions/list', 'admin/people/permissions/list', 'Permissions', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a36343a2244657465726d696e652061636365737320746f2066656174757265732062792073656c656374696e67207065726d697373696f6e7320666f7220726f6c65732e223b7d7d', 'system', -1, 0, 0, 0, -8, 4, 0, 1, 15, 36, 71, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 72, 50, 'admin/config/services/rss-publishing', 'admin/config/services/rss-publishing', 'RSS publishing', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3131343a22436f6e666967757265207468652073697465206465736372697074696f6e2c20746865206e756d626572206f66206974656d7320706572206665656420616e6420776865746865722066656564732073686f756c64206265207469746c65732f746561736572732f66756c6c2d746578742e223b7d7d', 'system', 0, 0, 0, 0, 0, 4, 0, 1, 7, 50, 72, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 50, 7, 'admin/config/services', 'admin/config/services', 'Web services', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33303a22546f6f6c732072656c6174656420746f207765622073657276696365732e223b7d7d', 'system', 0, 0, 1, 0, 0, 3, 0, 1, 7, 50, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 73, 38, 'admin/config/regional/settings', 'admin/config/regional/settings', 'Regional settings', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a35343a2253657474696e677320666f7220746865207369746527732064656661756c742074696d65207a6f6e6520616e6420636f756e7472792e223b7d7d', 'system', 0, 0, 0, 0, -20, 4, 0, 1, 7, 38, 73, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 38, 7, 'admin/config/regional', 'admin/config/regional', 'Regional and language', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34383a22526567696f6e616c2073657474696e67732c206c6f63616c697a6174696f6e20616e64207472616e736c6174696f6e2e223b7d7d', 'system', 0, 0, 1, 0, -5, 3, 0, 1, 7, 38, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 84, 53, 'admin/config/system/actions/configure', 'admin/config/system/actions/configure', 'Configure an advanced action', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 7, 43, 53, 84, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 36, 15, 'admin/people/permissions', 'admin/people/permissions', 'Permissions', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a36343a2244657465726d696e652061636365737320746f2066656174757265732062792073656c656374696e67207065726d697373696f6e7320666f7220726f6c65732e223b7d7d', 'system', -1, 0, 0, 0, 0, 3, 0, 1, 15, 36, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 75, 41, 'admin/appearance/settings/seven', 'admin/appearance/settings/seven', 'Seven', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 6, 41, 75, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 76, 43, 'admin/config/system/site-information', 'admin/config/system/site-information', 'Site information', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3130343a224368616e67652073697465206e616d652c20652d6d61696c20616464726573732c20736c6f67616e2c2064656661756c742066726f6e7420706167652c20616e64206e756d626572206f6620706f7374732070657220706167652c206572726f722070616765732e223b7d7d', 'system', 0, 0, 0, 0, -20, 4, 0, 1, 7, 43, 76, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 43, 7, 'admin/config/system', 'admin/config/system', 'System', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33373a2247656e6572616c2073797374656d2072656c6174656420636f6e66696775726174696f6e2e223b7d7d', 'system', 0, 0, 1, 0, -20, 3, 0, 1, 7, 43, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 77, 41, 'admin/appearance/settings/stark', 'admin/appearance/settings/stark', 'Stark', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 6, 41, 77, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 41, 6, 'admin/appearance/settings', 'admin/appearance/settings', 'Settings', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34363a22436f6e6669677572652064656661756c7420616e64207468656d652073706563696669632073657474696e67732e223b7d7d', 'system', -1, 0, 0, 0, 20, 3, 0, 1, 6, 41, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 25, 7, 'admin/config/content', 'admin/config/content', 'Content authoring', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a35333a2253657474696e67732072656c6174656420746f20666f726d617474696e6720616e6420617574686f72696e6720636f6e74656e742e223b7d7d', 'system', 0, 0, 1, 0, -15, 3, 0, 1, 7, 25, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 79, 46, 'admin/modules/uninstall/confirm', 'admin/modules/uninstall/confirm', 'Uninstall', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 13, 46, 79, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 46, 13, 'admin/modules/uninstall', 'admin/modules/uninstall', 'Uninstall', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 20, 3, 0, 1, 13, 46, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 80, 29, 'user/%/edit/account', 'user/%/edit/account', 'Account', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 3, 0, 14, 29, 80, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 29, 14, 'user/%/edit', 'user/%/edit', 'Edit', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 2, 0, 14, 29, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 82, 78, 'admin/config/content/formats/add', 'admin/config/content/formats/add', 'Add text format', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 1, 5, 0, 1, 7, 25, 78, 82, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 83, 22, 'admin/structure/block/list/bartik', 'admin/structure/block/list/bartik', 'Bartik', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 4, 0, 1, 18, 22, 83, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 26, 18, 'admin/structure/types', 'admin/structure/types', 'Content types', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a39323a224d616e61676520636f6e74656e742074797065732c20696e636c7564696e672064656661756c74207374617475732c2066726f6e7420706167652070726f6d6f74696f6e2c20636f6d6d656e742073657474696e67732c206574632e223b7d7d', 'system', 0, 0, 1, 0, 0, 3, 0, 1, 18, 26, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 88, 78, 'admin/config/content/formats/list', 'admin/config/content/formats/list', 'List', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 7, 25, 78, 88, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 78, 25, 'admin/config/content/formats', 'admin/config/content/formats', 'Text formats', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3132373a22436f6e66696775726520686f7720636f6e74656e7420696e7075742062792075736572732069732066696c74657265642c20696e636c7564696e6720616c6c6f7765642048544d4c20746167732e20416c736f20616c6c6f777320656e61626c696e67206f66206d6f64756c652d70726f76696465642066696c746572732e223b7d7d', 'system', 0, 0, 1, 0, 0, 4, 0, 1, 7, 25, 78, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 89, 53, 'admin/config/system/actions/manage', 'admin/config/system/actions/manage', 'Manage actions', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34313a224d616e6167652074686520616374696f6e7320646566696e656420666f7220796f757220736974652e223b7d7d', 'system', -1, 0, 0, 0, -2, 5, 0, 1, 7, 43, 53, 89, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 90, 52, 'admin/config/people/accounts/settings', 'admin/config/people/accounts/settings', 'Settings', '\x613a303a7b7d', 'system', -1, 0, 0, 0, -10, 5, 0, 1, 7, 35, 52, 90, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 52, 35, 'admin/config/people/accounts', 'admin/config/people/accounts', 'Account settings', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a3130393a22436f6e6669677572652064656661756c74206265686176696f72206f662075736572732c20696e636c7564696e6720726567697374726174696f6e20726571756972656d656e74732c20652d6d61696c732c206669656c64732c20616e6420757365722070696374757265732e223b7d7d', 'system', 0, 0, 0, 0, -10, 4, 0, 1, 7, 35, 52, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 59, 38, 'admin/config/regional/date-time', 'admin/config/regional/date-time', 'Date and time', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34343a22436f6e66696775726520646973706c617920666f726d61747320666f72206461746520616e642074696d652e223b7d7d', 'system', 0, 0, 0, 0, -15, 4, 0, 1, 7, 38, 59, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 94, 39, 'node/%/revisions/%/delete', 'node/%/revisions/%/delete', 'Delete earlier revision', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 3, 0, 4, 39, 94, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 95, 39, 'node/%/revisions/%/revert', 'node/%/revisions/%/revert', 'Revert to earlier revision', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 3, 0, 4, 39, 95, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 96, 39, 'node/%/revisions/%/view', 'node/%/revisions/%/view', 'Revisions', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 3, 0, 4, 39, 96, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 39, 4, 'node/%/revisions', 'node/%/revisions', 'Revisions', '\x613a303a7b7d', 'system', -1, 0, 1, 0, 2, 2, 0, 4, 39, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 97, 87, 'admin/structure/block/list/garland/add', 'admin/structure/block/list/garland/add', 'Add block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 22, 87, 97, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 87, 22, 'admin/structure/block/list/garland', 'admin/structure/block/list/garland', 'Garland', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 18, 22, 87, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 98, 91, 'admin/structure/block/list/seven/add', 'admin/structure/block/list/seven/add', 'Add block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 22, 91, 98, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 91, 22, 'admin/structure/block/list/seven', 'admin/structure/block/list/seven', 'Seven', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 18, 22, 91, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 99, 92, 'admin/structure/block/list/stark/add', 'admin/structure/block/list/stark/add', 'Add block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 22, 92, 99, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 92, 22, 'admin/structure/block/list/stark', 'admin/structure/block/list/stark', 'Stark', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 4, 0, 1, 18, 22, 92, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 100, 93, 'admin/config/regional/date-time/types/add', 'admin/config/regional/date-time/types/add', 'Add date type', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a31383a22416464206e6577206461746520747970652e223b7d7d', 'system', -1, 0, 0, 0, -10, 6, 0, 1, 7, 38, 59, 93, 100, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 101, 86, 'admin/config/regional/date-time/formats/add', 'admin/config/regional/date-time/formats/add', 'Add format', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34333a22416c6c6f7720757365727320746f20616464206164646974696f6e616c206461746520666f726d6174732e223b7d7d', 'system', -1, 0, 0, 0, -10, 6, 0, 1, 7, 38, 59, 86, 101, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 22, 18, 'admin/structure/block', 'admin/structure/block', 'Blocks', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a37393a22436f6e666967757265207768617420626c6f636b20636f6e74656e74206170706561727320696e20796f75722073697465277320736964656261727320616e64206f7468657220726567696f6e732e223b7d7d', 'system', 0, 0, 1, 0, 0, 3, 0, 1, 18, 22, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 103, 23, 'user/%/cancel/confirm/%/%', 'user/%/cancel/confirm/%/%', 'Confirm account cancellation', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 3, 0, 14, 23, 103, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('navigation', 23, 14, 'user/%/cancel', 'user/%/cancel', 'Cancel account', '\x613a303a7b7d', 'system', 0, 0, 1, 0, 0, 2, 0, 14, 23, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 104, 85, 'admin/structure/types/manage/%/delete', 'admin/structure/types/manage/%/delete', 'Delete', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 5, 0, 1, 18, 26, 85, 104, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 105, 64, 'admin/config/people/ip-blocking/delete/%', 'admin/config/people/ip-blocking/delete/%', 'Delete IP address', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 5, 0, 1, 7, 35, 64, 105, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 64, 35, 'admin/config/people/ip-blocking', 'admin/config/people/ip-blocking', 'IP address blocking', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a32383a224d616e61676520626c6f636b6564204950206164647265737365732e223b7d7d', 'system', 0, 0, 1, 0, 10, 4, 0, 1, 7, 35, 64, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 106, 53, 'admin/config/system/actions/delete/%', 'admin/config/system/actions/delete/%', 'Delete action', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a31373a2244656c65746520616e20616374696f6e2e223b7d7d', 'system', 0, 0, 0, 0, 0, 5, 0, 1, 7, 43, 53, 106, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 53, 43, 'admin/config/system/actions', 'admin/config/system/actions', 'Actions', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34313a224d616e6167652074686520616374696f6e7320646566696e656420666f7220796f757220736974652e223b7d7d', 'system', 0, 0, 1, 0, 0, 4, 0, 1, 7, 43, 53, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 107, 74, 'admin/people/permissions/roles/delete/%', 'admin/people/permissions/roles/delete/%', 'Delete role', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 5, 0, 1, 15, 36, 74, 107, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 108, 81, 'admin/config/content/formats/%/disable', 'admin/config/content/formats/%/disable', 'Disable text format', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 6, 0, 1, 7, 25, 78, 81, 108, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 81, 78, 'admin/config/content/formats/%', 'admin/config/content/formats/%', '', '\x613a303a7b7d', 'system', 0, 0, 1, 0, 0, 5, 0, 1, 7, 25, 78, 81, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 109, 85, 'admin/structure/types/manage/%/edit', 'admin/structure/types/manage/%/edit', 'Edit', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 26, 85, 109, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 85, 26, 'admin/structure/types/manage/%', 'admin/structure/types/manage/%', 'Edit content type', '\x613a303a7b7d', 'system', 0, 0, 1, 0, 0, 4, 0, 1, 18, 26, 85, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 110, 74, 'admin/people/permissions/roles/edit/%', 'admin/people/permissions/roles/edit/%', 'Edit role', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 5, 0, 1, 15, 36, 74, 110, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 74, 36, 'admin/people/permissions/roles', 'admin/people/permissions/roles', 'Roles', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a33303a224c6973742c20656469742c206f7220616464207573657220726f6c65732e223b7d7d', 'system', -1, 0, 1, 0, -5, 4, 0, 1, 15, 36, 74, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 111, 102, 'admin/structure/block/manage/%/%/configure', 'admin/structure/block/manage/%/%/configure', 'Configure block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 22, 102, 111, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 112, 102, 'admin/structure/block/manage/%/%/delete', 'admin/structure/block/manage/%/%/delete', 'Delete block', '\x613a303a7b7d', 'system', -1, 0, 0, 0, 0, 5, 0, 1, 18, 22, 102, 112, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 102, 22, 'admin/structure/block/manage/%/%', 'admin/structure/block/manage/%/%', 'Configure block', '\x613a303a7b7d', 'system', 0, 0, 0, 0, 0, 4, 0, 1, 18, 22, 102, 0, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 113, 86, 'admin/config/regional/date-time/formats/%/delete', 'admin/config/regional/date-time/formats/%/delete', 'Delete date format', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34373a22416c6c6f7720757365727320746f2064656c657465206120636f6e66696775726564206461746520666f726d61742e223b7d7d', 'system', 0, 0, 0, 0, 0, 6, 0, 1, 7, 38, 59, 86, 113, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 114, 93, 'admin/config/regional/date-time/types/%/delete', 'admin/config/regional/date-time/types/%/delete', 'Delete date type', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34353a22416c6c6f7720757365727320746f2064656c657465206120636f6e66696775726564206461746520747970652e223b7d7d', 'system', 0, 0, 0, 0, 0, 6, 0, 1, 7, 38, 59, 93, 114, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 93, 59, 'admin/config/regional/date-time/types', 'admin/config/regional/date-time/types', 'Types', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34343a22436f6e66696775726520646973706c617920666f726d61747320666f72206461746520616e642074696d652e223b7d7d', 'system', -1, 0, 1, 0, -10, 5, 0, 1, 7, 38, 59, 93, 0, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 115, 86, 'admin/config/regional/date-time/formats/%/edit', 'admin/config/regional/date-time/formats/%/edit', 'Edit date format', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a34353a22416c6c6f7720757365727320746f2065646974206120636f6e66696775726564206461746520666f726d61742e223b7d7d', 'system', 0, 0, 0, 0, 0, 6, 0, 1, 7, 38, 59, 86, 115, 0, 0, 0, 0);
INSERT INTO public.menu_links VALUES ('management', 86, 59, 'admin/config/regional/date-time/formats', 'admin/config/regional/date-time/formats', 'Formats', '\x613a313a7b733a31303a2261747472696275746573223b613a313a7b733a353a227469746c65223b733a35313a22436f6e66696775726520646973706c617920666f726d617420737472696e677320666f72206461746520616e642074696d652e223b7d7d', 'system', -1, 0, 1, 0, -9, 5, 0, 1, 7, 38, 59, 86, 0, 0, 0, 0, 0);


--
-- TOC entry 4049 (class 0 OID 16587)
-- Dependencies: 234
-- Data for Name: menu_router; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.menu_router VALUES ('admin/tasks', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 3, 2, 1, 'admin', 'admin', 'Tasks', 't', '', '', 'a:0:{}', 140, '', '', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('user/login', '\x', '\x', 'user_is_anonymous', '\x613a303a7b7d', 'user_page', '\x613a303a7b7d', '', 3, 2, 1, 'user', 'user', 'Log in', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('node/add', '\x', '\x', '_node_add_access', '\x613a303a7b7d', 'node_add_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'node/add', 'Add content', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/compact', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_compact_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'admin/compact', 'Compact mode', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('filter/tips', '\x', '\x', '1', '\x613a303a7b7d', 'filter_tips_long', '\x613a303a7b7d', '', 3, 2, 0, '', 'filter/tips', 'Compose tips', 't', '', '', 'a:0:{}', 20, '', '', 0, 'modules/filter/filter.pages.inc');
INSERT INTO public.menu_router VALUES ('user/register', '\x', '\x', 'user_register_access', '\x613a303a7b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31383a22757365725f72656769737465725f666f726d223b7d', '', 3, 2, 1, 'user', 'user', 'Create new account', 't', '', '', 'a:0:{}', 132, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('system/files', '\x', '\x', '1', '\x613a303a7b7d', 'file_download', '\x613a313a7b693a303b733a373a2270726976617465223b7d', '', 3, 2, 0, '', 'system/files', 'File download', 't', '', '', 'a:0:{}', 0, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('admin/index', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_index', '\x613a303a7b7d', '', 3, 2, 1, 'admin', 'admin', 'Index', 't', '', '', 'a:0:{}', 132, '', '', -18, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('system/temporary', '\x', '\x', '1', '\x613a303a7b7d', 'file_download', '\x613a313a7b693a303b733a393a2274656d706f72617279223b7d', '', 3, 2, 0, '', 'system/temporary', 'Temporary files', 't', '', '', 'a:0:{}', 0, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('system/timezone', '\x', '\x', '1', '\x613a303a7b7d', 'system_timezone', '\x613a303a7b7d', '', 3, 2, 0, '', 'system/timezone', 'Time zone', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_config_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'admin/config', 'Configuration', 't', '', '', 'a:0:{}', 6, 'Administer settings.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('user/logout', '\x', '\x', 'user_is_logged_in', '\x613a303a7b7d', 'user_logout', '\x613a303a7b7d', '', 3, 2, 0, '', 'user/logout', 'Log out', 't', '', '', 'a:0:{}', 6, '', '', 10, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('user/password', '\x', '\x', '1', '\x613a303a7b7d', 'drupal_get_form', '\x613a313a7b693a303b733a393a22757365725f70617373223b7d', '', 3, 2, 1, 'user', 'user', 'Request new password', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('user/autocomplete', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32303a2261636365737320757365722070726f66696c6573223b7d', 'user_autocomplete', '\x613a303a7b7d', '', 3, 2, 0, '', 'user/autocomplete', 'User autocomplete', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'system_themes_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'admin/appearance', 'Appearance', 't', '', '', 'a:0:{}', 6, 'Select and configure your themes.', 'left', -6, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/content', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32333a2261636365737320636f6e74656e74206f76657276696577223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31383a226e6f64655f61646d696e5f636f6e74656e74223b7d', '', 3, 2, 0, '', 'admin/content', 'Content', 't', '', '', 'a:0:{}', 6, 'Find and manage content.', '', -10, 'modules/node/node.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/modules', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e6973746572206d6f64756c6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31343a2273797374656d5f6d6f64756c6573223b7d', '', 3, 2, 0, '', 'admin/modules', 'Modules', 't', '', '', 'a:0:{}', 6, 'Extend site functionality.', '', -2, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31393a226163636573732073697465207265706f727473223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'admin/reports', 'Reports', 't', '', '', 'a:0:{}', 6, 'View reports, updates, and errors.', 'left', 5, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 3, 2, 0, '', 'admin/structure', 'Structure', 't', '', '', 'a:0:{}', 6, 'Administer blocks, content types, menus, etc.', 'right', -8, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%', '\x613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d', '\x', 'node_access', '\x613a323a7b693a303b733a343a2276696577223b693a313b693a313b7d', 'node_page_view', '\x613a313a7b693a303b693a313b7d', '', 2, 2, 0, '', 'node/%', '', 'node_page_title', 'a:1:{i:0;i:1;}', '', 'a:0:{}', 6, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('system/ajax', '\x', '\x', '1', '\x613a303a7b7d', 'ajax_form_callback', '\x613a303a7b7d', 'ajax_deliver', 3, 2, 0, '', 'system/ajax', 'AHAH callback', 't', '', 'ajax_base_page_theme', 'a:0:{}', 0, '', '', 0, 'includes/form.inc');
INSERT INTO public.menu_router VALUES ('admin/people', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31363a2261646d696e6973746572207573657273223b7d', 'user_admin', '\x613a313a7b693a303b733a343a226c697374223b7d', '', 3, 2, 0, '', 'admin/people', 'People', 't', '', '', 'a:0:{}', 6, 'Manage user accounts, roles, and permissions.', 'left', -4, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('user/%', '\x613a313a7b693a313b733a393a22757365725f6c6f6164223b7d', '\x', 'user_view_access', '\x613a313a7b693a303b693a313b7d', 'user_view_page', '\x613a313a7b693a303b693a313b7d', '', 2, 2, 0, '', 'user/%', 'My account', 'user_page_title', 'a:1:{i:0;i:1;}', '', 'a:0:{}', 6, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('admin/content/node', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32333a2261636365737320636f6e74656e74206f76657276696577223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31383a226e6f64655f61646d696e5f636f6e74656e74223b7d', '', 7, 3, 1, 'admin/content', 'admin/content', 'Content', 't', '', '', 'a:0:{}', 140, '', '', -10, 'modules/node/node.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/modules/list', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e6973746572206d6f64756c6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31343a2273797374656d5f6d6f64756c6573223b7d', '', 7, 3, 1, 'admin/modules', 'admin/modules', 'List', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%/view', '\x613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d', '\x', 'node_access', '\x613a323a7b693a303b733a343a2276696577223b693a313b693a313b7d', 'node_page_view', '\x613a313a7b693a303b693a313b7d', '', 5, 3, 1, 'node/%', 'node/%', 'View', 't', '', '', 'a:0:{}', 140, '', '', -10, '');
INSERT INTO public.menu_router VALUES ('user/%/view', '\x613a313a7b693a313b733a393a22757365725f6c6f6164223b7d', '\x', 'user_view_access', '\x613a313a7b693a303b693a313b7d', 'user_view_page', '\x613a313a7b693a303b693a313b7d', '', 5, 3, 1, 'user/%', 'user/%', 'View', 't', '', '', 'a:0:{}', 140, '', '', -10, '');
INSERT INTO public.menu_router VALUES ('admin/appearance/list', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'system_themes_page', '\x613a303a7b7d', '', 7, 3, 1, 'admin/appearance', 'admin/appearance', 'List', 't', '', '', 'a:0:{}', 140, 'Select and configure your theme', '', -1, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/disable', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'system_theme_disable', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/appearance/disable', 'Disable theme', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/enable', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'system_theme_enable', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/appearance/enable', 'Enable theme', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/people', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31363a2261646d696e6973746572207573657273223b7d', 'user_admin', '\x613a313a7b693a303b733a343a226c697374223b7d', '', 7, 3, 1, 'admin/people', 'admin/people', 'List', 't', '', '', 'a:0:{}', 140, 'Find and manage people interacting with your site.', '', -10, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/default', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'system_theme_default', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/appearance/default', 'Set default theme', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/modules/uninstall', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e6973746572206d6f64756c6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32343a2273797374656d5f6d6f64756c65735f756e696e7374616c6c223b7d', '', 7, 3, 1, 'admin/modules', 'admin/modules', 'Uninstall', 't', '', '', 'a:0:{}', 132, '', '', 20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/create', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31363a2261646d696e6973746572207573657273223b7d', 'user_admin', '\x613a313a7b693a303b733a363a22637265617465223b7d', '', 7, 3, 1, 'admin/people', 'admin/people', 'Add user', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'node_overview_types', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/structure/types', 'Content types', 't', '', '', 'a:0:{}', 6, 'Manage content types, including default status, front page promotion, comment settings, etc.', '', 0, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/dblog', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31393a226163636573732073697465207265706f727473223b7d', 'dblog_overview', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/reports/dblog', 'Recent log messages', 't', '', '', 'a:0:{}', 6, 'View events that have recently been logged.', '', -1, 'modules/dblog/dblog.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/status', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'system_status', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/reports/status', 'Status report', 't', '', '', 'a:0:{}', 6, 'Get a status report about your site''s operation and any detected problems.', '', -60, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'block_admin_display', '\x613a313a7b693a303b733a363a2262617274696b223b7d', '', 7, 3, 0, '', 'admin/structure/block', 'Blocks', 't', '', '', 'a:0:{}', 6, 'Configure what block content appears in your site''s sidebars and other regions.', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('user/%/cancel', '\x613a313a7b693a313b733a393a22757365725f6c6f6164223b7d', '\x', 'user_cancel_access', '\x613a313a7b693a303b693a313b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32343a22757365725f63616e63656c5f636f6e6669726d5f666f726d223b693a313b693a313b7d', '', 5, 3, 0, '', 'user/%/cancel', 'Cancel account', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('filter/tips/%', '\x613a313a7b693a323b733a31383a2266696c7465725f666f726d61745f6c6f6164223b7d', '\x', 'filter_access', '\x613a313a7b693a303b693a323b7d', 'filter_tips_long', '\x613a313a7b693a303b693a323b7d', '', 6, 3, 0, '', 'filter/tips/%', 'Compose tips', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/filter/filter.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/content', 'Content authoring', 't', '', '', 'a:0:{}', 6, 'Settings related to formatting and authoring content.', 'left', -15, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/development', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/development', 'Development', 't', '', '', 'a:0:{}', 6, 'Development tools.', 'right', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('user/%/edit', '\x613a313a7b693a313b733a393a22757365725f6c6f6164223b7d', '\x', 'user_edit_access', '\x613a313a7b693a303b693a313b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31373a22757365725f70726f66696c655f666f726d223b693a313b693a313b7d', '', 5, 3, 1, 'user/%', 'user/%', 'Edit', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/media', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/media', 'Media', 't', '', '', 'a:0:{}', 6, 'Media tools.', 'left', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types/list', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'node_overview_types', '\x613a303a7b7d', '', 15, 4, 1, 'admin/structure/types', 'admin/structure/types', 'List', 't', '', '', 'a:0:{}', 140, '', '', -10, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content/formats/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e69737465722066696c74657273223b7d', 'filter_admin_format_page', '\x613a303a7b7d', '', 31, 5, 1, 'admin/config/content/formats', 'admin/config/content/formats', 'Add text format', 't', '', '', 'a:0:{}', 388, '', '', 1, 'modules/filter/filter.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/permissions', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32323a2261646d696e6973746572207065726d697373696f6e73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32323a22757365725f61646d696e5f7065726d697373696f6e73223b7d', '', 7, 3, 1, 'admin/people', 'admin/people', 'Permissions', 't', '', '', 'a:0:{}', 132, 'Determine access to features by selecting permissions for roles.', '', 0, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/regional', 'Regional and language', 't', '', '', 'a:0:{}', 6, 'Regional settings, localization and translation.', 'left', -5, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%/revisions', '\x613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d', '\x', '_node_revision_access', '\x613a313a7b693a303b693a313b7d', 'node_revision_overview', '\x613a313a7b693a303b693a313b7d', '', 5, 3, 1, 'node/%', 'node/%', 'Revisions', 't', '', '', 'a:0:{}', 132, '', '', 2, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/search', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/search', 'Search and metadata', 't', '', '', 'a:0:{}', 6, 'Local site search, metadata and SEO.', 'left', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b7d', '', 7, 3, 1, 'admin/appearance', 'admin/appearance', 'Settings', 't', '', '', 'a:0:{}', 132, 'Configure default and theme specific settings.', '', 20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/system', 'System', 't', '', '', 'a:0:{}', 6, 'General system related configuration.', 'right', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/access-denied', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31393a226163636573732073697465207265706f727473223b7d', 'dblog_top', '\x613a313a7b693a303b733a31333a226163636573732064656e696564223b7d', '', 7, 3, 0, '', 'admin/reports/access-denied', 'Top ''access denied'' errors', 't', '', '', 'a:0:{}', 6, 'View ''access denied'' errors (403s).', '', 0, 'modules/dblog/dblog.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/page-not-found', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31393a226163636573732073697465207265706f727473223b7d', 'dblog_top', '\x613a313a7b693a303b733a31343a2270616765206e6f7420666f756e64223b7d', '', 7, 3, 0, '', 'admin/reports/page-not-found', 'Top ''page not found'' errors', 't', '', '', 'a:0:{}', 6, 'View ''page not found'' errors (404s).', '', 0, 'modules/dblog/dblog.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/user-interface', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/user-interface', 'User interface', 't', '', '', 'a:0:{}', 6, 'Tools that enhance the user interface.', 'right', -15, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/services', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/services', 'Web services', 't', '', '', 'a:0:{}', 6, 'Tools related to web services.', 'right', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/workflow', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/workflow', 'Workflow', 't', '', '', 'a:0:{}', 6, 'Content workflow, editorial workflow tools.', 'right', 5, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%/delete', '\x613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d', '\x', 'node_access', '\x613a323a7b693a303b733a363a2264656c657465223b693a313b693a313b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31393a226e6f64655f64656c6574655f636f6e6669726d223b693a313b693a313b7d', '', 5, 3, 2, 'node/%', 'node/%', 'Delete', 't', '', '', 'a:0:{}', 132, '', '', 1, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('node/%/edit', '\x613a313a7b693a313b733a393a226e6f64655f6c6f6164223b7d', '\x', 'node_access', '\x613a323a7b693a303b733a363a22757064617465223b693a313b693a313b7d', 'node_page_edit', '\x613a313a7b693a303b693a313b7d', '', 5, 3, 3, 'node/%', 'node/%', 'Edit', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/people', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 7, 3, 0, '', 'admin/config/people', 'People', 't', '', '', 'a:0:{}', 6, 'Configure user accounts.', 'left', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings/global', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e6973746572207468656d6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b7d', '', 15, 4, 1, 'admin/appearance/settings', 'admin/appearance', 'Global settings', 't', '', '', 'a:0:{}', 140, '', '', -1, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31343a2261636365737320636f6e74656e74223b7d', 'node_page_default', '\x613a303a7b7d', '', 1, 1, 0, '', 'node', '', 't', '', '', 'a:0:{}', 0, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('rss.xml', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31343a2261636365737320636f6e74656e74223b7d', 'node_feed', '\x613a323a7b693a303b623a303b693a313b613a303a7b7d7d', '', 1, 1, 0, '', 'rss.xml', 'RSS feed', 't', '', '', 'a:0:{}', 0, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('admin', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'system_admin_menu_block_page', '\x613a303a7b7d', '', 1, 1, 0, '', 'admin', 'Administration', 't', '', '', 'a:0:{}', 6, '', '', 9, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('batch', '\x', '\x', '1', '\x613a303a7b7d', 'system_batch_page', '\x613a303a7b7d', '', 1, 1, 0, '', 'batch', '', 't', '', '_system_batch_theme', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('user', '\x', '\x', '1', '\x613a303a7b7d', 'user_page', '\x613a303a7b7d', '', 1, 1, 0, '', 'user', 'User account', 'user_menu_title', '', '', 'a:0:{}', 6, '', '', -10, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('user/%/edit/account', '\x613a313a7b693a313b613a313a7b733a31383a22757365725f63617465676f72795f6c6f6164223b613a323a7b693a303b733a343a22256d6170223b693a313b733a363a2225696e646578223b7d7d7d', '\x', 'user_edit_access', '\x613a313a7b693a303b693a313b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31373a22757365725f70726f66696c655f666f726d223b693a313b693a313b7d', '', 11, 4, 1, 'user/%/edit', 'user/%', 'Account', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/modules/list/confirm', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e6973746572206d6f64756c6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31343a2273797374656d5f6d6f64756c6573223b7d', '', 15, 4, 0, '', 'admin/modules/list/confirm', 'List', 't', '', '', 'a:0:{}', 4, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/permissions/list', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32323a2261646d696e6973746572207065726d697373696f6e73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32323a22757365725f61646d696e5f7065726d697373696f6e73223b7d', '', 15, 4, 1, 'admin/people/permissions', 'admin/people', 'Permissions', 't', '', '', 'a:0:{}', 140, 'Determine access to features by selecting permissions for roles.', '', -8, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/modules/uninstall/confirm', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e6973746572206d6f64756c6573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32343a2273797374656d5f6d6f64756c65735f756e696e7374616c6c223b7d', '', 15, 4, 0, '', 'admin/modules/uninstall/confirm', 'Uninstall', 't', '', '', 'a:0:{}', 4, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/status/php', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'system_php', '\x613a303a7b7d', '', 15, 4, 0, '', 'admin/reports/status/php', 'PHP', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/status/run-cron', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'system_run_cron', '\x613a303a7b7d', '', 15, 4, 0, '', 'admin/reports/status/run-cron', 'Run cron', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/actions', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e697374657220616374696f6e73223b7d', 'system_actions_manage', '\x613a303a7b7d', '', 15, 4, 0, '', 'admin/config/system/actions', 'Actions', 't', '', '', 'a:0:{}', 6, 'Manage the actions defined for your site.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32303a22626c6f636b5f6164645f626c6f636b5f666f726d223b7d', '', 15, 4, 1, 'admin/structure/block', 'admin/structure/block', 'Add block', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31343a226e6f64655f747970655f666f726d223b7d', '', 15, 4, 1, 'admin/structure/types', 'admin/structure/types', 'Add content type', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings/bartik', '\x', '\x', '_system_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32353a227468656d65732f62617274696b2f62617274696b2e696e666f223b733a343a226e616d65223b733a363a2262617274696b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a363a2242617274696b223b733a31313a226465736372697074696f6e223b733a34383a224120666c657869626c652c207265636f6c6f7261626c65207468656d652077697468206d616e7920726567696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a373a22726567696f6e73223b613a31373a7b733a363a22686561646572223b733a363a22486561646572223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a383a226665617475726564223b733a383a224665617475726564223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a31333a22736964656261725f6669727374223b733a31333a2253696465626172206669727374223b733a31343a22736964656261725f7365636f6e64223b733a31343a2253696465626172207365636f6e64223b733a31343a2274726970747963685f6669727374223b733a31343a225472697074796368206669727374223b733a31353a2274726970747963685f6d6964646c65223b733a31353a225472697074796368206d6964646c65223b733a31333a2274726970747963685f6c617374223b733a31333a225472697074796368206c617374223b733a31383a22666f6f7465725f6669727374636f6c756d6e223b733a31393a22466f6f74657220666972737420636f6c756d6e223b733a31393a22666f6f7465725f7365636f6e64636f6c756d6e223b733a32303a22466f6f746572207365636f6e6420636f6c756d6e223b733a31383a22666f6f7465725f7468697264636f6c756d6e223b733a31393a22466f6f74657220746869726420636f6c756d6e223b733a31393a22666f6f7465725f666f75727468636f6c756d6e223b733a32303a22466f6f74657220666f7572746820636f6c756d6e223b733a363a22666f6f746572223b733a363a22466f6f746572223b7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2230223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32383a227468656d65732f62617274696b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'drupal_get_form', '\x613a323a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b693a313b733a363a2262617274696b223b7d', '', 15, 4, 1, 'admin/appearance/settings', 'admin/appearance', 'Bartik', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/event/%', '\x613a313a7b693a333b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31393a226163636573732073697465207265706f727473223b7d', 'dblog_event', '\x613a313a7b693a303b693a333b7d', '', 14, 4, 0, '', 'admin/reports/event/%', 'Details', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/dblog/dblog.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings/garland', '\x', '\x', '_system_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32373a227468656d65732f6761726c616e642f6761726c616e642e696e666f223b733a343a226e616d65223b733a373a226761726c616e64223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a373a224761726c616e64223b733a31313a226465736372697074696f6e223b733a3131313a2241206d756c74692d636f6c756d6e207468656d652077686963682063616e20626520636f6e6669677572656420746f206d6f6469667920636f6c6f727320616e6420737769746368206265747765656e20666978656420616e6420666c756964207769647468206c61796f7574732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a31333a226761726c616e645f7769647468223b733a353a22666c756964223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32393a227468656d65732f6761726c616e642f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'drupal_get_form', '\x613a323a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b693a313b733a373a226761726c616e64223b7d', '', 15, 4, 1, 'admin/appearance/settings', 'admin/appearance', 'Garland', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/people/ip-blocking', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a22626c6f636b20495020616464726573736573223b7d', 'system_ip_blocking', '\x613a303a7b7d', '', 15, 4, 0, '', 'admin/config/people/ip-blocking', 'IP address blocking', 't', '', '', 'a:0:{}', 6, 'Manage blocked IP addresses.', '', 10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/reports/status/rebuild', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32373a226163636573732061646d696e697374726174696f6e207061676573223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a33303a226e6f64655f636f6e6669677572655f72656275696c645f636f6e6669726d223b7d', '', 15, 4, 0, '', 'admin/reports/status/rebuild', 'Rebuild permissions', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/node/node.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings/seven', '\x', '\x', '_system_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f736576656e2f736576656e2e696e666f223b733a343a226e616d65223b733a353a22736576656e223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a353a22536576656e223b733a31313a226465736372697074696f6e223b733a36353a22412073696d706c65206f6e652d636f6c756d6e2c207461626c656c6573732c20666c7569642077696474682061646d696e697374726174696f6e207468656d652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2231223b7d733a373a22726567696f6e73223b613a353a7b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31333a22736964656261725f6669727374223b733a31333a2246697273742073696465626172223b7d733a31343a22726567696f6e735f68696464656e223b613a333a7b693a303b733a31333a22736964656261725f6669727374223b693a313b733a383a22706167655f746f70223b693a323b733a31313a22706167655f626f74746f6d223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f736576656e2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'drupal_get_form', '\x613a323a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b693a313b733a353a22736576656e223b7d', '', 15, 4, 1, 'admin/appearance/settings', 'admin/appearance', 'Seven', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/appearance/settings/stark', '\x', '\x', '_system_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f737461726b2f737461726b2e696e666f223b733a343a226e616d65223b733a353a22737461726b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31363a7b733a343a226e616d65223b733a353a22537461726b223b733a31313a226465736372697074696f6e223b733a3230383a2254686973207468656d652064656d6f6e737472617465732044727570616c27732064656661756c742048544d4c206d61726b757020616e6420435353207374796c65732e20546f206c6561726e20686f7720746f206275696c6420796f7572206f776e207468656d6520616e64206f766572726964652044727570616c27732064656661756c7420636f64652c2073656520746865203c6120687265663d22687474703a2f2f64727570616c2e6f72672f7468656d652d6775696465223e5468656d696e672047756964653c2f613e2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f737461726b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'drupal_get_form', '\x613a323a7b693a303b733a32313a2273797374656d5f7468656d655f73657474696e6773223b693a313b733a353a22737461726b223b7d', '', 15, 4, 1, 'admin/appearance/settings', 'admin/appearance', 'Stark', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/people/accounts', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31363a2261646d696e6973746572207573657273223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31393a22757365725f61646d696e5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/people/accounts', 'Account settings', 't', '', '', 'a:0:{}', 6, 'Configure default behavior of users, including registration requirements, e-mails, fields, and user pictures.', '', -10, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/search/clean-urls', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32353a2273797374656d5f636c65616e5f75726c5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/search/clean-urls', 'Clean URLs', 't', '', '', 'a:0:{}', 6, 'Enable or disable clean URLs for your site.', '', 5, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/cron', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32303a2273797374656d5f63726f6e5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/system/cron', 'Cron', 't', '', '', 'a:0:{}', 6, 'Manage automatic site maintenance tasks.', '', 20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32353a2273797374656d5f646174655f74696d655f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/regional/date-time', 'Date and time', 't', '', '', 'a:0:{}', 6, 'Configure display formats for date and time.', '', -15, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/media/file-system', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32373a2273797374656d5f66696c655f73797374656d5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/media/file-system', 'File system', 't', '', '', 'a:0:{}', 6, 'Tell Drupal where to store uploaded files and how they are accessed.', '', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/media/image-toolkit', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32393a2273797374656d5f696d6167655f746f6f6c6b69745f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/media/image-toolkit', 'Image toolkit', 't', '', '', 'a:0:{}', 6, 'Choose which image toolkit to use if you have installed optional toolkits.', '', 20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/development/logging', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32333a2273797374656d5f6c6f6767696e675f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/development/logging', 'Logging and errors', 't', '', '', 'a:0:{}', 6, 'Settings for logging and alerts modules. Various modules can route Drupal''s system events to different destinations, such as syslog, database, email, etc.', '', -15, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/development/maintenance', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32383a2273797374656d5f736974655f6d61696e74656e616e63655f6d6f6465223b7d', '', 15, 4, 0, '', 'admin/config/development/maintenance', 'Maintenance mode', 't', '', '', 'a:0:{}', 6, 'Take the site offline for maintenance or bring it back online.', '', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/development/performance', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32373a2273797374656d5f706572666f726d616e63655f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/development/performance', 'Performance', 't', '', '', 'a:0:{}', 6, 'Enable or disable page caching for anonymous users and set CSS and JS bandwidth optimization options.', '', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/services/rss-publishing', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32353a2273797374656d5f7273735f66656564735f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/services/rss-publishing', 'RSS publishing', 't', '', '', 'a:0:{}', 6, 'Configure the site description, the number of items per feed and whether feeds should be titles/teasers/full-text.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/settings', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32343a2273797374656d5f726567696f6e616c5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/regional/settings', 'Regional settings', 't', '', '', 'a:0:{}', 6, 'Settings for the site''s default time zone and country.', '', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/permissions/roles', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32323a2261646d696e6973746572207065726d697373696f6e73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31363a22757365725f61646d696e5f726f6c6573223b7d', '', 15, 4, 1, 'admin/people/permissions', 'admin/people', 'Roles', 't', '', '', 'a:0:{}', 132, 'List, edit, or add user roles.', '', -5, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/site-information', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a33323a2273797374656d5f736974655f696e666f726d6174696f6e5f73657474696e6773223b7d', '', 15, 4, 0, '', 'admin/config/system/site-information', 'Site information', 't', '', '', 'a:0:{}', 6, 'Change site name, e-mail address, slogan, default front page, and number of posts per page, error pages.', '', -20, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content/formats', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e69737465722066696c74657273223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32313a2266696c7465725f61646d696e5f6f76657276696577223b7d', '', 15, 4, 0, '', 'admin/config/content/formats', 'Text formats', 't', '', '', 'a:0:{}', 6, 'Configure how content input by users is filtered, including allowed HTML tags. Also allows enabling of module-provided filters.', '', 0, 'modules/filter/filter.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content/formats/list', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e69737465722066696c74657273223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32313a2266696c7465725f61646d696e5f6f76657276696577223b7d', '', 31, 5, 1, 'admin/config/content/formats', 'admin/config/content/formats', 'List', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/filter/filter.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/people/accounts/settings', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31363a2261646d696e6973746572207573657273223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a31393a22757365725f61646d696e5f73657474696e6773223b7d', '', 31, 5, 1, 'admin/config/people/accounts', 'admin/config/people/accounts', 'Settings', 't', '', '', 'a:0:{}', 140, '', '', -10, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/actions/manage', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e697374657220616374696f6e73223b7d', 'system_actions_manage', '\x613a303a7b7d', '', 31, 5, 1, 'admin/config/system/actions', 'admin/config/system/actions', 'Manage actions', 't', '', '', 'a:0:{}', 140, 'Manage the actions defined for your site.', '', -2, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/actions/orphan', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e697374657220616374696f6e73223b7d', 'system_actions_remove_orphans', '\x613a303a7b7d', '', 31, 5, 0, '', 'admin/config/system/actions/orphan', 'Remove orphans', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/bartik', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32353a227468656d65732f62617274696b2f62617274696b2e696e666f223b733a343a226e616d65223b733a363a2262617274696b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a363a2242617274696b223b733a31313a226465736372697074696f6e223b733a34383a224120666c657869626c652c207265636f6c6f7261626c65207468656d652077697468206d616e7920726567696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a373a22726567696f6e73223b613a31373a7b733a363a22686561646572223b733a363a22486561646572223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a383a226665617475726564223b733a383a224665617475726564223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a31333a22736964656261725f6669727374223b733a31333a2253696465626172206669727374223b733a31343a22736964656261725f7365636f6e64223b733a31343a2253696465626172207365636f6e64223b733a31343a2274726970747963685f6669727374223b733a31343a225472697074796368206669727374223b733a31353a2274726970747963685f6d6964646c65223b733a31353a225472697074796368206d6964646c65223b733a31333a2274726970747963685f6c617374223b733a31333a225472697074796368206c617374223b733a31383a22666f6f7465725f6669727374636f6c756d6e223b733a31393a22466f6f74657220666972737420636f6c756d6e223b733a31393a22666f6f7465725f7365636f6e64636f6c756d6e223b733a32303a22466f6f746572207365636f6e6420636f6c756d6e223b733a31383a22666f6f7465725f7468697264636f6c756d6e223b733a31393a22466f6f74657220746869726420636f6c756d6e223b733a31393a22666f6f7465725f666f75727468636f6c756d6e223b733a32303a22466f6f74657220666f7572746820636f6c756d6e223b733a363a22666f6f746572223b733a363a22466f6f746572223b7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2230223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32383a227468656d65732f62617274696b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_display', '\x613a313a7b693a303b733a363a2262617274696b223b7d', '', 31, 5, 1, 'admin/structure/block', 'admin/structure/block', 'Bartik', 't', '', '', 'a:0:{}', 140, '', '', -10, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/search/clean-urls/check', '\x', '\x', '1', '\x613a303a7b7d', 'drupal_json_output', '\x613a313a7b693a303b613a313a7b733a363a22737461747573223b623a313b7d7d', '', 31, 5, 0, '', 'admin/config/search/clean-urls/check', 'Clean URL check', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/actions/configure', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e697374657220616374696f6e73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32343a2273797374656d5f616374696f6e735f636f6e666967757265223b7d', '', 31, 5, 0, '', 'admin/config/system/actions/configure', 'Configure an advanced action', 't', '', '', 'a:0:{}', 4, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/formats', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'system_date_time_formats', '\x613a303a7b7d', '', 31, 5, 1, 'admin/config/regional/date-time', 'admin/config/regional/date-time', 'Formats', 't', '', '', 'a:0:{}', 132, 'Configure display format strings for date and time.', '', -9, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/garland', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32373a227468656d65732f6761726c616e642f6761726c616e642e696e666f223b733a343a226e616d65223b733a373a226761726c616e64223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a373a224761726c616e64223b733a31313a226465736372697074696f6e223b733a3131313a2241206d756c74692d636f6c756d6e207468656d652077686963682063616e20626520636f6e6669677572656420746f206d6f6469667920636f6c6f727320616e6420737769746368206265747765656e20666978656420616e6420666c756964207769647468206c61796f7574732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a31333a226761726c616e645f7769647468223b733a353a22666c756964223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32393a227468656d65732f6761726c616e642f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_display', '\x613a313a7b693a303b733a373a226761726c616e64223b7d', '', 31, 5, 1, 'admin/structure/block', 'admin/structure/block', 'Garland', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('user/reset/%/%/%', '\x613a333a7b693a323b4e3b693a333b4e3b693a343b4e3b7d', '\x', '1', '\x613a303a7b7d', 'drupal_get_form', '\x613a343a7b693a303b733a31353a22757365725f706173735f7265736574223b693a313b693a323b693a323b693a333b693a333b693a343b7d', '', 24, 5, 0, '', 'user/reset/%/%/%', 'Reset password', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/seven', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f736576656e2f736576656e2e696e666f223b733a343a226e616d65223b733a353a22736576656e223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a353a22536576656e223b733a31313a226465736372697074696f6e223b733a36353a22412073696d706c65206f6e652d636f6c756d6e2c207461626c656c6573732c20666c7569642077696474682061646d696e697374726174696f6e207468656d652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2231223b7d733a373a22726567696f6e73223b613a353a7b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31333a22736964656261725f6669727374223b733a31333a2246697273742073696465626172223b7d733a31343a22726567696f6e735f68696464656e223b613a333a7b693a303b733a31333a22736964656261725f6669727374223b693a313b733a383a22706167655f746f70223b693a323b733a31313a22706167655f626f74746f6d223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f736576656e2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_display', '\x613a313a7b693a303b733a353a22736576656e223b7d', '', 31, 5, 1, 'admin/structure/block', 'admin/structure/block', 'Seven', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/demo/seven', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f736576656e2f736576656e2e696e666f223b733a343a226e616d65223b733a353a22736576656e223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a353a22536576656e223b733a31313a226465736372697074696f6e223b733a36353a22412073696d706c65206f6e652d636f6c756d6e2c207461626c656c6573732c20666c7569642077696474682061646d696e697374726174696f6e207468656d652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2231223b7d733a373a22726567696f6e73223b613a353a7b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31333a22736964656261725f6669727374223b733a31333a2246697273742073696465626172223b7d733a31343a22726567696f6e735f68696464656e223b613a333a7b693a303b733a31333a22736964656261725f6669727374223b693a313b733a383a22706167655f746f70223b693a323b733a31313a22706167655f626f74746f6d223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f736576656e2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_demo', '\x613a313a7b693a303b733a353a22736576656e223b7d', '', 31, 5, 0, '', 'admin/structure/block/demo/seven', 'Seven', 't', '', '_block_custom_theme', 'a:1:{i:0;s:5:"seven";}', 0, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/stark', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f737461726b2f737461726b2e696e666f223b733a343a226e616d65223b733a353a22737461726b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31363a7b733a343a226e616d65223b733a353a22537461726b223b733a31313a226465736372697074696f6e223b733a3230383a2254686973207468656d652064656d6f6e737472617465732044727570616c27732064656661756c742048544d4c206d61726b757020616e6420435353207374796c65732e20546f206c6561726e20686f7720746f206275696c6420796f7572206f776e207468656d6520616e64206f766572726964652044727570616c27732064656661756c7420636f64652c2073656520746865203c6120687265663d22687474703a2f2f64727570616c2e6f72672f7468656d652d6775696465223e5468656d696e672047756964653c2f613e2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f737461726b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_display', '\x613a313a7b693a303b733a353a22737461726b223b7d', '', 31, 5, 1, 'admin/structure/block', 'admin/structure/block', 'Stark', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%/revisions/%/view', '\x613a323a7b693a313b613a313a7b733a393a226e6f64655f6c6f6164223b613a313a7b693a303b693a333b7d7d693a333b4e3b7d', '\x', '_node_revision_access', '\x613a313a7b693a303b693a313b7d', 'node_show', '\x613a323a7b693a303b693a313b693a313b623a313b7d', '', 21, 5, 0, '', 'node/%/revisions/%/view', 'Revisions', 't', '', '', 'a:0:{}', 6, '', '', 0, '');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/types', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32353a2273797374656d5f646174655f74696d655f73657474696e6773223b7d', '', 31, 5, 1, 'admin/config/regional/date-time', 'admin/config/regional/date-time', 'Types', 't', '', '', 'a:0:{}', 140, 'Configure display formats for date and time.', '', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('node/%/revisions/%/delete', '\x613a323a7b693a313b613a313a7b733a393a226e6f64655f6c6f6164223b613a313a7b693a303b693a333b7d7d693a333b4e3b7d', '\x', '_node_revision_access', '\x613a323a7b693a303b693a313b693a313b733a363a2264656c657465223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32383a226e6f64655f7265766973696f6e5f64656c6574655f636f6e6669726d223b693a313b693a313b7d', '', 21, 5, 0, '', 'node/%/revisions/%/delete', 'Delete earlier revision', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types/manage/%', '\x613a313a7b693a343b733a31343a226e6f64655f747970655f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31343a226e6f64655f747970655f666f726d223b693a313b693a343b7d', '', 30, 5, 0, '', 'admin/structure/types/manage/%', 'Edit content type', 'node_type_page_title', 'a:1:{i:0;i:4;}', '', 'a:0:{}', 6, '', '', 0, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('node/%/revisions/%/revert', '\x613a323a7b693a313b613a313a7b733a393a226e6f64655f6c6f6164223b613a313a7b693a303b693a333b7d7d693a333b4e3b7d', '\x', '_node_revision_access', '\x613a323a7b693a303b693a313b693a313b733a363a22757064617465223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32383a226e6f64655f7265766973696f6e5f7265766572745f636f6e6669726d223b693a313b693a313b7d', '', 21, 5, 0, '', 'node/%/revisions/%/revert', 'Revert to earlier revision', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/node/node.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content/formats/%', '\x613a313a7b693a343b733a31383a2266696c7465725f666f726d61745f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e69737465722066696c74657273223b7d', 'filter_admin_format_page', '\x613a313a7b693a303b693a343b7d', '', 30, 5, 0, '', 'admin/config/content/formats/%', '', 'filter_admin_format_title', 'a:1:{i:0;i:4;}', '', 'a:0:{}', 6, '', '', 0, 'modules/filter/filter.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/demo/bartik', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32353a227468656d65732f62617274696b2f62617274696b2e696e666f223b733a343a226e616d65223b733a363a2262617274696b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2231223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a363a2242617274696b223b733a31313a226465736372697074696f6e223b733a34383a224120666c657869626c652c207265636f6c6f7261626c65207468656d652077697468206d616e7920726567696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a373a22726567696f6e73223b613a31373a7b733a363a22686561646572223b733a363a22486561646572223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a383a226665617475726564223b733a383a224665617475726564223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a31333a22736964656261725f6669727374223b733a31333a2253696465626172206669727374223b733a31343a22736964656261725f7365636f6e64223b733a31343a2253696465626172207365636f6e64223b733a31343a2274726970747963685f6669727374223b733a31343a225472697074796368206669727374223b733a31353a2274726970747963685f6d6964646c65223b733a31353a225472697074796368206d6964646c65223b733a31333a2274726970747963685f6c617374223b733a31333a225472697074796368206c617374223b733a31383a22666f6f7465725f6669727374636f6c756d6e223b733a31393a22466f6f74657220666972737420636f6c756d6e223b733a31393a22666f6f7465725f7365636f6e64636f6c756d6e223b733a32303a22466f6f746572207365636f6e6420636f6c756d6e223b733a31383a22666f6f7465725f7468697264636f6c756d6e223b733a31393a22466f6f74657220746869726420636f6c756d6e223b733a31393a22666f6f7465725f666f75727468636f6c756d6e223b733a32303a22466f6f74657220666f7572746820636f6c756d6e223b733a363a22666f6f746572223b733a363a22466f6f746572223b7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2230223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32383a227468656d65732f62617274696b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_demo', '\x613a313a7b693a303b733a363a2262617274696b223b7d', '', 31, 5, 0, '', 'admin/structure/block/demo/bartik', 'Bartik', 't', '', '_block_custom_theme', 'a:1:{i:0;s:6:"bartik";}', 0, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/demo/garland', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32373a227468656d65732f6761726c616e642f6761726c616e642e696e666f223b733a343a226e616d65223b733a373a226761726c616e64223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31373a7b733a343a226e616d65223b733a373a224761726c616e64223b733a31313a226465736372697074696f6e223b733a3131313a2241206d756c74692d636f6c756d6e207468656d652077686963682063616e20626520636f6e6669677572656420746f206d6f6469667920636f6c6f727320616e6420737769746368206265747765656e20666978656420616e6420666c756964207769647468206c61796f7574732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a31333a226761726c616e645f7769647468223b733a353a22666c756964223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32393a227468656d65732f6761726c616e642f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_demo', '\x613a313a7b693a303b733a373a226761726c616e64223b7d', '', 31, 5, 0, '', 'admin/structure/block/demo/garland', 'Garland', 't', '', '_block_custom_theme', 'a:1:{i:0;s:7:"garland";}', 0, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/types/%/delete', '\x613a313a7b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a33353a2273797374656d5f64656c6574655f646174655f666f726d61745f747970655f666f726d223b693a313b693a353b7d', '', 125, 7, 0, '', 'admin/config/regional/date-time/types/%/delete', 'Delete date type', 't', '', '', 'a:0:{}', 6, 'Allow users to delete a configured date type.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/formats/%/edit', '\x613a313a7b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a33343a2273797374656d5f636f6e6669677572655f646174655f666f726d6174735f666f726d223b693a313b693a353b7d', '', 125, 7, 0, '', 'admin/config/regional/date-time/formats/%/edit', 'Edit date format', 't', '', '', 'a:0:{}', 6, 'Allow users to edit a configured date format.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/demo/stark', '\x', '\x', '_block_themes_access', '\x613a313a7b693a303b4f3a383a22737464436c617373223a31323a7b733a383a2266696c656e616d65223b733a32333a227468656d65732f737461726b2f737461726b2e696e666f223b733a343a226e616d65223b733a353a22737461726b223b733a343a2274797065223b733a353a227468656d65223b733a353a226f776e6572223b733a34353a227468656d65732f656e67696e65732f70687074656d706c6174652f70687074656d706c6174652e656e67696e65223b733a363a22737461747573223b733a313a2230223b733a393a22626f6f747374726170223b733a313a2230223b733a31343a22736368656d615f76657273696f6e223b733a323a222d31223b733a363a22776569676874223b733a313a2230223b733a343a22696e666f223b613a31363a7b733a343a226e616d65223b733a353a22537461726b223b733a31313a226465736372697074696f6e223b733a3230383a2254686973207468656d652064656d6f6e737472617465732044727570616c27732064656661756c742048544d4c206d61726b757020616e6420435353207374796c65732e20546f206c6561726e20686f7720746f206275696c6420796f7572206f776e207468656d6520616e64206f766572726964652044727570616c27732064656661756c7420636f64652c2073656520746865203c6120687265663d22687474703a2f2f64727570616c2e6f72672f7468656d652d6775696465223e5468656d696e672047756964653c2f613e2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f737461726b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d733a363a22707265666978223b733a31313a2270687074656d706c617465223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b7d7d', 'block_admin_demo', '\x613a313a7b693a303b733a353a22737461726b223b7d', '', 31, 5, 0, '', 'admin/structure/block/demo/stark', 'Stark', 't', '', '_block_custom_theme', 'a:1:{i:0;s:5:"stark";}', 0, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types/manage/%/edit', '\x613a313a7b693a343b733a31343a226e6f64655f747970655f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31343a226e6f64655f747970655f666f726d223b693a313b693a343b7d', '', 61, 6, 1, 'admin/structure/types/manage/%', 'admin/structure/types/manage/%', 'Edit', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/formats/lookup', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'system_date_time_lookup', '\x613a303a7b7d', '', 63, 6, 0, '', 'admin/config/regional/date-time/formats/lookup', 'Date and time lookup', 't', '', '', 'a:0:{}', 0, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/types/manage/%/delete', '\x613a313a7b693a343b733a31343a226e6f64655f747970655f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32343a2261646d696e697374657220636f6e74656e74207479706573223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32343a226e6f64655f747970655f64656c6574655f636f6e6669726d223b693a313b693a343b7d', '', 61, 6, 0, '', 'admin/structure/types/manage/%/delete', 'Delete', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/node/content_types.inc');
INSERT INTO public.menu_router VALUES ('admin/people/permissions/roles/edit/%', '\x613a313a7b693a353b733a31343a22757365725f726f6c655f6c6f6164223b7d', '\x', 'user_role_edit_access', '\x613a313a7b693a303b693a353b7d', 'drupal_get_form', '\x613a323a7b693a303b733a31353a22757365725f61646d696e5f726f6c65223b693a313b693a353b7d', '', 62, 6, 0, '', 'admin/people/permissions/roles/edit/%', 'Edit role', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/garland/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32303a22626c6f636b5f6164645f626c6f636b5f666f726d223b7d', '', 63, 6, 1, 'admin/structure/block/list/garland', 'admin/structure/block', 'Add block', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/seven/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32303a22626c6f636b5f6164645f626c6f636b5f666f726d223b7d', '', 63, 6, 1, 'admin/structure/block/list/seven', 'admin/structure/block', 'Add block', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/list/stark/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a32303a22626c6f636b5f6164645f626c6f636b5f666f726d223b7d', '', 63, 6, 1, 'admin/structure/block/list/stark', 'admin/structure/block', 'Add block', 't', '', '', 'a:0:{}', 388, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/manage/%/%', '\x613a323a7b693a343b4e3b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a333a7b693a303b733a32313a22626c6f636b5f61646d696e5f636f6e666967757265223b693a313b693a343b693a323b693a353b7d', '', 60, 6, 0, '', 'admin/structure/block/manage/%/%', 'Configure block', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/people/ip-blocking/delete/%', '\x613a313a7b693a353b733a31353a22626c6f636b65645f69705f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31383a22626c6f636b20495020616464726573736573223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32353a2273797374656d5f69705f626c6f636b696e675f64656c657465223b693a313b693a353b7d', '', 62, 6, 0, '', 'admin/config/people/ip-blocking/delete/%', 'Delete IP address', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/types/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a33323a2273797374656d5f6164645f646174655f666f726d61745f747970655f666f726d223b7d', '', 63, 6, 1, 'admin/config/regional/date-time/types', 'admin/config/regional/date-time', 'Add date type', 't', '', '', 'a:0:{}', 388, 'Add new date type.', '', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/formats/add', '\x', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a313a7b693a303b733a33343a2273797374656d5f636f6e6669677572655f646174655f666f726d6174735f666f726d223b7d', '', 63, 6, 1, 'admin/config/regional/date-time/formats', 'admin/config/regional/date-time', 'Add format', 't', '', '', 'a:0:{}', 388, 'Allow users to add additional date formats.', '', -10, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('user/%/cancel/confirm/%/%', '\x613a333a7b693a313b733a393a22757365725f6c6f6164223b693a343b4e3b693a353b4e3b7d', '\x', 'user_cancel_access', '\x613a313a7b693a303b693a313b7d', 'user_cancel_confirm', '\x613a333a7b693a303b693a313b693a313b693a343b693a323b693a353b7d', '', 44, 6, 0, '', 'user/%/cancel/confirm/%/%', 'Confirm account cancellation', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/user/user.pages.inc');
INSERT INTO public.menu_router VALUES ('admin/config/system/actions/delete/%', '\x613a313a7b693a353b733a31323a22616374696f6e735f6c6f6164223b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31383a2261646d696e697374657220616374696f6e73223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32363a2273797374656d5f616374696f6e735f64656c6574655f666f726d223b693a313b693a353b7d', '', 62, 6, 0, '', 'admin/config/system/actions/delete/%', 'Delete action', 't', '', '', 'a:0:{}', 6, 'Delete an action.', '', 0, 'modules/system/system.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/people/permissions/roles/delete/%', '\x613a313a7b693a353b733a31343a22757365725f726f6c655f6c6f6164223b7d', '\x', 'user_role_edit_access', '\x613a313a7b693a303b693a353b7d', 'drupal_get_form', '\x613a323a7b693a303b733a33303a22757365725f61646d696e5f726f6c655f64656c6574655f636f6e6669726d223b693a313b693a353b7d', '', 62, 6, 0, '', 'admin/people/permissions/roles/delete/%', 'Delete role', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/user/user.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/content/formats/%/disable', '\x613a313a7b693a343b733a31383a2266696c7465725f666f726d61745f6c6f6164223b7d', '\x', '_filter_disable_format_access', '\x613a313a7b693a303b693a343b7d', 'drupal_get_form', '\x613a323a7b693a303b733a32303a2266696c7465725f61646d696e5f64697361626c65223b693a313b693a343b7d', '', 61, 6, 0, '', 'admin/config/content/formats/%/disable', 'Disable text format', 't', '', '', 'a:0:{}', 6, '', '', 0, 'modules/filter/filter.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/manage/%/%/configure', '\x613a323a7b693a343b4e3b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a333a7b693a303b733a32313a22626c6f636b5f61646d696e5f636f6e666967757265223b693a313b693a343b693a323b693a353b7d', '', 121, 7, 2, 'admin/structure/block/manage/%/%', 'admin/structure/block/manage/%/%', 'Configure block', 't', '', '', 'a:0:{}', 140, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/structure/block/manage/%/%/delete', '\x613a323a7b693a343b4e3b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a31373a2261646d696e697374657220626c6f636b73223b7d', 'drupal_get_form', '\x613a333a7b693a303b733a32353a22626c6f636b5f637573746f6d5f626c6f636b5f64656c657465223b693a313b693a343b693a323b693a353b7d', '', 121, 7, 0, 'admin/structure/block/manage/%/%', 'admin/structure/block/manage/%/%', 'Delete block', 't', '', '', 'a:0:{}', 132, '', '', 0, 'modules/block/block.admin.inc');
INSERT INTO public.menu_router VALUES ('admin/config/regional/date-time/formats/%/delete', '\x613a313a7b693a353b4e3b7d', '\x', 'user_access', '\x613a313a7b693a303b733a32393a2261646d696e6973746572207369746520636f6e66696775726174696f6e223b7d', 'drupal_get_form', '\x613a323a7b693a303b733a33303a2273797374656d5f646174655f64656c6574655f666f726d61745f666f726d223b693a313b693a353b7d', '', 125, 7, 0, '', 'admin/config/regional/date-time/formats/%/delete', 'Delete date format', 't', '', '', 'a:0:{}', 6, 'Allow users to delete a configured date format.', '', 0, 'modules/system/system.admin.inc');


--
-- TOC entry 4071 (class 0 OID 16841)
-- Dependencies: 256
-- Data for Name: node; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4072 (class 0 OID 16874)
-- Dependencies: 257
-- Data for Name: node_access; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.node_access VALUES (0, 0, 'all', 1, 0, 0);


--
-- TOC entry 4074 (class 0 OID 16891)
-- Dependencies: 259
-- Data for Name: node_revision; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4075 (class 0 OID 16911)
-- Dependencies: 260
-- Data for Name: node_type; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4053 (class 0 OID 16662)
-- Dependencies: 238
-- Data for Name: queue; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4054 (class 0 OID 16676)
-- Dependencies: 239
-- Data for Name: registry; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.registry VALUES ('ArchiverTar', 'class', 'modules/system/system.archiver.inc', 'system', 0);
INSERT INTO public.registry VALUES ('ArchiverZip', 'class', 'modules/system/system.archiver.inc', 'system', 0);
INSERT INTO public.registry VALUES ('DefaultMailSystem', 'class', 'modules/system/system.mail.inc', 'system', 0);
INSERT INTO public.registry VALUES ('TestingMailSystem', 'class', 'modules/system/system.mail.inc', 'system', 0);
INSERT INTO public.registry VALUES ('DrupalQueue', 'class', 'modules/system/system.queue.inc', 'system', 0);
INSERT INTO public.registry VALUES ('DrupalQueueInterface', 'interface', 'modules/system/system.queue.inc', 'system', 0);
INSERT INTO public.registry VALUES ('DrupalReliableQueueInterface', 'interface', 'modules/system/system.queue.inc', 'system', 0);
INSERT INTO public.registry VALUES ('SystemQueue', 'class', 'modules/system/system.queue.inc', 'system', 0);
INSERT INTO public.registry VALUES ('MemoryQueue', 'class', 'modules/system/system.queue.inc', 'system', 0);
INSERT INTO public.registry VALUES ('Archive_Tar', 'class', 'modules/system/system.tar.inc', 'system', 0);
INSERT INTO public.registry VALUES ('ModuleUpdater', 'class', 'modules/system/system.updater.inc', 'system', 0);
INSERT INTO public.registry VALUES ('ThemeUpdater', 'class', 'modules/system/system.updater.inc', 'system', 0);
INSERT INTO public.registry VALUES ('ModuleTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('EnableDisableTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('HookRequirementsTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('ModuleDependencyTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('ModuleVersionTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('ModuleRequiredTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('IPAddressBlockingTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('CronRunTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('CronQueueTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('AdminMetaTagTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('AccessDeniedTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('PageNotFoundTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SiteMaintenanceTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('DateTimeFunctionalTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('DateFormatTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('PageTitleFiltering', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('FrontPageTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemBlockTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemMainContentFallback', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemThemeFunctionalTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('QueueTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('TokenReplaceTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('InfoFileParserTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemInfoAlterTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('UpdateScriptFunctionalTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('FloodFunctionalTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('RetrieveFileTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('ShutdownFunctionsTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemAdminTestCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemAuthorizeCase', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemIndexPhpTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('TokenScanTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemValidTokenTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('DrupalSetMessageTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('ConfirmFormTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('SystemArchiverTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('HtaccessTest', 'class', 'modules/system/system.test', 'system', 0);
INSERT INTO public.registry VALUES ('UserController', 'class', 'modules/user/user.module', 'user', 0);
INSERT INTO public.registry VALUES ('UserRegistrationTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserValidationTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserLoginTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserPasswordResetTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserCancelTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserPictureTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserPermissionsTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserAdminTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserTimeZoneFunctionalTest', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserAutocompleteTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserAccountLinksUnitTests', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserBlocksUnitTests', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserSaveTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserCreateTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserEditTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserEditRebuildTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserSignatureTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserEditedOwnAccountTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserRoleAdminTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserTokenReplaceTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserUserSearchTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserRolesAssignmentTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserAuthmapAssignmentTestCase', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserValidateCurrentPassCustomForm', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('UserActionsTest', 'class', 'modules/user/user.test', 'user', 0);
INSERT INTO public.registry VALUES ('DatabaseConnection_pgsql', 'class', 'includes/database/pgsql/database.inc', '', 0);
INSERT INTO public.registry VALUES ('SelectQuery_pgsql', 'class', 'includes/database/pgsql/select.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchema_pgsql', 'class', 'includes/database/pgsql/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('InsertQuery_pgsql', 'class', 'includes/database/pgsql/query.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdateQuery_pgsql', 'class', 'includes/database/pgsql/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTasks_pgsql', 'class', 'includes/database/pgsql/install.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseConnection_mysql', 'class', 'includes/database/mysql/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchema_mysql', 'class', 'includes/database/mysql/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('InsertQuery_mysql', 'class', 'includes/database/mysql/query.inc', '', 0);
INSERT INTO public.registry VALUES ('TruncateQuery_mysql', 'class', 'includes/database/mysql/query.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdateQuery_mysql', 'class', 'includes/database/mysql/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTasks_mysql', 'class', 'includes/database/mysql/install.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseConnection_sqlite', 'class', 'includes/database/sqlite/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseStatement_sqlite', 'class', 'includes/database/sqlite/database.inc', '', 0);
INSERT INTO public.registry VALUES ('SelectQuery_sqlite', 'class', 'includes/database/sqlite/select.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchema_sqlite', 'class', 'includes/database/sqlite/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('InsertQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdateQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DeleteQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', 0);
INSERT INTO public.registry VALUES ('TruncateQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTasks_sqlite', 'class', 'includes/database/sqlite/install.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseLog', 'class', 'includes/database/log.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseConnection', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('Database', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransactionNoActiveException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransactionNameNonUniqueException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransactionCommitFailedException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransactionExplicitCommitNotAllowedException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransactionOutOfOrderException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('InvalidMergeQueryException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('InvalidQueryConditionOperatorException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('FieldsOverlapException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('NoFieldsException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseConnectionNotDefinedException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseDriverNotSpecifiedException', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTransaction', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseStatementInterface', 'interface', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseStatementBase', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseStatementEmpty', 'class', 'includes/database/database.inc', '', 0);
INSERT INTO public.registry VALUES ('QueryExtendableInterface', 'interface', 'includes/database/select.inc', '', 0);
INSERT INTO public.registry VALUES ('SelectQueryInterface', 'interface', 'includes/database/select.inc', '', 0);
INSERT INTO public.registry VALUES ('SelectQueryExtender', 'class', 'includes/database/select.inc', '', 0);
INSERT INTO public.registry VALUES ('SelectQuery', 'class', 'includes/database/select.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchema', 'class', 'includes/database/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchemaObjectExistsException', 'class', 'includes/database/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseSchemaObjectDoesNotExistException', 'class', 'includes/database/schema.inc', '', 0);
INSERT INTO public.registry VALUES ('QueryConditionInterface', 'interface', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('QueryAlterableInterface', 'interface', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('QueryPlaceholderInterface', 'interface', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('Query', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('InsertQuery', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DeleteQuery', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('TruncateQuery', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdateQuery', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('MergeQuery', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseCondition', 'class', 'includes/database/query.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseStatementPrefetch', 'class', 'includes/database/prefetch.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferLocal', 'class', 'includes/filetransfer/local.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferSSH', 'class', 'includes/filetransfer/ssh.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferFTP', 'class', 'includes/filetransfer/ftp.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferFTPExtension', 'class', 'includes/filetransfer/ftp.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransfer', 'class', 'includes/filetransfer/filetransfer.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferException', 'class', 'includes/filetransfer/filetransfer.inc', '', 0);
INSERT INTO public.registry VALUES ('FileTransferChmodInterface', 'interface', 'includes/filetransfer/filetransfer.inc', '', 0);
INSERT INTO public.registry VALUES ('SkipDotsRecursiveDirectoryIterator', 'class', 'includes/filetransfer/filetransfer.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalEntityControllerInterface', 'interface', 'includes/entity.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalDefaultEntityController', 'class', 'includes/entity.inc', '', 0);
INSERT INTO public.registry VALUES ('EntityFieldQueryException', 'class', 'includes/entity.inc', '', 0);
INSERT INTO public.registry VALUES ('EntityFieldQuery', 'class', 'includes/entity.inc', '', 0);
INSERT INTO public.registry VALUES ('EntityMalformedException', 'class', 'includes/entity.inc', '', 0);
INSERT INTO public.registry VALUES ('MailSystemInterface', 'interface', 'includes/mail.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalCacheInterface', 'interface', 'includes/cache.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalDatabaseCache', 'class', 'includes/cache.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalUpdateException', 'class', 'includes/update.inc', '', 0);
INSERT INTO public.registry VALUES ('ArchiverInterface', 'interface', 'includes/archiver.inc', '', 0);
INSERT INTO public.registry VALUES ('TableSort', 'class', 'includes/tablesort.inc', '', 0);
INSERT INTO public.registry VALUES ('PagerDefault', 'class', 'includes/pager.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalRequestSanitizer', 'class', 'includes/request-sanitizer.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalUpdaterInterface', 'interface', 'includes/updater.inc', '', 0);
INSERT INTO public.registry VALUES ('Updater', 'class', 'includes/updater.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdaterException', 'class', 'includes/updater.inc', '', 0);
INSERT INTO public.registry VALUES ('UpdaterFileTransferException', 'class', 'includes/updater.inc', '', 0);
INSERT INTO public.registry VALUES ('BatchQueue', 'class', 'includes/batch.queue.inc', '', 0);
INSERT INTO public.registry VALUES ('BatchMemoryQueue', 'class', 'includes/batch.queue.inc', '', 0);
INSERT INTO public.registry VALUES ('ThemeRegistry', 'class', 'includes/theme.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalFakeCache', 'class', 'includes/cache-install.inc', '', 0);
INSERT INTO public.registry VALUES ('StreamWrapperInterface', 'interface', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalStreamWrapperInterface', 'interface', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalLocalStreamWrapper', 'class', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalPublicStreamWrapper', 'class', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalPrivateStreamWrapper', 'class', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalTemporaryStreamWrapper', 'class', 'includes/stream_wrappers.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTasks', 'class', 'includes/install.inc', '', 0);
INSERT INTO public.registry VALUES ('DatabaseTaskException', 'class', 'includes/install.inc', '', 0);
INSERT INTO public.registry VALUES ('DrupalCacheArray', 'class', 'includes/bootstrap.inc', '', 0);
INSERT INTO public.registry VALUES ('SchemaCache', 'class', 'includes/bootstrap.inc', '', 0);
INSERT INTO public.registry VALUES ('NodeController', 'class', 'modules/node/node.module', 'node', 0);
INSERT INTO public.registry VALUES ('NodeWebTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeLoadMultipleTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeLoadHooksTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeRevisionsTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('PageEditTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('PagePreviewTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeCreationTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('PageViewTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('SummaryLengthTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeTitleXSSTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeBlockTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodePostSettingsTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeRSSContentTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessRecordsTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessBaseTableTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeSaveTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeTypeTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeTypePersistenceTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessRebuildTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAdminTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeTitleTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeFeedTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeBlockFunctionalTest', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('MultiStepNodeFormBasicOptionsTest', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeBuildContent', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeQueryAlter', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeEntityFieldQueryAlter', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeTokenReplaceTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeRevisionPermissionsTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessPagerTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeAccessFieldTestCase', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeEntityViewModeAlterTest', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodePageCacheTest', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('NodeMultiByteUtf8Test', 'class', 'modules/node/node.test', 'node', 0);
INSERT INTO public.registry VALUES ('FilterCRUDTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterAdminTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterFormatAccessTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterDefaultFormatTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterNoFormatTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterSecurityTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterUnitTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterHooksTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterSettingsTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FilterDOMSerializeTestCase', 'class', 'modules/filter/filter.test', 'filter', 0);
INSERT INTO public.registry VALUES ('FieldSqlStorageTestCase', 'class', 'modules/field/modules/field_sql_storage/field_sql_storage.test', 'field_sql_storage', 0);
INSERT INTO public.registry VALUES ('FieldException', 'class', 'modules/field/field.module', 'field', 0);
INSERT INTO public.registry VALUES ('FieldUpdateForbiddenException', 'class', 'modules/field/field.module', 'field', 0);
INSERT INTO public.registry VALUES ('FieldValidationException', 'class', 'modules/field/field.attach.inc', 'field', 0);
INSERT INTO public.registry VALUES ('FieldInfo', 'class', 'modules/field/field.info.class.inc', 'field', 0);
INSERT INTO public.registry VALUES ('FieldTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldAttachTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldAttachStorageTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldAttachOtherTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldInfoTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldFormTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldDisplayAPITestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldCrudTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldInstanceCrudTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldTranslationsTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('FieldBulkDeleteTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('EntityPropertiesTestCase', 'class', 'modules/field/tests/field.test', 'field', 0);
INSERT INTO public.registry VALUES ('TextFieldTestCase', 'class', 'modules/field/modules/text/text.test', 'text', 0);
INSERT INTO public.registry VALUES ('TextSummaryTestCase', 'class', 'modules/field/modules/text/text.test', 'text', 0);
INSERT INTO public.registry VALUES ('TextTranslationTestCase', 'class', 'modules/field/modules/text/text.test', 'text', 0);
INSERT INTO public.registry VALUES ('BlockTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('NonDefaultBlockAdmin', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('NewDefaultThemeBlocks', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockAdminThemeTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockCacheTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockHTMLIdTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockTemplateSuggestionsUnitTest', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockViewModuleDeltaAlterWebTest', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockHiddenRegionTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockInvalidRegionTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('BlockHashTestCase', 'class', 'modules/block/block.test', 'block', 0);
INSERT INTO public.registry VALUES ('DBLogTestCase', 'class', 'modules/dblog/dblog.test', 'dblog', 0);


--
-- TOC entry 4055 (class 0 OID 16688)
-- Dependencies: 240
-- Data for Name: registry_file; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.registry_file VALUES ('modules/system/system.archiver.inc', '05caceec7b3baecfebd053959c513f134a5ae4070749339495274a81bebb904a');
INSERT INTO public.registry_file VALUES ('modules/system/system.mail.inc', 'd2f4fca46269981db5edb6316176b7b8161de59d4c24c514b63fe3c536ebb4d6');
INSERT INTO public.registry_file VALUES ('modules/system/system.queue.inc', 'a77a5913d84368092805ac551ca63737c1d829455504fcccb95baa2932f28009');
INSERT INTO public.registry_file VALUES ('modules/system/system.tar.inc', '2dd9560bddab659f0379ef9eca095fc65a364128420d9d9e540ef81ca649a7d6');
INSERT INTO public.registry_file VALUES ('modules/system/system.updater.inc', '9433fa8d39500b8c59ab05f41c0aac83b2586a43be4aa949821380e36c4d3c48');
INSERT INTO public.registry_file VALUES ('modules/system/system.test', 'ea0cf65bfee589ac22618cdfc7ac9fb57d2ca1b72420d59df67d747833d02aa5');
INSERT INTO public.registry_file VALUES ('modules/user/user.module', '417ef6ed68d72a573d50681055cbe7f814e40e321d38bc0d9a13abe4fbd70479');
INSERT INTO public.registry_file VALUES ('modules/user/user.test', '34b201554098ebf1b5d19d7da334155876cbab06fcdf2f61bc82ed7bb0bda0e9');
INSERT INTO public.registry_file VALUES ('includes/database/pgsql/database.inc', 'eb1bd4f8d53f207f3b074ebf7c811340b73a95e70515a85bcc2d6268a4c347f8');
INSERT INTO public.registry_file VALUES ('includes/database/pgsql/select.inc', '1e509bc97c58223750e8ea735145b316827e36f43c07b946003e41f5bca23659');
INSERT INTO public.registry_file VALUES ('includes/database/pgsql/schema.inc', '0eb77d1d8b30988ba89cbacbcbbc3b66d8ab98b8be8dfa4208a50a45ee77b6e2');
INSERT INTO public.registry_file VALUES ('includes/database/pgsql/query.inc', 'bb04ae9239c2179aeb3ef0a55596ee5ae0ddfb5dfd701896c41bf8c42a62280b');
INSERT INTO public.registry_file VALUES ('includes/database/pgsql/install.inc', '39587f26a9e054afaab2064d996af910f1b201ef1c6b82938ef130e4ff8c6aab');
INSERT INTO public.registry_file VALUES ('includes/database/mysql/database.inc', 'fb808762239838f920ffeb74a89db5894fb46131d8bb4c65a0caff82358562c6');
INSERT INTO public.registry_file VALUES ('includes/database/mysql/schema.inc', 'c34aa7b7d2cb4662965497ff86f242224116bbd9b72ca6287c12039a65feb72e');
INSERT INTO public.registry_file VALUES ('includes/database/mysql/query.inc', 'cddf695f7dbd483591f93af805e7118a04eac3f21c0105326642c6463587670c');
INSERT INTO public.registry_file VALUES ('includes/database/mysql/install.inc', '6ae316941f771732fbbabed7e1d6b4cbb41b1f429dd097d04b3345aa15e461a0');
INSERT INTO public.registry_file VALUES ('includes/database/sqlite/database.inc', '22e80c5a02c143eace3628e196dded78552e6f2889d1989d052e2a37f46e7f0f');
INSERT INTO public.registry_file VALUES ('includes/database/sqlite/select.inc', '8d1c426dbd337733c206cce9f59a172546c6ed856d8ef3f1c7bef05a16f7bf68');
INSERT INTO public.registry_file VALUES ('includes/database/sqlite/schema.inc', '7bf3af0a255f374ba0c5db175548e836d953b903d31e1adb1e4d3df40d6fdb98');
INSERT INTO public.registry_file VALUES ('includes/database/sqlite/query.inc', '5d4dc3ac34cb2dbc0293471e85e37c890da3da6cd8c0c540c6f33313e4c0cbe9');
INSERT INTO public.registry_file VALUES ('includes/database/sqlite/install.inc', '6620f354aa175a116ba3a0562c980d86cc3b8b481042fc3cc5ed6a4d1a7a6d74');
INSERT INTO public.registry_file VALUES ('includes/database/log.inc', '9feb5a17ae2fabcf26a96d2a634ba73da501f7bcfc3599a693d916a6971d00d1');
INSERT INTO public.registry_file VALUES ('includes/database/database.inc', '0409112ba028a31f3623ae3bbc462566600bf88aaf511dfe3ab728c8a32c3b68');
INSERT INTO public.registry_file VALUES ('includes/database/select.inc', 'f941806c7489ea88c214cd7a4573a9e8fb95fe743d7c8643aa61110ce9323611');
INSERT INTO public.registry_file VALUES ('includes/database/schema.inc', 'da9d48f26c3a47a91f1eb2fa216e9deab2ec42ba10c76039623ce7b6bc984a06');
INSERT INTO public.registry_file VALUES ('includes/database/query.inc', '5b77dd9d00b987e6b045ac2eb7890e6e3c85de881211640c049449e0a24c203c');
INSERT INTO public.registry_file VALUES ('includes/database/prefetch.inc', '026b6b272a91bae5d9325477530167e737b29bf988553a28cdf72fc1d1ea57ed');
INSERT INTO public.registry_file VALUES ('includes/filetransfer/local.inc', '7cbfdb46abbdf539640db27e66fb30e5265128f31002bd0dfc3af16ae01a9492');
INSERT INTO public.registry_file VALUES ('includes/filetransfer/ssh.inc', '92f1232158cb32ab04cbc93ae38ad3af04796e18f66910a9bc5ca8e437f06891');
INSERT INTO public.registry_file VALUES ('includes/filetransfer/ftp.inc', '51eb119b8e1221d598ffa6cc46c8a322aa77b49a3d8879f7fb38b7221cf7e06d');
INSERT INTO public.registry_file VALUES ('includes/filetransfer/filetransfer.inc', '764cc29ca923dbb55c9440ed3c5feb3b9e97ea27a28aba3011e8dbac0424f8bd');
INSERT INTO public.registry_file VALUES ('includes/theme.maintenance.inc', '39f068b3eee4d10a90d6aa3c86db587b6d25844c2919d418d34d133cfe330f5a');
INSERT INTO public.registry_file VALUES ('includes/module.inc', '75720e119c7fdc82bdefdd43e36661c990da6f69c1008e6f7997a6081590c8db');
INSERT INTO public.registry_file VALUES ('includes/path.inc', 'e399fc0af1f25cebda4b6c471ab203db8abe1a0fe15e632f19e614f32d71821e');
INSERT INTO public.registry_file VALUES ('includes/entity.inc', 'c0b06ea5088fed2c6f00acd67dd8b4443fd317daa6d12ad68ac33e1848e66003');
INSERT INTO public.registry_file VALUES ('includes/form.inc', 'c6f9db191716ae0ea71bd79951e55344825fbc600e8e07057557593d614f6f9c');
INSERT INTO public.registry_file VALUES ('includes/file.phar.inc', '544df23f736ce49f458033d6515a301a8ca1c7a7d1bfd3f388caef910534abb3');
INSERT INTO public.registry_file VALUES ('includes/mail.inc', 'a7bef724e057f7410e42c8f33b00c9a0246a2ca2e856a113c9e20eecc49fc069');
INSERT INTO public.registry_file VALUES ('includes/utility.inc', '3458fd2b55ab004dd0cc529b8e58af12916e8bd36653b072bdd820b26b907ed5');
INSERT INTO public.registry_file VALUES ('includes/unicode.inc', '89636ce5847340fd19be319839b4203b0d4bbc3487973413d6de9b5f6f839222');
INSERT INTO public.registry_file VALUES ('includes/authorize.inc', '3eb984facfe9e0228e4d01ece6345cf33dfcd2fcc9c291b15f2e4f782a6029a9');
INSERT INTO public.registry_file VALUES ('includes/cache.inc', '033c9bf2555dba29382b077f78cc00c82fd7f42a959ba31b710adddf6fdf24fe');
INSERT INTO public.registry_file VALUES ('includes/menu.inc', '9cbc6636d5c5f9c681eea9fd9c09973e2e29b66bca38420883b657f9e1c0800a');
INSERT INTO public.registry_file VALUES ('includes/unicode.entities.inc', '2b858138596d961fbaa4c6e3986e409921df7f76b6ee1b109c4af5970f1e0f54');
INSERT INTO public.registry_file VALUES ('includes/ajax.inc', '8d5ebead219c48d5929ee6a5a178a331471ee6ceb38653094514c952457eaebd');
INSERT INTO public.registry_file VALUES ('includes/errors.inc', '64c7f438c4793fcaa94f1b26ca886068c2da15f88d2456356db7156540d441f5');
INSERT INTO public.registry_file VALUES ('includes/file.inc', 'd0b26c57edd76096e28e3bb98a24129bf6070de1523106b03b53803ed883382b');
INSERT INTO public.registry_file VALUES ('includes/date.inc', '1de2c25e3b67a9919fc6c8061594442b6fb2cdd3a48ddf1591ee3aa98484b737');
INSERT INTO public.registry_file VALUES ('includes/common.inc', '3fe0f5d2609482a89a7abebd1d33e3dc7a6b7e969ffe72a731dd8ccdbc64879b');
INSERT INTO public.registry_file VALUES ('includes/install.core.inc', 'b6f3e5d9bd4154f840253e34aed131bb401deb4fcb3421b379851231b8b4c149');
INSERT INTO public.registry_file VALUES ('includes/image.inc', 'bcdc7e1599c02227502b9d0fe36eeb2b529b130a392bc709eb737647bd361826');
INSERT INTO public.registry_file VALUES ('includes/iso.inc', '09f14cce40153fa48e24a7daa44185c09ec9f56a638b5e56e9390c67ec5aaec8');
INSERT INTO public.registry_file VALUES ('includes/update.inc', '25c30f1e61ef9c91a7bdeb37791c2215d9dc2ae07dba124722d783ca31bb01e7');
INSERT INTO public.registry_file VALUES ('includes/archiver.inc', 'bdbb21b712a62f6b913590b609fd17cd9f3c3b77c0d21f68e71a78427ed2e3e9');
INSERT INTO public.registry_file VALUES ('includes/tablesort.inc', '2d88768a544829595dd6cda2a5eb008bedb730f36bba6dfe005d9ddd999d5c0f');
INSERT INTO public.registry_file VALUES ('includes/session.inc', '9981d139191b6a983f837e867058a376b62ae7cf5df607aee29e3e322a927b50');
INSERT INTO public.registry_file VALUES ('includes/graph.inc', '8e0e313a8bb33488f371df11fc1b58d7cf80099b886cd1003871e2c896d1b536');
INSERT INTO public.registry_file VALUES ('includes/batch.inc', '756b66e69a05b74629dee0ff175385813b27eb635aa49380edd4a65532998825');
INSERT INTO public.registry_file VALUES ('includes/password.inc', 'fd9a1c94fe5a0fa7c7049a2435c7280b1d666b2074595010e3c492dd15712775');
INSERT INTO public.registry_file VALUES ('includes/file.mimetypes.inc', '33266e837f4ce076378e7e8cef6c5af46446226ca4259f83e13f605856a7f147');
INSERT INTO public.registry_file VALUES ('includes/pager.inc', 'a596da575268e116c140b65e4ec98e4006c04a188f65a1c48b766b6ee276853f');
INSERT INTO public.registry_file VALUES ('includes/xmlrpcs.inc', '925c4d5bf429ad9650f059a8862a100bd394dce887933f5b3e7e32309a51fd8e');
INSERT INTO public.registry_file VALUES ('includes/request-sanitizer.inc', '770e8ece7b53d13e2b5ef99da02adb9a3d18071c6cd29eb01af30927cf749a73');
INSERT INTO public.registry_file VALUES ('includes/updater.inc', '89c602fd46c6aebb87bd86d495a930fbb9811dd905859a48f36d05d6aa5c1efe');
INSERT INTO public.registry_file VALUES ('includes/batch.queue.inc', '554b2e92e1dad0f7fd5a19cb8dff7e109f10fbe2441a5692d076338ec908de0f');
INSERT INTO public.registry_file VALUES ('includes/registry.inc', '2067cc87973e7af23428d3f41b8f8739d80092bc3c9e20b5a8858e481d03f22c');
INSERT INTO public.registry_file VALUES ('includes/xmlrpc.inc', 'ea24176ec445c440ba0c825fc7b04a31b440288df8ef02081560dc418e34e659');
INSERT INTO public.registry_file VALUES ('includes/language.inc', '4e08f30843a7ccaeea5c041083e9f77d33d57ff002f1ab4f66168e2c683ce128');
INSERT INTO public.registry_file VALUES ('includes/theme.inc', 'ae46daba6419ca613bc6a08ba4d7f9bbab9b19889937099d2e4c1737e9e7b2df');
INSERT INTO public.registry_file VALUES ('includes/locale.inc', '3161313aaab94a956f855a2635d738806142b33f06734cdc3df81a3f3854fbdb');
INSERT INTO public.registry_file VALUES ('includes/cache-install.inc', 'e7ed123c5805703c84ad2cce9c1ca46b3ce8caeeea0d8ef39a3024a4ab95fa0e');
INSERT INTO public.registry_file VALUES ('includes/stream_wrappers.inc', '3244dae1fa57557f8d0d805fc163830ac1263914587f652f009594a0fa51eeaf');
INSERT INTO public.registry_file VALUES ('includes/lock.inc', 'a181c8bd4f88d292a0a73b9f1fbd727e3314f66ec3631f288e6b9a54ba2b70fa');
INSERT INTO public.registry_file VALUES ('includes/json-encode.inc', '02a822a652d00151f79db9aa9e171c310b69b93a12f549bc2ce00533a8efa14e');
INSERT INTO public.registry_file VALUES ('includes/install.inc', 'dc7b5c97803df3e8e80e62984fe820de53ebc4141b645f66f6344f51ef4d5b19');
INSERT INTO public.registry_file VALUES ('includes/token.inc', '5e7898cd78689e2c291ed3cd8f41c032075656896f1db57e49217aac19ae0428');
INSERT INTO public.registry_file VALUES ('includes/bootstrap.inc', 'bf3f304ade531763f6466909c001844fed2dee9145a0be20eb25649efef99d42');
INSERT INTO public.registry_file VALUES ('includes/actions.inc', 'f36b066681463c7dfe189e0430cb1a89bf66f7e228cbb53cdfcd93987193f759');
INSERT INTO public.registry_file VALUES ('modules/node/node.module', 'a0431f275b291779ffd1061d7d98b6942106235350b807828e94c6929ad04a41');
INSERT INTO public.registry_file VALUES ('modules/node/node.test', 'de4fed92632a309ff1c63d42460eef161bb86c429f3a097118aecf262ebe598b');
INSERT INTO public.registry_file VALUES ('modules/filter/filter.test', 'f4aa37bb42e91fd7deb2c531a6752fb6fe85457e5e769aa39a58fa5e1999b70a');
INSERT INTO public.registry_file VALUES ('modules/field/modules/field_sql_storage/field_sql_storage.test', 'dc04de608db0a295543c971ece47b87521a9b4e1ec4430c84caf2e97cc96afc9');
INSERT INTO public.registry_file VALUES ('modules/field/field.module', '48b5b83f214a8d19e446f46c5d7a1cd35faa656ccb7b540f9f02462a440cacdd');
INSERT INTO public.registry_file VALUES ('modules/field/field.attach.inc', '2df4687b5ec078c4893dc1fea514f67524fd5293de717b9e05caf977e5ae2327');
INSERT INTO public.registry_file VALUES ('modules/field/field.info.class.inc', '31deca748d873bf78cc6b8c064fdecc5a3451a9d2e9a131bc8c204905029e31f');
INSERT INTO public.registry_file VALUES ('modules/field/tests/field.test', 'd6f29a2096e13e91fc403db710f1b2057c75e03c0083f51fc4a8e52816cd488c');
INSERT INTO public.registry_file VALUES ('modules/field/modules/text/text.test', 'b267aeb70e79d3a3f4ac45961f74c09a2ff7a114dcfee8b90d212d71e959e1a3');
INSERT INTO public.registry_file VALUES ('modules/block/block.test', 'b7794c581c0eeacc77fca184e52b416a65c6d51998728467f02e441d5ecabcd4');
INSERT INTO public.registry_file VALUES ('modules/dblog/dblog.test', '87a38f90f57c8a7069e9b34d461049d41388981fe1e16a8c437f0ff12753702e');


--
-- TOC entry 4067 (class 0 OID 16783)
-- Dependencies: 252
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.role VALUES (1, 'anonymous user', 0);
INSERT INTO public.role VALUES (2, 'authenticated user', 1);


--
-- TOC entry 4065 (class 0 OID 16773)
-- Dependencies: 250
-- Data for Name: role_permission; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.role_permission VALUES (1, 'access content', 'node');
INSERT INTO public.role_permission VALUES (2, 'access content', 'node');


--
-- TOC entry 4056 (class 0 OID 16693)
-- Dependencies: 241
-- Data for Name: semaphore; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4058 (class 0 OID 16705)
-- Dependencies: 243
-- Data for Name: sequences; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4059 (class 0 OID 16712)
-- Dependencies: 244
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sessions VALUES (1, 'McFPr6yTWZcxZyc8NRjPJtOrMKainMAs0nTwp2NGAJY', '', '172.18.0.1', 1727123502, 0, '\x');


--
-- TOC entry 4060 (class 0 OID 16727)
-- Dependencies: 245
-- Data for Name: system; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system VALUES ('modules/update/tests/bbb_update_test.module', 'bbb_update_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a22424242205570646174652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220757064617465206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/block/tests/block_test.module', 'block_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a22426c6f636b2074657374223b733a31313a226465736372697074696f6e223b733a32313a2250726f7669646573207465737420626c6f636b732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/book/book.module', 'book', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a343a22426f6f6b223b733a31313a226465736372697074696f6e223b733a36363a22416c6c6f777320757365727320746f2063726561746520616e64206f7267616e697a652072656c6174656420636f6e74656e7420696e20616e206f75746c696e652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a22626f6f6b2e74657374223b7d733a393a22636f6e666967757265223b733a32373a2261646d696e2f636f6e74656e742f626f6f6b2f73657474696e6773223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a22626f6f6b2e637373223b733a32313a226d6f64756c65732f626f6f6b2f626f6f6b2e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/boot_test_1.module', 'boot_test_1', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32313a224561726c7920626f6f747374726170207465737473223b733a31313a226465736372697074696f6e223b733a33393a224120737570706f7274206d6f64756c6520666f7220686f6f6b5f626f6f742074657374696e672e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/boot_test_2.module', 'boot_test_2', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32313a224561726c7920626f6f747374726170207465737473223b733a31313a226465736372697074696f6e223b733a34343a224120737570706f7274206d6f64756c6520666f7220686f6f6b5f626f6f7420686f6f6b2074657374696e672e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/update/tests/ccc_update_test.module', 'ccc_update_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a22434343205570646174652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220757064617465206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/color/color.module', 'color', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a353a22436f6c6f72223b733a31313a226465736372697074696f6e223b733a37303a22416c6c6f77732061646d696e6973747261746f727320746f206368616e67652074686520636f6c6f7220736368656d65206f6620636f6d70617469626c65207468656d65732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a22636f6c6f722e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/comment/comment.module', 'comment', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a373a22436f6d6d656e74223b733a31313a226465736372697074696f6e223b733a35373a22416c6c6f777320757365727320746f20636f6d6d656e74206f6e20616e642064697363757373207075626c697368656420636f6e74656e742e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a343a2274657874223b7d733a353a2266696c6573223b613a323a7b693a303b733a31343a22636f6d6d656e742e6d6f64756c65223b693a313b733a31323a22636f6d6d656e742e74657374223b7d733a393a22636f6e666967757265223b733a32313a2261646d696e2f636f6e74656e742f636f6d6d656e74223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31313a22636f6d6d656e742e637373223b733a32373a226d6f64756c65732f636f6d6d656e742f636f6d6d656e742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/comment/tests/comment_hook_test.module', 'comment_hook_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31383a22436f6d6d656e7420486f6f6b732054657374223b733a31313a226465736372697074696f6e223b733a33383a22537570706f7274206d6f64756c6520666f7220636f6d6d656e7420686f6f6b2074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/common_test.module', 'common_test', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a31313a22436f6d6d6f6e2054657374223b733a31313a226465736372697074696f6e223b733a33323a22537570706f7274206d6f64756c6520666f7220436f6d6d6f6e2074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a31353a22636f6d6d6f6e5f746573742e637373223b733a34303a226d6f64756c65732f73696d706c65746573742f74657374732f636f6d6d6f6e5f746573742e637373223b7d733a353a227072696e74223b613a313a7b733a32313a22636f6d6d6f6e5f746573742e7072696e742e637373223b733a34363a226d6f64756c65732f73696d706c65746573742f74657374732f636f6d6d6f6e5f746573742e7072696e742e637373223b7d7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/file_test.module', 'file_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a393a2246696c652074657374223b733a31313a226465736372697074696f6e223b733a33393a22537570706f7274206d6f64756c6520666f722066696c652068616e646c696e672074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31363a2266696c655f746573742e6d6f64756c65223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/contextual/contextual.module', 'contextual', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a31363a22436f6e7465787475616c206c696e6b73223b733a31313a226465736372697074696f6e223b733a37353a2250726f766964657320636f6e7465787475616c206c696e6b7320746f20706572666f726d20616374696f6e732072656c6174656420746f20656c656d656e7473206f6e206120706167652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31353a22636f6e7465787475616c2e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/overlay/overlay.module', 'overlay', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a373a224f7665726c6179223b733a31313a226465736372697074696f6e223b733a35393a22446973706c617973207468652044727570616c2061646d696e697374726174696f6e20696e7465726661636520696e20616e206f7665726c61792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/dashboard/dashboard.module', 'dashboard', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a393a2244617368626f617264223b733a31313a226465736372697074696f6e223b733a3133363a2250726f766964657320612064617368626f617264207061676520696e207468652061646d696e69737472617469766520696e7465726661636520666f72206f7267616e697a696e672061646d696e697374726174697665207461736b7320616e6420747261636b696e6720696e666f726d6174696f6e2077697468696e20796f757220736974652e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a353a2266696c6573223b613a313a7b693a303b733a31343a2264617368626f6172642e74657374223b7d733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a22626c6f636b223b7d733a393a22636f6e666967757265223b733a32353a2261646d696e2f64617368626f6172642f637573746f6d697a65223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/database_test.module', 'database_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31333a2244617461626173652054657374223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f72204461746162617365206c617965722074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/drupal_autoload_test/drupal_autoload_test.module', 'drupal_autoload_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32353a2244727570616c20636f64652072656769737472792074657374223b733a31313a226465736372697074696f6e223b733a34353a22537570706f7274206d6f64756c6520666f722074657374696e672074686520636f64652072656769737472792e223b733a353a2266696c6573223b613a323a7b693a303b733a33343a2264727570616c5f6175746f6c6f61645f746573745f696e746572666163652e696e63223b693a313b733a33303a2264727570616c5f6175746f6c6f61645f746573745f636c6173732e696e63223b7d733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/filter_test.module', 'filter_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31383a2246696c7465722074657374206d6f64756c65223b733a31313a226465736372697074696f6e223b733a33333a2254657374732066696c74657220686f6f6b7320616e642066756e6374696f6e732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/drupal_system_listing_compatible_test/drupal_system_listing_compatible_test.module', 'drupal_system_listing_compatible_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33373a2244727570616c2073797374656d206c697374696e6720636f6d70617469626c652074657374223b733a31313a226465736372697074696f6e223b733a36323a22537570706f7274206d6f64756c6520666f722074657374696e67207468652064727570616c5f73797374656d5f6c697374696e672066756e6374696f6e2e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/drupal_system_listing_incompatible_test/drupal_system_listing_incompatible_test.module', 'drupal_system_listing_incompatible_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33393a2244727570616c2073797374656d206c697374696e6720696e636f6d70617469626c652074657374223b733a31313a226465736372697074696f6e223b733a36323a22537570706f7274206d6f64756c6520666f722074657374696e67207468652064727570616c5f73797374656d5f6c697374696e672066756e6374696f6e2e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/entity_crud_hook_test.module', 'entity_crud_hook_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32323a22456e74697479204352554420486f6f6b732054657374223b733a31313a226465736372697074696f6e223b733a33353a22537570706f7274206d6f64756c6520666f72204352554420686f6f6b2074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/entity_query_access_test.module', 'entity_query_access_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32343a22456e74697479207175657279206163636573732074657374223b733a31313a226465736372697074696f6e223b733a34393a22537570706f7274206d6f64756c6520666f7220636865636b696e6720656e7469747920717565727920726573756c74732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/error_test.module', 'error_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a224572726f722074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f72206572726f7220616e6420657863657074696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field_ui/field_ui.module', 'field_ui', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a383a224669656c64205549223b733a31313a226465736372697074696f6e223b733a33333a225573657220696e7465726661636520666f7220746865204669656c64204150492e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a31333a226669656c645f75692e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/file/file.module', 'file', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a343a2246696c65223b733a31313a226465736372697074696f6e223b733a32363a22446566696e657320612066696c65206669656c6420747970652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a31353a2274657374732f66696c652e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/file/tests/file_module_test.module', 'file_module_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a393a2246696c652074657374223b733a31313a226465736372697074696f6e223b733a35333a2250726f766964657320686f6f6b7320666f722074657374696e672046696c65206d6f64756c652066756e6374696f6e616c6974792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/forum/forum.module', 'forum', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a353a22466f72756d223b733a31313a226465736372697074696f6e223b733a32373a2250726f76696465732064697363757373696f6e20666f72756d732e223b733a31323a22646570656e64656e63696573223b613a323a7b693a303b733a383a227461786f6e6f6d79223b693a313b733a373a22636f6d6d656e74223b7d733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a22666f72756d2e74657374223b7d733a393a22636f6e666967757265223b733a32313a2261646d696e2f7374727563747572652f666f72756d223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a393a22666f72756d2e637373223b733a32333a226d6f64756c65732f666f72756d2f666f72756d2e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/help/help.module', 'help', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a343a2248656c70223b733a31313a226465736372697074696f6e223b733a33353a224d616e616765732074686520646973706c6179206f66206f6e6c696e652068656c702e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a2268656c702e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/image/image.module', 'image', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a353a22496d616765223b733a31313a226465736372697074696f6e223b733a33343a2250726f766964657320696d616765206d616e6970756c6174696f6e20746f6f6c732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a343a2266696c65223b7d733a353a2266696c6573223b613a313a7b693a303b733a31303a22696d6167652e74657374223b7d733a393a22636f6e666967757265223b733a33313a2261646d696e2f636f6e6669672f6d656469612f696d6167652d7374796c6573223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/image/tests/image_module_styles_test.module', 'image_module_styles_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31373a22496d616765205374796c65732074657374223b733a31313a226465736372697074696f6e223b733a38303a2250726f7669646573206164646974696f6e616c20686f6f6b20696d706c656d656e746174696f6e7320666f722074657374696e6720496d616765205374796c65732066756e6374696f6e616c6974792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a33313a22696d6167655f6d6f64756c655f7374796c65735f746573742e6d6f64756c65223b7d733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a31373a22696d6167655f6d6f64756c655f74657374223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/image/tests/image_module_test.module', 'image_module_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a22496d6167652074657374223b733a31313a226465736372697074696f6e223b733a36393a2250726f766964657320686f6f6b20696d706c656d656e746174696f6e7320666f722074657374696e6720496d616765206d6f64756c652066756e6374696f6e616c6974792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a32343a22696d6167655f6d6f64756c655f746573742e6d6f64756c65223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/list/list.module', 'list', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a343a224c697374223b733a31313a226465736372697074696f6e223b733a36393a22446566696e6573206c697374206669656c642074797065732e205573652077697468204f7074696f6e7320746f206372656174652073656c656374696f6e206c697374732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a323a7b693a303b733a353a226669656c64223b693a313b733a373a226f7074696f6e73223b7d733a353a2266696c6573223b613a313a7b693a303b733a31353a2274657374732f6c6973742e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/list/tests/list_test.module', 'list_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a393a224c6973742074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220746865204c697374206d6f64756c652074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/locale/locale.module', 'locale', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a363a224c6f63616c65223b733a31313a226465736372697074696f6e223b733a3131393a2241646473206c616e67756167652068616e646c696e672066756e6374696f6e616c69747920616e6420656e61626c657320746865207472616e736c6174696f6e206f6620746865207573657220696e7465726661636520746f206c616e677561676573206f74686572207468616e20456e676c6973682e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a226c6f63616c652e74657374223b7d733a393a22636f6e666967757265223b733a33303a2261646d696e2f636f6e6669672f726567696f6e616c2f6c616e6775616765223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/locale/tests/locale_test.module', 'locale_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a224c6f63616c652054657374223b733a31313a226465736372697074696f6e223b733a34323a22537570706f7274206d6f64756c6520666f7220746865206c6f63616c65206c617965722074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/menu/menu.module', 'menu', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a343a224d656e75223b733a31313a226465736372697074696f6e223b733a36303a22416c6c6f77732061646d696e6973747261746f727320746f20637573746f6d697a65207468652073697465206e617669676174696f6e206d656e752e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a226d656e752e74657374223b7d733a393a22636f6e666967757265223b733a32303a2261646d696e2f7374727563747572652f6d656e75223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/menu_test.module', 'menu_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a22486f6f6b206d656e75207465737473223b733a31313a226465736372697074696f6e223b733a33373a22537570706f7274206d6f64756c6520666f72206d656e7520686f6f6b2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/module_test.module', 'module_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a224d6f64756c652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f72206d6f64756c652073797374656d2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/node/tests/node_test.module', 'node_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31373a224e6f6465206d6f64756c65207465737473223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f72206e6f64652072656c617465642074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/node/tests/node_test_exception.module', 'node_test_exception', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32373a224e6f6465206d6f64756c6520657863657074696f6e207465737473223b733a31313a226465736372697074696f6e223b733a35303a22537570706f7274206d6f64756c6520666f72206e6f64652072656c6174656420657863657074696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/openid/openid.module', 'openid', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a363a224f70656e4944223b733a31313a226465736372697074696f6e223b733a34383a22416c6c6f777320757365727320746f206c6f6720696e746f20796f75722073697465207573696e67204f70656e49442e223b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a227061636b616765223b733a343a22436f7265223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a226f70656e69642e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/openid/tests/openid_test.module', 'openid_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32313a224f70656e49442064756d6d792070726f7669646572223b733a31313a226465736372697074696f6e223b733a33333a224f70656e49442070726f7669646572207573656420666f722074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a363a226f70656e6964223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/options/options.module', 'options', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a373a224f7074696f6e73223b733a31313a226465736372697074696f6e223b733a38323a22446566696e65732073656c656374696f6e2c20636865636b20626f7820616e6420726164696f20627574746f6e207769646765747320666f72207465787420616e64206e756d65726963206669656c64732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a31323a226f7074696f6e732e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/path/path.module', 'path', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a343a2250617468223b733a31313a226465736372697074696f6e223b733a32383a22416c6c6f777320757365727320746f2072656e616d652055524c732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a22706174682e74657374223b7d733a393a22636f6e666967757265223b733a32343a2261646d696e2f636f6e6669672f7365617263682f70617468223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/path_test.module', 'path_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a22486f6f6b2070617468207465737473223b733a31313a226465736372697074696f6e223b733a33373a22537570706f7274206d6f64756c6520666f72207061746820686f6f6b2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/poll/poll.module', 'poll', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a343a22506f6c6c223b733a31313a226465736372697074696f6e223b733a39353a22416c6c6f777320796f7572207369746520746f206361707475726520766f746573206f6e20646966666572656e7420746f7069637320696e2074686520666f726d206f66206d756c7469706c652063686f696365207175657374696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a22706f6c6c2e74657374223b7d733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a22706f6c6c2e637373223b733a32313a226d6f64756c65732f706f6c6c2f706f6c6c2e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/profile/profile.module', 'profile', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a373a2250726f66696c65223b733a31313a226465736372697074696f6e223b733a33363a22537570706f72747320636f6e666967757261626c6520757365722070726f66696c65732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31323a2270726f66696c652e74657374223b7d733a393a22636f6e666967757265223b733a32373a2261646d696e2f636f6e6669672f70656f706c652f70726f66696c65223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/psr_0_test/psr_0_test.module', 'psr_0_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31363a225053522d302054657374206361736573223b733a31313a226465736372697074696f6e223b733a34343a225465737420636c617373657320746f20626520646973636f76657265642062792073696d706c65746573742e223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/psr_4_test/psr_4_test.module', 'psr_4_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31363a225053522d342054657374206361736573223b733a31313a226465736372697074696f6e223b733a34343a225465737420636c617373657320746f20626520646973636f76657265642062792073696d706c65746573742e223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/rdf/rdf.module', 'rdf', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a333a22524446223b733a31313a226465736372697074696f6e223b733a3134383a22456e72696368657320796f757220636f6e74656e742077697468206d6574616461746120746f206c6574206f74686572206170706c69636174696f6e732028652e672e2073656172636820656e67696e65732c2061676772656761746f7273292062657474657220756e6465727374616e64206974732072656c6174696f6e736869707320616e6420617474726962757465732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a383a227264662e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/rdf/tests/rdf_test.module', 'rdf_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31363a22524446206d6f64756c65207465737473223b733a31313a226465736372697074696f6e223b733a33383a22537570706f7274206d6f64756c6520666f7220524446206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a343a22626c6f67223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/requirements1_test.module', 'requirements1_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31393a22526571756972656d656e747320312054657374223b733a31313a226465736372697074696f6e223b733a38303a22546573747320746861742061206d6f64756c65206973206e6f7420696e7374616c6c6564207768656e206974206661696c7320686f6f6b5f726571756972656d656e74732827696e7374616c6c27292e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/translation/tests/translation_test.module', 'translation_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32343a22436f6e74656e74205472616e736c6174696f6e2054657374223b733a31313a226465736372697074696f6e223b733a34393a22537570706f7274206d6f64756c6520666f722074686520636f6e74656e74207472616e736c6174696f6e2074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/requirements2_test.module', 'requirements2_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31393a22526571756972656d656e747320322054657374223b733a31313a226465736372697074696f6e223b733a39383a22546573747320746861742061206d6f64756c65206973206e6f7420696e7374616c6c6564207768656e20746865206f6e6520697420646570656e6473206f6e206661696c7320686f6f6b5f726571756972656d656e74732827696e7374616c6c292e223b733a31323a22646570656e64656e63696573223b613a323a7b693a303b733a31383a22726571756972656d656e7473315f74657374223b693a313b733a373a22636f6d6d656e74223b7d733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/search/search.module', 'search', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a363a22536561726368223b733a31313a226465736372697074696f6e223b733a33363a22456e61626c657320736974652d77696465206b6579776f726420736561726368696e672e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a323a7b693a303b733a31393a227365617263682e657874656e6465722e696e63223b693a313b733a31313a227365617263682e74657374223b7d733a393a22636f6e666967757265223b733a32383a2261646d696e2f636f6e6669672f7365617263682f73657474696e6773223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a227365617263682e637373223b733a32353a226d6f64756c65732f7365617263682f7365617263682e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/search/tests/search_embedded_form.module', 'search_embedded_form', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32303a2253656172636820656d62656464656420666f726d223b733a31313a226465736372697074696f6e223b733a35393a22537570706f7274206d6f64756c6520666f7220736561726368206d6f64756c652074657374696e67206f6620656d62656464656420666f726d732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/search/tests/search_extra_type.module', 'search_extra_type', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31363a2254657374207365617263682074797065223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220736561726368206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/search/tests/search_node_tags.module', 'search_node_tags', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32313a225465737420736561726368206e6f64652074616773223b733a31313a226465736372697074696f6e223b733a34343a22537570706f7274206d6f64756c6520666f72204e6f64652073656172636820746167732074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/session_test.module', 'session_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31323a2253657373696f6e2074657374223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f722073657373696f6e20646174612074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/shortcut/shortcut.module', 'shortcut', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a383a2253686f7274637574223b733a31313a226465736372697074696f6e223b733a36303a22416c6c6f777320757365727320746f206d616e61676520637573746f6d697a61626c65206c69737473206f662073686f7274637574206c696e6b732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31333a2273686f72746375742e74657374223b7d733a393a22636f6e666967757265223b733a33363a2261646d696e2f636f6e6669672f757365722d696e746572666163652f73686f7274637574223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_requires_null_version_test.module', 'system_requires_null_version_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33333a2253797374656d207265717569726573206e756c6c2076657273696f6e2074657374223b733a31313a226465736372697074696f6e223b733a34343a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d5f6d6f64756c657328292e223b733a373a227061636b616765223b733a31363a224f6e6c7920466f722054657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a303b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a32343a2273797374656d5f6e756c6c5f76657273696f6e5f74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_test.module', 'system_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a2253797374656d2074657374223b733a31313a226465736372697074696f6e223b733a33343a22537570706f7274206d6f64756c6520666f722073797374656d2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31383a2273797374656d5f746573742e6d6f64756c65223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/simpletest.module', 'simpletest', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a373a2254657374696e67223b733a31313a226465736372697074696f6e223b733a35333a2250726f76696465732061206672616d65776f726b20666f7220756e697420616e642066756e6374696f6e616c2074657374696e672e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a35313a7b693a303b733a31353a2273696d706c65746573742e74657374223b693a313b733a32343a2264727570616c5f7765625f746573745f636173652e706870223b693a323b733a31383a2274657374732f616374696f6e732e74657374223b693a333b733a31353a2274657374732f616a61782e74657374223b693a343b733a31363a2274657374732f62617463682e74657374223b693a353b733a31353a2274657374732f626f6f742e74657374223b693a363b733a32303a2274657374732f626f6f7473747261702e74657374223b693a373b733a31363a2274657374732f63616368652e74657374223b693a383b733a31373a2274657374732f636f6d6d6f6e2e74657374223b693a393b733a32343a2274657374732f64617461626173655f746573742e74657374223b693a31303b733a32323a2274657374732f656e746974795f637275642e74657374223b693a31313b733a33323a2274657374732f656e746974795f637275645f686f6f6b5f746573742e74657374223b693a31323b733a32333a2274657374732f656e746974795f71756572792e74657374223b693a31333b733a31363a2274657374732f6572726f722e74657374223b693a31343b733a31353a2274657374732f66696c652e74657374223b693a31353b733a32333a2274657374732f66696c657472616e736665722e74657374223b693a31363b733a31353a2274657374732f666f726d2e74657374223b693a31373b733a31363a2274657374732f67726170682e74657374223b693a31383b733a31363a2274657374732f696d6167652e74657374223b693a31393b733a31353a2274657374732f6c6f636b2e74657374223b693a32303b733a31353a2274657374732f6d61696c2e74657374223b693a32313b733a31353a2274657374732f6d656e752e74657374223b693a32323b733a31373a2274657374732f6d6f64756c652e74657374223b693a32333b733a31363a2274657374732f70616765722e74657374223b693a32343b733a31393a2274657374732f70617373776f72642e74657374223b693a32353b733a31353a2274657374732f706174682e74657374223b693a32363b733a31393a2274657374732f72656769737472792e74657374223b693a32373b733a32383a2274657374732f726571756573745f73616e6974697a65722e74657374223b693a32383b733a31373a2274657374732f736368656d612e74657374223b693a32393b733a31383a2274657374732f73657373696f6e2e74657374223b693a33303b733a32303a2274657374732f7461626c65736f72742e74657374223b693a33313b733a31363a2274657374732f7468656d652e74657374223b693a33323b733a31383a2274657374732f756e69636f64652e74657374223b693a33333b733a31373a2274657374732f7570646174652e74657374223b693a33343b733a31373a2274657374732f786d6c7270632e74657374223b693a33353b733a32363a2274657374732f757067726164652f757067726164652e74657374223b693a33363b733a33343a2274657374732f757067726164652f757067726164652e636f6d6d656e742e74657374223b693a33373b733a33333a2274657374732f757067726164652f757067726164652e66696c7465722e74657374223b693a33383b733a33323a2274657374732f757067726164652f757067726164652e666f72756d2e74657374223b693a33393b733a33333a2274657374732f757067726164652f757067726164652e6c6f63616c652e74657374223b693a34303b733a33313a2274657374732f757067726164652f757067726164652e6d656e752e74657374223b693a34313b733a33313a2274657374732f757067726164652f757067726164652e6e6f64652e74657374223b693a34323b733a33353a2274657374732f757067726164652f757067726164652e7461786f6e6f6d792e74657374223b693a34333b733a33343a2274657374732f757067726164652f757067726164652e747269676765722e74657374223b693a34343b733a33393a2274657374732f757067726164652f757067726164652e7472616e736c617461626c652e74657374223b693a34353b733a33333a2274657374732f757067726164652f757067726164652e75706c6f61642e74657374223b693a34363b733a33313a2274657374732f757067726164652f757067726164652e757365722e74657374223b693a34373b733a33363a2274657374732f757067726164652f7570646174652e61676772656761746f722e74657374223b693a34383b733a33333a2274657374732f757067726164652f7570646174652e747269676765722e74657374223b693a34393b733a33313a2274657374732f757067726164652f7570646174652e6669656c642e74657374223b693a35303b733a33303a2274657374732f757067726164652f7570646174652e757365722e74657374223b7d733a393a22636f6e666967757265223b733a34313a2261646d696e2f636f6e6669672f646576656c6f706d656e742f74657374696e672f73657474696e6773223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/statistics/statistics.module', 'statistics', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a2253746174697374696373223b733a31313a226465736372697074696f6e223b733a33373a224c6f677320616363657373207374617469737469637320666f7220796f757220736974652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31353a22737461746973746963732e74657374223b7d733a393a22636f6e666967757265223b733a33303a2261646d696e2f636f6e6669672f73797374656d2f73746174697374696373223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/syslog/syslog.module', 'syslog', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a363a225379736c6f67223b733a31313a226465736372697074696f6e223b733a34313a224c6f677320616e64207265636f7264732073797374656d206576656e747320746f207379736c6f672e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a227379736c6f672e74657374223b7d733a393a22636f6e666967757265223b733a33323a2261646d696e2f636f6e6669672f646576656c6f706d656e742f6c6f6767696e67223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_admin_test.module', 'system_admin_test', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a31373a2253797374656d2041646d696e2054657374223b733a31313a226465736372697074696f6e223b733a34343a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d2e61646d696e2e696e632e223b733a373a227061636b616765223b733a31363a224f6e6c7920466f722054657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a303b733a393a22636f6e666967757265223b733a31333a22636f6e6669672f62726f6b656e223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/system/tests/system_cron_test.module', 'system_cron_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31363a2253797374656d2043726f6e2054657374223b733a31313a226465736372697074696f6e223b733a34353a22537570706f7274206d6f64756c6520666f722074657374696e67207468652073797374656d5f63726f6e28292e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_dependencies_test.module', 'system_dependencies_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32323a2253797374656d20646570656e64656e63792074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d20646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a31393a225f6d697373696e675f646570656e64656e6379223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/tracker/tracker.module', 'tracker', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a373a22547261636b6572223b733a31313a226465736372697074696f6e223b733a34353a22456e61626c657320747261636b696e67206f6620726563656e7420636f6e74656e7420666f722075736572732e223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a373a22636f6d6d656e74223b7d733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31323a22747261636b65722e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_incompatible_core_version_dependencies_test.module', 'system_incompatible_core_version_dependencies_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a35303a2253797374656d20696e636f6d70617469626c6520636f72652076657273696f6e20646570656e64656e636965732074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d20646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a33373a2273797374656d5f696e636f6d70617469626c655f636f72655f76657273696f6e5f74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_incompatible_core_version_test.module', 'system_incompatible_core_version_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33373a2253797374656d20696e636f6d70617469626c6520636f72652076657273696f6e2074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d20646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22352e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_incompatible_module_version_dependencies_test.module', 'system_incompatible_module_version_dependencies_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a35323a2253797374656d20696e636f6d70617469626c65206d6f64756c652076657273696f6e20646570656e64656e636965732074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d20646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a34363a2273797374656d5f696e636f6d70617469626c655f6d6f64756c655f76657273696f6e5f7465737420283e322e3029223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_incompatible_module_version_test.module', 'system_incompatible_module_version_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33393a2253797374656d20696e636f6d70617469626c65206d6f64756c652076657273696f6e2074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e672073797374656d20646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_null_version_test.module', 'system_null_version_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32343a2253797374656d206e756c6c2076657273696f6e2074657374223b733a31313a226465736372697074696f6e223b733a34373a22537570706f7274206d6f64756c6520666f722074657374696e6720776974682061206e756c6c2076657273696f6e2e223b733a373a227061636b616765223b733a31363a224f6e6c7920466f722054657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a303b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/system_project_namespace_test.module', 'system_project_namespace_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32393a2253797374656d2070726f6a656374206e616d6573706163652074657374223b733a31313a226465736372697074696f6e223b733a35383a22537570706f7274206d6f64756c6520666f722074657374696e672070726f6a656374206e616d65737061636520646570656e64656e636965732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a31333a2264727570616c3a66696c746572223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/taxonomy/taxonomy.module', 'taxonomy', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a383a225461786f6e6f6d79223b733a31313a226465736372697074696f6e223b733a33383a22456e61626c6573207468652063617465676f72697a6174696f6e206f6620636f6e74656e742e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a373a226f7074696f6e73223b7d733a353a2266696c6573223b613a323a7b693a303b733a31353a227461786f6e6f6d792e6d6f64756c65223b693a313b733a31333a227461786f6e6f6d792e74657374223b7d733a393a22636f6e666967757265223b733a32343a2261646d696e2f7374727563747572652f7461786f6e6f6d79223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/taxonomy_nodes_test.module', 'taxonomy_nodes_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33313a225461786f6e6f6d79206d6f64756c65206e6f6465206c697374207465737473223b733a31313a226465736372697074696f6e223b733a35343a22537570706f7274206d6f64756c6520666f72207461786f6e6f6d79206e6f6465206c6973742072656c617465642074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/taxonomy_test.module', 'taxonomy_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32303a225461786f6e6f6d792074657374206d6f64756c65223b733a31313a226465736372697074696f6e223b733a34353a222254657374732066756e6374696f6e7320616e6420686f6f6b73206e6f74207573656420696e20636f7265222e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a383a227461786f6e6f6d79223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/theme_test.module', 'theme_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a225468656d652074657374223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f72207468656d652073797374656d2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/toolbar/toolbar.module', 'toolbar', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a373a22546f6f6c626172223b733a31313a226465736372697074696f6e223b733a39393a2250726f7669646573206120746f6f6c62617220746861742073686f77732074686520746f702d6c6576656c2061646d696e697374726174696f6e206d656e75206974656d7320616e64206c696e6b732066726f6d206f74686572206d6f64756c65732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a353a2266696c6573223b613a313a7b693a303b733a31323a22746f6f6c6261722e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/trigger/trigger.module', 'trigger', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a373a2254726967676572223b733a31313a226465736372697074696f6e223b733a39303a22456e61626c657320616374696f6e7320746f206265206669726564206f6e206365727461696e2073797374656d206576656e74732c2073756368206173207768656e206e657720636f6e74656e7420697320637265617465642e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31323a22747269676765722e74657374223b7d733a393a22636f6e666967757265223b733a32333a2261646d696e2f7374727563747572652f74726967676572223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/trigger/tests/trigger_test.module', 'trigger_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31323a22547269676765722054657374223b733a31313a226465736372697074696f6e223b733a33333a22537570706f7274206d6f64756c6520666f7220547269676765722074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/update/update.module', 'update', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31343a22557064617465206d616e61676572223b733a31313a226465736372697074696f6e223b733a3130343a22436865636b7320666f7220617661696c61626c6520757064617465732c20616e642063616e207365637572656c7920696e7374616c6c206f7220757064617465206d6f64756c657320616e64207468656d65732076696120612077656220696e746572666163652e223b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a227061636b616765223b733a343a22436f7265223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a227570646174652e74657374223b7d733a393a22636f6e666967757265223b733a33303a2261646d696e2f7265706f7274732f757064617465732f73657474696e6773223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/update_script_test.module', 'update_script_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31383a22557064617465207363726970742074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220757064617465207363726970742074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/update/tests/update_test.module', 'update_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a225570646174652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220757064617465206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/update_test_1.module', 'update_test_1', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a225570646174652074657374223b733a31313a226465736372697074696f6e223b733a33343a22537570706f7274206d6f64756c6520666f72207570646174652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/url_alter_test.module', 'url_alter_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a2255726c5f616c746572207465737473223b733a31313a226465736372697074696f6e223b733a34353a224120737570706f7274206d6f64756c657320666f722075726c5f616c74657220686f6f6b2074657374696e672e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/tests/user_flood_test.module', 'user_flood_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33313a2255736572206d6f64756c6520666c6f6f6420636f6e74726f6c207465737473223b733a31313a226465736372697074696f6e223b733a34363a22537570706f7274206d6f64756c6520666f72207573657220666c6f6f6420636f6e74726f6c2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/xmlrpc_test.module', 'xmlrpc_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31323a22584d4c2d5250432054657374223b733a31313a226465736372697074696f6e223b733a37353a22537570706f7274206d6f64756c6520666f7220584d4c2d525043207465737473206163636f7264696e6720746f207468652076616c696461746f72312073706563696669636174696f6e2e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/filter/filter.module', 'filter', 'module', '', 1, 0, 7010, 0, '\x613a31343a7b733a343a226e616d65223b733a363a2246696c746572223b733a31313a226465736372697074696f6e223b733a34333a2246696c7465727320636f6e74656e7420696e207072657061726174696f6e20666f7220646973706c61792e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31313a2266696c7465722e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a32383a2261646d696e2f636f6e6669672f636f6e74656e742f666f726d617473223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/translation/translation.module', 'translation', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a31393a22436f6e74656e74207472616e736c6174696f6e223b733a31313a226465736372697074696f6e223b733a35373a22416c6c6f777320636f6e74656e7420746f206265207472616e736c6174656420696e746f20646966666572656e74206c616e6775616765732e223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a363a226c6f63616c65223b7d733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31363a227472616e736c6174696f6e2e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('themes/garland/garland.info', 'garland', 'theme', 'themes/engines/phptemplate/phptemplate.engine', 0, 0, -1, 0, '\x613a31373a7b733a343a226e616d65223b733a373a224761726c616e64223b733a31313a226465736372697074696f6e223b733a3131313a2241206d756c74692d636f6c756d6e207468656d652077686963682063616e20626520636f6e6669677572656420746f206d6f6469667920636f6c6f727320616e6420737769746368206265747765656e20666978656420616e6420666c756964207769647468206c61796f7574732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a313a7b733a393a227374796c652e637373223b733a32343a227468656d65732f6761726c616e642f7374796c652e637373223b7d733a353a227072696e74223b613a313a7b733a393a227072696e742e637373223b733a32343a227468656d65732f6761726c616e642f7072696e742e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a31333a226761726c616e645f7769647468223b733a353a22666c756964223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32393a227468656d65732f6761726c616e642f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/form_test.module', 'form_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31323a22466f726d4150492054657374223b733a31313a226465736372697074696f6e223b733a33343a22537570706f7274206d6f64756c6520666f7220466f726d204150492074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/node/tests/node_access_test.module', 'node_access_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32343a224e6f6465206d6f64756c6520616363657373207465737473223b733a31313a226465736372697074696f6e223b733a34333a22537570706f7274206d6f64756c6520666f72206e6f6465207065726d697373696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('themes/seven/seven.info', 'seven', 'theme', 'themes/engines/phptemplate/phptemplate.engine', 0, 0, -1, 0, '\x613a31373a7b733a343a226e616d65223b733a353a22536576656e223b733a31313a226465736372697074696f6e223b733a36353a22412073696d706c65206f6e652d636f6c756d6e2c207461626c656c6573732c20666c7569642077696474682061646d696e697374726174696f6e207468656d652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a363a2273637265656e223b613a323a7b733a393a2272657365742e637373223b733a32323a227468656d65732f736576656e2f72657365742e637373223b733a393a227374796c652e637373223b733a32323a227468656d65732f736576656e2f7374796c652e637373223b7d7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2231223b7d733a373a22726567696f6e73223b613a353a7b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31333a22736964656261725f6669727374223b733a31333a2246697273742073696465626172223b7d733a31343a22726567696f6e735f68696464656e223b613a333a7b693a303b733a31333a22736964656261725f6669727374223b693a313b733a383a22706167655f746f70223b693a323b733a31313a22706167655f626f74746f6d223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f736576656e2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/entity_cache_test.module', 'entity_cache_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31373a22456e746974792063616368652074657374223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f722074657374696e6720656e746974792063616368652e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a32383a22656e746974795f63616368655f746573745f646570656e64656e6379223b7d733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/system/system.module', 'system', 'module', '', 1, 0, 7085, 0, '\x613a31343a7b733a343a226e616d65223b733a363a2253797374656d223b733a31313a226465736372697074696f6e223b733a35343a2248616e646c65732067656e6572616c207369746520636f6e66696775726174696f6e20666f722061646d696e6973747261746f72732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a363a7b693a303b733a31393a2273797374656d2e61726368697665722e696e63223b693a313b733a31353a2273797374656d2e6d61696c2e696e63223b693a323b733a31363a2273797374656d2e71756575652e696e63223b693a333b733a31343a2273797374656d2e7461722e696e63223b693a343b733a31383a2273797374656d2e757064617465722e696e63223b693a353b733a31313a2273797374656d2e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a31393a2261646d696e2f636f6e6669672f73797374656d223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/tests/field_test.module', 'field_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31343a224669656c64204150492054657374223b733a31313a226465736372697074696f6e223b733a33393a22537570706f7274206d6f64756c6520666f7220746865204669656c64204150492074657374732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a353a2266696c6573223b613a313a7b693a303b733a32313a226669656c645f746573742e656e746974792e696e63223b7d733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/php/php.module', 'php', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a31303a225048502066696c746572223b733a31313a226465736372697074696f6e223b733a35303a22416c6c6f777320656d6265646465642050485020636f64652f736e69707065747320746f206265206576616c75617465642e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a383a227068702e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/actions_loop_test.module', 'actions_loop_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31373a22416374696f6e73206c6f6f702074657374223b733a31313a226465736372697074696f6e223b733a33393a22537570706f7274206d6f64756c6520666f7220616374696f6e206c6f6f702074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/tests/user_email_validation_test.module', 'user_email_validation_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33353a2255736572206d6f64756c6520652d6d61696c2076616c69646174696f6e207465737473223b733a31313a226465736372697074696f6e223b733a35303a22537570706f7274206d6f64756c6520666f72207573657220652d6d61696c2076616c69646174696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/blog/blog.module', 'blog', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a343a22426c6f67223b733a31313a226465736372697074696f6e223b733a32353a22456e61626c6573206d756c74692d7573657220626c6f67732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a393a22626c6f672e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/entity_cache_test_dependency.module', 'entity_cache_test_dependency', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32383a22456e74697479206361636865207465737420646570656e64656e6379223b733a31313a226465736372697074696f6e223b733a35313a22537570706f727420646570656e64656e6379206d6f64756c6520666f722074657374696e6720656e746974792063616368652e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/aggregator/tests/aggregator_test.module', 'aggregator_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32333a2241676772656761746f72206d6f64756c65207465737473223b733a31313a226465736372697074696f6e223b733a34363a22537570706f7274206d6f64756c6520666f722061676772656761746f722072656c617465642074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/update_test_3.module', 'update_test_3', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a225570646174652074657374223b733a31313a226465736372697074696f6e223b733a33343a22537570706f7274206d6f64756c6520666f72207570646174652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/contact/contact.module', 'contact', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a373a22436f6e74616374223b733a31313a226465736372697074696f6e223b733a36313a22456e61626c65732074686520757365206f6620626f746820706572736f6e616c20616e6420736974652d7769646520636f6e7461637420666f726d732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31323a22636f6e746163742e74657374223b7d733a393a22636f6e666967757265223b733a32333a2261646d696e2f7374727563747572652f636f6e74616374223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('themes/bartik/bartik.info', 'bartik', 'theme', 'themes/engines/phptemplate/phptemplate.engine', 1, 0, -1, 0, '\x613a31373a7b733a343a226e616d65223b733a363a2242617274696b223b733a31313a226465736372697074696f6e223b733a34383a224120666c657869626c652c207265636f6c6f7261626c65207468656d652077697468206d616e7920726567696f6e732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a323a7b733a333a22616c6c223b613a333a7b733a31343a226373732f6c61796f75742e637373223b733a32383a227468656d65732f62617274696b2f6373732f6c61796f75742e637373223b733a31333a226373732f7374796c652e637373223b733a32373a227468656d65732f62617274696b2f6373732f7374796c652e637373223b733a31343a226373732f636f6c6f72732e637373223b733a32383a227468656d65732f62617274696b2f6373732f636f6c6f72732e637373223b7d733a353a227072696e74223b613a313a7b733a31333a226373732f7072696e742e637373223b733a32373a227468656d65732f62617274696b2f6373732f7072696e742e637373223b7d7d733a373a22726567696f6e73223b613a31373a7b733a363a22686561646572223b733a363a22486561646572223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a383a226665617475726564223b733a383a224665617475726564223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a31333a22736964656261725f6669727374223b733a31333a2253696465626172206669727374223b733a31343a22736964656261725f7365636f6e64223b733a31343a2253696465626172207365636f6e64223b733a31343a2274726970747963685f6669727374223b733a31343a225472697074796368206669727374223b733a31353a2274726970747963685f6d6964646c65223b733a31353a225472697074796368206d6964646c65223b733a31333a2274726970747963685f6c617374223b733a31333a225472697074796368206c617374223b733a31383a22666f6f7465725f6669727374636f6c756d6e223b733a31393a22466f6f74657220666972737420636f6c756d6e223b733a31393a22666f6f7465725f7365636f6e64636f6c756d6e223b733a32303a22466f6f746572207365636f6e6420636f6c756d6e223b733a31383a22666f6f7465725f7468697264636f6c756d6e223b733a31393a22466f6f74657220746869726420636f6c756d6e223b733a31393a22666f6f7465725f666f75727468636f6c756d6e223b733a32303a22466f6f74657220666f7572746820636f6c756d6e223b733a363a22666f6f746572223b733a363a22466f6f746572223b7d733a383a2273657474696e6773223b613a313a7b733a32303a2273686f72746375745f6d6f64756c655f6c696e6b223b733a313a2230223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32383a227468656d65732f62617274696b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/batch_test.module', 'batch_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31343a224261746368204150492074657374223b733a31313a226465736372697074696f6e223b733a33353a22537570706f7274206d6f64756c6520666f72204261746368204150492074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/common_test_cron_helper.module', 'common_test_cron_helper', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32333a22436f6d6d6f6e20546573742043726f6e2048656c706572223b733a31313a226465736372697074696f6e223b733a35363a2248656c706572206d6f64756c6520666f722043726f6e52756e54657374436173653a3a7465737443726f6e457863657074696f6e7328292e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/dblog/dblog.module', 'dblog', 'module', '', 1, 1, 7003, 0, '\x613a31323a7b733a343a226e616d65223b733a31363a224461746162617365206c6f6767696e67223b733a31313a226465736372697074696f6e223b733a34373a224c6f677320616e64207265636f7264732073797374656d206576656e747320746f207468652064617461626173652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a2264626c6f672e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('themes/stark/stark.info', 'stark', 'theme', 'themes/engines/phptemplate/phptemplate.engine', 0, 0, -1, 0, '\x613a31363a7b733a343a226e616d65223b733a353a22537461726b223b733a31313a226465736372697074696f6e223b733a3230383a2254686973207468656d652064656d6f6e737472617465732044727570616c27732064656661756c742048544d4c206d61726b757020616e6420435353207374796c65732e20546f206c6561726e20686f7720746f206275696c6420796f7572206f776e207468656d6520616e64206f766572726964652044727570616c27732064656661756c7420636f64652c2073656520746865203c6120687265663d22687474703a2f2f64727570616c2e6f72672f7468656d652d6775696465223e5468656d696e672047756964653c2f613e2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31303a226c61796f75742e637373223b733a32333a227468656d65732f737461726b2f6c61796f75742e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a363a22656e67696e65223b733a31313a2270687074656d706c617465223b733a373a22726567696f6e73223b613a393a7b733a31333a22736964656261725f6669727374223b733a31323a224c6566742073696465626172223b733a31343a22736964656261725f7365636f6e64223b733a31333a2252696768742073696465626172223b733a373a22636f6e74656e74223b733a373a22436f6e74656e74223b733a363a22686561646572223b733a363a22486561646572223b733a363a22666f6f746572223b733a363a22466f6f746572223b733a31313a22686967686c696768746564223b733a31313a22486967686c696768746564223b733a343a2268656c70223b733a343a2248656c70223b733a383a22706167655f746f70223b733a383a225061676520746f70223b733a31313a22706167655f626f74746f6d223b733a31313a225061676520626f74746f6d223b7d733a383a226665617475726573223b613a393a7b693a303b733a343a226c6f676f223b693a313b733a373a2266617669636f6e223b693a323b733a343a226e616d65223b693a333b733a363a22736c6f67616e223b693a343b733a31373a226e6f64655f757365725f70696374757265223b693a353b733a32303a22636f6d6d656e745f757365725f70696374757265223b693a363b733a32353a22636f6d6d656e745f757365725f766572696669636174696f6e223b693a373b733a393a226d61696e5f6d656e75223b693a383b733a31343a227365636f6e646172795f6d656e75223b7d733a31303a2273637265656e73686f74223b733a32373a227468656d65732f737461726b2f73637265656e73686f742e706e67223b733a333a22706870223b733a353a22352e332e33223b733a373a2273637269707473223b613a303a7b7d733a353a226d74696d65223b693a313637383930323533303b733a31343a22726567696f6e735f68696464656e223b613a323a7b693a303b733a383a22706167655f746f70223b693a313b733a31313a22706167655f626f74746f6d223b7d7d');
INSERT INTO public.system VALUES ('modules/block/block.module', 'block', 'module', '', 1, 0, 7009, -5, '\x613a31333a7b733a343a226e616d65223b733a353a22426c6f636b223b733a31313a226465736372697074696f6e223b733a3134303a22436f6e74726f6c73207468652076697375616c206275696c64696e6720626c6f636b732061207061676520697320636f6e737472756374656420776974682e20426c6f636b732061726520626f786573206f6620636f6e74656e742072656e646572656420696e746f20616e20617265612c206f7220726567696f6e2c206f6620612077656220706167652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31303a22626c6f636b2e74657374223b7d733a393a22636f6e666967757265223b733a32313a2261646d696e2f7374727563747572652f626c6f636b223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/tests/user_session_test.module', 'user_session_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32353a2255736572206d6f64756c652073657373696f6e207465737473223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f7220757365722073657373696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/aggregator/aggregator.module', 'aggregator', 'module', '', 0, 0, -1, 0, '\x613a31343a7b733a343a226e616d65223b733a31303a2241676772656761746f72223b733a31313a226465736372697074696f6e223b733a35373a22416767726567617465732073796e6469636174656420636f6e74656e7420285253532c205244462c20616e642041746f6d206665656473292e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a313a7b693a303b733a31353a2261676772656761746f722e74657374223b7d733a393a22636f6e666967757265223b733a34313a2261646d696e2f636f6e6669672f73657276696365732f61676772656761746f722f73657474696e6773223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31343a2261676772656761746f722e637373223b733a33333a226d6f64756c65732f61676772656761746f722f61676772656761746f722e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/ajax_forms_test.module', 'ajax_forms_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32363a22414a415820666f726d2074657374206d6f636b206d6f64756c65223b733a31313a226465736372697074696f6e223b733a32353a225465737420666f7220414a415820666f726d2063616c6c732e223b733a343a22636f7265223b733a333a22372e78223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/ajax_test.module', 'ajax_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a393a22414a41582054657374223b733a31313a226465736372697074696f6e223b733a34303a22537570706f7274206d6f64756c6520666f7220414a4158206672616d65776f726b2074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/tests/anonymous_user_unblock_test.module', 'anonymous_user_unblock_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a33353a22416e6f6e796d6f7573207573657220756e626c6f636b20616374696f6e207465737473223b733a31313a226465736372697074696f6e223b733a35373a22537570706f7274206d6f64756c6520666f7220616e6f6e796d6f7573207573657220756e626c6f636b20616374696f6e2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/number/number.module', 'number', 'module', '', 0, 0, -1, 0, '\x613a31323a7b733a343a226e616d65223b733a363a224e756d626572223b733a31313a226465736372697074696f6e223b733a32383a22446566696e6573206e756d65726963206669656c642074797065732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a31313a226e756d6265722e74657374223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/system/tests/cron_queue_test.module', 'cron_queue_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a2243726f6e2051756575652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f72207468652063726f6e2071756575652072756e6e65722e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/update/tests/aaa_update_test.module', 'aaa_update_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31353a22414141205570646174652074657374223b733a31313a226465736372697074696f6e223b733a34313a22537570706f7274206d6f64756c6520666f7220757064617465206d6f64756c652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2276657273696f6e223b733a343a22372e3935223b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/tests/user_form_test.module', 'user_form_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a32323a2255736572206d6f64756c6520666f726d207465737473223b733a31313a226465736372697074696f6e223b733a33373a22537570706f7274206d6f64756c6520666f72207573657220666f726d2074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/user/user.module', 'user', 'module', '', 1, 0, 7020, 0, '\x613a31353a7b733a343a226e616d65223b733a343a2255736572223b733a31313a226465736372697074696f6e223b733a34373a224d616e6167657320746865207573657220726567697374726174696f6e20616e64206c6f67696e2073797374656d2e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a323a7b693a303b733a31313a22757365722e6d6f64756c65223b693a313b733a393a22757365722e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a31393a2261646d696e2f636f6e6669672f70656f706c65223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a22757365722e637373223b733a32313a226d6f64756c65732f757365722f757365722e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/node/node.module', 'node', 'module', '', 1, 0, 7016, 0, '\x613a31353a7b733a343a226e616d65223b733a343a224e6f6465223b733a31313a226465736372697074696f6e223b733a36363a22416c6c6f777320636f6e74656e7420746f206265207375626d697474656420746f20746865207369746520616e6420646973706c61796564206f6e2070616765732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a323a7b693a303b733a31313a226e6f64652e6d6f64756c65223b693a313b733a393a226e6f64652e74657374223b7d733a383a227265717569726564223b623a313b733a393a22636f6e666967757265223b733a32313a2261646d696e2f7374727563747572652f7479706573223b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a383a226e6f64652e637373223b733a32313a226d6f64756c65732f6e6f64652f6e6f64652e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/image_test.module', 'image_test', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31303a22496d6167652074657374223b733a31313a226465736372697074696f6e223b733a33393a22537570706f7274206d6f64756c6520666f7220696d61676520746f6f6c6b69742074657374732e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/simpletest/tests/update_test_2.module', 'update_test_2', 'module', '', 0, 0, -1, 0, '\x613a31333a7b733a343a226e616d65223b733a31313a225570646174652074657374223b733a31313a226465736372697074696f6e223b733a33343a22537570706f7274206d6f64756c6520666f72207570646174652074657374696e672e223b733a373a227061636b616765223b733a373a2254657374696e67223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a363a2268696464656e223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a31323a22646570656e64656e63696573223b613a303a7b7d733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'module', '', 1, 0, 7002, 0, '\x613a31333a7b733a343a226e616d65223b733a31373a224669656c642053514c2073746f72616765223b733a31313a226465736372697074696f6e223b733a33373a2253746f726573206669656c64206461746120696e20616e2053514c2064617461626173652e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a32323a226669656c645f73716c5f73746f726167652e74657374223b7d733a383a227265717569726564223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/field.module', 'field', 'module', '', 1, 0, 7004, 0, '\x613a31343a7b733a343a226e616d65223b733a353a224669656c64223b733a31313a226465736372697074696f6e223b733a35373a224669656c642041504920746f20616464206669656c647320746f20656e746974696573206c696b65206e6f64657320616e642075736572732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a353a2266696c6573223b613a343a7b693a303b733a31323a226669656c642e6d6f64756c65223b693a313b733a31363a226669656c642e6174746163682e696e63223b693a323b733a32303a226669656c642e696e666f2e636c6173732e696e63223b693a333b733a31363a2274657374732f6669656c642e74657374223b7d733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a31373a226669656c645f73716c5f73746f72616765223b7d733a383a227265717569726564223b623a313b733a31313a227374796c65736865657473223b613a313a7b733a333a22616c6c223b613a313a7b733a31353a227468656d652f6669656c642e637373223b733a32393a226d6f64756c65732f6669656c642f7468656d652f6669656c642e637373223b7d7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('modules/field/modules/text/text.module', 'text', 'module', '', 1, 0, 7000, 0, '\x613a31333a7b733a343a226e616d65223b733a343a2254657874223b733a31313a226465736372697074696f6e223b733a33323a22446566696e65732073696d706c652074657874206669656c642074797065732e223b733a373a227061636b616765223b733a343a22436f7265223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a313a7b693a303b733a353a226669656c64223b7d733a353a2266696c6573223b613a313a7b693a303b733a393a22746578742e74657374223b7d733a383a227265717569726564223b623a313b733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a333a22706870223b733a353a22352e332e33223b733a393a22626f6f747374726170223b693a303b7d');
INSERT INTO public.system VALUES ('profiles/minimal/minimal.profile', 'minimal', 'module', '', 1, 0, 0, 1000, '\x613a31353a7b733a343a226e616d65223b733a373a224d696e696d616c223b733a31313a226465736372697074696f6e223b733a33383a2253746172742077697468206f6e6c79206120666577206d6f64756c657320656e61626c65642e223b733a373a2276657273696f6e223b733a343a22372e3935223b733a343a22636f7265223b733a333a22372e78223b733a31323a22646570656e64656e63696573223b613a323a7b693a303b733a353a22626c6f636b223b693a313b733a353a2264626c6f67223b7d733a373a2270726f6a656374223b733a363a2264727570616c223b733a393a22646174657374616d70223b733a31303a2231363738393032353330223b733a353a226d74696d65223b693a313637383930323533303b733a373a227061636b616765223b733a353a224f74686572223b733a333a22706870223b733a353a22352e332e33223b733a353a2266696c6573223b613a303a7b7d733a393a22626f6f747374726170223b693a303b733a363a2268696464656e223b623a313b733a383a227265717569726564223b623a313b733a31373a22646973747269627574696f6e5f6e616d65223b733a363a2244727570616c223b7d');


--
-- TOC entry 4062 (class 0 OID 16745)
-- Dependencies: 247
-- Data for Name: url_alias; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4068 (class 0 OID 16795)
-- Dependencies: 253
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES (0, '', '', '', '', '', NULL, 0, 0, 0, 0, 0, NULL, '', 0, '', NULL);
INSERT INTO public.users VALUES (1, 'admin', '$S$DAktJ/LizuSOXgFRiTkJsYmihNQASYTSeTzUoXzeSiVach4DqqjQ', 'admin@example.com', '', '', NULL, 1727123467, 1727123502, 1727123502, 1727123502, 1, 'America/New_York', '', 0, 'admin@example.com', '\x623a303b');


--
-- TOC entry 4069 (class 0 OID 16824)
-- Dependencies: 254
-- Data for Name: users_roles; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4029 (class 0 OID 16401)
-- Dependencies: 214
-- Data for Name: variable; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.variable VALUES ('theme_default', '\x733a363a2262617274696b223b');
INSERT INTO public.variable VALUES ('cron_key', '\x733a34333a224a3441587a346170432d3143582d51796657614e314c4132765f424a33726c6833655f49623550424c6b6f223b');
INSERT INTO public.variable VALUES ('file_temporary_path', '\x733a343a222f746d70223b');
INSERT INTO public.variable VALUES ('path_alias_whitelist', '\x613a303a7b7d');
INSERT INTO public.variable VALUES ('drupal_private_key', '\x733a34333a2236397277483639724c5a3559646f416d6549563363576b434e4666733455457a3952506d302d64356f5677223b');
INSERT INTO public.variable VALUES ('filter_fallback_format', '\x733a31303a22706c61696e5f74657874223b');
INSERT INTO public.variable VALUES ('user_register', '\x693a323b');
INSERT INTO public.variable VALUES ('site_name', '\x733a31343a2262726f777365722064727570616c223b');
INSERT INTO public.variable VALUES ('site_mail', '\x733a31373a2261646d696e406578616d706c652e636f6d223b');
INSERT INTO public.variable VALUES ('date_default_timezone', '\x733a31363a22416d65726963612f4e65775f596f726b223b');
INSERT INTO public.variable VALUES ('site_default_country', '\x733a323a225553223b');
INSERT INTO public.variable VALUES ('clean_url', '\x733a313a2231223b');
INSERT INTO public.variable VALUES ('install_time', '\x693a313732373132333530323b');
INSERT INTO public.variable VALUES ('css_js_query_string', '\x733a363a22736b61393075223b');
INSERT INTO public.variable VALUES ('install_profile', '\x733a373a226d696e696d616c223b');
INSERT INTO public.variable VALUES ('cron_last', '\x693a313732373132333530323b');
INSERT INTO public.variable VALUES ('install_task', '\x733a343a22646f6e65223b');
INSERT INTO public.variable VALUES ('menu_masks', '\x613a32303a7b693a303b693a3132353b693a313b693a3132313b693a323b693a36333b693a333b693a36323b693a343b693a36313b693a353b693a36303b693a363b693a34343b693a373b693a33313b693a383b693a33303b693a393b693a32343b693a31303b693a32313b693a31313b693a31353b693a31323b693a31343b693a31333b693a31313b693a31343b693a373b693a31353b693a363b693a31363b693a353b693a31373b693a333b693a31383b693a323b693a31393b693a313b7d');
INSERT INTO public.variable VALUES ('menu_expanded', '\x613a303a7b7d');


--
-- TOC entry 4093 (class 0 OID 17088)
-- Dependencies: 278
-- Data for Name: watchdog; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.watchdog VALUES (1, 0, 'system', '%module module installed.', '\x613a313a7b733a373a22256d6f64756c65223b733a353a2264626c6f67223b7d', 6, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=do', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (2, 0, 'system', '%module module enabled.', '\x613a313a7b733a373a22256d6f64756c65223b733a353a2264626c6f67223b7d', 6, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=do', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (3, 0, 'system', '%module module installed.', '\x613a313a7b733a373a22256d6f64756c65223b733a373a226d696e696d616c223b7d', 6, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=do', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (4, 0, 'system', '%module module enabled.', '\x613a313a7b733a373a22256d6f64756c65223b733a373a226d696e696d616c223b7d', 6, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=do', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (5, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a31353a225075626c69736820636f6e74656e74223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (6, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a31373a22556e7075626c69736820636f6e74656e74223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (7, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a31393a224d616b6520636f6e74656e7420737469636b79223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (8, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a32313a224d616b6520636f6e74656e7420756e737469636b79223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (9, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a32393a2250726f6d6f746520636f6e74656e7420746f2066726f6e742070616765223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (10, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a33303a2252656d6f766520636f6e74656e742066726f6d2066726f6e742070616765223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (11, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a31323a225361766520636f6e74656e74223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (12, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a33303a2242616e2049502061646472657373206f662063757272656e742075736572223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (13, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a31383a22426c6f636b2063757272656e742075736572223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (14, 0, 'actions', 'Action ''%action'' added.', '\x613a313a7b733a373a2225616374696f6e223b733a32303a22556e626c6f636b2063757272656e742075736572223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en&id=1&op=do_nojs&op=finished', 'http://localhost:3332/install.php?profile=minimal&locale=en&op=start&id=1', '172.18.0.1', 1727123469);
INSERT INTO public.watchdog VALUES (15, 1, 'user', 'Session opened for %name.', '\x613a313a7b733a353a22256e616d65223b733a353a2261646d696e223b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en', 'http://localhost:3332/install.php?profile=minimal&locale=en', '172.18.0.1', 1727123502);
INSERT INTO public.watchdog VALUES (16, 0, 'cron', 'Cron run completed.', '\x613a303a7b7d', 5, '', 'http://localhost:3332/install.php?profile=minimal&locale=en', 'http://localhost:3332/install.php?profile=minimal&locale=en', '172.18.0.1', 1727123502);


--
-- TOC entry 4465 (class 0 OID 0)
-- Dependencies: 248
-- Name: authmap_aid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.authmap_aid_seq', 1, false);


--
-- TOC entry 4466 (class 0 OID 0)
-- Dependencies: 271
-- Name: block_bid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.block_bid_seq', 12, true);


--
-- TOC entry 4467 (class 0 OID 0)
-- Dependencies: 274
-- Name: block_custom_bid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.block_custom_bid_seq', 1, false);


--
-- TOC entry 4468 (class 0 OID 0)
-- Dependencies: 217
-- Name: blocked_ips_iid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blocked_ips_iid_seq', 1, false);


--
-- TOC entry 4469 (class 0 OID 0)
-- Dependencies: 226
-- Name: date_formats_dfid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.date_formats_dfid_seq', 35, true);


--
-- TOC entry 4470 (class 0 OID 0)
-- Dependencies: 266
-- Name: field_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_config_id_seq', 1, false);


--
-- TOC entry 4471 (class 0 OID 0)
-- Dependencies: 268
-- Name: field_config_instance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_config_instance_id_seq', 1, false);


--
-- TOC entry 4472 (class 0 OID 0)
-- Dependencies: 229
-- Name: file_managed_fid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.file_managed_fid_seq', 1, false);


--
-- TOC entry 4473 (class 0 OID 0)
-- Dependencies: 232
-- Name: flood_fid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.flood_fid_seq', 1, false);


--
-- TOC entry 4474 (class 0 OID 0)
-- Dependencies: 235
-- Name: menu_links_mlid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.menu_links_mlid_seq', 115, true);


--
-- TOC entry 4475 (class 0 OID 0)
-- Dependencies: 255
-- Name: node_nid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.node_nid_seq', 1, false);


--
-- TOC entry 4476 (class 0 OID 0)
-- Dependencies: 258
-- Name: node_revision_vid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.node_revision_vid_seq', 1, false);


--
-- TOC entry 4477 (class 0 OID 0)
-- Dependencies: 237
-- Name: queue_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.queue_item_id_seq', 9, true);


--
-- TOC entry 4478 (class 0 OID 0)
-- Dependencies: 251
-- Name: role_rid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.role_rid_seq', 2, true);


--
-- TOC entry 4479 (class 0 OID 0)
-- Dependencies: 242
-- Name: sequences_value_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sequences_value_seq', 1, true);


--
-- TOC entry 4480 (class 0 OID 0)
-- Dependencies: 246
-- Name: url_alias_pid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.url_alias_pid_seq', 1, false);


--
-- TOC entry 4481 (class 0 OID 0)
-- Dependencies: 277
-- Name: watchdog_wid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.watchdog_wid_seq', 16, true);


--
-- TOC entry 3697 (class 2606 OID 16419)
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (aid);


--
-- TOC entry 3787 (class 2606 OID 16771)
-- Name: authmap authmap_authname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authmap
    ADD CONSTRAINT authmap_authname_key UNIQUE (authname);


--
-- TOC entry 3789 (class 2606 OID 16769)
-- Name: authmap authmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authmap
    ADD CONSTRAINT authmap_pkey PRIMARY KEY (aid);


--
-- TOC entry 3699 (class 2606 OID 16427)
-- Name: batch batch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batch
    ADD CONSTRAINT batch_pkey PRIMARY KEY (bid);


--
-- TOC entry 3876 (class 2606 OID 17074)
-- Name: block_custom block_custom_info_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block_custom
    ADD CONSTRAINT block_custom_info_key UNIQUE (info);


--
-- TOC entry 3878 (class 2606 OID 17072)
-- Name: block_custom block_custom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block_custom
    ADD CONSTRAINT block_custom_pkey PRIMARY KEY (bid);


--
-- TOC entry 3834 (class 2606 OID 16930)
-- Name: block_node_type block_node_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block_node_type
    ADD CONSTRAINT block_node_type_pkey PRIMARY KEY (module, delta, type);


--
-- TOC entry 3869 (class 2606 OID 17051)
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT block_pkey PRIMARY KEY (bid);


--
-- TOC entry 3873 (class 2606 OID 17060)
-- Name: block_role block_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block_role
    ADD CONSTRAINT block_role_pkey PRIMARY KEY (module, delta, rid);


--
-- TOC entry 3871 (class 2606 OID 17053)
-- Name: block block_tmd_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT block_tmd_key UNIQUE (theme, module, delta);


--
-- TOC entry 3703 (class 2606 OID 16437)
-- Name: blocked_ips blocked_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips
    ADD CONSTRAINT blocked_ips_pkey PRIMARY KEY (iid);


--
-- TOC entry 3881 (class 2606 OID 17085)
-- Name: cache_block cache_block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_block
    ADD CONSTRAINT cache_block_pkey PRIMARY KEY (cid);


--
-- TOC entry 3709 (class 2606 OID 16461)
-- Name: cache_bootstrap cache_bootstrap_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_bootstrap
    ADD CONSTRAINT cache_bootstrap_pkey PRIMARY KEY (cid);


--
-- TOC entry 3866 (class 2606 OID 17031)
-- Name: cache_field cache_field_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_field
    ADD CONSTRAINT cache_field_pkey PRIMARY KEY (cid);


--
-- TOC entry 3849 (class 2606 OID 16979)
-- Name: cache_filter cache_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_filter
    ADD CONSTRAINT cache_filter_pkey PRIMARY KEY (cid);


--
-- TOC entry 3712 (class 2606 OID 16473)
-- Name: cache_form cache_form_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_form
    ADD CONSTRAINT cache_form_pkey PRIMARY KEY (cid);


--
-- TOC entry 3718 (class 2606 OID 16497)
-- Name: cache_menu cache_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_menu
    ADD CONSTRAINT cache_menu_pkey PRIMARY KEY (cid);


--
-- TOC entry 3715 (class 2606 OID 16485)
-- Name: cache_page cache_page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_page
    ADD CONSTRAINT cache_page_pkey PRIMARY KEY (cid);


--
-- TOC entry 3721 (class 2606 OID 16509)
-- Name: cache_path cache_path_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_path
    ADD CONSTRAINT cache_path_pkey PRIMARY KEY (cid);


--
-- TOC entry 3706 (class 2606 OID 16449)
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (cid);


--
-- TOC entry 3730 (class 2606 OID 16533)
-- Name: date_format_locale date_format_locale_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_format_locale
    ADD CONSTRAINT date_format_locale_pkey PRIMARY KEY (type, language);


--
-- TOC entry 3723 (class 2606 OID 16516)
-- Name: date_format_type date_format_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_format_type
    ADD CONSTRAINT date_format_type_pkey PRIMARY KEY (type);


--
-- TOC entry 3726 (class 2606 OID 16528)
-- Name: date_formats date_formats_formats_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_formats
    ADD CONSTRAINT date_formats_formats_key UNIQUE (format, type);


--
-- TOC entry 3728 (class 2606 OID 16526)
-- Name: date_formats date_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_formats
    ADD CONSTRAINT date_formats_pkey PRIMARY KEY (dfid);


--
-- TOC entry 3863 (class 2606 OID 17018)
-- Name: field_config_instance field_config_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_config_instance
    ADD CONSTRAINT field_config_instance_pkey PRIMARY KEY (id);


--
-- TOC entry 3855 (class 2606 OID 16997)
-- Name: field_config field_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_config
    ADD CONSTRAINT field_config_pkey PRIMARY KEY (id);


--
-- TOC entry 3732 (class 2606 OID 16553)
-- Name: file_managed file_managed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_managed
    ADD CONSTRAINT file_managed_pkey PRIMARY KEY (fid);


--
-- TOC entry 3737 (class 2606 OID 16555)
-- Name: file_managed file_managed_uri_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_managed
    ADD CONSTRAINT file_managed_uri_key UNIQUE (uri);


--
-- TOC entry 3741 (class 2606 OID 16570)
-- Name: file_usage file_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_usage
    ADD CONSTRAINT file_usage_pkey PRIMARY KEY (fid, type, id, module);


--
-- TOC entry 3843 (class 2606 OID 16967)
-- Name: filter_format filter_format_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_format
    ADD CONSTRAINT filter_format_name_key UNIQUE (name);


--
-- TOC entry 3845 (class 2606 OID 16965)
-- Name: filter_format filter_format_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_format
    ADD CONSTRAINT filter_format_pkey PRIMARY KEY (format);


--
-- TOC entry 3841 (class 2606 OID 16952)
-- Name: filter filter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter
    ADD CONSTRAINT filter_pkey PRIMARY KEY (format, name);


--
-- TOC entry 3745 (class 2606 OID 16584)
-- Name: flood flood_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flood
    ADD CONSTRAINT flood_pkey PRIMARY KEY (fid);


--
-- TOC entry 3838 (class 2606 OID 16940)
-- Name: history history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history
    ADD CONSTRAINT history_pkey PRIMARY KEY (uid, nid);


--
-- TOC entry 3756 (class 2606 OID 16656)
-- Name: menu_links menu_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_links
    ADD CONSTRAINT menu_links_pkey PRIMARY KEY (mlid);


--
-- TOC entry 3749 (class 2606 OID 16610)
-- Name: menu_router menu_router_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_router
    ADD CONSTRAINT menu_router_pkey PRIMARY KEY (path);


--
-- TOC entry 3826 (class 2606 OID 16889)
-- Name: node_access node_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node_access
    ADD CONSTRAINT node_access_pkey PRIMARY KEY (nid, gid, realm);


--
-- TOC entry 3819 (class 2606 OID 16861)
-- Name: node node_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node
    ADD CONSTRAINT node_pkey PRIMARY KEY (nid);


--
-- TOC entry 3829 (class 2606 OID 16908)
-- Name: node_revision node_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node_revision
    ADD CONSTRAINT node_revision_pkey PRIMARY KEY (vid);


--
-- TOC entry 3832 (class 2606 OID 16925)
-- Name: node_type node_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node_type
    ADD CONSTRAINT node_type_pkey PRIMARY KEY (type);


--
-- TOC entry 3824 (class 2606 OID 16863)
-- Name: node node_vid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.node
    ADD CONSTRAINT node_vid_key UNIQUE (vid);


--
-- TOC entry 3761 (class 2606 OID 16673)
-- Name: queue queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (item_id);


--
-- TOC entry 3766 (class 2606 OID 16692)
-- Name: registry_file registry_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registry_file
    ADD CONSTRAINT registry_file_pkey PRIMARY KEY (filename);


--
-- TOC entry 3764 (class 2606 OID 16686)
-- Name: registry registry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registry
    ADD CONSTRAINT registry_pkey PRIMARY KEY (name, type);


--
-- TOC entry 3795 (class 2606 OID 16793)
-- Name: role role_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_name_key UNIQUE (name);


--
-- TOC entry 3793 (class 2606 OID 16780)
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (rid, permission);


--
-- TOC entry 3798 (class 2606 OID 16791)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (rid);


--
-- TOC entry 3769 (class 2606 OID 16701)
-- Name: semaphore semaphore_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semaphore
    ADD CONSTRAINT semaphore_pkey PRIMARY KEY (name);


--
-- TOC entry 3772 (class 2606 OID 16711)
-- Name: sequences sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT sequences_pkey PRIMARY KEY (value);


--
-- TOC entry 3774 (class 2606 OID 16723)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sid, ssid);


--
-- TOC entry 3779 (class 2606 OID 16741)
-- Name: system system_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system
    ADD CONSTRAINT system_pkey PRIMARY KEY (filename);


--
-- TOC entry 3784 (class 2606 OID 16756)
-- Name: url_alias url_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_alias
    ADD CONSTRAINT url_alias_pkey PRIMARY KEY (pid);


--
-- TOC entry 3804 (class 2606 OID 16818)
-- Name: users users_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_name_key UNIQUE (name);


--
-- TOC entry 3807 (class 2606 OID 16816)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uid);


--
-- TOC entry 3809 (class 2606 OID 16832)
-- Name: users_roles users_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_pkey PRIMARY KEY (uid, rid);


--
-- TOC entry 3695 (class 2606 OID 16408)
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (name);


--
-- TOC entry 3883 (class 2606 OID 17102)
-- Name: watchdog watchdog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchdog
    ADD CONSTRAINT watchdog_pkey PRIMARY KEY (wid);


--
-- TOC entry 3790 (class 1259 OID 16772)
-- Name: authmap_uid_module_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authmap_uid_module_idx ON public.authmap USING btree (uid, module);


--
-- TOC entry 3700 (class 1259 OID 16428)
-- Name: batch_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX batch_token_idx ON public.batch USING btree (token);


--
-- TOC entry 3867 (class 1259 OID 17054)
-- Name: block_list_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_list_idx ON public.block USING btree (theme, status, region, weight, module);


--
-- TOC entry 3835 (class 1259 OID 16931)
-- Name: block_node_type_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_node_type_type_idx ON public.block_node_type USING btree (type);


--
-- TOC entry 3874 (class 1259 OID 17061)
-- Name: block_role_rid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_role_rid_idx ON public.block_role USING btree (rid);


--
-- TOC entry 3701 (class 1259 OID 16438)
-- Name: blocked_ips_blocked_ip_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blocked_ips_blocked_ip_idx ON public.blocked_ips USING btree (ip);


--
-- TOC entry 3879 (class 1259 OID 17086)
-- Name: cache_block_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_block_expire_idx ON public.cache_block USING btree (expire);


--
-- TOC entry 3707 (class 1259 OID 16462)
-- Name: cache_bootstrap_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_bootstrap_expire_idx ON public.cache_bootstrap USING btree (expire);


--
-- TOC entry 3704 (class 1259 OID 16450)
-- Name: cache_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_expire_idx ON public.cache USING btree (expire);


--
-- TOC entry 3864 (class 1259 OID 17032)
-- Name: cache_field_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_field_expire_idx ON public.cache_field USING btree (expire);


--
-- TOC entry 3847 (class 1259 OID 16980)
-- Name: cache_filter_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_filter_expire_idx ON public.cache_filter USING btree (expire);


--
-- TOC entry 3710 (class 1259 OID 16474)
-- Name: cache_form_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_form_expire_idx ON public.cache_form USING btree (expire);


--
-- TOC entry 3716 (class 1259 OID 16498)
-- Name: cache_menu_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_menu_expire_idx ON public.cache_menu USING btree (expire);


--
-- TOC entry 3713 (class 1259 OID 16486)
-- Name: cache_page_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_page_expire_idx ON public.cache_page USING btree (expire);


--
-- TOC entry 3719 (class 1259 OID 16510)
-- Name: cache_path_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_path_expire_idx ON public.cache_path USING btree (expire);


--
-- TOC entry 3724 (class 1259 OID 16517)
-- Name: date_format_type_title_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX date_format_type_title_idx ON public.date_format_type USING btree (title);


--
-- TOC entry 3850 (class 1259 OID 16999)
-- Name: field_config_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_active_idx ON public.field_config USING btree (active);


--
-- TOC entry 3851 (class 1259 OID 17001)
-- Name: field_config_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_deleted_idx ON public.field_config USING btree (deleted);


--
-- TOC entry 3852 (class 1259 OID 16998)
-- Name: field_config_field_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_field_name_idx ON public.field_config USING btree (field_name);


--
-- TOC entry 3860 (class 1259 OID 17020)
-- Name: field_config_instance_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_instance_deleted_idx ON public.field_config_instance USING btree (deleted);


--
-- TOC entry 3861 (class 1259 OID 17019)
-- Name: field_config_instance_field_name_bundle_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_instance_field_name_bundle_idx ON public.field_config_instance USING btree (field_name, entity_type, bundle);


--
-- TOC entry 3853 (class 1259 OID 17002)
-- Name: field_config_module_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_module_idx ON public.field_config USING btree (module);


--
-- TOC entry 3856 (class 1259 OID 17000)
-- Name: field_config_storage_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_storage_active_idx ON public.field_config USING btree (storage_active);


--
-- TOC entry 3857 (class 1259 OID 17003)
-- Name: field_config_storage_module_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_storage_module_idx ON public.field_config USING btree (storage_module);


--
-- TOC entry 3858 (class 1259 OID 17005)
-- Name: field_config_storage_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_storage_type_idx ON public.field_config USING btree (storage_type);


--
-- TOC entry 3859 (class 1259 OID 17004)
-- Name: field_config_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_config_type_idx ON public.field_config USING btree (type);


--
-- TOC entry 3733 (class 1259 OID 16557)
-- Name: file_managed_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_managed_status_idx ON public.file_managed USING btree (status);


--
-- TOC entry 3734 (class 1259 OID 16558)
-- Name: file_managed_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_managed_timestamp_idx ON public.file_managed USING btree ("timestamp");


--
-- TOC entry 3735 (class 1259 OID 16556)
-- Name: file_managed_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_managed_uid_idx ON public.file_managed USING btree (uid);


--
-- TOC entry 3738 (class 1259 OID 16572)
-- Name: file_usage_fid_count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_usage_fid_count_idx ON public.file_usage USING btree (fid, count);


--
-- TOC entry 3739 (class 1259 OID 16573)
-- Name: file_usage_fid_module_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_usage_fid_module_idx ON public.file_usage USING btree (fid, module);


--
-- TOC entry 3742 (class 1259 OID 16571)
-- Name: file_usage_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_usage_type_id_idx ON public.file_usage USING btree (type, id);


--
-- TOC entry 3846 (class 1259 OID 16968)
-- Name: filter_format_status_weight_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX filter_format_status_weight_idx ON public.filter_format USING btree (status, weight);


--
-- TOC entry 3839 (class 1259 OID 16953)
-- Name: filter_list_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX filter_list_idx ON public.filter USING btree (weight, module, name);


--
-- TOC entry 3743 (class 1259 OID 16585)
-- Name: flood_allow_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flood_allow_idx ON public.flood USING btree (event, identifier, "timestamp");


--
-- TOC entry 3746 (class 1259 OID 16586)
-- Name: flood_purge_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flood_purge_idx ON public.flood USING btree (expiration);


--
-- TOC entry 3836 (class 1259 OID 16941)
-- Name: history_nid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX history_nid_idx ON public.history USING btree (nid);


--
-- TOC entry 3752 (class 1259 OID 16659)
-- Name: menu_links_menu_parents_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_links_menu_parents_idx ON public.menu_links USING btree (menu_name, p1, p2, p3, p4, p5, p6, p7, p8, p9);


--
-- TOC entry 3753 (class 1259 OID 16658)
-- Name: menu_links_menu_plid_expand_child_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_links_menu_plid_expand_child_idx ON public.menu_links USING btree (menu_name, plid, expanded, has_children);


--
-- TOC entry 3754 (class 1259 OID 16657)
-- Name: menu_links_path_menu_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_links_path_menu_idx ON public.menu_links USING btree (substr((link_path)::text, 1, 128), menu_name);


--
-- TOC entry 3757 (class 1259 OID 16660)
-- Name: menu_links_router_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_links_router_path_idx ON public.menu_links USING btree (substr((router_path)::text, 1, 128));


--
-- TOC entry 3747 (class 1259 OID 16611)
-- Name: menu_router_fit_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_router_fit_idx ON public.menu_router USING btree (fit);


--
-- TOC entry 3750 (class 1259 OID 16612)
-- Name: menu_router_tab_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_router_tab_parent_idx ON public.menu_router USING btree (substr((tab_parent)::text, 1, 64), weight, title);


--
-- TOC entry 3751 (class 1259 OID 16613)
-- Name: menu_router_tab_root_weight_title_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_router_tab_root_weight_title_idx ON public.menu_router USING btree (substr((tab_root)::text, 1, 64), weight, title);


--
-- TOC entry 3811 (class 1259 OID 16873)
-- Name: node_language_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_language_idx ON public.node USING btree (language);


--
-- TOC entry 3812 (class 1259 OID 16864)
-- Name: node_node_changed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_changed_idx ON public.node USING btree (changed);


--
-- TOC entry 3813 (class 1259 OID 16865)
-- Name: node_node_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_created_idx ON public.node USING btree (created);


--
-- TOC entry 3814 (class 1259 OID 16866)
-- Name: node_node_frontpage_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_frontpage_idx ON public.node USING btree (promote, status, sticky, created);


--
-- TOC entry 3815 (class 1259 OID 16867)
-- Name: node_node_status_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_status_type_idx ON public.node USING btree (status, type, nid);


--
-- TOC entry 3816 (class 1259 OID 16868)
-- Name: node_node_title_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_title_type_idx ON public.node USING btree (title, substr((type)::text, 1, 4));


--
-- TOC entry 3817 (class 1259 OID 16869)
-- Name: node_node_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_node_type_idx ON public.node USING btree (substr((type)::text, 1, 4));


--
-- TOC entry 3827 (class 1259 OID 16909)
-- Name: node_revision_nid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_revision_nid_idx ON public.node_revision USING btree (nid);


--
-- TOC entry 3830 (class 1259 OID 16910)
-- Name: node_revision_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_revision_uid_idx ON public.node_revision USING btree (uid);


--
-- TOC entry 3820 (class 1259 OID 16871)
-- Name: node_tnid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_tnid_idx ON public.node USING btree (tnid);


--
-- TOC entry 3821 (class 1259 OID 16872)
-- Name: node_translate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_translate_idx ON public.node USING btree (translate);


--
-- TOC entry 3822 (class 1259 OID 16870)
-- Name: node_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_uid_idx ON public.node USING btree (uid);


--
-- TOC entry 3758 (class 1259 OID 16675)
-- Name: queue_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX queue_expire_idx ON public.queue USING btree (expire);


--
-- TOC entry 3759 (class 1259 OID 16674)
-- Name: queue_name_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX queue_name_created_idx ON public.queue USING btree (name, created);


--
-- TOC entry 3762 (class 1259 OID 16687)
-- Name: registry_hook_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX registry_hook_idx ON public.registry USING btree (type, weight, module);


--
-- TOC entry 3796 (class 1259 OID 16794)
-- Name: role_name_weight_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_name_weight_idx ON public.role USING btree (name, weight);


--
-- TOC entry 3791 (class 1259 OID 16781)
-- Name: role_permission_permission_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_permission_permission_idx ON public.role_permission USING btree (permission);


--
-- TOC entry 3767 (class 1259 OID 16703)
-- Name: semaphore_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX semaphore_expire_idx ON public.semaphore USING btree (expire);


--
-- TOC entry 3770 (class 1259 OID 16702)
-- Name: semaphore_value_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX semaphore_value_idx ON public.semaphore USING btree (value);


--
-- TOC entry 3775 (class 1259 OID 16726)
-- Name: sessions_ssid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_ssid_idx ON public.sessions USING btree (ssid);


--
-- TOC entry 3776 (class 1259 OID 16724)
-- Name: sessions_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_timestamp_idx ON public.sessions USING btree ("timestamp");


--
-- TOC entry 3777 (class 1259 OID 16725)
-- Name: sessions_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_uid_idx ON public.sessions USING btree (uid);


--
-- TOC entry 3780 (class 1259 OID 16742)
-- Name: system_system_list_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX system_system_list_idx ON public.system USING btree (status, bootstrap, type, weight, name);


--
-- TOC entry 3781 (class 1259 OID 16743)
-- Name: system_type_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX system_type_name_idx ON public.system USING btree (type, name);


--
-- TOC entry 3782 (class 1259 OID 16757)
-- Name: url_alias_alias_language_pid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX url_alias_alias_language_pid_idx ON public.url_alias USING btree (alias, language, pid);


--
-- TOC entry 3785 (class 1259 OID 16758)
-- Name: url_alias_source_language_pid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX url_alias_source_language_pid_idx ON public.url_alias USING btree (source, language, pid);


--
-- TOC entry 3799 (class 1259 OID 16819)
-- Name: users_access_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_access_idx ON public.users USING btree (access);


--
-- TOC entry 3800 (class 1259 OID 16821)
-- Name: users_changed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_changed_idx ON public.users USING btree (changed);


--
-- TOC entry 3801 (class 1259 OID 16820)
-- Name: users_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_created_idx ON public.users USING btree (created);


--
-- TOC entry 3802 (class 1259 OID 16822)
-- Name: users_mail_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_mail_idx ON public.users USING btree (mail);


--
-- TOC entry 3805 (class 1259 OID 16823)
-- Name: users_picture_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_picture_idx ON public.users USING btree (picture);


--
-- TOC entry 3810 (class 1259 OID 16833)
-- Name: users_roles_rid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_roles_rid_idx ON public.users_roles USING btree (rid);


--
-- TOC entry 3884 (class 1259 OID 17105)
-- Name: watchdog_severity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX watchdog_severity_idx ON public.watchdog USING btree (severity);


--
-- TOC entry 3885 (class 1259 OID 17103)
-- Name: watchdog_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX watchdog_type_idx ON public.watchdog USING btree (type);


--
-- TOC entry 3886 (class 1259 OID 17104)
-- Name: watchdog_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX watchdog_uid_idx ON public.watchdog USING btree (uid);


-- Completed on 2024-09-23 16:55:43 EDT

--
-- PostgreSQL database dump complete
--

