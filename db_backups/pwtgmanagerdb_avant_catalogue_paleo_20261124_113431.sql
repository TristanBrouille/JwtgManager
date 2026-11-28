--
-- PostgreSQL database dump
--

\restrict U2tcqXoJoWwGCz7SD1O0QpLwBfbdsfutrlRh4AsdRKavYJZznLhhpLz4gwwA1Me

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

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    pseudo text NOT NULL,
    password_hash text NOT NULL,
    role text DEFAULT 'USER'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT app_user_role_check CHECK ((role = ANY (ARRAY['USER'::text, 'ADMIN'::text])))
);


ALTER TABLE public.app_user OWNER TO postgres;

--
-- Name: creature_sheet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.creature_sheet (
    species_id integer NOT NULL,
    source_key text NOT NULL,
    region text,
    creature_class text,
    release_date date,
    health_lvl10 integer NOT NULL,
    health_lvl20 integer NOT NULL,
    health_lvl30 integer NOT NULL,
    health_lvl40 integer NOT NULL,
    attack_lvl10 integer NOT NULL,
    attack_lvl20 integer NOT NULL,
    attack_lvl30 integer NOT NULL,
    attack_lvl40 integer NOT NULL,
    ferocity integer,
    coins bigint,
    coin_minutes integer,
    coins_per_minute integer,
    hatch_minutes integer,
    dna_buy bigint,
    dna_sell bigint,
    region_code text,
    class_code text
);


ALTER TABLE public.creature_sheet OWNER TO postgres;

--
-- Name: hybrid_recipe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hybrid_recipe (
    hybrid_id integer NOT NULL,
    component_id integer NOT NULL,
    CONSTRAINT hybrid_recipe_check CHECK ((hybrid_id <> component_id))
);


ALTER TABLE public.hybrid_recipe OWNER TO postgres;

--
-- Name: investment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.investment (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    species_id integer NOT NULL,
    from_level smallint,
    to_level smallint NOT NULL,
    quantity smallint DEFAULT 1 NOT NULL,
    cost integer NOT NULL,
    currency text NOT NULL,
    invested_on date DEFAULT CURRENT_DATE NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT investment_check CHECK (((from_level IS NULL) OR (to_level > from_level))),
    CONSTRAINT investment_cost_check CHECK ((cost >= 0)),
    CONSTRAINT investment_currency_check CHECK ((currency = ANY (ARRAY['dna'::text, 'super_dna'::text, 'amber'::text]))),
    CONSTRAINT investment_from_level_check CHECK ((from_level = ANY (ARRAY[10, 20, 30]))),
    CONSTRAINT investment_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT investment_to_level_check CHECK ((to_level = ANY (ARRAY[10, 20, 30, 40])))
);


ALTER TABLE public.investment OWNER TO postgres;

--
-- Name: investment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.investment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.investment_id_seq OWNER TO postgres;

--
-- Name: investment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.investment_id_seq OWNED BY public.investment.id;


--
-- Name: player_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_settings (
    user_id uuid NOT NULL,
    weekly_dna integer DEFAULT 0 CONSTRAINT player_settings_weekly_coins_not_null NOT NULL,
    weekly_amber integer DEFAULT 0 NOT NULL,
    default_target smallint DEFAULT 3 NOT NULL,
    weekly_super_dna integer DEFAULT 0 NOT NULL,
    CONSTRAINT player_settings_default_target_check CHECK ((default_target >= 0)),
    CONSTRAINT player_settings_weekly_amber_check CHECK ((weekly_amber >= 0)),
    CONSTRAINT player_settings_weekly_coins_check CHECK ((weekly_dna >= 0)),
    CONSTRAINT player_settings_weekly_super_dna_check CHECK ((weekly_super_dna >= 0))
);


ALTER TABLE public.player_settings OWNER TO postgres;

--
-- Name: player_species; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_species (
    user_id uuid NOT NULL,
    species_id integer NOT NULL,
    unlocked boolean DEFAULT false NOT NULL,
    count_lvl10 smallint DEFAULT 0 NOT NULL,
    count_lvl20 smallint DEFAULT 0 NOT NULL,
    count_lvl30 smallint DEFAULT 0 NOT NULL,
    count_lvl40 smallint DEFAULT 0 NOT NULL,
    target_lvl40 smallint DEFAULT 3 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    favorite boolean DEFAULT false NOT NULL,
    CONSTRAINT player_species_count_lvl10_check CHECK ((count_lvl10 >= 0)),
    CONSTRAINT player_species_count_lvl20_check CHECK ((count_lvl20 >= 0)),
    CONSTRAINT player_species_count_lvl30_check CHECK ((count_lvl30 >= 0)),
    CONSTRAINT player_species_count_lvl40_check CHECK ((count_lvl40 >= 0)),
    CONSTRAINT player_species_target_lvl40_check CHECK ((target_lvl40 >= 0))
);


ALTER TABLE public.player_species OWNER TO postgres;

--
-- Name: species; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.species (
    id integer NOT NULL,
    name text NOT NULL,
    rarity_code character(1) NOT NULL,
    dna_cost integer,
    amber_cost integer,
    default_unlocked boolean DEFAULT false NOT NULL,
    hybrid_kind text DEFAULT 'NONE'::text NOT NULL,
    CONSTRAINT species_amber_cost_check CHECK ((amber_cost >= 0)),
    CONSTRAINT species_coin_cost_check CHECK ((dna_cost >= 0)),
    CONSTRAINT species_hybrid_kind_check CHECK ((hybrid_kind = ANY (ARRAY['NONE'::text, 'HYBRID'::text, 'SUPER_HYBRID'::text])))
);


ALTER TABLE public.species OWNER TO postgres;

--
-- Name: player_species_progress; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.player_species_progress AS
 SELECT ps.user_id,
    s.id AS species_id,
    s.name,
    s.rarity_code,
    s.hybrid_kind,
    ps.target_lvl40,
        CASE
            WHEN ((NOT ps.unlocked) AND (COALESCE(s.amber_cost, 0) > 0)) THEN 'amber'::text
            WHEN (s.hybrid_kind = 'SUPER_HYBRID'::text) THEN 'super_dna'::text
            ELSE 'dna'::text
        END AS currency,
    c.unit_cost,
    c.units,
    GREATEST(0, ((8 * ps.target_lvl40) - c.units)) AS units_remaining,
    ((ps.count_lvl40 >= ps.target_lvl40) AND ((8 * ps.target_lvl40) <= c.units)) AS done,
        CASE
            WHEN (ps.count_lvl40 >= ps.target_lvl40) THEN (1)::numeric
            ELSE LEAST(0.99, ((((((ps.count_lvl10)::numeric / 48.0) + ((ps.count_lvl20)::numeric / 6.0)) + (((ps.count_lvl30)::numeric * 5.0) / 12.0)) + (ps.count_lvl40)::numeric) / (ps.target_lvl40)::numeric))
        END AS progress,
    (c.units * COALESCE(c.unit_cost, 0)) AS invested,
    (GREATEST(0, ((8 * ps.target_lvl40) - c.units)) * COALESCE(c.unit_cost, 0)) AS remaining
   FROM ((public.player_species ps
     JOIN public.species s ON ((s.id = ps.species_id)))
     CROSS JOIN LATERAL ( SELECT
                CASE
                    WHEN ((NOT ps.unlocked) AND (COALESCE(s.amber_cost, 0) > 0)) THEN s.amber_cost
                    ELSE s.dna_cost
                END AS unit_cost,
            (((ps.count_lvl10 + (2 * ps.count_lvl20)) + (4 * ps.count_lvl30)) + (8 * ps.count_lvl40)) AS units) c);


ALTER VIEW public.player_species_progress OWNER TO postgres;

--
-- Name: progress_snapshot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.progress_snapshot (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    taken_on date DEFAULT CURRENT_DATE NOT NULL,
    completion_pct numeric(5,2) NOT NULL,
    lvl40_count integer NOT NULL,
    lvl40_target integer NOT NULL,
    dna_remaining bigint CONSTRAINT progress_snapshot_coins_remaining_not_null NOT NULL,
    amber_remaining bigint NOT NULL,
    super_dna_remaining bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.progress_snapshot OWNER TO postgres;

--
-- Name: progress_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.progress_snapshot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.progress_snapshot_id_seq OWNER TO postgres;

--
-- Name: progress_snapshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.progress_snapshot_id_seq OWNED BY public.progress_snapshot.id;


--
-- Name: rarity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rarity (
    code character(1) NOT NULL,
    label text NOT NULL,
    sort_order smallint NOT NULL
);


ALTER TABLE public.rarity OWNER TO postgres;

--
-- Name: species_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.species_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.species_id_seq OWNER TO postgres;

--
-- Name: species_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.species_id_seq OWNED BY public.species.id;


--
-- Name: tournament_leftover; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_leftover (
    user_id uuid NOT NULL,
    tournament text NOT NULL,
    species_id integer NOT NULL,
    level smallint NOT NULL,
    class_code text NOT NULL,
    health integer NOT NULL,
    attack integer NOT NULL,
    quantity smallint NOT NULL,
    CONSTRAINT tournament_leftover_level_check CHECK ((level = ANY (ARRAY[10, 20, 30, 40]))),
    CONSTRAINT tournament_leftover_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT tournament_leftover_tournament_check CHECK ((tournament = ANY (ARRAY['JURASSIC'::text, 'AQUATIC'::text, 'CENOZOIC'::text])))
);


ALTER TABLE public.tournament_leftover OWNER TO postgres;

--
-- Name: tournament_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_plan (
    user_id uuid NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL,
    collection_hash text NOT NULL
);


ALTER TABLE public.tournament_plan OWNER TO postgres;

--
-- Name: tournament_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_team (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    tournament text NOT NULL,
    league text NOT NULL,
    rank smallint NOT NULL,
    pair_class text NOT NULL,
    single_class text NOT NULL,
    total_ferocity integer NOT NULL,
    CONSTRAINT tournament_team_league_check CHECK ((league = ANY (ARRAY['NEWBORN'::text, 'HUNTER'::text, 'PREDATOR'::text, 'DOMINANT'::text]))),
    CONSTRAINT tournament_team_rank_check CHECK ((rank > 0)),
    CONSTRAINT tournament_team_tournament_check CHECK ((tournament = ANY (ARRAY['JURASSIC'::text, 'AQUATIC'::text, 'CENOZOIC'::text])))
);


ALTER TABLE public.tournament_team OWNER TO postgres;

--
-- Name: tournament_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_team_id_seq OWNER TO postgres;

--
-- Name: tournament_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_team_id_seq OWNED BY public.tournament_team.id;


--
-- Name: tournament_team_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_team_member (
    team_id bigint NOT NULL,
    slot smallint NOT NULL,
    species_id integer NOT NULL,
    level smallint NOT NULL,
    health integer NOT NULL,
    attack integer NOT NULL,
    ferocity integer NOT NULL,
    profile text NOT NULL,
    CONSTRAINT tournament_team_member_level_check CHECK ((level = ANY (ARRAY[10, 20, 30, 40]))),
    CONSTRAINT tournament_team_member_profile_check CHECK ((profile = ANY (ARRAY['TANK'::text, 'BALANCED'::text, 'STRIKER'::text]))),
    CONSTRAINT tournament_team_member_slot_check CHECK (((slot >= 1) AND (slot <= 3)))
);


ALTER TABLE public.tournament_team_member OWNER TO postgres;

--
-- Name: investment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment ALTER COLUMN id SET DEFAULT nextval('public.investment_id_seq'::regclass);


--
-- Name: progress_snapshot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progress_snapshot ALTER COLUMN id SET DEFAULT nextval('public.progress_snapshot_id_seq'::regclass);


--
-- Name: species id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species ALTER COLUMN id SET DEFAULT nextval('public.species_id_seq'::regclass);


--
-- Name: tournament_team id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team ALTER COLUMN id SET DEFAULT nextval('public.tournament_team_id_seq'::regclass);


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, email, pseudo, password_hash, role, created_at) FROM stdin;
00000000-0000-0000-0000-000000000001	demo@jwtg.local	Joueur démo	$2a$10$TcDcIGkqY/uOXLsFpq2yA.57YqrPblequez.5ZQfbyap7nCDwmW7K	USER	2026-11-20 12:04:19.408892+01
5b802b07-59ee-4005-bec8-75e256aa5210	tristan.dhersin@gmail.com	seckmet	$2a$10$p67I5fDM28nv0NuEGxcyxeAPsvx8b7KHvqx0gwsFutPUdFTrFXn/a	USER	2026-11-20 13:16:08.491262+01
\.


