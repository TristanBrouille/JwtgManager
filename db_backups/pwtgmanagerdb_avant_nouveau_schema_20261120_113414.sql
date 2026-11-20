--
-- PostgreSQL database dump
--

\restrict 7oRUwHzvZkPgNSLRB8XYuLc2e0fWJdhPbLyrmzr0BGYM7gyoa7gWR006MdPHsgz

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: creature; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.creature (
    creature_id bigint NOT NULL,
    name character varying(255),
    rarity character varying(50),
    region character varying(50),
    creature_class character varying(50),
    creature_hybride character varying(50),
    dna_price integer,
    amber_price integer,
    value bigint NOT NULL
);


ALTER TABLE public.creature OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    value bigint NOT NULL,
    username character varying(255),
    email character varying(255),
    password character varying(255),
    role character varying(255)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: creature; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.creature (creature_id, name, rarity, region, creature_class, creature_hybride, dna_price, amber_price, value) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (value, username, email, password, role) FROM stdin;
\.


--
-- Name: creature creature_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creature
    ADD CONSTRAINT creature_pkey PRIMARY KEY (creature_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (value);


--
-- PostgreSQL database dump complete
--

\unrestrict 7oRUwHzvZkPgNSLRB8XYuLc2e0fWJdhPbLyrmzr0BGYM7gyoa7gWR006MdPHsgz

