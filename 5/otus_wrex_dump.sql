--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: wrex; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA wrex;


ALTER SCHEMA wrex OWNER TO postgres;

--
-- Name: SCHEMA wrex; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA wrex IS 'standard public schema';


SET search_path = wrex, pg_catalog;

--
-- Name: device_status; Type: TYPE; Schema: wrex; Owner: postgres
--

CREATE TYPE device_status AS ENUM (
    'down',
    'wait',
    'checking',
    'running',
    'installing',
    'deleted'
);


ALTER TYPE wrex.device_status OWNER TO postgres;

--
-- Name: reachability; Type: TYPE; Schema: wrex; Owner: postgres
--

CREATE TYPE reachability AS (
	reachable boolean,
	lastseen_at timestamp with time zone
);


ALTER TYPE wrex.reachability OWNER TO postgres;

--
-- Name: result_status; Type: TYPE; Schema: wrex; Owner: postgres
--

CREATE TYPE result_status AS ENUM (
    'running',
    'done',
    'error'
);


ALTER TYPE wrex.result_status OWNER TO postgres;

--
-- Name: check_device_correct_existence(boolean, boolean); Type: FUNCTION; Schema: wrex; Owner: postgres
--

CREATE FUNCTION check_device_correct_existence(deleted boolean, reachable boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN
  
    -- if reachable is NULL then OK
    IF (reachable IS NULL) THEN
        RETURN true;
    -- something is going really wrong, deleted must be non-NULL
    ELSEIF (deleted IS NULL) THEN
        RAISE EXCEPTION 'Parameter `deleted` can not be NULL';
    -- if device was deleted then reachabilisy has to be unknown (i.e. NULL)
    ELSEIF (deleted = true) THEN
        RETURN false;
    -- otherwise deleted must not be equal reachable
    else
        RETURN (deleted != reachable);
    
    END IF;

END

$$;


ALTER FUNCTION wrex.check_device_correct_existence(deleted boolean, reachable boolean) OWNER TO postgres;

--
-- Name: FUNCTION check_device_correct_existence(deleted boolean, reachable boolean); Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON FUNCTION check_device_correct_existence(deleted boolean, reachable boolean) IS 'checking if deleted device is not reachable';


--
-- Name: check_device_correct_reachability(reachability); Type: FUNCTION; Schema: wrex; Owner: postgres
--

CREATE FUNCTION check_device_correct_reachability(state reachability) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN
  
    -- both is NULL ther OK
    IF ((state).reachable IS NULL) AND ((state).lastseen_at IS NULL) THEN
    	RETURN TRUE;  
    -- both is not NULL then OK
    ELSEIF ((state).reachable IS NOT NULL) AND ((state).lastseen_at is NOT NULL) THEN
    	RETURN TRUE;
    -- otherwise both has to have the same NULL state
    ELSE
    	RETURN FALSE;
    
    END IF;

END

$$;


ALTER FUNCTION wrex.check_device_correct_reachability(state reachability) OWNER TO postgres;

--
-- Name: FUNCTION check_device_correct_reachability(state reachability); Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON FUNCTION check_device_correct_reachability(state reachability) IS 'checking if device reachability state has the same NULL state';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attr_names; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE attr_names (
    id bigint NOT NULL,
    name character varying(128) NOT NULL,
    CONSTRAINT attr_names_check_name CHECK (((name)::text <> ''::text))
);


ALTER TABLE wrex.attr_names OWNER TO postgres;

--
-- Name: TABLE attr_names; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE attr_names IS 'Table contains possible names for attributes';


--
-- Name: COLUMN attr_names.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attr_names.id IS 'attribute name id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN attr_names.name; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attr_names.name IS 'attribute name
VARCHAR was chosen due it represents attribute name
128 is enough for this field
can not be NULL due field is required';


--
-- Name: CONSTRAINT attr_names_check_name ON attr_names; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT attr_names_check_name ON attr_names IS 'checking for non-empty string';


--
-- Name: attr_names_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE attr_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.attr_names_id_seq OWNER TO postgres;

--
-- Name: attr_names_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE attr_names_id_seq OWNED BY attr_names.id;


--
-- Name: attributes; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE attributes (
    id bigint NOT NULL,
    name bigint NOT NULL,
    value character varying(128) NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT attributes_check_value CHECK (((value)::text <> ''::text))
);


ALTER TABLE wrex.attributes OWNER TO postgres;

--
-- Name: TABLE attributes; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE attributes IS 'Table of devices, tests and results attributes';


--
-- Name: COLUMN attributes.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attributes.id IS 'attribute id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN attributes.name; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attributes.name IS 'attribute name
BIGINT was chosen due attribute name key has the same properties';


--
-- Name: COLUMN attributes.value; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attributes.value IS 'attribute value
VARCHAR was chosen due it represents attribute value
128 is enough for this field
can not be NULL due field is required';


--
-- Name: COLUMN attributes.deleted; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN attributes.deleted IS 'attribute existence
BOOL was chosen due it can be described in 2 states
can not be NULL due field is required';


--
-- Name: CONSTRAINT attributes_check_value ON attributes; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT attributes_check_value ON attributes IS 'checking for non-empty string';


--
-- Name: attributes_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.attributes_id_seq OWNER TO postgres;

--
-- Name: attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE attributes_id_seq OWNED BY attributes.id;


--
-- Name: collected_data; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE collected_data (
    id bigint NOT NULL,
    datapath character varying(4096)
);


ALTER TABLE wrex.collected_data OWNER TO postgres;

--
-- Name: TABLE collected_data; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE collected_data IS 'Table contains link to path to result data file';


--
-- Name: COLUMN collected_data.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN collected_data.id IS 'result data id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN collected_data.datapath; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN collected_data.datapath IS 'result data path
VARCHAR was chosen due it does not required any special actions like search, sort, etc
4096 due file path can be very long
can be NULL due test result may not exist yet, or deleted';


--
-- Name: collected_data_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE collected_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.collected_data_id_seq OWNER TO postgres;

--
-- Name: collected_data_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE collected_data_id_seq OWNED BY collected_data.id;


--
-- Name: devices; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE devices (
    id bigint NOT NULL,
    name character varying(128) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    status device_status NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    address character varying(256),
    reachable reachability,
    location character varying(1000),
    description character varying(1000),
    CONSTRAINT devices_check_correct_existence CHECK (check_device_correct_existence(deleted, (reachable).reachable)),
    CONSTRAINT devices_check_correct_reachability CHECK (check_device_correct_reachability(reachable)),
    CONSTRAINT devices_check_name CHECK (((name)::text <> ''::text))
);


ALTER TABLE wrex.devices OWNER TO postgres;

--
-- Name: TABLE devices; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE devices IS 'Devices table';


--
-- Name: COLUMN devices.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.id IS 'device id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN devices.name; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.name IS 'device name
VARCHAR was chosen due it represents device name
128 is enough for this field
can not be NULL due field is required';


--
-- Name: COLUMN devices.created_at; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.created_at IS 'device creation date and time
TIMESTAMPTZ was chosen due it is representation of date and time
can not be NULL due field is required ';


--
-- Name: COLUMN devices.status; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.status IS 'device status
ENUM was choosen due statuses can be described in several mutually exclusive states';


--
-- Name: COLUMN devices.deleted; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.deleted IS 'device existence
BOOL was chosen due it can be described in 2 states
can not be NULL due field is required';


--
-- Name: COLUMN devices.address; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.address IS 'device access address
field represents address as IP or hostname as string also may contain port
VARCHAR was chosen due it does not require any special actions like search, sort, etc
256 due it is maximum address length
can be NULL due device can be deleted or disabled';


--
-- Name: COLUMN devices.reachable; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.reachable IS 'device reachability
STRUCT was chosen due it contains several related entries
can be NULL due device can be deleted or disabled';


--
-- Name: COLUMN devices.location; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.location IS 'device location
VARCHAR was chosen due it does not require any special actions like search, sort, etc
1000 due location can be long
can be NULL due field is not required';


--
-- Name: COLUMN devices.description; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices.description IS 'device description
VARCHAR was chosen due it does not require any special actions like search, sort, etc
1000 due description can be long
can be NULL due field is not required';


--
-- Name: CONSTRAINT devices_check_correct_existence ON devices; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT devices_check_correct_existence ON devices IS 'checking for device correct existence, device can not be deleted and reachable';


--
-- Name: CONSTRAINT devices_check_correct_reachability ON devices; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT devices_check_correct_reachability ON devices IS 'checking for device reachability state, it has to have equal NULL state, device can not be reachable and does not have lastseen time';


--
-- Name: CONSTRAINT devices_check_name ON devices; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT devices_check_name ON devices IS 'checking for non-empty string';


--
-- Name: devices_attributes; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE devices_attributes (
    id bigint NOT NULL,
    device_id bigint NOT NULL,
    attribute_id bigint NOT NULL
);


ALTER TABLE wrex.devices_attributes OWNER TO postgres;

--
-- Name: TABLE devices_attributes; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE devices_attributes IS 'Devices and attributes cross table';


--
-- Name: COLUMN devices_attributes.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices_attributes.id IS 'device attrbute id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN devices_attributes.device_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices_attributes.device_id IS 'device id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: COLUMN devices_attributes.attribute_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN devices_attributes.attribute_id IS 'attribute id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: devices_attributes_attribute_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE devices_attributes_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.devices_attributes_attribute_id_seq OWNER TO postgres;

--
-- Name: devices_attributes_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE devices_attributes_attribute_id_seq OWNED BY devices_attributes.attribute_id;


--
-- Name: devices_attributes_device_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE devices_attributes_device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.devices_attributes_device_id_seq OWNER TO postgres;

--
-- Name: devices_attributes_device_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE devices_attributes_device_id_seq OWNED BY devices_attributes.device_id;


--
-- Name: devices_attributes_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE devices_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.devices_attributes_id_seq OWNER TO postgres;

--
-- Name: devices_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE devices_attributes_id_seq OWNED BY devices_attributes.id;


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.devices_id_seq OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: result_data; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE result_data (
    id bigint NOT NULL,
    data bigint,
    error bigint
);


ALTER TABLE wrex.result_data OWNER TO postgres;

--
-- Name: TABLE result_data; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE result_data IS 'Table contains information about processed test';


--
-- Name: COLUMN result_data.data; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_data.data IS 'collected data id
BIGINT was chosen due attribute key has the same properties
can be NULL because data collecting might fail or result file can be deleted';


--
-- Name: COLUMN result_data.error; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_data.error IS 'result error id
BIGINT was chosen due attribute key has the same properties
can be NULL because no error during data collecting or error entry might be deleted';


--
-- Name: result_data_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE result_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.result_data_id_seq OWNER TO postgres;

--
-- Name: result_data_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE result_data_id_seq OWNED BY result_data.id;


--
-- Name: result_errors; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE result_errors (
    id bigint NOT NULL,
    identifier bigint NOT NULL,
    name character varying(1000) NOT NULL,
    value character varying(4096) NOT NULL,
    description character varying(1000),
    CONSTRAINT result_errors_check_name CHECK (((name)::text <> ''::text)),
    CONSTRAINT result_errors_check_positive_identifier CHECK ((identifier >= 0)),
    CONSTRAINT result_errors_check_value CHECK (((value)::text <> ''::text))
);


ALTER TABLE wrex.result_errors OWNER TO postgres;

--
-- Name: TABLE result_errors; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE result_errors IS 'Tables of test errors';


--
-- Name: COLUMN result_errors.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_errors.id IS 'error id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN result_errors.identifier; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_errors.identifier IS 'external identifier
it represents id of error whithin company
BIGINT was chosen due it is large enough
can not be NULL due field is required';


--
-- Name: COLUMN result_errors.name; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_errors.name IS 'error title
VARCHAR was chosen due it represents error title
1000 due this field can be long
can not be NULL due field is required';


--
-- Name: COLUMN result_errors.value; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_errors.value IS 'error value
VARCHAR was chosen due it represents error value
4096 due this field can be very long
can not be NULL due field is required';


--
-- Name: COLUMN result_errors.description; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN result_errors.description IS 'error description
VARCHAR was chosen due it does not require any special actions like search, sort, etc
1000 due description can be long
can be NULL due field is not required
';


--
-- Name: CONSTRAINT result_errors_check_name ON result_errors; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT result_errors_check_name ON result_errors IS 'checking for non-empty string';


--
-- Name: CONSTRAINT result_errors_check_positive_identifier ON result_errors; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT result_errors_check_positive_identifier ON result_errors IS 'identifier has to be positive';


--
-- Name: CONSTRAINT result_errors_check_value ON result_errors; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT result_errors_check_value ON result_errors IS 'checking for non-empty string';


--
-- Name: results; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE results (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    passed boolean,
    status result_status NOT NULL,
    test bigint NOT NULL,
    device bigint NOT NULL,
    data bigint,
    deleted boolean DEFAULT false NOT NULL,
    description character varying(1000)
);


ALTER TABLE wrex.results OWNER TO postgres;

--
-- Name: TABLE results; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE results IS 'Results table';


--
-- Name: COLUMN results.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.id IS 'result id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN results.created_at; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.created_at IS 'result creation date and time
TIMESTAMPTZ was chosen due it is representation of date and time
can not be NULL due field is required ';


--
-- Name: COLUMN results.passed; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.passed IS 'representation of passing test
BOOL was chosen due it can be described in 2 states
can be NULL due test takes some time for obtaining result, until one is not completed result passing is unknown';


--
-- Name: COLUMN results.status; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.status IS 'result status
ENUM was choosen due statuses can be described in several mutually exclusive states';


--
-- Name: COLUMN results.test; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.test IS 'origin
BIGINT was chosen due attribute key has the same properties';


--
-- Name: COLUMN results.device; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.device IS 'device
BIGINT was chosen due attribute key has the same properties';


--
-- Name: COLUMN results.data; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.data IS 'result data
BIGINT was chosen due attribute key has the same properties
can be NULL because data collecting might fail or result file can be deleted';


--
-- Name: COLUMN results.deleted; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.deleted IS 'result existence
BOOL was chosen due it can be described in 2 states
can not be NULL due field is required';


--
-- Name: COLUMN results.description; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results.description IS 'result description
VARCHAR was chosen due it does not require any special actions like search, sort, etc
1000 due description can be long
can be NULL due field is not required';


--
-- Name: results_attributes; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE results_attributes (
    id bigint NOT NULL,
    result_id bigint NOT NULL,
    attribute_id bigint NOT NULL
);


ALTER TABLE wrex.results_attributes OWNER TO postgres;

--
-- Name: TABLE results_attributes; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE results_attributes IS 'Results and attributes cross table';


--
-- Name: COLUMN results_attributes.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results_attributes.id IS 'result attribute id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN results_attributes.result_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results_attributes.result_id IS 'result id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: COLUMN results_attributes.attribute_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN results_attributes.attribute_id IS 'attribute id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: results_attributes_attribute_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE results_attributes_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.results_attributes_attribute_id_seq OWNER TO postgres;

--
-- Name: results_attributes_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE results_attributes_attribute_id_seq OWNED BY results_attributes.attribute_id;


--
-- Name: results_attributes_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE results_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.results_attributes_id_seq OWNER TO postgres;

--
-- Name: results_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE results_attributes_id_seq OWNED BY results_attributes.id;


--
-- Name: results_attributes_result_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE results_attributes_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.results_attributes_result_id_seq OWNER TO postgres;

--
-- Name: results_attributes_result_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE results_attributes_result_id_seq OWNED BY results_attributes.result_id;


--
-- Name: results_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.results_id_seq OWNER TO postgres;

--
-- Name: results_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE results_id_seq OWNED BY results.id;


--
-- Name: test_errors_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE test_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.test_errors_id_seq OWNER TO postgres;

--
-- Name: test_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE test_errors_id_seq OWNED BY result_errors.id;


--
-- Name: tests; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE tests (
    id bigint NOT NULL,
    name character varying(128) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    body json NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    description character varying(1000),
    CONSTRAINT tests_check_name CHECK (((name)::text <> ''::text))
);


ALTER TABLE wrex.tests OWNER TO postgres;

--
-- Name: TABLE tests; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE tests IS 'Tests table';


--
-- Name: COLUMN tests.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.id IS 'test id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN tests.name; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.name IS 'test name
VARCHAR was chosen due it represents test name
128 is enough for this field
can not be NULL due field is required';


--
-- Name: COLUMN tests.created_at; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.created_at IS 'test creation date and time
TIMESTAMPTZ was chosen due it is representation of date and time
can not be NULL due field is required ';


--
-- Name: COLUMN tests.body; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.body IS 'test body
JSON was chosen due test settings has this format
can not be NULL due field is required';


--
-- Name: COLUMN tests.deleted; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.deleted IS 'test existence
BOOL was chosen due it can be described in 2 states
can not be NULL due field is required';


--
-- Name: COLUMN tests.description; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests.description IS 'test description
VARCHAR was chosen due it does not require any special actions like search, sort, etc
1000 due description can be long
can be NULL due field is not required';


--
-- Name: CONSTRAINT tests_check_name ON tests; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON CONSTRAINT tests_check_name ON tests IS 'checking for non-empty string';


--
-- Name: tests_attributes; Type: TABLE; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE TABLE tests_attributes (
    id bigint NOT NULL,
    test_id bigint NOT NULL,
    attribute_id bigint NOT NULL
);


ALTER TABLE wrex.tests_attributes OWNER TO postgres;

--
-- Name: TABLE tests_attributes; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON TABLE tests_attributes IS 'Tests and attributes cross table';


--
-- Name: COLUMN tests_attributes.id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests_attributes.id IS 'test attribute id
BIGSERIAL was chosen as best and simple surrogate key';


--
-- Name: COLUMN tests_attributes.test_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests_attributes.test_id IS 'test id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: COLUMN tests_attributes.attribute_id; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON COLUMN tests_attributes.attribute_id IS 'attribute id
BIGINT was chosen due attribute key has the same properties';


--
-- Name: tests_attributes_attribute_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE tests_attributes_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.tests_attributes_attribute_id_seq OWNER TO postgres;

--
-- Name: tests_attributes_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE tests_attributes_attribute_id_seq OWNED BY tests_attributes.attribute_id;


--
-- Name: tests_attributes_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE tests_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.tests_attributes_id_seq OWNER TO postgres;

--
-- Name: tests_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE tests_attributes_id_seq OWNED BY tests_attributes.id;


--
-- Name: tests_attributes_test_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE tests_attributes_test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.tests_attributes_test_id_seq OWNER TO postgres;

--
-- Name: tests_attributes_test_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE tests_attributes_test_id_seq OWNED BY tests_attributes.test_id;


--
-- Name: tests_id_seq; Type: SEQUENCE; Schema: wrex; Owner: postgres
--

CREATE SEQUENCE tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrex.tests_id_seq OWNER TO postgres;

--
-- Name: tests_id_seq; Type: SEQUENCE OWNED BY; Schema: wrex; Owner: postgres
--

ALTER SEQUENCE tests_id_seq OWNED BY tests.id;


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY attr_names ALTER COLUMN id SET DEFAULT nextval('attr_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY attributes ALTER COLUMN id SET DEFAULT nextval('attributes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY collected_data ALTER COLUMN id SET DEFAULT nextval('collected_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY devices_attributes ALTER COLUMN id SET DEFAULT nextval('devices_attributes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY result_data ALTER COLUMN id SET DEFAULT nextval('result_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY result_errors ALTER COLUMN id SET DEFAULT nextval('test_errors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results ALTER COLUMN id SET DEFAULT nextval('results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results_attributes ALTER COLUMN id SET DEFAULT nextval('results_attributes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY tests ALTER COLUMN id SET DEFAULT nextval('tests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY tests_attributes ALTER COLUMN id SET DEFAULT nextval('tests_attributes_id_seq'::regclass);


--
-- Name: attr_names_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attr_names
    ADD CONSTRAINT attr_names_pk PRIMARY KEY (id);


--
-- Name: attr_names_un; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attr_names
    ADD CONSTRAINT attr_names_un UNIQUE (id, name);


--
-- Name: attributes_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_pk PRIMARY KEY (id);


--
-- Name: attributes_un; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_un UNIQUE (id);


--
-- Name: collected_data_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collected_data
    ADD CONSTRAINT collected_data_pk PRIMARY KEY (id);


--
-- Name: devices_attributes_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY devices_attributes
    ADD CONSTRAINT devices_attributes_pk PRIMARY KEY (id);


--
-- Name: devices_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pk PRIMARY KEY (id);


--
-- Name: devices_un; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_un UNIQUE (id);


--
-- Name: result_data_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result_data
    ADD CONSTRAINT result_data_pk PRIMARY KEY (id);


--
-- Name: results_attributes_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY results_attributes
    ADD CONSTRAINT results_attributes_pk PRIMARY KEY (id);


--
-- Name: results_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_pk PRIMARY KEY (id);


--
-- Name: test_errors_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result_errors
    ADD CONSTRAINT test_errors_pk PRIMARY KEY (id);


--
-- Name: test_errors_un; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result_errors
    ADD CONSTRAINT test_errors_un UNIQUE (id, identifier, name);


--
-- Name: tests_attributes_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tests_attributes
    ADD CONSTRAINT tests_attributes_pk PRIMARY KEY (id);


--
-- Name: tests_pk; Type: CONSTRAINT; Schema: wrex; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tests
    ADD CONSTRAINT tests_pk PRIMARY KEY (id);


--
-- Name: attributes_name_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX attributes_name_idx ON attributes USING btree (name);


--
-- Name: INDEX attributes_name_idx; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON INDEX attributes_name_idx IS 'Attribute name index';


--
-- Name: attributes_value_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX attributes_value_idx ON attributes USING btree (value);


--
-- Name: INDEX attributes_value_idx; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON INDEX attributes_value_idx IS 'Attribute value index';


--
-- Name: devices_attributes_device_id_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX devices_attributes_device_id_idx ON devices_attributes USING btree (device_id, attribute_id);


--
-- Name: devices_description_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX devices_description_idx ON devices USING btree (description);


--
-- Name: devices_name_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX devices_name_idx ON devices USING btree (name);


--
-- Name: INDEX devices_name_idx; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON INDEX devices_name_idx IS 'Device name index';


--
-- Name: result_errors_description_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX result_errors_description_idx ON result_errors USING btree (description);


--
-- Name: result_errors_identifier_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX result_errors_identifier_idx ON result_errors USING btree (identifier);


--
-- Name: result_errors_name_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX result_errors_name_idx ON result_errors USING btree (name);


--
-- Name: results_attributes_result_id_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX results_attributes_result_id_idx ON results_attributes USING btree (result_id, attribute_id);


--
-- Name: tests_attributes_test_id_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX tests_attributes_test_id_idx ON tests_attributes USING btree (test_id, attribute_id);


--
-- Name: tests_description_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX tests_description_idx ON tests USING btree (description);


--
-- Name: tests_name_idx; Type: INDEX; Schema: wrex; Owner: postgres; Tablespace: 
--

CREATE INDEX tests_name_idx ON tests USING btree (name);


--
-- Name: INDEX tests_name_idx; Type: COMMENT; Schema: wrex; Owner: postgres
--

COMMENT ON INDEX tests_name_idx IS 'Test name index';


--
-- Name: attributes_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_fk FOREIGN KEY (name) REFERENCES attr_names(id);


--
-- Name: devices_attributes_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY devices_attributes
    ADD CONSTRAINT devices_attributes_fk FOREIGN KEY (attribute_id) REFERENCES attributes(id);


--
-- Name: devices_attributes_fk_1; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY devices_attributes
    ADD CONSTRAINT devices_attributes_fk_1 FOREIGN KEY (device_id) REFERENCES devices(id);


--
-- Name: result_data_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY result_data
    ADD CONSTRAINT result_data_fk FOREIGN KEY (data) REFERENCES collected_data(id);


--
-- Name: result_data_fk_1; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY result_data
    ADD CONSTRAINT result_data_fk_1 FOREIGN KEY (error) REFERENCES result_errors(id);


--
-- Name: results_attributes_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results_attributes
    ADD CONSTRAINT results_attributes_fk FOREIGN KEY (attribute_id) REFERENCES attributes(id);


--
-- Name: results_attributes_fk_1; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results_attributes
    ADD CONSTRAINT results_attributes_fk_1 FOREIGN KEY (result_id) REFERENCES results(id);


--
-- Name: results_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_fk FOREIGN KEY (data) REFERENCES result_data(id);


--
-- Name: results_fk_1; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_fk_1 FOREIGN KEY (test) REFERENCES tests(id);


--
-- Name: results_fk_2; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_fk_2 FOREIGN KEY (device) REFERENCES devices(id);


--
-- Name: tests_attributes_fk; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY tests_attributes
    ADD CONSTRAINT tests_attributes_fk FOREIGN KEY (attribute_id) REFERENCES attributes(id);


--
-- Name: tests_attributes_fk_1; Type: FK CONSTRAINT; Schema: wrex; Owner: postgres
--

ALTER TABLE ONLY tests_attributes
    ADD CONSTRAINT tests_attributes_fk_1 FOREIGN KEY (test_id) REFERENCES tests(id);


--
-- Name: wrex; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA wrex FROM PUBLIC;
REVOKE ALL ON SCHEMA wrex FROM postgres;
GRANT ALL ON SCHEMA wrex TO postgres;
GRANT ALL ON SCHEMA wrex TO PUBLIC;


--
-- Name: results_attributes; Type: ACL; Schema: wrex; Owner: postgres
--

REVOKE ALL ON TABLE results_attributes FROM PUBLIC;
REVOKE ALL ON TABLE results_attributes FROM postgres;
GRANT ALL ON TABLE results_attributes TO postgres;


--
-- PostgreSQL database dump complete
--