--
-- Data for Name: creature_sheet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.creature_sheet (species_id, source_key, region, creature_class, release_date, health_lvl10, health_lvl20, health_lvl30, health_lvl40, attack_lvl10, attack_lvl20, attack_lvl30, attack_lvl40, ferocity, coins, coin_minutes, coins_per_minute, hatch_minutes, dna_buy, dna_sell, region_code, class_code) FROM stdin;
1	triceratops	Jurassique	Herbivore	2015-04-11	74	127	194	274	19	32	49	70	156	1280	5	256	2	100	50	jurassic	herbivore
2	majungasaurus	Jurassique	Carnivore	2015-04-11	61	104	158	224	23	40	60	86	156	9216	180	51	3	110	60	jurassic	carnivore
3	alanqa	Jurassique	Ptérosaures	2015-04-11	59	101	154	217	22	38	59	83	151	7680	60	128	8	120	60	jurassic	pterosaur
4	tuojiangosaurus	Jurassique	Herbivore	2015-04-11	64	109	166	235	20	34	52	73	146	17424	360	48	20	130	70	jurassic	herbivore
5	limnoscelis	Jurassique	Amphibien	2015-04-11	72	123	188	266	18	31	48	68	151	9216	180	51	10	130	70	jurassic	amphibian
6	labyrinthodontia	Jurassique	Amphibien	2015-10-02	64	110	167	236	24	42	64	90	164	10599	180	59	18	130	70	jurassic	amphibian
7	coloborhynchus	Jurassique	Ptérosaures	2015-04-18	64	110	168	238	25	42	64	91	165	3625	15	242	19	140	70	jurassic	pterosaur
8	bonitasaura	Jurassique	Herbivore	2016-01-24	71	122	186	263	18	31	48	67	149	28570	900	32	20	150	80	jurassic	herbivore
9	argentinosaurus	Jurassique	Herbivore	2015-04-11	76	130	199	281	19	33	51	72	160	7488	30	250	15	160	80	jurassic	herbivore
10	guanlong	Jurassique	Carnivore	2015-12-18	69	118	180	255	22	37	56	80	160	15322	360	43	23	170	90	jurassic	carnivore
11	pelecanimimus	Jurassique	Herbivore	2015-04-11	72	123	188	266	23	39	59	83	166	12811	180	71	26	170	90	jurassic	herbivore
12	tropeognathus	Jurassique	Ptérosaures	2015-04-11	71	121	184	260	22	38	58	81	162	15668	360	44	6	180	90	jurassic	pterosaur
13	diplocaulus	Jurassique	Amphibien	2016-01-22	77	132	201	284	20	34	51	73	162	28628	720	40	27	190	100	jurassic	amphibian
14	hatzegopteryx	Jurassique	Ptérosaures	2016-01-29	69	118	179	253	26	45	68	97	176	11290	60	188	29	200	100	jurassic	pterosaur
15	utahraptor	Jurassique	Carnivore	2015-04-11	70	120	183	259	27	46	70	99	180	12673	120	106	30	200	100	jurassic	carnivore
16	alangasaurus	Jurassique	Carnivore	2016-06-29	218	373	569	804	102	175	266	377	628	24192	30	806	52	1290	650	jurassic	carnivore
17	limnorhynchus	Jurassique	Ptérosaures	2016-06-29	297	508	775	1096	93	159	242	343	686	26370	30	879	62	1490	750	jurassic	pterosaur
18	labyrinthosaurus	Jurassique	Herbivore	2016-06-29	317	543	827	1170	109	187	286	404	770	29636	30	988	79	1630	820	jurassic	herbivore
19	pelecanipteryx	Jurassique	Ptérosaures	2016-06-29	350	600	915	1294	134	229	349	494	898	86487	360	240	107	2030	1020	jurassic	pterosaur
20	pelecachtylus	Jurassique	Ptérosaures	2022-02-21	1331	1806	2324	2765	416	564	726	864	1728	188496	480	393	394	\N	7430	jurassic	pterosaur
21	allosaurus	Jurassique	Carnivore	2015-04-11	119	204	311	440	37	64	97	138	276	18432	180	102	95	500	250	jurassic	carnivore
22	giganotosaurus	Jurassique	Carnivore	2015-04-18	129	221	337	476	33	56	86	122	271	18985	180	105	101	520	260	jurassic	carnivore
23	irritator	Jurassique	Carnivore	2016-01-24	108	185	283	400	41	71	108	153	278	19538	180	109	107	530	270	jurassic	carnivore
24	nasutoceratops	Jurassique	Herbivore	2015-04-11	132	227	346	489	34	58	88	125	278	20091	180	112	113	550	280	jurassic	herbivore
25	dsungaripterus	Jurassique	Ptérosaures	2016-01-24	105	179	273	386	40	68	104	148	269	5161	10	516	120	560	280	jurassic	pterosaur
26	gallimimus	Jurassique	Herbivore	2016-01-24	107	184	280	396	41	70	107	151	275	24730	300	82	125	580	290	jurassic	herbivore
27	pachycephalosaurus	Jurassique	Herbivore	2015-04-11	122	210	319	452	38	65	100	141	282	21750	180	121	132	590	300	jurassic	herbivore
28	koolasuchus	Jurassique	Amphibien	2015-11-17	126	217	330	467	40	68	103	146	292	22488	180	125	141	610	310	jurassic	amphibian
29	corythosaurus	Jurassique	Herbivore	2016-01-24	144	246	375	531	37	63	96	136	302	52255	1080	48	150	630	320	jurassic	herbivore
30	pyroraptor	Jurassique	Carnivore	2015-04-11	121	208	317	448	46	79	121	171	311	23962	180	133	160	650	330	jurassic	carnivore
31	tapejara	Jurassique	Ptérosaures	2015-04-11	116	198	302	428	36	62	94	134	268	30874	180	172	160	670	340	jurassic	pterosaur
32	dilophosaurus	Jurassique	Carnivore	2015-12-25	107	184	280	396	41	70	107	151	275	15898	30	530	180	690	350	jurassic	carnivore
33	nundasuchus	Jurassique	Amphibien	2015-12-11	171	293	447	632	44	75	114	162	360	76801	1440	53	212	700	350	jurassic	amphibian
34	tyrannotitan	Jurassique	Carnivore	2015-04-11	110	189	288	408	42	72	110	156	284	29991	120	250	190	710	360	jurassic	carnivore
35	carnotaurus	Jurassique	Carnivore	2015-06-06	114	194	296	419	43	74	113	160	291	36442	240	152	202	730	370	jurassic	carnivore
36	diplodocus	Jurassique	Herbivore	2015-04-18	143	244	372	527	36	62	95	135	300	37440	240	156	213	750	380	jurassic	herbivore
37	rhamphorhynchus	Jurassique	Ptérosaures	2016-03-16	156	266	406	575	49	83	127	180	360	66816	1200	56	212	750	380	jurassic	pterosaur
38	ophiacodon	Jurassique	Carnivore	2015-08-04	103	176	268	379	75	128	195	277	395	46080	660	70	213	780	390	jurassic	carnivore
39	monolophosaurus	Jurassique	Carnivore	2015-08-04	187	320	487	689	58	100	152	215	430	38016	360	106	258	850	430	jurassic	carnivore
40	diplotator	Jurassique	Amphibien	2015-12-11	458	784	1195	1691	158	271	413	584	1112	107050	360	297	295	4000	2000	jurassic	amphibian
41	nundagosaurus	Jurassique	Amphibien	2016-12-07	630	1080	1646	2328	161	276	421	595	1323	101849	180	566	420	4600	2300	jurassic	amphibian
42	pachyceratops	Jurassique	Herbivore	2015-09-30	680	1164	1775	2511	174	298	454	642	1427	54916	30	1831	487	6360	3180	jurassic	herbivore
43	ophiacomimus	Jurassique	Herbivore	2020-04-01	541	927	1412	1999	282	483	736	1041	1666	117533	120	979	436	7560	3780	jurassic	herbivore
44	carnoraptor	Jurassique	Carnivore	2015-06-10	676	1158	1765	2498	258	442	674	954	1735	189182	480	394	720	7730	3870	jurassic	carnivore
45	tapejalosaurus	Jurassique	Ptérosaures	2017-04-19	814	1394	2125	3007	254	436	664	940	1880	253170	720	352	843	8520	4260	jurassic	pterosaur
46	diplosuchus	Jurassique	Amphibien	2019-01-28	1702	2264	2820	3415	716	953	1187	1410	2477	186521	180	1036	1402	\N	13820	jurassic	amphibian
47	dimetrocarnus	Jurassique	Carnivore	2020-09-23	2549	3434	4257	5075	921	1221	1660	1995	3581	169425	120	1412	1377	\N	24620	jurassic	carnivore
48	tapejalocephalus	Jurassique	Ptérosaures	2019-09-27	3076	4070	5053	6017	972	1286	1600	1905	3785	303973	720	422	1216	\N	27340	jurassic	pterosaur
49	euoplocephalus	Jurassique	Herbivore	2015-11-17	262	449	685	969	67	115	175	248	551	76801	1440	53	298	1000	500	jurassic	herbivore
50	zhejiangopterus	Jurassique	Ptérosaures	2015-04-11	215	368	560	793	82	140	214	303	551	27879	120	232	360	1100	550	jurassic	pterosaur
51	ankylosaurus	Jurassique	Herbivore	2015-12-15	274	469	715	1011	70	120	183	259	575	30413	120	253	429	1200	600	jurassic	herbivore
52	parasaurolophus	Jurassique	Herbivore	2015-04-11	238	408	623	881	75	128	195	275	550	33178	180	184	429	1200	600	jurassic	herbivore
53	rajasaurus	Jurassique	Carnivore	2015-04-11	238	408	623	881	75	128	195	275	550	35943	180	200	503	1300	650	jurassic	carnivore
54	quetzalcoatlus	Jurassique	Ptérosaures	2015-04-11	241	413	629	891	75	129	197	278	556	37325	180	207	543	1350	680	jurassic	pterosaur
55	amphicyon	Cénozoïque	Cavernes	2017-04-19	283	486	740	1047	43	73	111	158	485	46656	360	130	542	1400	700	cenozoic	cavern
56	doedicurus	Cénozoïque	Cavernes	2017-06-07	213	364	555	785	66	114	173	245	490	47232	360	131	556	1400	700	cenozoic	cavern
57	elasmotherium	Cénozoïque	Savanes	2017-02-15	207	355	541	766	65	111	169	239	478	36864	180	205	528	1400	700	cenozoic	savannah
58	megistotherium	Cénozoïque	Cavernes	2018-04-02	153	263	401	567	82	140	213	302	479	33792	120	282	528	1400	700	cenozoic	cavern
59	metriorhynchus	Jurassique	Amphibien	2015-04-11	215	368	560	793	82	140	214	303	551	38708	180	215	584	1400	700	jurassic	amphibian
60	sarkastodon	Cénozoïque	Glaces	2017-02-15	210	360	548	776	66	112	171	242	485	37325	180	207	542	1400	700	cenozoic	snow
61	supersaurus	Jurassique	Herbivore	2015-04-11	262	449	685	969	67	115	175	248	551	38708	180	215	584	1400	700	jurassic	herbivore
62	archaeotherium	Cénozoïque	Savanes	2017-08-02	240	410	625	885	61	105	160	226	503	48384	360	134	584	1500	750	cenozoic	savannah
63	spinosaurus	Jurassique	Carnivore	2015-04-11	265	453	691	978	68	116	177	250	556	41472	180	230	670	1500	750	jurassic	carnivore
64	stegosaurus	Jurassique	Herbivore	2015-04-11	266	455	694	982	68	116	177	251	558	41472	180	230	670	1500	750	jurassic	herbivore
65	velociraptor	Jurassique	Carnivore	2015-04-11	217	371	565	800	83	142	216	306	556	38016	120	317	670	1500	750	jurassic	carnivore
66	velociraptor_gen_2	Jurassique	Carnivore	2019-11-28	277	474	723	1023	87	148	226	320	640	43930	120	366	893	1500	750	jurassic	carnivore
67	aerotitan	Jurassique	Ptérosaures	2016-06-29	187	320	487	689	97	167	254	359	574	55296	360	154	762	1600	800	jurassic	pterosaur
68	deinotherium	Cénozoïque	Glaces	2017-10-26	238	408	623	881	75	128	195	275	550	52992	360	147	700	1600	800	cenozoic	snow
69	entelodon	Cénozoïque	Savanes	2017-02-15	187	320	487	689	87	150	228	323	538	38016	120	317	669	1600	800	cenozoic	savannah
70	kaprosuchus	Jurassique	Amphibien	2015-12-11	337	577	880	1245	57	97	148	209	598	111898	1320	85	730	1600	800	jurassic	amphibian
71	postosuchus	Jurassique	Amphibien	2016-03-16	149	256	390	552	109	186	284	402	575	117965	1380	85	761	1650	830	jurassic	amphibian
72	synthetoceras	Cénozoïque	Glaces	2017-10-26	249	426	650	919	78	133	203	287	574	40551	120	338	761	1650	830	cenozoic	snow
73	dakosaurus	Aquatique	Grottes	2015-12-11	124	213	325	460	91	155	237	335	479	64512	720	90	528	2000	1000	aquatic	cave
74	dolichorhynchops	Aquatique	Récifs	2016-12-07	233	400	609	862	73	125	190	269	538	72576	720	101	669	2000	1000	aquatic	reef
75	onchopristis	Aquatique	Surfaces	2016-12-07	350	599	914	1293	36	62	95	135	539	72576	720	101	669	2000	1000	aquatic	surface
76	leptocleidus	Aquatique	Récifs	2015-12-11	314	538	821	1161	42	72	110	156	519	69835	720	97	620	2150	1080	aquatic	reef
77	protostega	Aquatique	Récifs	2016-10-19	240	410	625	885	61	105	160	226	503	67738	720	94	583	2200	1100	aquatic	reef
78	prognathodon	Aquatique	Surfaces	2015-12-11	193	331	505	714	91	155	237	335	558	75157	720	104	717	2250	1130	aquatic	surface
79	elasmosaurus	Aquatique	Surfaces	2016-10-19	249	426	650	919	78	133	203	287	574	77415	720	108	762	2400	1200	aquatic	surface
80	helicoprion	Aquatique	Surfaces	2016-03-16	174	298	455	644	101	173	264	373	574	77415	720	108	762	2500	1250	aquatic	surface
81	mauisaurus	Aquatique	Surfaces	2016-03-16	149	256	390	552	109	186	284	402	575	77415	720	108	761	2500	1250	aquatic	surface
82	trinacromerum	Aquatique	Récifs	2016-03-16	199	341	520	735	93	160	244	345	575	77415	720	108	761	2500	1250	aquatic	reef
83	xiphactinus	Aquatique	Grottes	2016-03-16	149	256	390	552	109	186	284	402	575	77415	720	108	761	2500	1250	aquatic	cave
84	geosaurus	Aquatique	Grottes	2016-03-16	154	264	402	569	112	192	293	415	593	79834	720	111	810	2900	1450	aquatic	cave
85	baculites	Aquatique	Grottes	2016-03-16	259	444	677	958	81	139	212	299	598	80640	720	112	827	3000	1500	aquatic	cave
86	psephoderma	Aquatique	Récifs	2015-12-11	363	622	948	1341	49	83	127	180	599	80640	720	112	826	3000	1500	aquatic	reef
87	tropeogopterus	Jurassique	Ptérosaures	2015-06-10	571	978	1490	2109	218	373	569	805	1464	140919	360	391	717	7130	3570	jurassic	pterosaur
88	parasaura	Jurassique	Herbivore	2016-06-29	725	1241	1892	2677	185	317	484	684	1521	58545	30	1952	774	7550	3780	jurassic	herbivore
89	giganocephalus	Jurassique	Herbivore	2015-09-30	826	1415	2158	3053	172	295	450	636	1590	122412	180	680	847	8490	4250	jurassic	herbivore
90	metrialong	Jurassique	Carnivore	2016-06-29	677	1160	1768	2502	259	443	675	956	1738	66891	30	2230	1011	8770	4390	jurassic	carnivore
91	stegoceratops	Jurassique	Herbivore	2015-06-10	823	1410	2150	3042	211	361	550	778	1729	133056	180	739	1000	8960	4480	jurassic	herbivore
92	spinoraptor	Jurassique	Carnivore	2015-06-10	735	1259	1919	2715	281	481	733	1037	1885	145152	180	806	1190	9520	4760	jurassic	carnivore
93	ankylodocus	Jurassique	Herbivore	2015-06-10	898	1538	2345	3318	281	481	733	1037	2074	443520	1440	308	1440	10920	5460	jurassic	herbivore
94	suprannotitan	Jurassique	Carnivore	2016-10-19	910	1559	2376	3362	314	538	821	1161	2212	241275	480	503	1620	11820	5910	jurassic	carnivore
95	megistocurus	Cénozoïque	Cavernes	2019-02-08	942	1614	2461	3482	394	676	1030	1457	2545	342922	720	476	1088	15680	7840	cenozoic	cavern
96	archaeophicyon	Cénozoïque	Cavernes	2019-11-15	1347	2308	3518	4977	281	481	733	1037	2592	249481	360	693	2280	16240	8120	cenozoic	cavern
97	leptostega	Aquatique	Récifs	2019-01-07	778	1332	2031	2873	482	826	1260	1782	2680	292341	480	609	1353	24360	12180	aquatic	reef
98	xinathodon	Aquatique	Surfaces	2019-03-24	901	1544	2353	3329	523	896	1366	1932	2972	324214	480	675	1620	26600	13300	aquatic	surface
99	dakoderma	Aquatique	Grottes	2019-04-05	735	1259	1919	2715	536	918	1399	1980	2828	381024	720	529	1500	28000	14000	aquatic	cave
100	geolasmosaurus	Aquatique	Grottes	2021-02-14	1327	2273	3465	4902	415	710	1083	1532	3064	412776	720	573	3720	29680	14840	aquatic	cave
101	gigakylocephalus	Jurassique	Herbivore	2021-06-30	3110	4292	5414	6546	567	1249	1558	1851	3897	299981	180	1667	5040	\N	27260	jurassic	herbivore
102	monostegotops	Jurassique	Herbivore	2018-11-02	3084	4085	5076	6033	964	1277	1586	1885	3770	290304	180	1613	4740	\N	28590	jurassic	herbivore
103	spinotasuchus	Jurassique	Carnivore	2019-06-06	2160	2871	3610	4469	1215	1619	2115	2594	3991	261677	120	2181	4560	\N	30160	jurassic	carnivore
104	microposaurus	Jurassique	Amphibien	2015-04-11	425	728	1110	1570	133	228	347	491	982	46080	180	256	1750	2500	1250	jurassic	amphibian
105	suchomimus	Jurassique	Carnivore	2015-04-11	437	748	1141	1614	112	191	292	413	917	48477	180	269	1937	2630	1320	jurassic	carnivore
106	unaysaurus	Jurassique	Herbivore	2015-04-11	476	815	1242	1757	122	208	318	449	998	46802	120	390	2150	2770	1390	jurassic	herbivore
107	pteranodon	Jurassique	Ptérosaures	2015-04-11	412	705	1075	1520	157	269	410	581	1056	53638	180	298	2372	2910	1460	jurassic	pterosaur
108	phorusrhacos	Cénozoïque	Savanes	2017-02-15	311	533	812	1149	97	167	254	359	718	69121	360	192	2460	3000	1500	cenozoic	savannah
109	eremotherium	Cénozoïque	Cavernes	2017-04-19	316	542	826	1168	99	169	258	365	730	56218	180	312	2580	3050	1530	cenozoic	cavern
110	sarcosuchus	Jurassique	Amphibien	2015-04-11	406	695	1060	1500	155	266	405	573	1042	56218	180	312	2605	3050	1530	jurassic	amphibian
111	megaloceros	Cénozoïque	Glaces	2017-04-19	351	601	916	1296	90	154	234	331	736	70848	360	197	2640	3080	1540	cenozoic	snow
112	shunosaurus	Jurassique	Herbivore	2015-08-04	459	786	1198	1695	143	246	374	530	1060	86631	420	206	3480	3100	1550	jurassic	herbivore
113	ostafrikasaurus	Jurassique	Carnivore	2015-04-11	382	654	997	1410	146	250	381	539	980	58799	180	327	2850	3190	1600	jurassic	carnivore
114	diprotodon	Cénozoïque	Glaces	2018-02-23	332	568	866	1226	104	178	271	383	766	58983	180	328	2820	3200	1600	cenozoic	snow
115	indricotherium	Cénozoïque	Savanes	2017-02-15	253	433	660	934	132	225	344	486	778	59904	180	333	2940	3250	1630	cenozoic	savannah
116	ichthyostega	Jurassique	Amphibien	2016-01-22	404	692	1055	1493	154	264	403	570	1037	71609	300	239	3120	3330	1670	jurassic	amphibian
117	scolosaurus	Jurassique	Herbivore	2026-01-06	399	683	1041	1473	169	289	440	623	1083	110477	720	153	3240	3430	1720	jurassic	herbivore
118	prionosuchus	Jurassique	Amphibien	2015-04-11	438	749	1142	1616	137	234	357	505	1010	63960	180	355	3360	3470	1740	jurassic	amphibian
119	therizinosaurus	Jurassique	Herbivore	2015-09-30	657	1125	1715	2427	88	151	230	325	1083	139200	960	145	3680	3500	1750	jurassic	herbivore
120	andrewsarchus	Cénozoïque	Cavernes	2017-02-15	276	473	721	1020	144	246	375	531	850	65434	180	364	3480	3550	1780	cenozoic	cavern
121	dimorphodon	Jurassique	Ptérosaures	2015-09-30	425	727	1109	1569	162	278	423	599	1089	156980	1140	138	3720	3600	1800	jurassic	pterosaur
122	dimetrodon	Jurassique	Carnivore	2016-01-24	412	705	1075	1520	157	269	410	581	1056	99810	540	185	3600	3610	1810	jurassic	carnivore
123	uintatherium	Cénozoïque	Savanes	2018-02-23	526	901	1374	1944	72	124	188	267	875	61671	120	514	3720	3650	1830	cenozoic	savannah
124	scaphognathus	Jurassique	Ptérosaures	2015-12-11	474	813	1239	1752	148	254	387	548	1096	169344	1260	134	3780	3700	1850	jurassic	pterosaur
125	glyptodon	Cénozoïque	Cavernes	2017-11-21	467	799	1218	1724	97	167	254	359	898	63360	120	528	3900	3750	1880	cenozoic	cavern
126	tyrannosaurus_rex	Jurassique	Carnivore	2015-04-11	434	743	1133	1603	166	284	433	612	1113	97920	480	204	3960	3750	1880	jurassic	carnivore
127	tyrannosaurus_rex_gen_2	Jurassique	Carnivore	2019-10-31	518	888	1354	1915	162	278	423	599	1197	107060	480	223	4800	3750	1880	jurassic	carnivore
128	marsupial_lion	Cénozoïque	Glaces	2017-04-19	222	381	581	822	183	314	478	677	934	65895	120	549	4200	3900	1950	cenozoic	snow
129	ammonite	Aquatique	Grottes	2015-12-11	539	924	1408	1992	91	155	237	335	958	129024	720	179	4440	4000	2000	aquatic	cave
130	compsognathus	Jurassique	Carnivore	2023-03-17	233	400	609	862	89	153	233	329	598	42240	120	352	4440	4000	2000	jurassic	carnivore
131	pliosaurus	Aquatique	Récifs	2016-06-29	456	781	1191	1685	117	200	305	431	958	129024	720	179	4440	4000	2000	aquatic	reef
132	hyneria	Aquatique	Grottes	2019-09-06	231	396	603	853	190	326	497	703	970	130637	720	181	4620	4050	2030	aquatic	cave
133	dunkleosteus	Aquatique	Grottes	2015-12-11	435	746	1137	1609	136	233	355	503	1006	135476	720	188	4980	4200	2100	aquatic	cave
134	hauffiosaurus	Aquatique	Récifs	2019-02-19	446	764	1164	1647	139	239	364	515	1030	72653	120	605	5160	4300	2150	aquatic	reef
135	kronosaurus	Aquatique	Récifs	2015-12-11	228	391	596	843	214	366	558	790	1053	141927	720	197	5460	4400	2200	aquatic	reef
136	leedsichthys	Aquatique	Grottes	2019-08-16	366	663	1011	1431	155	253	386	546	993	133863	720	186	4800	4400	2200	aquatic	cave
137	liopleurodon	Aquatique	Récifs	2016-03-16	513	879	1340	1896	131	225	343	485	1078	145152	720	202	5640	4500	2250	aquatic	reef
138	plesiosaurus	Aquatique	Surfaces	2016-03-16	513	879	1340	1896	131	225	343	485	1078	145152	720	202	5700	4500	2250	aquatic	surface
139	megalodon	Aquatique	Surfaces	2015-12-11	334	572	872	1233	194	332	506	716	1101	148378	720	206	5880	4600	2300	aquatic	surface
140	kaiwhekea	Aquatique	Surfaces	2018-09-21	482	826	1259	1781	151	258	393	557	1114	78567	120	655	6000	4800	2400	aquatic	surface
141	styxosaurus	Aquatique	Surfaces	2015-12-11	647	1108	1689	2390	109	186	284	402	1149	154829	720	215	6420	4800	2400	aquatic	surface
142	rhizodus	Aquatique	Grottes	2018-07-27	500	856	1305	1846	100	171	261	369	946	127412	720	177	4320	4900	2450	aquatic	cave
143	suchoripterus	Jurassique	Ptérosaures	2015-12-11	1021	1748	2665	3771	319	546	833	1178	2356	181440	180	1008	3900	17870	8940	jurassic	pterosaur
144	unayrhynchus	Jurassique	Herbivore	2016-10-19	1278	2190	3338	4723	327	560	853	1208	2684	189384	120	1578	5100	19720	9860	jurassic	herbivore
145	koolasaurus	Jurassique	Amphibien	2015-06-10	1046	1792	2731	3864	399	684	1043	1476	2684	206600	180	1148	5100	20500	10250	jurassic	amphibian
146	skoolasaurus	Jurassique	Amphibien	2026-01-06	822	1408	2146	3036	533	914	1393	1970	2919	449488	900	499	6240	22600	11300	jurassic	amphibian
147	entelorhacos	Cénozoïque	Savanes	2020-01-31	1429	2448	3731	5279	447	765	1166	1650	3300	317520	360	882	3840	25760	12880	cenozoic	savannah
148	rajastega	Jurassique	Carnivore	2016-10-19	1365	2339	3565	5044	472	808	1231	1742	3318	361913	480	754	7800	25930	12970	jurassic	carnivore
149	andrewtherium	Cénozoïque	Cavernes	2022-04-21	1353	2318	3534	5000	572	980	1494	2114	3677	283047	180	1572	5280	28840	14420	cenozoic	cavern
150	indominus_rex	Jurassique	Carnivore	2015-06-10	1470	2517	3837	5430	561	962	1466	2074	3771	508033	720	706	10080	29400	14700	jurassic	carnivore
151	indominus_rex_gen_2	Jurassique	Carnivore	2019-12-20	1823	3124	4761	6737	570	976	1488	2105	4210	405216	360	1126	10080	29400	14700	jurassic	carnivore
152	ostaposaurus	Jurassique	Amphibien	2016-03-16	1394	2388	3639	5149	532	912	1390	1967	3576	344132	360	956	9060	31870	15940	jurassic	amphibian
153	indricoceros	Cénozoïque	Savanes	2019-01-18	1721	2949	4495	6360	538	921	1405	1987	3975	280527	120	2338	5460	35420	17710	cenozoic	savannah
154	hynecoprion	Aquatique	Grottes	2022-01-20	1404	2406	3667	5188	658	1128	1719	2432	4053	546135	720	759	10080	36680	18340	aquatic	cave
155	priotrodon	Jurassique	Carnivore	2016-03-16	1734	2971	4528	6407	662	1135	1730	2447	4449	342559	180	1903	10020	39650	19830	jurassic	carnivore
156	liosichtodon	Aquatique	Grottes	2020-06-05	2354	4033	6147	8698	736	1260	1921	2718	5436	383645	120	3197	10080	49840	24920	aquatic	cave
157	skoonasaurus	Jurassique	Herbivore	2026-06-05	6480	8584	10603	13087	1863	2590	3349	4040	8130	771120	360	2142	10080	\N	70270	jurassic	herbivore
158	indoraptor	Jurassique	Carnivore	2018-06-21	5103	6764	8550	10181	2658	3554	4399	5302	8484	1034209	600	1724	10080	\N	89320	jurassic	carnivore
159	indoraptor_gen_2	Jurassique	Carnivore	2020-06-19	7076	9479	12081	14747	2211	2962	3775	4608	9216	1034209	600	1724	10080	\N	89320	jurassic	carnivore
160	compsognathus_gen_2	Jurassique	Carnivore	2026-02-13	647	1108	1689	2390	109	186	284	402	1149	88474	180	492	7260	6400	3200	jurassic	carnivore
161	deinocheirus	Jurassique	Herbivore	2016-02-18	342	586	893	1264	249	427	651	922	1317	84480	60	1408	8460	5500	2750	jurassic	herbivore
162	dodo	Jurassique	Herbivore	2023-10-03	754	1292	1969	2787	79	135	205	290	1161	163892	780	210	9900	6470	3240	jurassic	herbivore
163	pterodactylus	Jurassique	Ptérosaures	2016-06-29	907	1554	2369	3352	527	902	1375	1945	2993	403200	720	560	360	10000	5000	jurassic	pterosaur
164	gorgosaurus	Jurassique	Carnivore	2016-03-18	498	852	1299	1839	233	400	609	862	1437	110592	180	614	10080	6000	3000	jurassic	carnivore
165	kentrosaurus	Jurassique	Herbivore	2016-04-14	622	1066	1624	2298	194	333	508	718	1436	221184	900	246	10020	6000	3000	jurassic	herbivore
166	little_eatie	Jurassique	Carnivore	2025-06-06	658	1128	1719	2432	206	352	537	760	1520	253594	1020	249	10080	6350	3180	jurassic	carnivore
167	aquilops	Jurassique	Herbivore	2025-06-30	398	682	1040	1471	187	320	487	689	1149	228557	1320	173	10080	6400	3200	jurassic	herbivore
168	australotitan	Jurassique	Herbivore	2024-01-19	372	637	970	1373	299	512	780	1103	1532	327680	1440	228	10080	6400	3200	jurassic	herbivore
169	dracovenator	Jurassique	Carnivore	2025-02-14	401	687	1048	1482	293	501	764	1081	1544	227866	840	271	10080	6450	3230	jurassic	carnivore
170	ceratosaurus	Jurassique	Carnivore	2016-01-22	896	1535	2340	3311	151	258	394	557	1592	109824	120	915	10080	6500	3250	jurassic	carnivore
171	yutyrannus	Jurassique	Carnivore	2017-03-17	505	866	1320	1867	263	451	687	973	1556	179712	540	333	10080	6500	3250	jurassic	carnivore
172	eucladoceros	Cénozoïque	Glaces	2019-10-18	679	1163	1773	2509	212	364	554	784	1568	211277	720	293	10080	6550	3280	cenozoic	snow
173	yuxisaurus	Jurassique	Herbivore	2024-11-11	441	756	1153	1631	286	491	748	1058	1568	211277	720	293	10080	6550	3280	jurassic	herbivore
174	kelenken	Cénozoïque	Savanes	2018-03-20	682	1168	1780	2518	213	365	556	787	1574	212084	720	295	10080	6580	3290	cenozoic	savannah
175	cervalces	Cénozoïque	Glaces	2022-08-10	821	1407	2144	3034	171	293	447	632	1580	111514	120	929	10080	6600	3300	cenozoic	snow
176	diabloceratops	Jurassique	Herbivore	2024-11-22	855	1465	2233	3160	160	275	419	593	1581	337920	1440	235	10080	6600	3300	jurassic	herbivore
177	gigantophis	Cénozoïque	Cavernes	2019-03-01	684	1172	1787	2528	214	366	558	790	1580	212890	720	296	10080	6600	3300	cenozoic	cavern
178	nodosaurus	Jurassique	Herbivore	2018-10-19	731	1252	1909	2700	228	391	596	844	1688	162432	360	451	10080	6600	3300	jurassic	herbivore
179	pederpes_lux	Jurassique	Amphibien	2025-03-14	770	1319	2010	2844	80	137	209	296	1185	182477	900	203	10080	6600	3300	jurassic	amphibian
180	scelidosaurus	Jurassique	Herbivore	2024-09-12	684	1172	1787	2528	214	366	558	790	1580	192615	600	321	10080	6600	3300	jurassic	herbivore
181	rodrigues_solitaire	Jurassique	Herbivore	2024-02-16	537	919	1401	1982	168	287	438	619	1238	166925	720	232	10080	6900	3450	jurassic	herbivore
182	smilodon	Cénozoïque	Glaces	2017-02-15	486	833	1270	1796	282	483	737	1043	1604	174951	480	364	10080	6700	3350	cenozoic	snow
183	bumpy	Jurassique	Herbivore	2022-01-31	560	959	1462	2068	262	450	685	970	1616	176256	480	367	10080	6750	3380	jurassic	herbivore
184	einiosaurus	Jurassique	Herbivore	2017-09-22	1015	1738	2650	3749	120	206	314	444	1616	196993	600	328	10080	6750	3380	jurassic	herbivore
185	pachyrhinosaurus	Jurassique	Herbivore	2016-04-14	700	1199	1827	2586	219	375	571	808	1616	228096	780	292	10080	6750	3380	jurassic	herbivore
186	mylodon	Cénozoïque	Glaces	2022-02-15	705	1208	1841	2605	220	377	575	814	1628	177562	480	370	10080	6800	3400	cenozoic	snow
187	struthiomimus	Jurassique	Herbivore	2022-07-01	705	1208	1841	2605	220	377	575	814	1628	114893	120	957	10080	6800	3400	jurassic	herbivore
188	big_eatie	Jurassique	Carnivore	2025-05-09	708	1212	1848	2614	221	379	577	817	1634	230631	780	296	10080	6830	3420	jurassic	carnivore
189	borealopelta	Jurassique	Herbivore	2024-08-02	533	912	1391	1968	277	475	724	1025	1640	199911	600	333	10080	6850	3430	jurassic	herbivore
190	masiakasaurus	Jurassique	Carnivore	2025-01-06	533	912	1391	1968	277	475	724	1025	1640	263040	960	274	10080	6850	3430	jurassic	carnivore
191	iguanodon	Jurassique	Herbivore	2020-12-23	715	1225	1868	2643	224	383	584	826	1652	158976	360	442	10080	6900	3450	jurassic	herbivore
192	irritator_gen_2	Jurassique	Carnivore	2024-04-15	644	1103	1681	2379	246	421	642	909	1652	201370	600	336	10080	6900	3450	jurassic	carnivore
193	megatherium	Cénozoïque	Cavernes	2017-04-19	715	1225	1868	2643	224	383	584	826	1652	180173	480	375	10080	6900	3450	cenozoic	cavern
194	sinosauropteryx	Jurassique	Carnivore	2023-11-24	429	732	1115	1578	201	343	523	740	1233	143079	540	265	10080	6900	3450	jurassic	carnivore
195	stegouros	Jurassique	Herbivore	2024-03-15	829	1419	2164	3061	191	328	500	707	1664	192154	540	356	10080	6950	3480	jurassic	herbivore
196	styracosaurus_lux	Jurassique	Herbivore	2023-12-22	483	827	1261	1784	300	513	782	1107	1665	309581	1200	258	10080	6950	3480	jurassic	herbivore
197	red	Jurassique	Carnivore	2024-09-27	723	1239	1888	2672	226	387	590	835	1670	203559	600	339	10080	6980	3490	jurassic	carnivore
198	ailurarctos	Cénozoïque	Glaces	2023-03-16	778	1332	2030	2873	243	416	635	898	1796	207360	540	384	10080	7000	3500	cenozoic	snow
199	antarctopelta	Jurassique	Herbivore	2015-11-09	798	1368	2085	2949	204	350	533	754	1676	247296	840	294	10080	7000	3500	jurassic	herbivore
200	arctodus	Cénozoïque	Glaces	2018-06-29	740	1268	1933	2735	222	381	580	821	1676	182784	480	381	10080	7000	3500	cenozoic	snow
201	beta	Jurassique	Carnivore	2022-12-23	508	870	1327	1877	295	505	770	1089	1676	182784	480	381	10080	7000	3500	jurassic	carnivore
202	dracorex	Jurassique	Herbivore	2020-03-06	726	1243	1895	2413	227	389	592	922	1676	129024	180	717	10080	7000	3500	jurassic	herbivore
203	erlikosaurus	Jurassique	Herbivore	2017-03-25	871	1492	2274	3218	181	311	474	670	1676	290304	1080	269	10080	7000	3500	jurassic	herbivore
204	eryops	Jurassique	Amphibien	2017-10-20	1016	1740	2653	3754	136	233	355	503	1676	204288	600	340	10080	7000	3500	jurassic	amphibian
205	giganotosaurus_gen_2	Jurassique	Carnivore	2022-11-23	980	1678	2558	3620	147	253	385	545	1676	139776	240	582	10080	7000	3500	jurassic	carnivore
206	megalosaurus	Jurassique	Carnivore	2015-11-27	741	1270	1936	2739	232	397	605	856	1712	139776	240	582	10080	7000	3500	jurassic	carnivore
207	woolly_rhinoceros	Cénozoïque	Glaces	2021-01-01	726	1243	1895	2681	227	389	592	838	1676	225792	720	314	10080	7000	3500	cenozoic	snow
208	zalmoxes	Jurassique	Herbivore	2017-04-24	363	622	948	1341	340	583	888	1257	1676	204288	600	340	10080	7000	3500	jurassic	herbivore
209	dracorex_gen_2	Jurassique	Herbivore	2025-05-20	512	876	1336	1890	297	509	775	1097	1688	173261	420	413	10080	7050	3530	jurassic	herbivore
210	lythronax	Jurassique	Carnivore	2019-03-22	475	814	1241	1755	308	528	805	1139	1687	227405	720	316	10080	7050	3530	jurassic	carnivore
211	brunette	Jurassique	Carnivore	2024-10-25	731	1252	1909	2700	228	391	596	844	1688	314036	1200	262	10080	7050	3530	jurassic	carnivore
212	tsintaosaurus	Jurassique	Herbivore	2022-01-10	914	1565	2386	3376	171	293	447	633	1688	162432	360	451	10080	7050	3530	jurassic	herbivore
213	charlie	Jurassique	Carnivore	2024-08-30	844	1445	2203	3117	195	334	509	720	1694	260813	900	290	10080	7080	3540	jurassic	carnivore
214	albertosaurus	Jurassique	Carnivore	2021-06-30	626	1135	1730	2448	265	433	661	935	1700	229018	720	318	10080	7100	3550	jurassic	carnivore
215	deinonychus	Jurassique	Carnivore	2021-05-14	736	1261	1922	2720	230	394	601	850	1700	119962	120	1000	10080	7100	3550	jurassic	carnivore
216	delta	Jurassique	Carnivore	2025-01-17	736	1265	1929	2729	230	395	603	853	1706	163584	360	454	10080	7100	3550	jurassic	carnivore
217	gastornis	Cénozoïque	Savanes	2017-12-23	368	630	961	1360	345	591	901	1275	1700	185396	480	386	10080	7100	3550	cenozoic	savannah
218	homalocephale	Jurassique	Herbivore	2025-01-27	663	1135	1730	2448	253	433	661	935	1700	239924	780	308	10080	7100	3550	jurassic	herbivore
219	deinosuchus	Jurassique	Amphibien	2021-10-01	964	1651	2516	3560	162	278	423	599	1712	120807	120	1007	10080	7100	3550	jurassic	amphibian
220	fukuisaurus	Jurassique	Herbivore	2023-04-12	815	1397	2129	3013	208	357	544	770	1712	164736	360	458	10080	7150	3580	jurassic	herbivore
221	koreanosaurus	Jurassique	Herbivore	2024-02-09	534	914	1394	1972	297	508	774	1096	1712	230631	720	320	10080	7150	3580	jurassic	herbivore
222	sinoceratops	Jurassique	Herbivore	2020-11-26	593	1270	1936	2739	278	397	605	856	1712	230631	720	320	10080	7150	3580	jurassic	herbivore
223	sphenacodon	Jurassique	Carnivore	2020-10-17	778	1279	1949	2758	243	400	609	862	1724	230400	660	349	10080	7150	3580	jurassic	carnivore
224	blonde_becky	Jurassique	Carnivore	2025-04-07	1001	1714	2613	3697	151	258	393	556	1711	241613	780	310	10080	7150	3580	jurassic	carnivore
225	tyrannosaur_doe	Jurassique	Carnivore	2024-05-10	741	1270	1936	2739	232	397	605	856	1712	274560	960	286	10080	7150	3580	jurassic	carnivore
226	tyrannosaur_buck	Jurassique	Carnivore	2024-04-12	875	1499	2284	3232	190	325	496	702	1712	274560	960	286	10080	7150	3580	jurassic	carnivore
227	carbonemys	Cénozoïque	Cavernes	2021-11-25	1038	1778	2710	3834	139	238	363	514	1712	131789	180	732	10080	7150	3580	cenozoic	cavern
228	cryolophosaurus	Jurassique	Carnivore	2022-09-01	746	1279	1949	2758	233	400	609	862	1724	188007	480	392	10080	7200	3600	jurassic	carnivore
229	sonorasaurus	Jurassique	Herbivore	2021-07-09	970	1662	2534	3585	163	280	426	603	1723	121652	120	1014	10080	7200	3600	jurassic	herbivore
230	triceratops_gen_2	Jurassique	Herbivore	2021-01-04	858	1471	2242	3172	198	340	518	733	1724	132711	180	737	10080	7200	3600	jurassic	herbivore
231	toro	Jurassique	Carnivore	2022-10-28	373	639	975	1379	350	599	914	1293	1724	199066	540	369	10080	7200	3600	jurassic	carnivore
232	the_big_one	Jurassique	Carnivore	2023-10-28	752	1288	1963	2777	235	402	613	868	1736	211584	600	353	10080	7200	3600	jurassic	carnivore
233	acanthostega	Jurassique	Amphibien	2018-03-03	438	750	1143	1617	266	455	693	981	1486	243168	480	507	10080	7250	3630	jurassic	amphibian
234	diplocaulus_gen_2	Jurassique	Amphibien	2024-07-08	564	966	1472	2083	294	503	767	1085	1736	133632	180	742	10080	7250	3630	jurassic	amphibian
235	mastodon	Cénozoïque	Glaces	2019-07-04	654	1120	1708	2416	265	455	693	981	1736	189313	480	394	10080	7250	3630	cenozoic	snow
236	secodontosaurus	Jurassique	Carnivore	2016-05-13	977	1674	2552	3610	164	282	429	607	1735	233857	720	325	10080	7250	3630	jurassic	carnivore
237	ghost	Jurassique	Carnivore	2022-10-28	977	1674	2552	3610	164	282	429	607	1735	189313	480	394	10080	7250	3630	jurassic	carnivore
238	stegosaurus_gen_2	Jurassique	Herbivore	2024-07-05	752	1288	1963	2777	235	402	613	868	1736	278400	960	290	10080	7250	3630	jurassic	herbivore
239	echo	Jurassique	Carnivore	2024-06-07	566	969	1477	2090	295	505	769	1089	1742	189965	480	396	10080	7280	3640	jurassic	carnivore
240	purussaurus	Jurassique	Amphibien	2026-10-23	755	1294	1972	2790	236	404	616	872	1744	156657	300	522	10080	7290	3650	jurassic	amphibian
241	monkeydactyl	Jurassique	Ptérosaures	2024-01-19	757	1296	1976	2796	237	405	618	874	1748	235469	720	327	10080	7300	3650	jurassic	pterosaur
242	seymouria	Jurassique	Amphibien	2024-08-12	1060	1815	2767	3915	142	243	371	524	1747	235469	720	327	10080	7300	3650	jurassic	amphibian
243	spinosaurus_gen_2	Jurassique	Carnivore	2021-03-19	757	1296	1976	2796	237	405	618	874	1748	134554	180	748	10080	7300	3650	jurassic	carnivore
244	bajadasaurus	Jurassique	Herbivore	2023-11-10	457	783	1194	1689	333	571	871	1232	1760	270951	900	301	10080	7350	3680	jurassic	herbivore
245	edaphosaurus	Jurassique	Carnivore	2022-03-28	1101	1886	2875	4069	131	224	341	482	1754	135015	180	750	10080	7330	3670	jurassic	carnivore
246	proterogyrinus	Jurassique	Amphibien	2018-05-26	754	1292	1970	2787	241	412	628	889	1760	191924	480	400	10080	7350	3680	jurassic	amphibian
247	rinchenia	Jurassique	Carnivore	2023-07-07	838	1436	2189	3097	214	367	560	792	1760	237082	720	329	10080	7350	3680	jurassic	carnivore
248	tyrannosaur_bull	Jurassique	Carnivore	2025-08-01	688	1179	1797	2542	263	450	686	971	1765	271872	900	302	10080	7380	3690	jurassic	carnivore
249	the_spino	Jurassique	Carnivore	2024-12-20	650	1113	1697	2401	275	471	718	1015	1765	215233	600	359	10080	7380	3690	jurassic	carnivore
250	bageherpeton	Jurassique	Amphibien	2022-03-21	765	1310	1997	2825	239	409	624	883	1766	135936	180	755	10080	7380	3690	jurassic	amphibian
251	therizinosaurus_gen_2	Jurassique	Herbivore	2023-01-11	1070	1834	2795	3955	143	246	374	530	1766	147264	240	614	10080	7380	3690	jurassic	herbivore
252	geosternbergia	Jurassique	Ptérosaures	2024-01-19	575	986	1502	2126	300	513	783	1107	1771	215962	600	360	10080	7400	3700	jurassic	pterosaur
253	gryposuchus	Jurassique	Amphibien	2020-10-30	575	986	1502	2126	300	513	783	1107	1771	136397	180	758	10080	7400	3700	jurassic	amphibian
254	blue	Jurassique	Carnivore	2022-06-09	460	789	1202	1701	336	575	876	1240	1772	193229	480	403	10080	7400	3700	jurassic	carnivore
255	carnotaurus_toy	Jurassique	Carnivore	2026-07-31	454	777	1184	1676	339	580	885	1252	1776	193621	480	403	10080	7420	3710	jurassic	carnivore
256	one_armed_baryonyx	Jurassique	Carnivore	2025-09-26	386	662	1008	1427	282	482	735	1040	1486	357600	960	373	10080	7450	3730	jurassic	carnivore
257	panthera	Jurassique	Carnivore	2023-05-12	726	1244	1896	2683	256	438	668	945	1783	148762	240	620	10080	7450	3730	jurassic	carnivore
258	leucistic_baryonyx	Jurassique	Carnivore	2025-04-11	525	900	1372	1941	319	546	832	1177	1784	240308	720	334	10080	7450	3730	jurassic	carnivore
259	diploceraspis	Jurassique	Amphibien	2022-08-03	1015	1738	2650	3749	153	262	399	564	1736	133632	180	742	10080	7450	3730	jurassic	amphibian
260	panthera_blytheae	Cénozoïque	Glaces	2026-03-03	434	744	1133	1604	349	597	911	1288	1789	275559	900	306	10080	7480	3740	cenozoic	snow
261	amargasaurus	Jurassique	Herbivore	2018-01-20	816	1399	2132	3016	231	395	603	853	1796	138240	180	768	10080	7500	3750	jurassic	herbivore
262	cearadactylus	Jurassique	Ptérosaures	2023-10-05	677	1159	1766	2499	258	443	675	955	1736	122497	120	1021	10080	7500	3750	jurassic	pterosaur
263	darwinopterus	Jurassique	Ptérosaures	2016-11-03	622	1066	1624	2298	292	500	761	1077	1795	322560	1140	283	10080	7500	3750	jurassic	pterosaur
264	dilophosaurus_gen_2	Jurassique	Carnivore	2020-12-11	921	1577	2404	3401	192	329	501	709	1772	125031	120	1042	10080	7500	3750	jurassic	carnivore
265	dreadnoughtus	Jurassique	Herbivore	2023-09-01	819	1402	2138	3025	201	344	525	743	1688	162432	360	451	10080	7500	3750	jurassic	herbivore
266	kaprosuchus_gen_2	Jurassique	Amphibien	2021-03-05	783	1341	2044	2892	245	419	639	904	1808	127565	120	1063	10080	7500	3750	jurassic	amphibian
267	metriacanthosaurus	Jurassique	Carnivore	2017-01-30	389	666	1015	1436	365	624	952	1347	1796	161280	300	538	10080	7500	3750	jurassic	carnivore
268	parasaurolophus_gen_2	Jurassique	Herbivore	2020-09-18	778	1332	2030	2873	243	416	635	898	1796	138240	180	768	10080	7500	3750	jurassic	herbivore
269	segnosaurus	Jurassique	Herbivore	2017-08-04	544	932	1421	2011	316	541	825	1167	1795	299520	1020	294	10080	7500	3750	jurassic	herbivore
270	troodon	Jurassique	Carnivore	2016-01-04	622	1066	1624	2298	292	500	761	1077	1795	195840	480	408	10080	7500	3750	jurassic	carnivore
271	rexy	Jurassique	Carnivore	2023-06-11	544	932	1421	2011	316	541	825	1167	1795	207360	540	384	10080	7500	3750	jurassic	carnivore
272	dakotaraptor	Jurassique	Carnivore	2026-06-05	778	1333	2032	2875	243	417	635	898	1796	195971	480	408	10080	7510	3760	jurassic	carnivore
273	nyctosaurus	Jurassique	Ptérosaures	2023-07-15	626	1073	1635	2314	294	503	766	1084	1807	139162	180	773	10080	7550	3780	jurassic	pterosaur
274	woolly_mammoth	Cénozoïque	Glaces	2016-12-15	906	1552	2366	3348	209	359	547	773	1819	140084	180	778	10080	7600	3800	cenozoic	snow
275	arambourgiania	Jurassique	Ptérosaures	2021-12-17	555	951	1450	2051	322	552	841	1190	1831	129255	120	1077	10080	7650	3830	jurassic	pterosaur
276	urtinotherium	Cénozoïque	Savanes	2018-08-24	888	1522	2320	3282	218	374	570	806	1832	141005	180	783	10080	7650	3830	cenozoic	savannah
277	brachiosaurus	Jurassique	Herbivore	2020-07-03	801	1372	2091	2959	250	429	654	925	1850	130522	120	1088	10080	7730	3870	jurassic	herbivore
278	edmontosaurus	Jurassique	Herbivore	2021-03-12	522	963	1469	2078	339	559	852	1206	1855	249984	720	347	10080	7750	3880	jurassic	herbivore
279	thalassodromeus	Jurassique	Ptérosaures	2022-05-06	1085	1858	2832	4008	163	280	426	603	1856	130944	120	1091	10080	7750	3880	jurassic	pterosaur
280	titanoboa	Cénozoïque	Cavernes	2017-11-24	763	1308	1993	2820	264	452	688	974	1855	142848	180	794	10080	7750	3880	cenozoic	cavern
281	tupandactylus	Jurassique	Ptérosaures	2021-02-12	930	1593	2428	3436	215	368	561	794	1868	143770	180	799	10080	7800	3900	jurassic	pterosaur
282	ornithocheirus	Jurassique	Ptérosaures	2020-07-31	977	1673	2550	3608	203	349	531	752	1880	132634	120	1105	10080	7850	3930	jurassic	pterosaur
283	archelon	Aquatique	Récifs	2016-04-15	912	1563	2382	3371	233	400	609	862	1915	258048	720	358	10080	8000	4000	aquatic	reef
284	mosasaurus	Aquatique	Surfaces	2015-09-30	829	1421	2166	3064	259	444	677	958	1916	258048	720	358	10080	8000	4000	aquatic	surface
285	pteranodon_gen_2	Jurassique	Ptérosaures	2020-09-04	829	1421	2166	3064	259	444	677	958	1916	135168	120	1126	10080	8000	4000	jurassic	pterosaur
286	tupuxuara	Jurassique	Ptérosaures	2018-09-14	804	1376	2098	2969	251	430	656	928	1856	119040	60	1984	10080	8000	4000	jurassic	pterosaur
287	mosasaurus_gen_2	Aquatique	Surfaces	2020-05-15	599	1026	1563	2212	347	595	907	1284	1975	139392	120	1162	10080	8250	4130	aquatic	surface
288	ophthalmosaurus	Aquatique	Récifs	2022-04-16	855	1465	2233	3160	267	458	698	988	1976	215424	480	449	10080	8250	4130	aquatic	reef
289	gillicus	Aquatique	Grottes	2018-07-13	928	1590	2423	3428	290	497	757	1071	2142	288692	720	401	10080	8300	4150	aquatic	cave
290	barracudasaurus	Aquatique	Surfaces	2024-05-31	871	1492	2274	3218	272	466	711	1005	2011	193536	360	538	10080	8400	4200	aquatic	surface
291	platecarpus	Aquatique	Surfaces	2021-07-30	1146	1962	2991	4233	193	330	503	712	2035	143616	120	1197	10080	8500	4250	aquatic	surface
292	temnodontosaurus	Aquatique	Récifs	2022-09-23	881	1510	2301	3256	275	472	719	1017	2035	143616	120	1197	10080	8500	4250	aquatic	reef
293	umoonasaurus	Aquatique	Récifs	2017-03-10	793	1359	2071	2930	303	519	791	1119	2035	274176	720	381	10080	8500	4250	aquatic	reef
294	goronyosaurus	Aquatique	Récifs	2023-08-04	448	768	1171	1657	420	720	1098	1553	2071	305588	840	364	10080	8650	4330	aquatic	reef
295	plesiosuchus	Aquatique	Grottes	2020-04-24	1170	2003	3054	4321	244	417	636	900	2250	303207	720	421	10080	8900	4450	aquatic	cave
296	bananogmius	Aquatique	Grottes	2016-11-25	467	799	1218	1724	437	749	1142	1616	2155	290304	720	403	10080	9000	4500	aquatic	cave
297	edestus	Aquatique	Surfaces	2016-09-09	1026	1758	2680	3792	262	450	685	970	2155	290304	720	403	10080	9000	4500	aquatic	surface
298	suchodus	Aquatique	Grottes	2019-07-31	933	1598	2436	3447	292	500	761	1077	2154	290304	720	403	10080	9000	4500	aquatic	cave
299	smoothie	Jurassique	Herbivore	2025-10-24	1267	2170	3308	4680	191	326	498	704	2167	319719	840	381	10080	9050	4530	jurassic	herbivore
300	pierce	Jurassique	Herbivore	2025-10-17	943	1616	2464	3486	295	505	770	1089	2178	419328	1260	333	10080	9100	4550	jurassic	herbivore
301	major	Jurassique	Carnivore	2025-11-21	954	1634	2491	3524	298	511	778	1101	2202	471040	1440	327	10080	9200	4600	jurassic	carnivore
302	tiger	Jurassique	Carnivore	2025-12-19	623	1068	1628	2303	405	693	1056	1495	2215	412032	1200	343	10080	9250	4630	jurassic	carnivore
303	rebel	Jurassique	Herbivore	2026-06-05	1147	1965	2995	4237	249	427	650	920	2244	388800	1080	360	10080	9380	4690	jurassic	herbivore
304	angel	Jurassique	Herbivore	2026-05-08	603	1032	1574	2226	419	718	1095	1549	2245	388800	1080	360	10080	9380	4690	jurassic	herbivore
305	junior	Jurassique	Carnivore	2026-01-16	591	1012	1543	2183	431	738	1125	1592	2274	321024	780	412	10080	9500	4750	jurassic	carnivore
306	spinosaurus_rebirth	Jurassique	Carnivore/Surfaces	2025-08-29	943	1616	2464	3486	612	1049	1599	2262	3351	623616	1200	520	10080	14000	7000	jurassic	carnivore-surface
307	ceratosaurus_gen_2	Jurassique	Carnivore	2025-06-02	1916	3282	5003	7079	308	528	805	1140	3352	344064	420	819	10080	14000	7000	jurassic	carnivore
308	one_eyed_allosaurus	Jurassique	Carnivore	2026-04-10	1459	2500	3810	5391	456	781	1191	1685	3370	720640	1440	500	10080	14080	7040	jurassic	carnivore
309	pyroraptor_dominion	Jurassique	Carnivore/Surfaces	2025-12-19	731	1252	1909	2700	685	1174	1789	2532	3376	721920	1440	501	10080	14100	7050	jurassic	carnivore-surface
310	mosasaurus_gen_3	Aquatique	Surfaces	2025-07-04	1773	3037	4629	6550	369	633	964	1365	3412	569088	1020	558	10080	14250	7130	aquatic	surface
311	gorgosuchus	Jurassique	Amphibien	2016-12-07	2500	4282	6527	9235	639	1095	1669	2361	5247	1043684	1320	791	10080	42560	21280	jurassic	amphibian
312	erliphosaurus	Jurassique	Carnivore	2017-04-19	2623	4493	6849	9690	606	1038	1582	2238	5266	709552	720	985	10080	43070	21540	jurassic	carnivore
313	allonogmius	Jurassique	Carnivore	2020-01-01	2232	3823	5827	8245	1004	1719	2620	3708	6285	604800	360	1680	10080	53200	26600	jurassic	carnivore
314	smithetoceras	Cénozoïque	Glaces	2019-07-16	1610	2758	4204	5948	1045	1790	2728	3860	5719	550368	360	1529	10080	46760	23380	cenozoic	snow
315	cerazinosaurus	Jurassique	Carnivore	2018-04-23	2480	4248	6476	9163	947	1623	2473	3500	6363	734832	540	1361	10080	56000	28000	jurassic	carnivore
316	sah_panthera	Cénozoïque	Glaces	2026-03-03	1862	3189	4861	6877	1034	1772	2700	3821	5970	727776	600	1213	10080	49700	24850	cenozoic	snow
317	mammotherium	Cénozoïque	Savanes	2018-12-10	3266	5594	8528	12066	612	1049	1599	2262	6033	503194	240	2097	10080	50400	25200	cenozoic	savannah
318	segnosuchus	Jurassique	Herbivore	2017-08-04	1347	2308	3518	4977	1263	2163	3298	4666	6221	678586	480	1414	10080	51240	25620	jurassic	herbivore
319	pteraquetzal	Jurassique	Ptérosaures	2020-09-14	3547	6076	9262	13104	597	1022	1558	2205	6300	444629	120	3705	10080	52360	26180	jurassic	pterosaur
320	zalmonodon	Jurassique	Ptérosaures	2020-05-22	2697	4620	7043	9964	843	1444	2201	3114	6228	439529	120	3663	10080	55500	27750	jurassic	pterosaur
321	rhinoprotodon	Cénozoïque	Glaces	2021-12-24	2498	4280	6524	9230	954	1635	2492	3525	6409	863655	720	1200	10080	57120	28560	cenozoic	snow
322	gillirhynchops	Aquatique	Récifs	2022-06-23	2439	4177	6367	9009	1143	1958	2985	4223	7038	948327	720	1317	10080	57680	28840	aquatic	reef
323	glythronax	Jurassique	Carnivore	2020-02-14	2939	5035	7675	10859	919	1573	2398	3393	6786	653184	360	1814	10080	60480	30240	jurassic	carnivore
324	secodontognathus	Jurassique	Ptérosaures	2022-12-08	2379	4075	6211	8788	1115	1910	2911	4119	6865	528596	180	2937	10080	61320	30660	jurassic	pterosaur
325	metriaphodon	Jurassique	Ptérosaures	2017-01-30	1517	2599	3962	5606	1422	2437	3714	5255	7007	539482	180	2997	10080	62160	31080	jurassic	pterosaur
326	tyrannolophosaur	Jurassique	Carnivore	2022-12-29	2817	4825	7355	10407	1076	1843	2809	3975	7227	788256	480	1642	10080	63000	31500	jurassic	carnivore
327	megarchelon	Aquatique	Surfaces	2019-08-20	3429	5874	8954	12669	1072	1836	2798	3959	7918	762048	360	2117	10080	70560	35280	aquatic	surface
328	dunkleosaurus	Aquatique	Surfaces	2018-11-20	2490	4266	6502	9200	1297	2222	3387	4792	7667	836237	480	1742	10080	68320	34160	aquatic	surface
329	dreadactylus	Jurassique	Ptérosaures	2025-11-15	4175	7152	10901	15424	703	1203	1834	2595	7415	1046708	780	1342	10080	77700	38850	jurassic	pterosaur
330	pachygalosaurus	Jurassique	Carnivore	2018-03-20	5426	9295	14169	20047	643	1102	1679	2376	8641	942480	480	1964	10080	77000	38500	jurassic	carnivore
331	kaprodacthylus	Jurassique	Ptérosaures	2025-04-18	4178	7156	10908	15434	1306	2236	3409	4823	9646	1052151	480	2192	10080	85680	42840	jurassic	pterosaur
332	scorpios_rex_gen_2	Jurassique	Carnivore	2024-09-30	2724	4666	7112	10063	1513	2592	3951	5590	8735	1176941	720	1635	10080	77840	38920	jurassic	carnivore
333	fukuimimus	Jurassique	Herbivore	2025-08-27	3037	5203	7931	11221	1424	2439	3718	5260	8767	843696	360	2344	10080	78120	39060	jurassic	herbivore
334	draco_lux	Jurassique	Herbivore	2025-05-20	2515	4308	6566	9291	1596	2733	4166	5895	8798	1072512	600	1788	10080	78400	39200	jurassic	herbivore
335	yudon	Jurassique	Carnivore	2017-10-23	3810	6527	9949	14077	1191	2040	3109	4399	8798	959616	480	1999	10080	78400	39200	jurassic	carnivore
336	compsovenator	Jurassique	Carnivore	2025-02-14	2436	4173	6360	8999	761	1304	1988	2812	5624	793901	780	1018	10080	58520	29260	jurassic	carnivore
337	dracoceratops	Jurassique	Herbivore	2021-08-13	3865	6620	10091	14278	1208	2069	3153	4462	8924	1202343	720	1670	10080	79520	39760	jurassic	herbivore
338	iguanosuchus	Jurassique	Herbivore	2022-02-01	3892	6667	10162	14378	1216	2083	3176	4493	8986	864864	360	2402	10080	80080	40040	jurassic	herbivore
339	scorpios_rex	Jurassique	Carnivore	2021-10-26	3285	5627	8578	12136	1389	2379	3627	5131	8924	629799	120	5248	10080	79520	39760	jurassic	carnivore
340	spinoceratops	Jurassique	Herbivore	2024-12-16	3343	5726	8728	12350	1413	2421	3690	5222	9081	699149	180	3884	10080	80920	40460	jurassic	herbivore
341	bagehesaurus	Jurassique	Amphibien	2022-05-27	2601	4455	6790	9608	1688	2891	4407	6236	9239	711245	180	3951	10080	82320	41160	jurassic	amphibian
342	chromaspinus	Jurassique	Carnivore	2021-08-30	4028	6900	10517	14881	1259	2156	3287	4650	9300	716084	180	3978	10080	82880	41440	jurassic	carnivore
343	armormata	Jurassique	Herbivore	2020-11-16	4164	7133	10873	15384	1301	2229	3398	4807	9615	678586	120	5655	10080	83160	41580	jurassic	herbivore
344	cryolobourgiania	Jurassique	Ptérosaures	2022-09-09	5254	9000	13719	19411	884	1514	2309	3266	9332	658628	120	5489	10080	83160	41580	jurassic	pterosaur
345	poukadei	Jurassique	Ptérosaures	2026-07-03	3137	5373	8190	11588	1533	2626	4003	5664	9285	1906330	1380	1381	10080	82740	41370	jurassic	pterosaur
346	dilophoboa	Cénozoïque	Cavernes	2021-04-26	4123	7063	10766	15233	1289	2207	3364	4760	9520	1282781	720	1782	10080	85400	42700	cenozoic	cavern
347	ophthacerapsis	Jurassique	Amphibien	2023-02-14	5062	8671	13218	18702	1055	1807	2754	3896	9740	937440	360	2604	10080	87920	43960	jurassic	amphibian
348	megalocevia	Jurassique	Amphibien	2025-05-09	9850	13024	16469	19152	2322	3099	3737	4589	10574	980180	480	2042	10080	\N	129670	jurassic	amphibian
349	quetzaljara	Jurassique	Ptérosaures	2025-11-11	14444	19175	23823	28319	2440	3240	4026	4785	13635	966874	780	1240	10080	\N	157110	jurassic	pterosaur
350	spinotops	Jurassique	Herbivore	2025-08-27	10264	13496	16769	19931	4366	5805	7212	8572	14800	1563610	1140	1372	10080	\N	237080	jurassic	herbivore
351	hydraboa	Cénozoïque	Cavernes	2025-06-30	15340	20276	25087	29813	4794	6336	7840	9317	18634	1461600	960	1523	10080	\N	249620	cenozoic	cavern
\.


