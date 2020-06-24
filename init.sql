CREATE TABLE "signing"."profilesignatureparameters" (
    "profileid" character varying(255) NOT NULL,
    "archivetimestampcanonicalizationmethod" character varying(255),
    "archivetimestampdigestalgorithm" character varying(255),
    "asiccontainertype" character varying(255),
    "contenttimestampcanonicalizationmethod" character varying(255),
    "contenttimestampdigestalgorithm" character varying(255),
    "created" timestamp NOT NULL,
    "digestalgorithm" character varying(255) NOT NULL,
    "generatetbswithoutcertificate" boolean,
    "isdefault" boolean,
    "maskgenerationfunction" character varying(255),
    "policydescription" character varying(255),
    "policydigestalgorithm" character varying(255),
    "policydigestvalue" bytea,
    "policyid" character varying(255),
    "policyqualifier" character varying(255),
    "policyspuri" character varying(255),
    "referencedigestalgorithm" character varying(255),
    "signwithexpiredcertificate" boolean,
    "signaturelevel" character varying(255) NOT NULL,
    "signaturepackaging" character varying(255) NOT NULL,
    "signaturetimestampcanonicalizationmethod" character varying(255),
    "signaturetimestampdigestalgorithm" character varying(255),
    "trustanchorbppolicy" boolean,
    "updated" timestamp NOT NULL,
    "version" integer NOT NULL,
    CONSTRAINT "profilesignatureparameters_pkey" PRIMARY KEY ("profileid"),
    CONSTRAINT "uk_ki2dvs5cm22t4ae3pbicjvd1u" UNIQUE ("isdefault")
) WITH (oids = false);

INSERT INTO "profilesignatureparameters" ("profileid", "archivetimestampcanonicalizationmethod", "archivetimestampdigestalgorithm", "asiccontainertype", "contenttimestampcanonicalizationmethod", "contenttimestampdigestalgorithm", "created", "digestalgorithm", "generatetbswithoutcertificate", "isdefault", "maskgenerationfunction", "policydescription", "policydigestalgorithm", "policydigestvalue", "policyid", "policyqualifier", "policyspuri", "referencedigestalgorithm", "signwithexpiredcertificate", "signaturelevel", "signaturepackaging", "signaturetimestampcanonicalizationmethod", "signaturetimestampdigestalgorithm", "trustanchorbppolicy", "updated", "version") VALUES
('XADES_1',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-05-07 09:51:23.602475',	'SHA256',	NULL,	'1',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'XAdES_BASELINE_B',	'ENVELOPED',	NULL,	NULL,	NULL,	'2020-05-07 09:51:23.602475',	1),
('XADES_2',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-05-07 09:51:34.191644',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'XAdES_BASELINE_B',	'ENVELOPING',	NULL,	NULL,	NULL,	'2020-05-07 09:51:34.191644',	1),
('PADES_1',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-05-07 09:51:42.753703',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'PAdES_BASELINE_B',	'ENVELOPED',	NULL,	NULL,	NULL,	'2020-05-07 09:51:42.753703',	1),
('CADES_1',	NULL,	NULL,	'ASiC_S',	NULL,	NULL,	'2020-05-28 09:23:12.760081',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'CAdES_BASELINE_B',	'DETACHED',	NULL,	NULL,	NULL,	'2020-05-28 09:23:12.760081',	1),
('CADES_2',	NULL,	NULL,	'ASiC_E',	NULL,	NULL,	'2020-05-28 09:23:15.760081',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'CAdES_BASELINE_B',	'DETACHED',	NULL,	NULL,	NULL,	'2020-05-28 09:23:15.760081',	1),
('XADES_LTA',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'XAdES_BASELINE_LTA',	'ENVELOPED',	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	1),
('PADES_LTA',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'PAdES_BASELINE_LTA',	'ENVELOPED',	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	1),
('CADES_LTA',	NULL,	NULL,	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	'SHA256',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'CAdES_BASELINE_LTA',	'ENVELOPED',	NULL,	NULL,	NULL,	'2020-06-11 11:44:39.864068',	1);

CREATE TABLE "signing"."profilesignatureparameters_commitmenttypeindications" (
    "profilesignatureparameters_profileid" character varying(255) NOT NULL,
    "commitmenttypeindications" character varying(255),
    CONSTRAINT "fkfb4hrfeschj688ldpwievcq1t" FOREIGN KEY (profilesignatureparameters_profileid) REFERENCES profilesignatureparameters(profileid) NOT DEFERRABLE
) WITH (oids = false);

