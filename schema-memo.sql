--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: rubymemo; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE "rubymemo" WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII' LC_COLLATE = 'C' LC_CTYPE = 'C';


\connect "rubymemo"

SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: memos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memos (
    id integer NOT NULL,
    sender character varying(128),
    recipient character varying(128),
    time_sent timestamp without time zone DEFAULT now() NOT NULL,
    time_told timestamp without time zone,
    message character varying(4096),
    recipient_regexp character varying(128)
);


--
-- Name: memos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memos_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: memos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memos_id_seq OWNED BY memos.id;


--
-- Name: memos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('memos_id_seq', 1, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE memos ALTER COLUMN id SET DEFAULT nextval('memos_id_seq'::regclass);


--
-- Name: memos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memos
    ADD CONSTRAINT memos_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