--
-- Data for Name: hybrid_recipe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hybrid_recipe (hybrid_id, component_id) FROM stdin;
91	1
16	2
16	3
41	4
17	5
18	6
17	7
88	8
18	9
90	10
19	11
87	12
40	13
19	14
92	15
20	19
313	21
89	22
40	23
42	24
143	25
43	26
42	27
146	28
44	30
45	31
312	32
41	33
94	34
44	35
93	36
144	37
43	38
45	39
46	40
47	44
48	45
89	49
87	50
93	51
88	52
148	53
95	56
317	57
95	58
90	59
316	60
94	61
92	63
91	64
150	65
151	66
147	69
311	70
318	71
314	72
99	73
322	74
97	76
97	77
98	78
100	79
154	80
98	83
100	84
99	86
101	89
102	91
103	92
152	104
143	105
144	106
320	107
147	108
153	111
152	113
321	114
153	115
148	116
146	117
155	118
315	119
325	121
155	122
324	124
323	125
150	126
151	127
336	130
154	132
328	133
156	136
156	137
327	139
157	146
158	150
159	151
311	164
336	169
315	170
335	171
343	178
314	182
330	185
333	187
338	191
334	196
312	203
330	206
321	207
320	208
334	209
323	210
339	214
339	215
333	220
340	222
324	236
340	243
338	253
347	259
316	260
346	264
329	265
325	267
342	268
318	269
335	270
317	274
346	280
327	283
328	284
343	287
347	288
322	289
313	296
348	311
349	319
350	340
351	346
149	120
149	68
96	62
96	55
341	250
341	245
344	275
344	228
337	230
337	202
331	282
331	266
145	110
319	285
319	54
332	205
332	192
\.


--
-- Data for Name: investment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.investment (id, user_id, species_id, from_level, to_level, quantity, cost, currency, invested_on, created_at) FROM stdin;
\.


--
-- Data for Name: player_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_settings (user_id, weekly_dna, weekly_amber, default_target, weekly_super_dna) FROM stdin;
00000000-0000-0000-0000-000000000001	60000	40000	3	0
5b802b07-59ee-4005-bec8-75e256aa5210	80000	40000	3	400
\.


--
-- Data for Name: player_species; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_species (user_id, species_id, unlocked, count_lvl10, count_lvl20, count_lvl30, count_lvl40, target_lvl40, updated_at, favorite) FROM stdin;
00000000-0000-0000-0000-000000000001	1	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	2	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	3	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	4	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	5	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	6	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	7	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	8	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	9	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	10	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	11	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	12	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	13	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	14	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	15	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	16	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	17	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	18	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	19	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	20	t	0	4	4	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	21	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	22	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	23	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	24	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	25	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	26	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	27	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	28	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	29	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	30	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	31	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	32	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	33	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	34	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	35	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	36	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	37	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	38	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	39	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	40	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	41	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	42	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	43	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	44	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	45	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	47	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	48	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	49	f	1	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	50	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	51	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	52	f	0	1	0	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	53	f	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	54	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	55	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	56	f	1	0	1	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	57	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	58	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	59	f	1	1	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	60	f	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	61	f	0	0	1	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	62	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	63	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	64	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	65	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	66	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	67	f	0	0	1	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	68	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	69	f	1	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	70	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	71	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	72	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	73	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	74	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	75	f	1	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	76	f	1	1	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	77	t	0	1	1	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	78	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	79	f	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	80	t	0	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	81	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	82	f	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	83	t	1	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	84	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	85	f	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	86	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	87	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	88	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	89	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	90	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	91	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	92	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	93	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	94	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	95	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	97	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	98	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	99	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	100	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	101	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	102	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	103	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	104	t	1	0	1	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	105	f	1	1	0	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	106	t	0	0	1	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	107	t	0	0	0	2	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	108	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	109	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	110	f	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	111	t	1	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	112	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	113	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	114	t	1	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	115	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	116	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	117	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	118	f	1	1	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	119	t	0	0	0	3	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	120	t	0	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	121	t	0	1	1	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	122	f	0	1	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	123	t	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	124	f	0	0	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	125	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	127	t	1	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	128	t	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	129	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	130	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	131	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	132	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	133	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	134	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	135	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	136	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	137	t	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	138	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	139	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	140	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	141	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	142	f	1	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	143	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	144	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	146	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	147	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	148	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	150	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	151	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	152	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	153	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	154	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	155	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	156	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	157	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	158	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	159	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	160	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	161	t	0	1	0	1	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	162	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	163	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	164	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	165	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	166	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	167	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	168	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	169	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	170	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	171	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	172	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	173	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	174	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	175	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	176	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	177	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	178	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	179	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	180	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	181	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	182	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	183	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	184	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	185	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	186	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	187	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	188	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	189	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	190	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	191	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	192	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	193	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	194	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	195	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	196	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	197	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	198	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	199	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	200	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	201	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	202	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	203	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	204	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	205	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	206	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	207	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	208	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	209	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	210	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	211	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	212	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	213	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	214	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	215	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	216	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	217	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	218	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	219	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	220	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	221	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	222	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	223	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	224	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	225	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	226	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	227	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	228	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	229	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	230	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	231	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	232	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	233	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	234	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	235	f	2	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	236	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	237	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	238	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	239	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	240	f	3	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	9	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
00000000-0000-0000-0000-000000000001	241	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	242	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	243	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	244	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	245	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	246	f	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	247	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	248	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	249	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	250	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	251	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	252	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	253	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	254	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	255	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	256	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	257	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	258	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	259	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	260	f	2	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	261	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	262	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	263	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	264	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	265	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	266	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	267	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	268	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	269	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	270	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	271	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	272	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	273	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	274	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	275	t	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	276	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	277	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	278	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	279	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	280	t	0	0	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	281	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	282	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	283	t	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	284	f	0	1	1	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	285	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	286	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	287	t	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	288	t	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	289	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	290	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	291	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	292	f	1	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	293	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	294	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	295	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	296	f	0	1	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	297	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	298	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	299	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	300	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	301	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	302	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	303	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	304	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	305	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	306	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	307	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	308	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	309	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	310	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	311	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	312	f	1	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	313	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	314	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	315	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	316	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	317	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	318	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	105	f	1	1	0	2	3	2026-11-20 15:15:01.306571+01	f
00000000-0000-0000-0000-000000000001	320	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	321	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	322	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	323	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	324	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	325	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	326	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	327	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	328	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	329	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	330	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	333	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	334	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	335	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	336	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	338	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	339	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	340	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	342	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	343	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	345	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	346	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	347	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	348	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	349	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	350	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	351	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	126	t	0	0	0	3	3	2026-11-20 12:15:02.135272+01	f
00000000-0000-0000-0000-000000000001	46	t	5	4	1	0	3	2026-11-20 18:16:38.37632+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	104	t	0	0	0	3	3	2026-11-22 20:38:09.498878+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	10	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	123	t	1	0	1	0	3	2026-11-20 15:11:49.446805+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	122	f	0	1	0	1	3	2026-11-20 15:16:00.582483+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	78	t	0	1	1	1	3	2026-11-24 09:35:14.647506+01	t
5b802b07-59ee-4005-bec8-75e256aa5210	245	t	1	1	0	0	3	2026-11-20 15:23:59.850692+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	250	t	1	0	0	0	3	2026-11-20 15:24:09.898434+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	106	t	0	0	1	2	3	2026-11-22 20:39:30.891607+01	t
5b802b07-59ee-4005-bec8-75e256aa5210	244	f	1	0	0	0	3	2026-11-24 11:11:32.468631+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	246	f	0	0	1	0	3	2026-11-24 11:11:42.699824+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	248	f	1	1	0	0	3	2026-11-24 11:12:34.289609+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	249	f	1	1	0	0	3	2026-11-24 11:12:40.610747+01	f
00000000-0000-0000-0000-000000000001	149	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	96	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	341	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	242	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	243	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	247	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	264	t	0	1	0	0	3	2026-11-20 15:24:32.824142+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	337	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	1	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
00000000-0000-0000-0000-000000000001	344	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	280	t	0	0	1	0	3	2026-11-20 15:25:15.466532+01	f
00000000-0000-0000-0000-000000000001	337	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	266	t	1	1	0	0	3	2026-11-20 15:25:03.958805+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	275	t	0	1	1	0	3	2026-11-20 15:25:10.770229+01	f
00000000-0000-0000-0000-000000000001	331	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	145	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	319	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
00000000-0000-0000-0000-000000000001	332	f	0	0	0	0	3	2026-11-20 12:04:19.408892+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	331	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	287	t	0	1	0	0	3	2026-11-20 15:25:57.633492+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	145	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	319	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	332	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	282	t	1	0	0	0	3	2026-11-20 15:25:46.585429+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	283	t	1	1	0	0	3	2026-11-20 15:25:53.354687+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	288	t	1	0	0	0	3	2026-11-20 15:26:03.720682+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	277	t	1	1	0	0	3	2026-11-24 08:57:04.998485+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	257	f	1	0	0	0	3	2026-11-24 11:15:21.420837+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	256	f	1	1	0	0	3	2026-11-24 11:14:56.389302+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	255	f	1	1	0	0	3	2026-11-24 11:15:02.409707+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	265	f	1	0	0	0	3	2026-11-24 11:15:51.888234+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	263	f	0	0	1	0	3	2026-11-24 11:16:13.028372+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	269	f	1	0	0	0	3	2026-11-24 11:16:27.15581+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	267	f	1	0	0	0	3	2026-11-24 11:17:08.702334+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	268	f	1	1	0	0	3	2026-11-24 11:16:47.705862+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	270	f	1	1	0	0	3	2026-11-24 11:16:57.550107+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	276	f	0	1	0	0	3	2026-11-24 11:17:44.950718+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	271	f	0	0	0	0	3	2026-11-24 11:17:23.582384+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	272	f	1	1	0	0	3	2026-11-24 11:17:24.461703+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	274	f	1	1	0	0	3	2026-11-24 11:17:34.348879+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	291	f	1	0	0	0	3	2026-11-24 11:18:44.085477+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	284	f	0	1	1	0	3	2026-11-24 11:18:20.268414+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	289	f	1	1	0	0	3	2026-11-24 11:18:35.33985+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	293	f	0	1	0	0	3	2026-11-24 11:18:53.548855+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	294	f	1	0	0	0	3	2026-11-24 11:19:15.1377+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	292	f	1	1	0	0	3	2026-11-24 11:19:04.761707+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	295	f	1	0	0	0	3	2026-11-24 11:19:21.367805+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	298	f	1	0	0	0	3	2026-11-24 11:19:39.573475+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	296	f	1	1	0	0	3	2026-11-24 11:19:30.192627+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	297	f	1	0	0	0	3	2026-11-24 11:19:50.183769+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	299	f	1	0	0	0	3	2026-11-24 11:19:57.606689+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	258	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	273	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	278	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	279	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	281	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	285	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	286	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	290	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	300	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	301	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	302	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	303	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	304	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	305	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	306	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	307	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	308	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	309	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	310	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	311	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	312	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	313	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	314	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	315	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	316	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	317	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	318	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	320	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	321	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	322	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	323	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	324	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	325	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	326	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	327	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	328	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	329	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	330	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	333	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	334	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	335	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	336	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	338	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	339	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	340	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	342	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	343	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	345	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	346	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	347	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	348	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	349	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	350	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	351	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	96	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	341	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	344	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	5	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	7	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	259	t	1	0	0	0	3	2026-11-20 15:24:22.921649+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	260	f	0	1	0	0	3	2026-11-24 11:15:37.99134+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	261	f	1	1	0	0	3	2026-11-24 11:16:37.184385+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	262	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	21	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	47	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	131	t	1	0	0	0	3	2026-11-20 15:12:45.105136+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	132	t	0	1	1	0	3	2026-11-20 15:12:58.282193+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	24	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	130	f	1	1	0	0	3	2026-11-20 15:17:26.330318+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	165	t	0	1	1	0	3	2026-11-20 15:21:34.732814+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	170	t	1	1	0	0	3	2026-11-20 15:22:12.704537+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	185	t	0	1	0	0	3	2026-11-20 15:22:17.947911+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	192	t	0	1	0	0	3	2026-11-20 15:22:24.577494+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	161	t	0	1	0	1	3	2026-11-24 10:12:51.923809+01	t
5b802b07-59ee-4005-bec8-75e256aa5210	164	f	1	1	0	0	3	2026-11-24 10:58:08.474453+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	163	f	1	0	0	0	3	2026-11-24 10:58:46.587502+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	167	f	1	0	0	0	3	2026-11-24 10:58:59.063904+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	160	f	0	0	1	0	3	2026-11-24 10:59:21.061642+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	168	f	1	0	0	0	3	2026-11-24 10:59:27.703317+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	162	f	1	0	0	0	3	2026-11-24 10:59:43.154916+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	171	f	0	0	1	0	3	2026-11-24 10:59:51.572247+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	172	f	1	0	0	0	3	2026-11-24 11:00:10.33091+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	174	f	1	1	0	0	3	2026-11-24 11:00:54.343136+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	179	f	1	0	0	0	3	2026-11-24 11:01:06.229008+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	177	f	1	0	0	0	3	2026-11-24 11:01:19.171835+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	178	f	0	1	0	0	3	2026-11-24 11:01:42.666517+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	181	f	1	1	0	0	3	2026-11-24 11:02:33.717069+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	182	f	1	0	0	0	3	2026-11-24 11:02:53.764103+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	184	f	0	0	0	0	3	2026-11-24 11:03:36.590103+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	187	f	1	0	0	0	3	2026-11-24 11:03:36.682409+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	188	f	1	1	0	0	3	2026-11-24 11:03:45.905329+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	189	f	1	0	0	0	3	2026-11-24 11:03:53.777003+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	193	f	0	1	0	0	3	2026-11-24 11:04:38.00485+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	166	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	169	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	173	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	175	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	176	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	180	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	183	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	186	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	190	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	191	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	65	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	8	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	52	f	0	1	0	2	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	48	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	88	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	89	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	90	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	91	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	92	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	94	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	95	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	97	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	98	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	99	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	100	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	101	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	102	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	103	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	12	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	4	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	18	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	16	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	149	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	11	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	19	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	3	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	6	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	2	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	23	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	13	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	14	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	15	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	17	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	20	t	0	4	4	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	25	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	26	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	27	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	28	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	31	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	50	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	32	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	33	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	35	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	36	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	37	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	38	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	39	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	29	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	22	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	30	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	34	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	40	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	41	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	42	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	43	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	44	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	45	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	51	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	54	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	55	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	57	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	58	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	62	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	63	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	64	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	66	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	68	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	70	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	71	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	72	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	73	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	74	t	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	80	t	0	0	0	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	84	t	0	0	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	81	t	0	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	83	t	1	0	0	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	67	f	0	0	1	2	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	86	t	0	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	53	f	0	0	0	3	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	49	f	1	0	0	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	56	f	1	0	1	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	60	f	1	0	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	59	f	1	1	0	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	61	f	1	0	1	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	69	f	1	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	75	f	1	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	76	f	1	1	0	1	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	87	t	0	1	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	79	f	0	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	82	f	0	1	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	85	f	1	0	1	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	93	f	1	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	108	t	1	1	1	0	3	2026-11-20 15:09:20.507468+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	107	t	0	0	0	2	3	2026-11-20 15:09:10.316188+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	109	t	0	0	1	0	3	2026-11-20 15:09:27.751425+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	111	t	1	1	1	0	3	2026-11-20 15:09:37.531583+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	113	t	0	0	0	3	3	2026-11-20 15:10:38.885753+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	116	t	0	0	0	3	3	2026-11-20 15:11:14.114563+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	114	t	1	0	0	1	3	2026-11-20 15:10:52.582356+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	115	t	0	1	1	0	3	2026-11-20 15:10:59.699124+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	119	t	0	0	0	3	3	2026-11-20 15:11:22.931268+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	120	t	0	0	0	1	3	2026-11-20 15:11:29.271997+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	121	t	0	1	1	1	3	2026-11-20 15:11:37.240398+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	126	t	0	0	0	3	3	2026-11-20 15:12:01.379526+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	133	t	1	0	0	0	3	2026-11-20 15:13:18.590975+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	127	t	1	1	1	0	3	2026-11-20 15:12:08.143512+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	128	t	1	0	1	0	3	2026-11-20 15:12:31.109688+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	129	t	1	1	0	0	3	2026-11-20 15:12:38.804414+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	112	f	0	0	1	0	3	2026-11-20 15:15:26.594076+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	110	f	1	0	1	0	3	2026-11-20 15:15:15.52605+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	117	f	1	0	0	0	3	2026-11-20 15:15:34.840389+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	118	f	1	1	0	1	3	2026-11-20 15:15:48.907141+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	124	f	0	0	0	1	3	2026-11-20 15:16:11.962927+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	125	f	0	1	0	0	3	2026-11-20 15:16:24.285408+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	77	t	0	0	0	3	3	2026-11-22 17:25:32.548813+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	46	t	7	4	1	0	3	2026-11-20 18:23:12.553624+01	t
5b802b07-59ee-4005-bec8-75e256aa5210	143	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	144	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	146	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	147	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	148	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	150	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	151	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	152	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	153	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	154	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	155	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	156	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	157	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	158	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	159	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	198	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	202	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	203	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	206	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	209	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	212	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	213	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	218	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	219	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	220	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	221	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	223	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	224	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	229	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	231	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	238	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	239	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	241	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	252	f	0	0	0	0	3	2026-11-20 14:54:36.239106+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	134	t	0	1	1	0	3	2026-11-20 15:13:27.345306+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	197	f	1	1	0	0	3	2026-11-24 11:04:59.268182+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	136	t	1	1	0	0	3	2026-11-20 15:13:36.732666+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	251	f	0	0	0	0	3	2026-11-24 11:12:33.440718+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	137	t	1	0	1	0	3	2026-11-20 15:13:44.920001+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	199	f	0	0	0	0	3	2026-11-24 11:05:20.686069+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	138	t	1	1	0	0	3	2026-11-20 15:13:52.903641+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	139	t	0	0	1	0	3	2026-11-20 15:13:58.119224+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	204	f	0	0	1	0	3	2026-11-24 11:05:20.727619+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	140	t	1	1	0	0	3	2026-11-20 15:14:07.416538+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	135	f	0	1	0	0	3	2026-11-20 15:18:25.358746+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	141	f	1	0	0	0	3	2026-11-20 15:18:37.695164+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	200	f	0	1	0	0	3	2026-11-24 11:05:43.78805+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	142	f	1	0	1	0	3	2026-11-20 15:18:56.186444+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	207	f	1	0	0	0	3	2026-11-24 11:06:26.731339+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	205	f	1	0	0	0	3	2026-11-24 11:06:34.2734+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	208	t	1	1	0	0	3	2026-11-20 15:22:36.667651+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	210	t	0	0	1	0	3	2026-11-20 15:22:42.614744+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	201	f	1	0	0	0	3	2026-11-24 11:06:40.617813+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	211	f	1	0	0	0	3	2026-11-24 11:07:04.62875+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	230	t	1	1	0	0	3	2026-11-20 15:23:30.924603+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	217	f	0	1	0	0	3	2026-11-24 11:07:47.569488+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	228	t	1	1	0	0	3	2026-11-20 15:23:36.940269+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	234	t	0	1	0	0	3	2026-11-20 15:23:43.684161+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	214	f	1	0	0	0	3	2026-11-24 11:08:01.886758+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	236	t	0	1	1	0	3	2026-11-20 15:23:51.367484+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	196	t	2	0	0	0	3	2026-11-24 10:12:30.619519+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	215	f	1	0	0	0	3	2026-11-24 11:08:09.839933+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	194	f	1	1	0	0	3	2026-11-24 11:04:26.008842+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	195	f	0	0	1	0	3	2026-11-24 11:04:46.848689+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	216	f	0	0	1	0	3	2026-11-24 11:08:19.565356+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	253	f	1	1	0	0	3	2026-11-24 11:13:59.069578+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	222	f	1	0	0	0	3	2026-11-24 11:08:56.28002+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	227	f	1	0	0	0	3	2026-11-24 11:09:05.92591+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	226	f	1	0	0	0	3	2026-11-24 11:09:18.12483+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	225	f	1	0	0	0	3	2026-11-24 11:09:24.252072+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	232	f	0	1	0	0	3	2026-11-24 11:10:01.62726+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	233	f	1	0	0	0	3	2026-11-24 11:10:18.501591+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	235	f	0	0	1	0	3	2026-11-24 11:10:29.611179+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	254	f	0	0	0	1	3	2026-11-24 11:14:13.978413+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	237	f	1	1	0	0	3	2026-11-24 11:10:53.111133+01	f
5b802b07-59ee-4005-bec8-75e256aa5210	240	f	1	1	0	0	3	2026-11-24 11:11:10.608645+01	f
\.


--
-- Data for Name: progress_snapshot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.progress_snapshot (id, user_id, taken_on, completion_pct, lvl40_count, lvl40_target, dna_remaining, amber_remaining, super_dna_remaining) FROM stdin;
1	00000000-0000-0000-0000-000000000001	2026-11-20	24.75	225	1053	103028170	13200000	4620
3	5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-20	23.98	226	1053	104088620	13125000	3300
4	5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-21	24.02	226	1053	104077320	13125000	3300
5	5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-22	24.12	228	1053	104065920	13125000	3300
7	5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-24	25.26	230	1053	102928470	13125000	3300
6	5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-23	24.17	229	1053	104052420	13125000	3300
\.


--
-- Data for Name: rarity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rarity (code, label, sort_order) FROM stdin;
C	Commun	1
R	Rare	2
E	Extra rare	3
L	Légendaire	4
T	Tournoi	5
\.


--
-- Data for Name: species; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.species (id, name, rarity_code, dna_cost, amber_cost, default_unlocked, hybrid_kind) FROM stdin;
4	Tuojangosaure	C	130	5000	f	NONE
7	Coloborhyncus	C	140	5000	f	NONE
11	Pelecanimimus	C	170	5000	f	NONE
21	Allosaure	R	500	10000	f	NONE
22	Giganotosaure	R	520	10000	f	NONE
24	Nasutoceratops	R	550	10000	f	NONE
29	Corythosaure	R	630	10000	f	NONE
30	Pyroraptor	R	650	10000	f	NONE
34	Tyrannotitan	R	710	10000	f	NONE
49	Euoplocephalus	E	1000	25000	f	NONE
52	Parasaurolophus	E	1200	25000	f	NONE
53	Rajasaurus	E	1300	25000	f	NONE
56	Deodicurus	E	1400	25000	f	NONE
59	Metriorhynchus	E	1400	25000	f	NONE
60	Sarkastodon	E	1400	25000	f	NONE
61	Supersaurus	E	1400	25000	f	NONE
69	Entelodonte	E	1600	25000	f	NONE
75	Onchopristis	E	2000	25000	f	NONE
76	Leptocleidus	E	2150	25000	f	NONE
79	Elasmosaure	E	2400	25000	f	NONE
82	Trinacromerum	E	2500	25000	f	NONE
85	Baculite	E	3000	25000	f	NONE
105	Suchomimus	L	2630	50000	f	NONE
110	Sarcosuchus	L	3050	50000	f	NONE
112	Shunosaurus	L	3100	50000	f	NONE
113	Ostafrikasaurus	L	3190	50000	t	NONE
114	Diprotodon	L	3200	50000	t	NONE
116	Ichtyostega	L	3330	50000	t	NONE
117	Scolosaure	L	3430	50000	f	NONE
118	Prionosuchus	L	3470	50000	f	NONE
121	Dimorphodon	L	3600	50000	t	NONE
122	Dimetrodon	L	3610	50000	f	NONE
124	Scaphognathus	L	3700	50000	f	NONE
132	Hyneria	L	4050	50000	t	NONE
133	Dunkleosteus	L	4200	50000	t	NONE
134	Hauffiosaurus	L	4300	50000	t	NONE
135	Kronosaurus	L	4400	50000	f	NONE
8	Bonitasaura	C	150	5000	t	NONE
9	Argentinosaure	C	160	5000	t	NONE
10	Guanlong	C	170	5000	t	NONE
1	Triceratops	C	100	5000	t	NONE
12	Tropeognathus	C	180	5000	t	NONE
13	Diplocaulus	C	190	5000	t	NONE
14	Hatzegopterix	C	200	5000	t	NONE
15	Utahraptor	C	200	5000	t	NONE
2	Majungasaurus	C	110	5000	t	NONE
3	Alanka	C	120	5000	t	NONE
5	Limnocelis	C	130	5000	t	NONE
6	Labyrinthodonte	C	130	5000	t	NONE
58	Megistotherium	E	1400	25000	t	NONE
62	Archaeotherium	E	1500	25000	t	NONE
63	Spinausaurus	E	1500	25000	t	NONE
64	Stegosaure	E	1500	25000	t	NONE
65	Velocirapore	E	1500	25000	t	NONE
66	Velociraptore Gen 2	E	1500	25000	t	NONE
86	Psephoderma	E	3000	25000	t	NONE
84	Geosaure	E	2900	25000	t	NONE
83	Xiphactinus	E	2500	25000	t	NONE
81	Mauisaurus	E	2500	25000	t	NONE
80	Helicoprion	E	2500	25000	t	NONE
78	Prognathodon	E	2250	25000	t	NONE
77	Protostega	E	2200	25000	t	NONE
74	Dolichorhynchops	E	2000	25000	t	NONE
73	Dakosaure	E	2000	25000	t	NONE
50	Zhejiangopterus	E	1100	25000	t	NONE
51	Ankylosaure	E	1200	25000	t	NONE
54	Quetzalcoatlus	E	1350	25000	t	NONE
55	Amphicyon	E	1400	25000	t	NONE
71	Postosuchus	E	1650	25000	t	NONE
72	Synthetoceras	E	1650	25000	t	NONE
70	Kaprosuchus	E	1600	25000	t	NONE
68	Deinotherium	E	1600	25000	t	NONE
130	Compsognathus	L	4000	\N	f	NONE
57	Elasmotherium	E	1400	25000	t	NONE
136	Leedsichthys	L	4400	50000	t	NONE
137	Liopleurodon	L	4500	50000	t	NONE
131	Pliosaure	L	4000	50000	t	NONE
129	Ammonite	L	4000	50000	t	NONE
128	Lion Marsupial	L	3900	50000	t	NONE
127	T-Rex Gen 2	L	3750	50000	t	NONE
126	Tyrannosaure	L	3750	50000	t	NONE
123	Uintatherium	L	3650	50000	t	NONE
120	Andrewsarchus	L	3550	50000	t	NONE
119	Therizinosaure	L	3500	50000	t	NONE
115	Indricotherium	L	3250	50000	t	NONE
111	Megaloceros	L	3080	50000	t	NONE
109	Eremotherium	L	3050	50000	t	NONE
108	Phorusrhacos	L	3000	50000	t	NONE
107	Pteranodon	L	2910	50000	t	NONE
106	Unaysaurus	L	2770	50000	t	NONE
104	Microposaure	L	2500	50000	t	NONE
32	Dilophosaure	R	690	10000	t	NONE
31	Tapejara	R	670	10000	t	NONE
28	Koolasuchus	R	610	10000	t	NONE
27	Pachycephalosaure	R	590	10000	t	NONE
26	Gallimimus	R	580	10000	t	NONE
25	Dsungaripterus	R	560	10000	t	NONE
23	Irritator	R	530	10000	t	NONE
39	Monolophosaure	R	850	10000	t	NONE
38	Ophiacodon	R	780	10000	t	NONE
37	Rhamphorgynchus	R	750	10000	t	NONE
36	Diplodocus	R	750	10000	t	NONE
35	Carnotaurus	R	730	10000	t	NONE
33	Nundasuchus	R	700	10000	t	NONE
67	Aerotitan	E	1600	\N	f	NONE
125	Glyptodon	L	3750	\N	f	NONE
141	Styxosaurus	L	4800	50000	f	NONE
142	Rhizodus	L	4900	50000	f	NONE
160	Compsognathus Gen 2	T	6400	\N	f	NONE
162	Dodo	T	6470	\N	f	NONE
163	Pterodactylus	T	6380	\N	f	NONE
181	Solitaire De Rodrigues	T	6900	\N	f	NONE
138	Plesiosaure	L	4500	50000	t	NONE
139	Megalodon	L	4600	50000	t	NONE
140	Kaiwhekea	L	4800	50000	t	NONE
258	Baryonyx Leucistique	T	7450	\N	f	NONE
184	Einiosaure	T	6750	\N	f	NONE
180	Scélidosaure	T	6600	\N	f	NONE
183	Bumpy	T	6750	\N	f	NONE
251	Thérizinosaure Gén 2	T	7380	\N	t	NONE
244	Bajadasaurus	T	7350	\N	f	NONE
231	Toro	T	7200	\N	f	NONE
237	Ghost	T	7250	\N	f	NONE
189	Borealopelta	T	6850	\N	f	NONE
262	Cearadactylus	T	7500	\N	f	NONE
185	Pachyrhinosaure	T	6750	\N	t	NONE
260	Panthera Blytheae	T	7480	\N	f	NONE
201	Beta	T	7000	\N	f	NONE
268	Parasaurolophus Gén 2	T	7500	\N	f	NONE
199	Antarctopelta	T	7000	\N	f	NONE
175	Cervalces	T	6600	\N	f	NONE
161	Deinocheirus	T	5500	\N	t	NONE
234	Diplocaulus Gén 2	T	7250	\N	t	NONE
239	Echo	T	7280	\N	f	NONE
174	Kelenken	T	6580	\N	f	NONE
241	Monkeydactyl	T	7300	\N	f	NONE
179	Pederpes Lux	T	6600	\N	f	NONE
242	Seymouria	T	7300	\N	f	NONE
212	Tsintaosaurus	T	7050	\N	f	NONE
247	Rinchenia	T	7350	\N	f	NONE
263	Darwinopterus	T	7500	\N	f	NONE
256	One-Armed Baryonyx	T	7450	\N	f	NONE
190	Masiakasaurus	T	6850	\N	f	NONE
200	Arctodus	T	7000	\N	f	NONE
171	Yutyrannus	T	6500	\N	f	NONE
228	Cryolophosaurus	T	7200	\N	t	NONE
215	Deinonychus	T	7100	\N	f	NONE
225	Doe	T	7150	\N	f	NONE
240	Purussaurus	T	7290	\N	f	NONE
253	Gryposuchus	T	7400	\N	f	NONE
221	Koreanosaurus	T	7150	\N	f	NONE
210	Lythronax	T	7050	\N	t	NONE
275	Arambourgiania	T	7650	\N	t	NONE
250	Bageherpeton	T	7380	\N	t	NONE
265	Dreadnoughtus	T	7500	\N	f	NONE
272	Dakotaraptor	T	7510	\N	f	NONE
173	Yuxisaurus	T	6550	\N	f	NONE
220	Fukuisaurus	T	7150	\N	f	NONE
208	Zalmoxes	T	7000	\N	t	NONE
165	Kentrosaure	T	6000	\N	t	NONE
213	Charlie	T	7080	\N	f	NONE
264	Dilophosaure Gén 2	T	7500	\N	t	NONE
164	Gorgosaure	T	6000	\N	f	NONE
273	Nyctosaurus	T	7550	\N	f	NONE
246	Proterogyrinus	T	7350	\N	f	NONE
269	Segnosaure	T	7500	\N	f	NONE
229	Sonorasaurus	T	7200	\N	f	NONE
227	Carbonemys	T	7150	\N	f	NONE
203	Erlikosaure	T	7000	\N	f	NONE
257	Panthera	T	7450	\N	f	NONE
206	Mégalosaure	T	7000	\N	f	NONE
196	Styracosaurus Lux	T	6950	\N	t	NONE
224	Blonde Becky	T	7150	\N	f	NONE
211	Brunette	T	7050	\N	f	NONE
235	Mastodonte	T	7250	\N	f	NONE
192	Irritator Gén 2	T	6900	\N	t	NONE
266	Kaprosuchus Gén 2	T	7500	\N	t	NONE
267	Metriacanthosaure	T	7500	\N	f	NONE
187	Struthiomimus	T	6800	\N	f	NONE
238	Stégosaure Gén 2	T	7250	\N	f	NONE
271	Rexy	T	7500	\N	f	NONE
261	Amargasaurus	T	7500	\N	f	NONE
167	Aquilops	T	6400	\N	f	NONE
168	Australotitan	T	6400	\N	f	NONE
188	Big Eatie	T	6830	\N	f	NONE
204	Eryops	T	7000	\N	f	NONE
172	Eucladocéros	T	6550	\N	f	NONE
178	Nodosaure	T	6600	\N	f	NONE
169	Dracovenator	T	6450	\N	f	NONE
274	Mammouth	T	7600	\N	f	NONE
248	Bull	T	7380	\N	f	NONE
276	Urtinotherium	T	7650	\N	f	NONE
216	Delta	T	7100	\N	f	NONE
176	Diabloceratops	T	6600	\N	f	NONE
252	Geosternbergia	T	7400	\N	f	NONE
191	Iguanodon	T	6900	\N	f	NONE
217	Gastornis	T	7100	\N	f	NONE
166	Little Eatie	T	6350	\N	f	NONE
194	Sinosauropteryx	T	6900	\N	f	NONE
243	Spinosaurus Gén 2	T	7300	\N	f	NONE
254	Blue	T	7400	\N	f	NONE
209	Dracorex Gén 2	T	7050	\N	f	NONE
255	Carnotaurus Jouet	T	7450	\N	f	NONE
170	Cératosaure	T	6500	\N	t	NONE
223	Sphenacodon	T	7150	\N	f	NONE
270	Troödon	T	7500	\N	f	NONE
249	The Spino	T	7380	\N	f	NONE
198	Ailurarctos	T	7000	\N	f	NONE
259	Diploceraspis	T	7450	\N	t	NONE
193	Megatherium	T	6900	\N	f	NONE
205	Giganotosaurus Gén 2	T	7000	\N	f	NONE
245	Edaphosaurus	T	7330	\N	t	NONE
197	Red	T	6980	\N	f	NONE
186	Mylodon	T	6800	\N	f	NONE
222	Sinocératops	T	7150	\N	f	NONE
233	Acanthostega	T	7250	\N	f	NONE
177	Gigantophis	T	6600	\N	f	NONE
218	Homalocéphale	T	7100	\N	f	NONE
182	Smilodon	T	6700	\N	f	NONE
195	Stegouros	T	6950	\N	f	NONE
232	The Big One	T	7200	\N	f	NONE
40	Doplotator	R	4000	\N	t	HYBRID
41	Nundagosaure	R	4600	\N	t	HYBRID
42	Pachyceratops	R	6360	\N	t	HYBRID
43	Ophiacomimus	R	7560	\N	t	HYBRID
44	Carnoraptor	R	7730	\N	t	HYBRID
45	Tapejalosaurus	R	8520	\N	t	HYBRID
143	Suchoripterus	L	17900	\N	f	HYBRID
144	Unayrhynchus	L	19720	\N	f	HYBRID
145	Koolasaurus	L	20500	\N	f	HYBRID
146	Skoolasaure	L	22600	\N	f	HYBRID
147	Entelorhacos	L	25750	\N	f	HYBRID
148	Rajastega	L	25930	\N	f	HYBRID
149	Andrewterium	L	28840	\N	f	HYBRID
150	Indominus Rex	L	29400	\N	f	HYBRID
151	Indominus Rex Gen 2	L	29400	\N	f	HYBRID
152	Ostaposaure	L	31870	\N	f	HYBRID
153	Indricoceros	L	35420	\N	f	HYBRID
154	Hynecoprion	L	36680	\N	f	HYBRID
155	Priotrodon	L	39650	\N	f	HYBRID
156	Liosichtodon	L	49840	\N	f	HYBRID
311	Gorgosuchus	T	42560	\N	f	HYBRID
312	Erliphosaurus	T	43070	\N	f	HYBRID
313	Allonogmius	T	45000	\N	f	HYBRID
314	Smithetoceras	T	46760	\N	f	HYBRID
315	Cerazinosaure	T	48000	\N	f	HYBRID
316	Sah Panthera	T	49700	\N	f	HYBRID
317	Mammotherium	T	50400	\N	f	HYBRID
318	Segnosuchus	T	51240	\N	f	HYBRID
319	Ptéraquetzal	T	52360	\N	f	HYBRID
320	Zalmonodon	T	55500	\N	f	HYBRID
334	Draco Lux	T	78400	\N	f	HYBRID
94	Suprannotitan	E	11820	\N	f	HYBRID
95	Megistocurus	E	15680	\N	f	HYBRID
96	Archeaophicyon	E	16240	\N	f	HYBRID
97	Leptostega	E	24360	\N	f	HYBRID
98	Xinathodon	E	26600	\N	f	HYBRID
99	Dakoderma	E	28000	\N	f	HYBRID
100	Geolasmosaurus	E	29680	\N	f	HYBRID
288	Ophthalmosaure	T	8250	\N	t	NONE
282	Ornithocheirus	T	7800	\N	f	NONE
300	Pierce	T	9100	\N	f	NONE
291	Platecarpus	T	8500	\N	f	NONE
295	Plesiosuchus	T	8900	\N	f	NONE
19	Pelecanipteryx	C	2030	\N	t	HYBRID
18	Labyrinthosaure	C	1630	\N	t	HYBRID
17	Limnorhynque	C	1490	\N	t	HYBRID
16	Alangasaure	C	1290	\N	t	HYBRID
87	Tropeogopterus	E	7130	\N	t	HYBRID
88	Parasaura	E	7550	\N	f	HYBRID
89	Giganocephalus	E	8490	\N	f	HYBRID
90	Metrialong	E	8770	\N	f	HYBRID
91	Stegoceratops	E	8960	\N	f	HYBRID
92	Spinoraptor	E	9520	\N	f	HYBRID
93	Ankylodocus	E	10920	\N	f	HYBRID
285	Ptéranodon Gén 2	T	8000	\N	f	NONE
309	Pyroraptor Dominion	T	14100	\N	f	NONE
303	Rebel	T	9380	\N	f	NONE
299	Smoothie	T	9050	\N	f	NONE
306	Spinosaurus Rebirth	T	14000	\N	f	NONE
298	Suchodus	T	9000	\N	f	NONE
292	Temnodontosaurus	T	8500	\N	f	NONE
279	Thalassodromeus	T	7750	\N	f	NONE
307	The Cerato Jp3	T	14000	\N	f	NONE
304	Angel	T	9380	\N	f	NONE
283	Archelon	T	8000	\N	t	NONE
296	Bananogmius	T	9000	\N	f	NONE
290	Barracudasaurus	T	8400	\N	f	NONE
277	Brachiosaure	T	7730	\N	f	NONE
297	Edestus	T	9000	\N	f	NONE
278	Edmontosaurus	T	7750	\N	f	NONE
289	Gillicus	T	8300	\N	f	NONE
294	Goronyosaurus	T	8650	\N	f	NONE
305	Junior	T	9500	\N	f	NONE
301	Major	T	9200	\N	f	NONE
284	Mosasaure	T	8000	\N	f	NONE
287	Mosasaure Gén 2	T	8250	\N	t	NONE
310	Mosasaurus Rebirth	T	14250	\N	f	NONE
308	One-Eyed Allosaurus	T	14080	\N	f	NONE
302	Tiger	T	9250	\N	f	NONE
280	Titanoboa	T	7750	\N	t	NONE
281	Tupandactylus	T	7750	\N	f	NONE
286	Tupuxuara	T	8000	\N	f	NONE
293	Umoonasaurus	T	8500	\N	f	NONE
321	Rhinoprotodon	T	57120	\N	f	HYBRID
322	Gillirhynchops	T	57680	\N	f	HYBRID
323	Glythronax	T	60400	\N	f	HYBRID
324	Secodontognathus	T	61320	\N	f	HYBRID
325	Metriaphodon	T	62160	\N	f	HYBRID
326	Tyrannolophosaure	T	63000	\N	f	HYBRID
327	Megarchelon	T	66960	\N	f	HYBRID
328	Dunkleosaure	T	68320	\N	f	HYBRID
329	Dreadactylus	T	75600	\N	f	HYBRID
330	Pachygalosaure	T	77000	\N	f	HYBRID
331	Kaprodacthylus	T	77120	\N	f	HYBRID
332	Scorpios Rex Gén 2	T	77840	\N	f	HYBRID
333	Fukuimimus	T	78120	\N	f	HYBRID
335	Yudon	T	78400	\N	f	HYBRID
336	Compsovenator	T	78420	\N	f	HYBRID
337	Dracocératops	T	79520	\N	f	HYBRID
338	Iguanosuchus	T	80080	\N	f	HYBRID
339	Scorpios Rex	T	79520	\N	f	HYBRID
340	Spinoceratops	T	80920	\N	f	HYBRID
341	Bagehesaurus	T	82320	\N	f	HYBRID
342	Chromaspinus	T	82740	\N	f	HYBRID
343	Armormata	T	83160	\N	f	HYBRID
344	Cryolobourgiania	T	83160	\N	f	HYBRID
345	Poukadei	T	82740	\N	f	HYBRID
346	Dilophoboa	T	85400	\N	f	HYBRID
347	Ophthacerapsis	T	87920	\N	f	HYBRID
46	Diplosuchus	R	660	\N	t	SUPER_HYBRID
47	Dimetrocarnus	R	\N	\N	f	SUPER_HYBRID
48	Tapejalocephalus	R	\N	\N	f	SUPER_HYBRID
157	Skoonasaure	L	\N	\N	f	SUPER_HYBRID
158	Indoraptor	L	\N	\N	f	SUPER_HYBRID
159	Indoraptor Gen 2	L	\N	\N	f	SUPER_HYBRID
348	Megalocevia	T	\N	\N	f	SUPER_HYBRID
349	Quetzaljara	T	\N	\N	f	SUPER_HYBRID
350	Spinotops	T	\N	\N	f	SUPER_HYBRID
351	Hydraboa	T	\N	\N	f	SUPER_HYBRID
103	Spinotasuchus	E	\N	\N	f	SUPER_HYBRID
102	Monostegotops	E	\N	\N	f	SUPER_HYBRID
101	Gigakylocephalus	E	\N	\N	f	SUPER_HYBRID
20	Pelecachtylus	C	500	\N	t	SUPER_HYBRID
214	Albertosaurus	T	7100	\N	f	NONE
226	Buck	T	7150	\N	f	NONE
219	Deinosuchus	T	7100	\N	f	NONE
202	Dracorex	T	7000	\N	f	NONE
207	Rhinocéros Laineux	T	7000	\N	f	NONE
236	Sécodontosaure	T	7250	\N	t	NONE
230	Tricératops Gén 2	T	7200	\N	f	NONE
\.


--
-- Data for Name: tournament_leftover; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_leftover (user_id, tournament, species_id, level, class_code, health, attack, quantity) FROM stdin;
5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	34	40	CARNIVORE	408	156	1
5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	52	20	HERBIVORE	408	128	1
5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	280	30	CAVERN	1993	688	1
5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	56	10	CAVERN	213	66	1
00000000-0000-0000-0000-000000000001	JURASSIC	197	10	CARNIVORE	723	226	1
00000000-0000-0000-0000-000000000001	JURASSIC	188	10	CARNIVORE	708	221	1
00000000-0000-0000-0000-000000000001	JURASSIC	24	40	HERBIVORE	489	125	1
00000000-0000-0000-0000-000000000001	JURASSIC	4	40	HERBIVORE	235	73	1
00000000-0000-0000-0000-000000000001	AQUATIC	284	30	SURFACE	2166	677	1
00000000-0000-0000-0000-000000000001	AQUATIC	76	10	REEF	314	42	1
\.


--
-- Data for Name: tournament_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_plan (user_id, computed_at, collection_hash) FROM stdin;
5b802b07-59ee-4005-bec8-75e256aa5210	2026-11-24 10:52:40.933777+01	42f93d421845cbe619878885b138baade7ee6b3583d43c933a55670ec87c9194
00000000-0000-0000-0000-000000000001	2026-11-24 10:52:57.546414+01	4315a6efad3aed0d59eef5e5fb565cbebbe000cc4b81cee8f53617ba6f712bc0
\.


--
-- Data for Name: tournament_team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_team (id, user_id, tournament, league, rank, pair_class, single_class, total_ferocity) FROM stdin;
173	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	1	CARNIVORE	PTEROSAUR	726
174	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	2	CARNIVORE	PTEROSAUR	717
175	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	3	CARNIVORE	PTEROSAUR	716
176	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	4	CARNIVORE	PTEROSAUR	707
177	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	5	CARNIVORE	PTEROSAUR	707
178	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	6	CARNIVORE	PTEROSAUR	605
179	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	7	CARNIVORE	PTEROSAUR	536
180	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	8	HERBIVORE	AMPHIBIAN	496
181	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	9	AMPHIBIAN	HERBIVORE	494
182	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	10	PTEROSAUR	CARNIVORE	486
183	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	11	CARNIVORE	PTEROSAUR	482
184	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	12	HERBIVORE	AMPHIBIAN	482
185	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	13	CARNIVORE	PTEROSAUR	481
186	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	14	HERBIVORE	AMPHIBIAN	478
187	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	15	CARNIVORE	PTEROSAUR	463
188	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	16	HERBIVORE	AMPHIBIAN	463
189	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	17	HERBIVORE	AMPHIBIAN	457
190	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	18	HERBIVORE	AMPHIBIAN	449
191	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	19	HERBIVORE	AMPHIBIAN	449
192	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	NEWBORN	20	HERBIVORE	AMPHIBIAN	441
193	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	1	CARNIVORE	PTEROSAUR	1460
194	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	2	AMPHIBIAN	HERBIVORE	1412
195	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	3	CARNIVORE	PTEROSAUR	1378
196	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	4	HERBIVORE	AMPHIBIAN	1312
197	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	5	CARNIVORE	PTEROSAUR	1266
198	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	6	CARNIVORE	PTEROSAUR	1180
199	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	7	CARNIVORE	PTEROSAUR	995
200	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	8	CARNIVORE	PTEROSAUR	982
201	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	9	HERBIVORE	AMPHIBIAN	964
202	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	10	HERBIVORE	AMPHIBIAN	962
203	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	11	HERBIVORE	AMPHIBIAN	960
204	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	12	AMPHIBIAN	HERBIVORE	878
205	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	13	HERBIVORE	AMPHIBIAN	849
206	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	14	HERBIVORE	AMPHIBIAN	846
207	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	15	HERBIVORE	AMPHIBIAN	824
208	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	16	HERBIVORE	AMPHIBIAN	811
209	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	17	PTEROSAUR	CARNIVORE	809
210	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	18	PTEROSAUR	CARNIVORE	808
211	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	HUNTER	19	PTEROSAUR	CARNIVORE	807
212	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	1	AMPHIBIAN	HERBIVORE	2990
213	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	2	AMPHIBIAN	HERBIVORE	2962
296	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	1	CARNIVORE	PTEROSAUR	791
297	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	2	AMPHIBIAN	HERBIVORE	777
298	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	3	CARNIVORE	PTEROSAUR	747
299	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	4	CARNIVORE	PTEROSAUR	720
300	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	5	CARNIVORE	PTEROSAUR	718
301	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	6	HERBIVORE	AMPHIBIAN	718
302	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	7	CARNIVORE	PTEROSAUR	605
303	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	8	CARNIVORE	PTEROSAUR	536
304	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	9	HERBIVORE	AMPHIBIAN	496
305	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	10	AMPHIBIAN	HERBIVORE	494
306	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	11	CARNIVORE	PTEROSAUR	482
307	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	12	HERBIVORE	AMPHIBIAN	482
308	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	13	CARNIVORE	PTEROSAUR	478
309	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	14	HERBIVORE	AMPHIBIAN	478
310	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	15	CARNIVORE	PTEROSAUR	463
311	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	16	HERBIVORE	AMPHIBIAN	463
312	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	17	HERBIVORE	AMPHIBIAN	449
313	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	18	HERBIVORE	AMPHIBIAN	449
314	00000000-0000-0000-0000-000000000001	JURASSIC	NEWBORN	19	HERBIVORE	AMPHIBIAN	441
315	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	1	CARNIVORE	PTEROSAUR	1466
316	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	2	HERBIVORE	AMPHIBIAN	1462
317	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	3	CARNIVORE	PTEROSAUR	1461
318	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	4	AMPHIBIAN	HERBIVORE	1436
319	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	5	HERBIVORE	AMPHIBIAN	1431
320	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	6	HERBIVORE	AMPHIBIAN	1412
321	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	7	AMPHIBIAN	HERBIVORE	1410
322	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	8	HERBIVORE	AMPHIBIAN	1373
323	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	9	HERBIVORE	AMPHIBIAN	1372
324	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	10	CARNIVORE	PTEROSAUR	1234
325	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	11	CARNIVORE	PTEROSAUR	1220
326	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	12	AMPHIBIAN	HERBIVORE	1152
327	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	13	CARNIVORE	PTEROSAUR	1012
328	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	14	HERBIVORE	AMPHIBIAN	998
329	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	15	CARNIVORE	PTEROSAUR	995
330	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	16	CARNIVORE	PTEROSAUR	982
331	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	17	HERBIVORE	AMPHIBIAN	960
332	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	18	CARNIVORE	PTEROSAUR	952
333	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	19	CARNIVORE	PTEROSAUR	935
334	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	20	HERBIVORE	AMPHIBIAN	925
335	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	21	AMPHIBIAN	HERBIVORE	884
336	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	22	HERBIVORE	AMPHIBIAN	849
214	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	3	CARNIVORE	PTEROSAUR	2858
215	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	4	HERBIVORE	AMPHIBIAN	2797
216	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	5	HERBIVORE	AMPHIBIAN	2724
217	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	6	PTEROSAUR	CARNIVORE	2713
218	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	7	CARNIVORE	PTEROSAUR	2675
219	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	8	HERBIVORE	AMPHIBIAN	2524
220	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	9	CARNIVORE	PTEROSAUR	2462
221	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	10	CARNIVORE	PTEROSAUR	2448
222	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	11	HERBIVORE	AMPHIBIAN	2382
223	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	12	HERBIVORE	AMPHIBIAN	2378
224	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	13	HERBIVORE	AMPHIBIAN	2364
225	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	14	HERBIVORE	AMPHIBIAN	2357
226	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	15	CARNIVORE	PTEROSAUR	2336
227	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	16	HERBIVORE	AMPHIBIAN	2325
228	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	17	CARNIVORE	PTEROSAUR	2313
229	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	18	CARNIVORE	PTEROSAUR	2304
230	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	19	HERBIVORE	AMPHIBIAN	2234
231	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	20	CARNIVORE	PTEROSAUR	2138
232	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	21	CARNIVORE	PTEROSAUR	2052
233	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	22	CARNIVORE	PTEROSAUR	1959
234	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	23	CARNIVORE	PTEROSAUR	1882
235	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	24	CARNIVORE	PTEROSAUR	1758
236	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	25	CARNIVORE	PTEROSAUR	1758
237	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	26	AMPHIBIAN	HERBIVORE	1748
238	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	27	AMPHIBIAN	HERBIVORE	1748
239	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	28	AMPHIBIAN	HERBIVORE	1748
240	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	29	PTEROSAUR	CARNIVORE	1668
241	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	30	CARNIVORE	PTEROSAUR	1668
242	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	31	PTEROSAUR	CARNIVORE	1652
243	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	32	HERBIVORE	AMPHIBIAN	1651
244	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	33	CARNIVORE	PTEROSAUR	1651
245	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	PREDATOR	34	HERBIVORE	AMPHIBIAN	1552
246	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	1	CARNIVORE	PTEROSAUR	5350
247	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	2	AMPHIBIAN	HERBIVORE	4988
248	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	3	AMPHIBIAN	HERBIVORE	4988
249	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	4	HERBIVORE	AMPHIBIAN	4416
250	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	5	HERBIVORE	AMPHIBIAN	4177
251	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	6	AMPHIBIAN	HERBIVORE	3813
252	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	7	CARNIVORE	PTEROSAUR	3743
253	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	8	CARNIVORE	PTEROSAUR	3714
254	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	9	PTEROSAUR	CARNIVORE	3369
337	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	23	HERBIVORE	AMPHIBIAN	846
338	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	24	CARNIVORE	PTEROSAUR	836
339	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	25	HERBIVORE	AMPHIBIAN	824
340	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	26	CARNIVORE	PTEROSAUR	824
341	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	27	CARNIVORE	PTEROSAUR	824
342	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	28	CARNIVORE	PTEROSAUR	821
343	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	29	CARNIVORE	PTEROSAUR	820
344	00000000-0000-0000-0000-000000000001	JURASSIC	HUNTER	30	CARNIVORE	PTEROSAUR	819
345	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	1	CARNIVORE	PTEROSAUR	2986
346	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	2	AMPHIBIAN	HERBIVORE	2962
347	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	3	CARNIVORE	PTEROSAUR	2858
348	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	4	CARNIVORE	PTEROSAUR	2799
349	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	5	CARNIVORE	PTEROSAUR	2787
350	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	6	HERBIVORE	AMPHIBIAN	2748
351	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	7	CARNIVORE	PTEROSAUR	2568
352	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	8	CARNIVORE	PTEROSAUR	2534
353	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	9	CARNIVORE	PTEROSAUR	2529
354	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	10	CARNIVORE	PTEROSAUR	2503
355	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	11	HERBIVORE	AMPHIBIAN	2502
356	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	12	CARNIVORE	PTEROSAUR	2488
357	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	13	HERBIVORE	AMPHIBIAN	2485
358	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	14	CARNIVORE	PTEROSAUR	2447
359	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	15	HERBIVORE	AMPHIBIAN	2432
360	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	16	CARNIVORE	PTEROSAUR	2416
361	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	17	CARNIVORE	PTEROSAUR	2396
362	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	18	HERBIVORE	AMPHIBIAN	2382
363	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	19	CARNIVORE	PTEROSAUR	2382
364	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	20	HERBIVORE	AMPHIBIAN	2373
365	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	21	HERBIVORE	AMPHIBIAN	2364
366	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	22	CARNIVORE	PTEROSAUR	2310
367	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	23	HERBIVORE	AMPHIBIAN	2234
368	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	24	HERBIVORE	AMPHIBIAN	2234
369	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	25	CARNIVORE	PTEROSAUR	2180
370	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	26	CARNIVORE	PTEROSAUR	2157
371	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	27	CARNIVORE	PTEROSAUR	2101
372	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	28	CARNIVORE	PTEROSAUR	2084
373	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	29	CARNIVORE	PTEROSAUR	1959
374	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	30	HERBIVORE	AMPHIBIAN	1795
375	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	31	CARNIVORE	PTEROSAUR	1758
376	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	32	AMPHIBIAN	HERBIVORE	1748
377	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	33	AMPHIBIAN	HERBIVORE	1748
255	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	10	PTEROSAUR	CARNIVORE	3369
256	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	11	AMPHIBIAN	HERBIVORE	3307
257	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	12	PTEROSAUR	CARNIVORE	3298
258	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	13	AMPHIBIAN	HERBIVORE	3232
259	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	14	CARNIVORE	PTEROSAUR	3191
260	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	15	HERBIVORE	AMPHIBIAN	3189
261	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	16	PTEROSAUR	CARNIVORE	3168
262	5b802b07-59ee-4005-bec8-75e256aa5210	JURASSIC	DOMINANT	17	AMPHIBIAN	HERBIVORE	3090
263	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	NEWBORN	1	SURFACE	CAVE	763
264	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	NEWBORN	2	REEF	CAVE	759
265	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	NEWBORN	3	CAVE	SURFACE	463
266	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	1	REEF	SURFACE	1491
267	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	2	REEF	CAVE	1485
268	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	3	CAVE	REEF	1476
269	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	4	CAVE	REEF	1372
270	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	5	SURFACE	CAVE	1261
271	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	6	REEF	CAVE	1249
272	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	7	SURFACE	CAVE	1211
273	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	8	REEF	SURFACE	970
274	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	9	SURFACE	REEF	848
275	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	10	SURFACE	REEF	845
276	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	HUNTER	11	CAVE	REEF	808
277	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	PREDATOR	1	REEF	SURFACE	2429
278	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	PREDATOR	2	CAVE	REEF	2082
279	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	PREDATOR	3	SURFACE	CAVE	2065
280	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	PREDATOR	4	REEF	SURFACE	1634
281	5b802b07-59ee-4005-bec8-75e256aa5210	AQUATIC	PREDATOR	5	REEF	SURFACE	1588
282	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	NEWBORN	1	SNOW	SAVANNAH	797
283	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	NEWBORN	2	SAVANNAH	SNOW	738
284	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	NEWBORN	3	SNOW	SAVANNAH	602
285	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	1	CAVERN	SAVANNAH	1467
286	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	2	CAVERN	SAVANNAH	1442
287	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	3	SAVANNAH	CAVERN	1435
288	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	4	SAVANNAH	CAVERN	1322
289	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	5	SAVANNAH	CAVERN	1157
290	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	HUNTER	6	SNOW	CAVERN	1030
291	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	PREDATOR	1	SNOW	CAVERN	2276
292	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	PREDATOR	2	SNOW	SAVANNAH	1765
293	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	PREDATOR	3	SNOW	SAVANNAH	1650
294	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	PREDATOR	4	SNOW	SAVANNAH	1627
295	5b802b07-59ee-4005-bec8-75e256aa5210	CENOZOIC	PREDATOR	5	CAVERN	SAVANNAH	1514
378	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	34	CARNIVORE	PTEROSAUR	1735
379	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	35	HERBIVORE	AMPHIBIAN	1711
380	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	36	CARNIVORE	PTEROSAUR	1702
381	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	37	PTEROSAUR	CARNIVORE	1668
382	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	38	CARNIVORE	PTEROSAUR	1668
383	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	39	CARNIVORE	PTEROSAUR	1657
384	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	40	HERBIVORE	AMPHIBIAN	1651
385	00000000-0000-0000-0000-000000000001	JURASSIC	PREDATOR	41	CARNIVORE	PTEROSAUR	1651
386	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	1	CARNIVORE	PTEROSAUR	5350
387	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	2	AMPHIBIAN	HERBIVORE	4988
388	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	3	AMPHIBIAN	HERBIVORE	4988
389	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	4	CARNIVORE	PTEROSAUR	4613
390	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	5	HERBIVORE	AMPHIBIAN	4416
391	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	6	HERBIVORE	AMPHIBIAN	4177
392	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	7	AMPHIBIAN	HERBIVORE	3813
393	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	8	CARNIVORE	PTEROSAUR	3714
394	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	9	AMPHIBIAN	HERBIVORE	3672
395	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	10	CARNIVORE	PTEROSAUR	3447
396	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	11	CARNIVORE	PTEROSAUR	3354
397	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	12	AMPHIBIAN	HERBIVORE	3307
398	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	13	HERBIVORE	AMPHIBIAN	3278
399	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	14	PTEROSAUR	CARNIVORE	3168
400	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	15	CARNIVORE	PTEROSAUR	3113
401	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	16	AMPHIBIAN	HERBIVORE	3090
402	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	17	HERBIVORE	AMPHIBIAN	3056
403	00000000-0000-0000-0000-000000000001	JURASSIC	DOMINANT	18	AMPHIBIAN	HERBIVORE	3045
404	00000000-0000-0000-0000-000000000001	AQUATIC	NEWBORN	1	SURFACE	REEF	775
405	00000000-0000-0000-0000-000000000001	AQUATIC	NEWBORN	2	CAVE	REEF	755
406	00000000-0000-0000-0000-000000000001	AQUATIC	NEWBORN	3	CAVE	SURFACE	463
407	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	1	REEF	SURFACE	1491
408	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	2	CAVE	REEF	1476
409	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	3	CAVE	REEF	1372
410	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	4	CAVE	SURFACE	1290
411	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	5	REEF	CAVE	1249
412	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	6	REEF	SURFACE	1173
413	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	7	SURFACE	REEF	1131
414	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	8	SURFACE	REEF	879
415	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	9	SURFACE	REEF	859
416	00000000-0000-0000-0000-000000000001	AQUATIC	HUNTER	10	CAVE	REEF	808
417	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	1	CAVE	REEF	2881
418	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	2	REEF	SURFACE	2804
419	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	3	SURFACE	REEF	2429
420	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	4	CAVE	REEF	2082
421	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	5	CAVE	SURFACE	1759
422	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	6	CAVE	SURFACE	1747
423	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	7	REEF	SURFACE	1639
424	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	8	REEF	SURFACE	1592
425	00000000-0000-0000-0000-000000000001	AQUATIC	PREDATOR	9	REEF	CAVE	1558
426	00000000-0000-0000-0000-000000000001	CENOZOIC	NEWBORN	1	SAVANNAH	SNOW	738
427	00000000-0000-0000-0000-000000000001	CENOZOIC	NEWBORN	2	SNOW	SAVANNAH	553
428	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	1	SAVANNAH	SNOW	1498
429	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	2	CAVERN	SNOW	1449
430	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	3	CAVERN	SNOW	1449
431	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	4	SAVANNAH	CAVERN	1435
432	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	5	SNOW	CAVERN	1401
433	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	6	SAVANNAH	CAVERN	1343
434	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	7	CAVERN	SAVANNAH	1301
435	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	8	SNOW	CAVERN	1295
436	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	9	SAVANNAH	SNOW	1214
437	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	10	SNOW	CAVERN	1070
438	00000000-0000-0000-0000-000000000001	CENOZOIC	HUNTER	11	SNOW	CAVERN	1030
439	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	1	SNOW	SAVANNAH	2331
440	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	2	SNOW	SAVANNAH	2234
441	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	3	SNOW	SAVANNAH	1765
442	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	4	SNOW	SAVANNAH	1650
443	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	5	SNOW	SAVANNAH	1627
444	00000000-0000-0000-0000-000000000001	CENOZOIC	PREDATOR	6	CAVERN	SAVANNAH	1514
445	00000000-0000-0000-0000-000000000001	CENOZOIC	DOMINANT	1	CAVERN	SAVANNAH	3011
\.


--
-- Data for Name: tournament_team_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_team_member (team_id, slot, species_id, level, health, attack, ferocity, profile) FROM stdin;
173	1	32	40	396	151	275	BALANCED
173	2	32	40	396	151	275	BALANCED
173	3	14	40	253	97	176	BALANCED
174	1	21	40	440	138	276	BALANCED
174	2	21	40	440	138	276	BALANCED
174	3	7	40	238	91	165	BALANCED
175	1	32	40	396	151	275	BALANCED
175	2	21	40	440	138	276	BALANCED
175	3	7	40	238	91	165	BALANCED
176	1	23	40	400	153	278	BALANCED
176	2	23	40	400	153	278	BALANCED
176	3	3	40	217	83	151	BALANCED
177	1	23	40	400	153	278	BALANCED
177	2	130	20	400	153	278	BALANCED
177	3	3	40	217	83	151	BALANCED
178	1	15	40	259	99	180	BALANCED
178	2	105	10	437	112	249	TANK
178	3	14	40	253	97	176	BALANCED
179	1	15	40	259	99	180	BALANCED
179	2	15	40	259	99	180	BALANCED
179	3	14	40	253	97	176	BALANCED
180	1	11	40	266	83	166	BALANCED
180	2	11	40	266	83	166	BALANCED
180	3	6	40	236	90	164	BALANCED
181	1	6	40	236	90	164	BALANCED
181	2	6	40	236	90	164	BALANCED
181	3	11	40	266	83	166	BALANCED
182	1	12	40	260	81	162	BALANCED
182	2	12	40	260	81	162	BALANCED
182	3	130	10	233	89	162	BALANCED
183	1	10	40	255	80	160	BALANCED
183	2	10	40	255	80	160	BALANCED
183	3	12	40	260	81	162	BALANCED
184	1	9	40	281	72	160	TANK
184	2	9	40	281	72	160	TANK
184	3	13	40	284	73	162	TANK
185	1	2	40	224	86	156	BALANCED
185	2	10	40	255	80	160	BALANCED
185	3	7	40	238	91	165	BALANCED
186	1	1	40	274	70	156	TANK
186	2	9	40	281	72	160	TANK
186	3	13	40	284	73	162	TANK
187	1	2	40	224	86	156	BALANCED
187	2	2	40	224	86	156	BALANCED
187	3	3	40	217	83	151	BALANCED
188	1	1	40	274	70	156	TANK
188	2	1	40	274	70	156	TANK
188	3	5	40	266	68	151	TANK
189	1	4	40	235	73	146	BALANCED
189	2	61	10	262	67	149	TANK
189	3	13	40	284	73	162	TANK
190	1	8	40	263	67	149	TANK
190	2	8	40	263	67	149	TANK
190	3	5	40	266	68	151	TANK
191	1	8	40	263	67	149	TANK
191	2	49	10	262	67	149	TANK
191	3	5	40	266	68	151	TANK
192	1	4	40	235	73	146	BALANCED
192	2	4	40	235	73	146	BALANCED
192	3	59	10	215	82	149	BALANCED
193	1	228	10	746	233	466	BALANCED
193	2	122	20	705	269	489	BALANCED
193	3	121	20	727	278	505	BALANCED
194	1	118	20	749	234	468	BALANCED
194	2	250	10	765	239	478	BALANCED
194	3	230	10	858	198	466	TANK
195	1	38	40	379	277	395	STRIKER
195	2	245	10	1101	131	475	TANK
195	3	282	10	977	203	508	TANK
196	1	61	30	685	175	389	TANK
196	2	208	10	363	340	453	STRIKER
196	3	259	10	1015	153	470	TANK
197	1	39	40	689	215	430	BALANCED
197	2	39	40	689	215	430	BALANCED
197	3	67	30	487	254	406	STRIKER
198	1	38	40	379	277	395	STRIKER
198	2	105	20	748	191	425	TANK
198	3	37	40	575	180	360	BALANCED
199	1	30	40	448	171	311	BALANCED
199	2	127	10	518	162	324	BALANCED
199	3	37	40	575	180	360	BALANCED
200	1	30	40	448	171	311	BALANCED
200	2	30	40	448	171	311	BALANCED
200	3	37	40	575	180	360	BALANCED
201	1	29	40	531	136	302	TANK
201	2	29	40	531	136	302	TANK
201	3	33	40	632	162	360	TANK
202	1	36	40	527	135	300	TANK
202	2	29	40	531	136	302	TANK
202	3	33	40	632	162	360	TANK
203	1	36	40	527	135	300	TANK
203	2	36	40	527	135	300	TANK
203	3	33	40	632	162	360	TANK
204	1	28	40	467	146	292	BALANCED
204	2	28	40	467	146	292	BALANCED
204	3	117	10	399	169	294	BALANCED
205	1	26	40	396	151	275	BALANCED
205	2	27	40	452	141	282	BALANCED
205	3	28	40	467	146	292	BALANCED
206	1	27	40	452	141	282	BALANCED
206	2	27	40	452	141	282	BALANCED
206	3	110	10	406	155	282	BALANCED
207	1	26	40	396	151	275	BALANCED
207	2	26	40	396	151	275	BALANCED
207	3	118	10	438	137	274	BALANCED
208	1	24	40	489	125	278	TANK
208	2	24	40	489	125	278	TANK
208	3	59	20	368	140	255	BALANCED
209	1	25	40	386	148	269	BALANCED
209	2	25	40	386	148	269	BALANCED
209	3	22	40	476	122	271	TANK
210	1	31	40	428	134	268	BALANCED
210	2	25	40	386	148	269	BALANCED
210	3	22	40	476	122	271	TANK
211	1	31	40	428	134	268	BALANCED
211	2	31	40	428	134	268	BALANCED
211	3	22	40	476	122	271	TANK
212	1	104	40	1570	491	982	BALANCED
212	2	118	40	1616	505	1010	BALANCED
212	3	106	40	1757	449	998	TANK
213	1	104	40	1570	491	982	BALANCED
213	2	104	40	1570	491	982	BALANCED
213	3	106	40	1757	449	998	TANK
214	1	113	40	1410	539	980	BALANCED
214	2	113	40	1410	539	980	BALANCED
214	3	19	40	1294	494	898	BALANCED
215	1	24	40	489	125	278	TANK
215	2	196	10	483	300	451	STRIKER
296	1	35	40	419	160	291	BALANCED
296	2	194	10	429	201	335	STRIKER
296	3	7	40	238	91	165	BALANCED
297	1	59	20	368	140	255	BALANCED
297	2	104	10	425	133	266	BALANCED
297	3	52	20	408	128	256	BALANCED
298	1	35	40	419	160	291	BALANCED
298	2	35	40	419	160	291	BALANCED
298	3	7	40	238	91	165	BALANCED
299	1	22	40	476	122	271	TANK
299	2	34	40	408	156	284	BALANCED
299	3	7	40	238	91	165	BALANCED
300	1	22	40	476	122	271	TANK
300	2	22	40	476	122	271	TANK
300	3	14	40	253	97	176	BALANCED
301	1	24	40	489	125	278	TANK
301	2	24	40	489	125	278	TANK
301	3	13	40	284	73	162	TANK
302	1	15	40	259	99	180	BALANCED
302	2	105	10	437	112	249	TANK
302	3	14	40	253	97	176	BALANCED
303	1	15	40	259	99	180	BALANCED
303	2	15	40	259	99	180	BALANCED
303	3	14	40	253	97	176	BALANCED
304	1	11	40	266	83	166	BALANCED
304	2	11	40	266	83	166	BALANCED
304	3	6	40	236	90	164	BALANCED
305	1	6	40	236	90	164	BALANCED
305	2	6	40	236	90	164	BALANCED
305	3	11	40	266	83	166	BALANCED
306	1	10	40	255	80	160	BALANCED
306	2	10	40	255	80	160	BALANCED
306	3	12	40	260	81	162	BALANCED
307	1	9	40	281	72	160	TANK
307	2	9	40	281	72	160	TANK
307	3	13	40	284	73	162	TANK
308	1	2	40	224	86	156	BALANCED
308	2	10	40	255	80	160	BALANCED
308	3	12	40	260	81	162	BALANCED
309	1	1	40	274	70	156	TANK
309	2	9	40	281	72	160	TANK
309	3	13	40	284	73	162	TANK
310	1	2	40	224	86	156	BALANCED
310	2	2	40	224	86	156	BALANCED
310	3	3	40	217	83	151	BALANCED
311	1	1	40	274	70	156	TANK
311	2	1	40	274	70	156	TANK
311	3	5	40	266	68	151	TANK
312	1	8	40	263	67	149	TANK
312	2	8	40	263	67	149	TANK
312	3	5	40	266	68	151	TANK
313	1	8	40	263	67	149	TANK
313	2	49	10	262	67	149	TANK
313	3	5	40	266	68	151	TANK
314	1	4	40	235	73	146	BALANCED
314	2	4	40	235	73	146	BALANCED
314	3	59	10	215	82	149	BALANCED
315	1	248	10	688	263	478	BALANCED
315	2	257	10	726	256	483	BALANCED
315	3	121	20	727	278	505	BALANCED
316	1	261	10	816	231	486	BALANCED
316	2	268	10	778	243	486	BALANCED
316	3	266	10	783	245	490	BALANCED
317	1	272	10	778	243	486	BALANCED
317	2	122	20	705	269	489	BALANCED
317	3	263	10	622	292	486	STRIKER
318	1	259	10	1015	153	470	TANK
318	2	253	10	575	300	480	STRIKER
318	3	269	10	544	316	486	STRIKER
319	1	244	10	457	333	476	STRIKER
319	2	251	10	1070	143	477	TANK
319	3	250	10	765	239	478	BALANCED
320	1	187	10	705	220	440	BALANCED
320	2	277	10	801	250	500	BALANCED
320	3	240	10	755	236	472	BALANCED
321	1	240	10	755	236	472	BALANCED
321	2	240	10	755	236	472	BALANCED
321	3	230	10	858	198	466	TANK
322	1	208	10	363	340	453	STRIKER
322	2	265	10	819	201	457	TANK
322	3	219	10	964	162	463	TANK
323	1	196	10	483	300	451	STRIKER
323	2	199	10	798	204	453	TANK
323	3	118	20	749	234	468	BALANCED
324	1	256	10	386	282	403	STRIKER
324	2	105	20	748	191	425	TANK
324	3	67	30	487	254	406	STRIKER
325	1	39	40	689	215	430	BALANCED
325	2	39	40	689	215	430	BALANCED
325	3	37	40	575	180	360	BALANCED
326	1	33	40	632	162	360	TANK
326	2	233	10	438	266	403	STRIKER
326	3	61	30	685	175	389	TANK
327	1	39	40	689	215	430	BALANCED
327	2	170	10	896	151	431	TANK
327	3	3	40	217	83	151	BALANCED
328	1	29	40	531	136	302	TANK
328	2	181	10	537	168	336	BALANCED
328	3	33	40	632	162	360	TANK
329	1	30	40	448	171	311	BALANCED
329	2	127	10	518	162	324	BALANCED
329	3	37	40	575	180	360	BALANCED
330	1	30	40	448	171	311	BALANCED
330	2	30	40	448	171	311	BALANCED
330	3	37	40	575	180	360	BALANCED
331	1	36	40	527	135	300	TANK
331	2	36	40	527	135	300	TANK
331	3	33	40	632	162	360	TANK
332	1	38	40	379	277	395	STRIKER
332	2	38	40	379	277	395	STRIKER
332	3	12	40	260	81	162	BALANCED
333	1	164	10	498	233	389	STRIKER
333	2	38	40	379	277	395	STRIKER
333	3	3	40	217	83	151	BALANCED
334	1	29	40	531	136	302	TANK
334	2	29	40	531	136	302	TANK
334	3	179	10	770	80	321	TANK
335	1	28	40	467	146	292	BALANCED
335	2	28	40	467	146	292	BALANCED
335	3	36	40	527	135	300	TANK
336	1	26	40	396	151	275	BALANCED
336	2	27	40	452	141	282	BALANCED
336	3	28	40	467	146	292	BALANCED
337	1	27	40	452	141	282	BALANCED
337	2	27	40	452	141	282	BALANCED
337	3	110	10	406	155	282	BALANCED
338	1	34	40	408	156	284	BALANCED
338	2	34	40	408	156	284	BALANCED
338	3	31	40	428	134	268	BALANCED
339	1	26	40	396	151	275	BALANCED
339	2	26	40	396	151	275	BALANCED
339	3	118	10	438	137	274	BALANCED
340	1	23	40	400	153	278	BALANCED
340	2	23	40	400	153	278	BALANCED
340	3	31	40	428	134	268	BALANCED
341	1	23	40	400	153	278	BALANCED
341	2	130	20	400	153	278	BALANCED
341	3	31	40	428	134	268	BALANCED
342	1	21	40	440	138	276	BALANCED
342	2	21	40	440	138	276	BALANCED
342	3	25	40	386	148	269	BALANCED
343	1	32	40	396	151	275	BALANCED
343	2	21	40	440	138	276	BALANCED
343	3	25	40	386	148	269	BALANCED
344	1	32	40	396	151	275	BALANCED
344	2	32	40	396	151	275	BALANCED
344	3	25	40	386	148	269	BALANCED
345	1	105	40	1614	413	917	TANK
345	2	113	40	1410	539	980	BALANCED
345	3	121	40	1569	599	1089	BALANCED
346	1	104	40	1570	491	982	BALANCED
346	2	104	40	1570	491	982	BALANCED
346	3	106	40	1757	449	998	TANK
347	1	113	40	1410	539	980	BALANCED
347	2	113	40	1410	539	980	BALANCED
347	3	19	40	1294	494	898	BALANCED
348	1	211	10	731	228	456	BALANCED
348	2	226	10	875	190	463	TANK
348	3	45	40	3007	940	1880	BALANCED
349	1	205	10	980	147	453	TANK
349	2	201	10	508	295	454	STRIKER
349	3	45	40	3007	940	1880	BALANCED
350	1	106	30	1242	318	706	TANK
350	2	277	20	1372	429	858	BALANCED
350	3	204	30	2653	355	1184	TANK
351	1	16	40	804	377	628	STRIKER
351	2	160	30	1689	284	812	TANK
351	3	20	20	1806	564	1128	BALANCED
352	1	245	20	1886	224	813	TANK
352	2	255	20	777	580	823	STRIKER
352	3	19	40	1294	494	898	BALANCED
353	1	272	20	1333	417	834	BALANCED
353	2	127	30	1354	423	846	BALANCED
353	3	275	20	951	552	849	STRIKER
354	1	228	20	1279	400	800	BALANCED
354	2	232	20	1288	402	805	BALANCED
354	3	19	40	1294	494	898	BALANCED
355	1	261	20	1399	395	832	BALANCED
355	2	268	20	1332	416	832	BALANCED
355	3	266	20	1341	419	838	BALANCED
356	1	264	20	1577	329	822	TANK
356	2	270	20	1066	500	833	STRIKER
356	3	263	20	1066	500	833	STRIKER
357	1	51	40	1011	259	575	TANK
357	2	165	20	1066	333	666	BALANCED
357	3	246	30	1970	628	1244	BALANCED
358	1	248	20	1179	450	818	BALANCED
358	2	249	20	1113	471	819	BALANCED
358	3	163	10	907	527	810	STRIKER
359	1	49	40	969	248	551	TANK
359	2	64	40	982	251	558	TANK
359	3	41	40	2328	595	1323	TANK
360	1	249	10	650	275	478	BALANCED
360	2	271	10	544	316	486	STRIKER
360	3	20	30	2324	726	1452	BALANCED
361	1	237	10	977	164	469	TANK
361	2	245	10	1101	131	475	TANK
361	3	20	30	2324	726	1452	BALANCED
362	1	208	20	622	583	777	STRIKER
362	2	230	20	1471	340	800	TANK
362	3	234	20	966	503	805	STRIKER
363	1	225	10	741	232	464	BALANCED
363	2	228	10	746	233	466	BALANCED
363	3	20	30	2324	726	1452	BALANCED
364	1	18	40	1170	404	770	BALANCED
364	2	178	20	1252	391	782	BALANCED
364	3	253	20	986	513	821	STRIKER
365	1	64	40	982	251	558	TANK
365	2	64	40	982	251	558	TANK
365	3	46	10	1702	716	1248	BALANCED
366	1	192	20	1103	421	766	BALANCED
366	2	197	20	1239	387	774	BALANCED
366	3	121	30	1109	423	770	BALANCED
367	1	112	30	1198	374	748	BALANCED
367	2	185	20	1199	375	750	BALANCED
367	3	110	30	1060	405	736	BALANCED
368	1	18	40	1170	404	770	BALANCED
368	2	18	40	1170	404	770	BALANCED
368	3	104	30	1110	347	694	BALANCED
369	1	256	20	662	482	689	STRIKER
369	2	236	20	1674	282	805	TANK
369	3	17	40	1096	343	686	BALANCED
370	1	164	20	852	400	666	STRIKER
370	2	237	20	1674	282	805	TANK
370	3	17	40	1096	343	686	BALANCED
371	1	270	10	622	292	486	STRIKER
371	2	267	10	389	365	487	STRIKER
371	3	20	20	1806	564	1128	BALANCED
372	1	66	40	1023	320	640	BALANCED
372	2	188	20	1212	379	758	BALANCED
372	3	17	40	1096	343	686	BALANCED
373	1	66	40	1023	320	640	BALANCED
373	2	66	40	1023	320	640	BALANCED
373	3	87	20	978	373	679	BALANCED
374	1	299	10	1267	191	587	TANK
374	2	161	20	586	427	610	STRIKER
374	3	70	40	1245	209	598	TANK
375	1	63	40	978	250	556	TANK
375	2	16	40	804	377	628	STRIKER
375	3	67	40	689	359	574	STRIKER
376	1	71	40	552	402	575	STRIKER
376	2	70	40	1245	209	598	TANK
376	3	51	40	1011	259	575	TANK
377	1	71	40	552	402	575	STRIKER
377	2	70	40	1245	209	598	TANK
377	3	51	40	1011	259	575	TANK
378	1	63	40	978	250	556	TANK
378	2	16	40	804	377	628	STRIKER
378	3	50	40	793	303	551	BALANCED
379	1	93	10	898	281	562	BALANCED
379	2	181	20	919	287	574	BALANCED
379	3	71	40	552	402	575	STRIKER
380	1	63	40	978	250	556	TANK
380	2	194	20	732	343	572	STRIKER
380	3	67	40	689	359	574	STRIKER
381	1	54	40	891	278	556	BALANCED
381	2	54	40	891	278	556	BALANCED
215	3	46	30	2820	1187	2068	BALANCED
216	1	106	30	1242	318	706	TANK
216	2	18	40	1170	404	770	BALANCED
216	3	46	10	1702	716	1248	BALANCED
217	1	19	40	1294	494	898	BALANCED
217	2	19	40	1294	494	898	BALANCED
217	3	105	40	1614	413	917	TANK
218	1	127	30	1354	423	846	BALANCED
218	2	113	40	1410	539	980	BALANCED
218	3	275	20	951	552	849	STRIKER
219	1	161	20	586	427	610	STRIKER
219	2	165	20	1066	333	666	BALANCED
219	3	46	10	1702	716	1248	BALANCED
220	1	35	40	419	160	291	BALANCED
220	2	35	40	419	160	291	BALANCED
220	3	45	40	3007	940	1880	BALANCED
221	1	34	40	408	156	284	BALANCED
221	2	34	40	408	156	284	BALANCED
221	3	45	40	3007	940	1880	BALANCED
222	1	208	20	622	583	777	STRIKER
222	2	230	20	1471	340	800	TANK
222	3	234	20	966	503	805	STRIKER
223	1	18	40	1170	404	770	BALANCED
223	2	18	40	1170	404	770	BALANCED
223	3	266	20	1341	419	838	BALANCED
224	1	64	40	982	251	558	TANK
224	2	64	40	982	251	558	TANK
224	3	46	10	1702	716	1248	BALANCED
225	1	49	40	969	248	551	TANK
225	2	64	40	982	251	558	TANK
225	3	46	10	1702	716	1248	BALANCED
226	1	192	20	1103	421	766	BALANCED
226	2	228	20	1279	400	800	BALANCED
226	3	121	30	1109	423	770	BALANCED
227	1	196	10	483	300	451	STRIKER
227	2	61	40	969	248	551	TANK
227	3	41	40	2328	595	1323	TANK
228	1	39	40	689	215	430	BALANCED
228	2	170	10	896	151	431	TANK
228	3	20	30	2324	726	1452	BALANCED
229	1	236	20	1674	282	805	TANK
229	2	245	20	1886	224	813	TANK
229	3	17	40	1096	343	686	BALANCED
230	1	112	30	1198	374	748	BALANCED
230	2	185	20	1199	375	750	BALANCED
230	3	110	30	1060	405	736	BALANCED
231	1	35	40	419	160	291	BALANCED
231	2	38	40	379	277	395	STRIKER
231	3	20	30	2324	726	1452	BALANCED
232	1	16	40	804	377	628	STRIKER
232	2	170	20	1535	258	738	TANK
232	3	17	40	1096	343	686	BALANCED
233	1	66	40	1023	320	640	BALANCED
233	2	66	40	1023	320	640	BALANCED
233	3	87	20	978	373	679	BALANCED
234	1	65	40	800	306	556	BALANCED
234	2	66	40	1023	320	640	BALANCED
234	3	17	40	1096	343	686	BALANCED
235	1	63	40	978	250	556	TANK
235	2	16	40	804	377	628	STRIKER
235	3	67	40	689	359	574	STRIKER
236	1	63	40	978	250	556	TANK
236	2	16	40	804	377	628	STRIKER
236	3	67	40	689	359	574	STRIKER
237	1	71	40	552	402	575	STRIKER
237	2	70	40	1245	209	598	TANK
237	3	51	40	1011	259	575	TANK
238	1	71	40	552	402	575	STRIKER
238	2	70	40	1245	209	598	TANK
238	3	51	40	1011	259	575	TANK
239	1	71	40	552	402	575	STRIKER
239	2	70	40	1245	209	598	TANK
239	3	51	40	1011	259	575	TANK
240	1	54	40	891	278	556	BALANCED
240	2	54	40	891	278	556	BALANCED
240	3	127	20	888	278	556	BALANCED
241	1	65	40	800	306	556	BALANCED
241	2	65	40	800	306	556	BALANCED
241	3	54	40	891	278	556	BALANCED
242	1	50	40	793	303	551	BALANCED
242	2	50	40	793	303	551	BALANCED
242	3	53	40	881	275	550	BALANCED
243	1	52	40	881	275	550	BALANCED
243	2	52	40	881	275	550	BALANCED
243	3	59	40	793	303	551	BALANCED
244	1	53	40	881	275	550	BALANCED
244	2	53	40	881	275	550	BALANCED
244	3	50	40	793	303	551	BALANCED
245	1	277	10	801	250	500	BALANCED
245	2	93	10	898	281	562	BALANCED
245	3	266	10	783	245	490	BALANCED
246	1	44	40	2498	954	1735	BALANCED
246	2	44	40	2498	954	1735	BALANCED
246	3	45	40	3007	940	1880	BALANCED
247	1	46	20	2264	953	1661	BALANCED
247	2	46	20	2264	953	1661	BALANCED
247	3	43	40	1999	1041	1666	STRIKER
248	1	46	20	2264	953	1661	BALANCED
248	2	46	20	2264	953	1661	BALANCED
248	3	43	40	1999	1041	1666	STRIKER
249	1	42	40	2511	642	1427	TANK
249	2	43	40	1999	1041	1666	STRIKER
249	3	41	40	2328	595	1323	TANK
250	1	42	40	2511	642	1427	TANK
250	2	42	40	2511	642	1427	TANK
250	3	41	40	2328	595	1323	TANK
251	1	46	10	1702	716	1248	BALANCED
251	2	46	10	1702	716	1248	BALANCED
251	3	161	40	1264	922	1317	STRIKER
252	1	63	40	978	250	556	TANK
252	2	44	40	2498	954	1735	BALANCED
252	3	20	30	2324	726	1452	BALANCED
253	1	210	30	1241	805	1193	STRIKER
253	2	236	30	2552	429	1227	TANK
253	3	275	30	1450	841	1294	STRIKER
254	1	20	20	1806	564	1128	BALANCED
254	2	20	20	1806	564	1128	BALANCED
254	3	126	40	1603	612	1113	BALANCED
255	1	20	20	1806	564	1128	BALANCED
255	2	20	20	1806	564	1128	BALANCED
255	3	126	40	1603	612	1113	BALANCED
256	1	40	40	1691	584	1112	BALANCED
256	2	40	40	1691	584	1112	BALANCED
256	3	119	40	2427	325	1083	TANK
257	1	121	40	1569	599	1089	BALANCED
257	2	124	40	1752	548	1096	BALANCED
257	3	126	40	1603	612	1113	BALANCED
258	1	116	40	1493	570	1037	BALANCED
258	2	40	40	1691	584	1112	BALANCED
258	3	119	40	2427	325	1083	TANK
259	1	264	20	1577	329	822	TANK
259	2	105	40	1614	413	917	TANK
259	3	20	30	2324	726	1452	BALANCED
260	1	277	20	1372	429	858	BALANCED
260	2	119	40	2427	325	1083	TANK
260	3	46	10	1702	716	1248	BALANCED
261	1	107	40	1520	581	1056	BALANCED
261	2	107	40	1520	581	1056	BALANCED
261	3	122	40	1520	581	1056	BALANCED
262	1	116	40	1493	570	1037	BALANCED
262	2	116	40	1493	570	1037	BALANCED
262	3	165	30	1624	508	1016	BALANCED
263	1	75	20	599	62	249	TANK
263	2	78	20	331	155	258	STRIKER
263	3	142	10	500	100	256	TANK
264	1	76	20	538	72	240	TANK
264	2	131	10	456	117	260	TANK
264	3	129	10	539	91	259	TANK
265	1	83	10	149	109	156	STRIKER
265	2	85	10	259	81	162	BALANCED
265	3	75	10	350	36	145	TANK
266	1	135	20	391	366	488	STRIKER
266	2	77	40	885	226	503	TANK
266	3	138	20	879	225	500	TANK
267	1	77	40	885	226	503	TANK
267	2	77	40	885	226	503	TANK
267	3	73	40	460	335	479	STRIKER
268	1	73	40	460	335	479	STRIKER
268	2	73	40	460	335	479	STRIKER
268	3	283	10	912	233	518	TANK
269	1	129	20	924	155	444	TANK
269	2	132	20	396	326	450	STRIKER
269	3	134	20	764	239	478	BALANCED
270	1	78	30	505	237	395	STRIKER
270	2	79	30	650	203	406	BALANCED
270	3	136	20	663	253	460	BALANCED
271	1	82	30	520	244	407	STRIKER
271	2	86	30	948	127	423	TANK
271	3	84	30	402	293	419	STRIKER
272	1	75	30	914	95	381	TANK
272	2	81	30	390	284	406	STRIKER
272	3	85	30	677	212	424	BALANCED
273	1	76	10	314	42	140	TANK
273	2	76	40	1161	156	519	TANK
273	3	141	10	647	109	311	TANK
274	1	81	20	256	186	266	STRIKER
274	2	138	10	513	131	291	TANK
274	3	137	10	513	131	291	TANK
275	1	79	20	426	133	266	BALANCED
275	2	140	10	482	151	302	BALANCED
275	3	86	20	622	83	277	TANK
276	1	136	10	366	155	269	BALANCED
276	2	133	10	435	136	272	BALANCED
276	3	82	20	341	160	267	STRIKER
277	1	137	30	1340	343	762	TANK
277	2	283	20	1563	400	888	TANK
277	3	139	30	872	506	779	STRIKER
278	1	142	30	1305	261	669	TANK
278	2	132	30	603	497	685	STRIKER
278	3	134	30	1164	364	728	BALANCED
279	1	80	40	644	373	574	STRIKER
279	2	287	20	1026	595	916	STRIKER
279	3	83	40	552	402	575	STRIKER
280	1	74	40	862	269	538	BALANCED
280	2	74	40	862	269	538	BALANCED
280	3	78	40	714	335	558	STRIKER
281	1	288	10	855	267	534	BALANCED
281	2	74	40	862	269	538	BALANCED
281	3	140	20	826	258	516	BALANCED
282	1	60	10	210	66	132	BALANCED
282	2	111	30	916	234	520	TANK
282	3	69	10	187	87	145	STRIKER
283	1	123	10	526	72	236	TANK
283	2	69	20	320	150	250	STRIKER
283	3	128	10	222	183	252	STRIKER
284	1	111	10	351	90	200	TANK
284	2	114	10	332	104	208	BALANCED
284	3	108	10	311	97	194	BALANCED
285	1	58	40	567	302	479	STRIKER
285	2	55	40	1047	158	485	TANK
285	3	62	40	885	226	503	TANK
286	1	58	40	567	302	479	STRIKER
286	2	55	40	1047	158	485	TANK
286	3	57	40	766	239	478	BALANCED
287	1	57	40	766	239	478	BALANCED
287	2	57	40	766	239	478	BALANCED
287	3	58	40	567	302	479	STRIKER
288	1	108	20	533	167	334	BALANCED
288	2	62	40	885	226	503	TANK
288	3	55	40	1047	158	485	TANK
289	1	115	20	433	225	360	STRIKER
289	2	69	30	487	228	380	STRIKER
289	3	125	20	799	167	417	TANK
290	1	60	30	548	171	342	BALANCED
290	2	111	20	601	154	342	TANK
290	3	56	30	555	173	346	BALANCED
291	1	128	30	581	478	660	STRIKER
291	2	114	40	1226	383	766	BALANCED
291	3	120	40	1020	531	850	STRIKER
292	1	72	40	919	287	574	BALANCED
292	2	72	40	919	287	574	BALANCED
292	3	123	30	1374	188	617	TANK
293	1	68	40	881	275	550	BALANCED
293	2	68	40	881	275	550	BALANCED
293	3	115	30	660	344	550	STRIKER
294	1	68	40	881	275	550	BALANCED
294	2	72	40	919	287	574	BALANCED
294	3	62	40	885	226	503	TANK
295	1	56	40	785	245	490	BALANCED
295	2	109	30	826	258	516	BALANCED
295	3	108	30	812	254	508	BALANCED
381	3	127	20	888	278	556	BALANCED
382	1	65	40	800	306	556	BALANCED
382	2	65	40	800	306	556	BALANCED
382	3	54	40	891	278	556	BALANCED
383	1	53	40	881	275	550	BALANCED
383	2	65	40	800	306	556	BALANCED
383	3	50	40	793	303	551	BALANCED
384	1	52	40	881	275	550	BALANCED
384	2	52	40	881	275	550	BALANCED
384	3	59	40	793	303	551	BALANCED
385	1	53	40	881	275	550	BALANCED
385	2	53	40	881	275	550	BALANCED
385	3	50	40	793	303	551	BALANCED
386	1	44	40	2498	954	1735	BALANCED
386	2	44	40	2498	954	1735	BALANCED
386	3	45	40	3007	940	1880	BALANCED
387	1	46	20	2264	953	1661	BALANCED
387	2	46	20	2264	953	1661	BALANCED
387	3	43	40	1999	1041	1666	STRIKER
388	1	46	20	2264	953	1661	BALANCED
388	2	46	20	2264	953	1661	BALANCED
388	3	43	40	1999	1041	1666	STRIKER
389	1	312	10	2623	606	1426	TANK
389	2	44	40	2498	954	1735	BALANCED
389	3	20	30	2324	726	1452	BALANCED
390	1	42	40	2511	642	1427	TANK
390	2	43	40	1999	1041	1666	STRIKER
390	3	41	40	2328	595	1323	TANK
391	1	42	40	2511	642	1427	TANK
391	2	42	40	2511	642	1427	TANK
391	3	41	40	2328	595	1323	TANK
392	1	46	10	1702	716	1248	BALANCED
392	2	46	10	1702	716	1248	BALANCED
392	3	161	40	1264	922	1317	STRIKER
393	1	210	30	1241	805	1193	STRIKER
393	2	236	30	2552	429	1227	TANK
393	3	275	30	1450	841	1294	STRIKER
394	1	46	10	1702	716	1248	BALANCED
394	2	46	10	1702	716	1248	BALANCED
394	3	195	30	2164	500	1176	TANK
395	1	126	40	1603	612	1113	BALANCED
395	2	216	30	1929	603	1206	BALANCED
395	3	20	20	1806	564	1128	BALANCED
396	1	126	40	1603	612	1113	BALANCED
396	2	126	40	1603	612	1113	BALANCED
396	3	20	20	1806	564	1128	BALANCED
397	1	40	40	1691	584	1112	BALANCED
397	2	40	40	1691	584	1112	BALANCED
397	3	119	40	2427	325	1083	TANK
398	1	119	40	2427	325	1083	TANK
398	2	119	40	2427	325	1083	TANK
398	3	40	40	1691	584	1112	BALANCED
399	1	107	40	1520	581	1056	BALANCED
399	2	107	40	1520	581	1056	BALANCED
399	3	122	40	1520	581	1056	BALANCED
400	1	105	40	1614	413	917	TANK
400	2	171	30	1320	687	1100	STRIKER
400	3	124	40	1752	548	1096	BALANCED
401	1	116	40	1493	570	1037	BALANCED
401	2	116	40	1493	570	1037	BALANCED
401	3	165	30	1624	508	1016	BALANCED
402	1	184	10	1015	120	437	TANK
402	2	61	40	969	248	551	TANK
402	3	46	30	2820	1187	2068	BALANCED
403	1	118	40	1616	505	1010	BALANCED
403	2	116	40	1493	570	1037	BALANCED
403	3	106	40	1757	449	998	TANK
404	1	75	20	599	62	249	TANK
404	2	81	20	256	186	266	STRIKER
404	3	131	10	456	117	260	TANK
405	1	142	10	500	100	256	TANK
405	2	129	10	539	91	259	TANK
405	3	76	20	538	72	240	TANK
406	1	83	10	149	109	156	STRIKER
406	2	85	10	259	81	162	BALANCED
406	3	75	10	350	36	145	TANK
407	1	135	20	391	366	488	STRIKER
407	2	77	40	885	226	503	TANK
407	3	138	20	879	225	500	TANK
408	1	73	40	460	335	479	STRIKER
408	2	73	40	460	335	479	STRIKER
408	3	283	10	912	233	518	TANK
409	1	129	20	924	155	444	TANK
409	2	132	20	396	326	450	STRIKER
409	3	134	20	764	239	478	BALANCED
410	1	85	30	677	212	424	BALANCED
410	2	136	20	663	253	460	BALANCED
410	3	81	30	390	284	406	STRIKER
411	1	82	30	520	244	407	STRIKER
411	2	86	30	948	127	423	TANK
411	3	84	30	402	293	419	STRIKER
412	1	77	20	410	105	233	TANK
412	2	288	10	855	267	534	BALANCED
412	3	79	30	650	203	406	BALANCED
413	1	75	30	914	95	381	TANK
413	2	78	30	505	237	395	STRIKER
413	3	77	30	625	160	355	TANK
414	1	138	10	513	131	291	TANK
414	2	141	10	647	109	311	TANK
414	3	86	20	622	83	277	TANK
415	1	79	20	426	133	266	BALANCED
415	2	140	10	482	151	302	BALANCED
415	3	137	10	513	131	291	TANK
416	1	136	10	366	155	269	BALANCED
416	2	133	10	435	136	272	BALANCED
416	3	82	20	341	160	267	STRIKER
417	1	289	20	1590	497	994	BALANCED
417	2	296	20	799	749	999	STRIKER
417	3	283	20	1563	400	888	TANK
418	1	292	20	1510	472	944	BALANCED
418	2	293	20	1359	519	944	BALANCED
418	3	287	20	1026	595	916	STRIKER
419	1	139	30	872	506	779	STRIKER
419	2	284	20	1421	444	888	BALANCED
419	3	137	30	1340	343	762	TANK
420	1	142	30	1305	261	669	TANK
420	2	132	30	603	497	685	STRIKER
420	3	134	30	1164	364	728	BALANCED
421	1	83	40	552	402	575	STRIKER
421	2	295	10	1170	244	610	TANK
421	3	80	40	644	373	574	STRIKER
422	1	289	10	928	290	580	BALANCED
422	2	298	10	933	292	584	BALANCED
422	3	297	10	1026	262	583	TANK
423	1	74	40	862	269	538	BALANCED
423	2	292	10	881	275	550	BALANCED
423	3	291	10	1146	193	551	TANK
424	1	74	40	862	269	538	BALANCED
424	2	74	40	862	269	538	BALANCED
424	3	140	20	826	258	516	BALANCED
425	1	76	40	1161	156	519	TANK
425	2	294	10	448	420	560	STRIKER
425	3	73	40	460	335	479	STRIKER
426	1	123	10	526	72	236	TANK
426	2	69	20	320	150	250	STRIKER
426	3	128	10	222	183	252	STRIKER
427	1	111	10	351	90	200	TANK
427	2	114	10	332	104	208	BALANCED
427	3	69	10	187	87	145	STRIKER
428	1	62	40	885	226	503	TANK
428	2	62	40	885	226	503	TANK
428	3	274	10	906	209	492	TANK
429	1	58	40	567	302	479	STRIKER
429	2	55	40	1047	158	485	TANK
429	3	260	10	434	349	485	STRIKER
430	1	58	40	567	302	479	STRIKER
430	2	55	40	1047	158	485	TANK
430	3	260	10	434	349	485	STRIKER
431	1	57	40	766	239	478	BALANCED
431	2	57	40	766	239	478	BALANCED
431	3	58	40	567	302	479	STRIKER
432	1	235	10	654	265	469	BALANCED
432	2	235	10	654	265	469	BALANCED
432	3	227	10	1038	139	463	TANK
433	1	69	30	487	228	380	STRIKER
433	2	57	40	766	239	478	BALANCED
433	3	55	40	1047	158	485	TANK
434	1	177	10	684	214	428	BALANCED
434	2	193	10	715	224	447	BALANCED
434	3	174	10	682	213	426	BALANCED
435	1	172	10	679	212	424	BALANCED
435	2	207	10	726	227	454	BALANCED
435	3	125	20	799	167	417	TANK
436	1	108	20	533	167	334	BALANCED
436	2	115	20	433	225	360	STRIKER
436	3	111	30	916	234	520	TANK
437	1	60	10	210	66	132	BALANCED
437	2	235	20	1120	455	805	BALANCED
437	3	56	10	213	66	133	BALANCED
438	1	60	30	548	171	342	BALANCED
438	2	111	20	601	154	342	TANK
438	3	56	30	555	173	346	BALANCED
439	1	114	40	1226	383	766	BALANCED
439	2	200	20	1268	381	777	BALANCED
439	3	217	20	630	591	788	STRIKER
440	1	128	30	581	478	660	STRIKER
440	2	274	20	1552	359	844	TANK
440	3	174	20	1168	365	730	BALANCED
441	1	72	40	919	287	574	BALANCED
441	2	72	40	919	287	574	BALANCED
441	3	123	30	1374	188	617	TANK
442	1	68	40	881	275	550	BALANCED
442	2	68	40	881	275	550	BALANCED
442	3	115	30	660	344	550	STRIKER
443	1	68	40	881	275	550	BALANCED
443	2	72	40	919	287	574	BALANCED
443	3	62	40	885	226	503	TANK
444	1	56	40	785	245	490	BALANCED
444	2	109	30	826	258	516	BALANCED
444	3	108	30	812	254	508	BALANCED
445	1	120	40	1020	531	850	STRIKER
445	2	280	30	1993	688	1311	BALANCED
445	3	276	20	1522	374	850	TANK
\.


--
-- Name: investment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.investment_id_seq', 3, true);


--
-- Name: progress_snapshot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.progress_snapshot_id_seq', 7, true);


--
-- Name: species_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.species_id_seq', 360, true);


--
-- Name: tournament_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_team_id_seq', 445, true);


--
-- Name: app_user app_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_email_key UNIQUE (email);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: creature_sheet creature_sheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creature_sheet
    ADD CONSTRAINT creature_sheet_pkey PRIMARY KEY (species_id);


--
-- Name: creature_sheet creature_sheet_source_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creature_sheet
    ADD CONSTRAINT creature_sheet_source_key_key UNIQUE (source_key);


--
-- Name: hybrid_recipe hybrid_recipe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hybrid_recipe
    ADD CONSTRAINT hybrid_recipe_pkey PRIMARY KEY (hybrid_id, component_id);


--
-- Name: investment investment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT investment_pkey PRIMARY KEY (id);


--
-- Name: player_settings player_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_settings
    ADD CONSTRAINT player_settings_pkey PRIMARY KEY (user_id);


--
-- Name: player_species player_species_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_species
    ADD CONSTRAINT player_species_pkey PRIMARY KEY (user_id, species_id);


--
-- Name: progress_snapshot progress_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progress_snapshot
    ADD CONSTRAINT progress_snapshot_pkey PRIMARY KEY (id);


--
-- Name: progress_snapshot progress_snapshot_user_id_taken_on_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progress_snapshot
    ADD CONSTRAINT progress_snapshot_user_id_taken_on_key UNIQUE (user_id, taken_on);


--
-- Name: rarity rarity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rarity
    ADD CONSTRAINT rarity_pkey PRIMARY KEY (code);


--
-- Name: species species_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_name_key UNIQUE (name);


--
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (id);


--
-- Name: tournament_leftover tournament_leftover_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_leftover
    ADD CONSTRAINT tournament_leftover_pkey PRIMARY KEY (user_id, tournament, species_id, level);


--
-- Name: tournament_plan tournament_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_plan
    ADD CONSTRAINT tournament_plan_pkey PRIMARY KEY (user_id);


--
-- Name: tournament_team_member tournament_team_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team_member
    ADD CONSTRAINT tournament_team_member_pkey PRIMARY KEY (team_id, slot);


--
-- Name: tournament_team tournament_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team
    ADD CONSTRAINT tournament_team_pkey PRIMARY KEY (id);


--
-- Name: tournament_team tournament_team_user_id_tournament_league_rank_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team
    ADD CONSTRAINT tournament_team_user_id_tournament_league_rank_key UNIQUE (user_id, tournament, league, rank);


--
-- Name: investment_user_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX investment_user_date_idx ON public.investment USING btree (user_id, invested_on DESC);


--
-- Name: creature_sheet creature_sheet_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creature_sheet
    ADD CONSTRAINT creature_sheet_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: hybrid_recipe hybrid_recipe_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hybrid_recipe
    ADD CONSTRAINT hybrid_recipe_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: hybrid_recipe hybrid_recipe_hybrid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hybrid_recipe
    ADD CONSTRAINT hybrid_recipe_hybrid_id_fkey FOREIGN KEY (hybrid_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: investment investment_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT investment_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: investment investment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT investment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: player_settings player_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_settings
    ADD CONSTRAINT player_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: player_species player_species_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_species
    ADD CONSTRAINT player_species_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: player_species player_species_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_species
    ADD CONSTRAINT player_species_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: progress_snapshot progress_snapshot_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progress_snapshot
    ADD CONSTRAINT progress_snapshot_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: species species_rarity_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_rarity_code_fkey FOREIGN KEY (rarity_code) REFERENCES public.rarity(code);


--
-- Name: tournament_leftover tournament_leftover_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_leftover
    ADD CONSTRAINT tournament_leftover_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: tournament_leftover tournament_leftover_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_leftover
    ADD CONSTRAINT tournament_leftover_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.tournament_plan(user_id) ON DELETE CASCADE;


--
-- Name: tournament_plan tournament_plan_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_plan
    ADD CONSTRAINT tournament_plan_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: tournament_team_member tournament_team_member_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team_member
    ADD CONSTRAINT tournament_team_member_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id) ON DELETE CASCADE;


--
-- Name: tournament_team_member tournament_team_member_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team_member
    ADD CONSTRAINT tournament_team_member_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.tournament_team(id) ON DELETE CASCADE;


--
-- Name: tournament_team tournament_team_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_team
    ADD CONSTRAINT tournament_team_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.tournament_plan(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict U2tcqXoJoWwGCz7SD1O0QpLwBfbdsfutrlRh4AsdRKavYJZznLhhpLz4gwwA1Me

