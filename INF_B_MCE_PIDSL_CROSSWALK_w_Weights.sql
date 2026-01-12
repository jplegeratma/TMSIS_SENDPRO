
select *
from MHTEAM.DWDQ.INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS
order by MCE_NUM;

-----------

create TABLE MHTEAM.DWDQ.INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS (
	MCE_GROUP VARCHAR(10),
	MCE_NUM NUMBER(38,0),
	CDE_ENTITY_MODEL VARCHAR(5),
	MCE VARCHAR(5),
	MCO VARCHAR(5),
	MCO_CURRENT VARCHAR(5),
	ACO VARCHAR(20),
	ACO_CURRENT VARCHAR(20),
	ENTITY_PIDSL VARCHAR(20),
	ENTITY_NAME VARCHAR(100),
	ORG VARCHAR(100),
	WEIGHT NUMBER(34,4)
);


--drop table INF_B_MCE_PIDSL_CROSSWALK2;

--create table INF_B_MCE_PIDSL_CROSSWALK2 AS SELECT * FROM INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS;

truncate table INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS;


select *
from MHTEAM.DWDQ.INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS;

MINUS
select *
from MHTEAM.DWDQ.INF_B_MCE_PIDSL_CROSSWALK2;


INSERT INTO INF_B_MCE_PIDSL_CROSSWALK_WEIGHTS (
    MCE_GROUP, MCE_NUM, CDE_ENTITY_MODEL, MCE, MCO, MCO_CURRENT, ACO, ACO_CURRENT, ENTITY_PIDSL, ENTITY_NAME, ORG, WEIGHT
) VALUES
('Group 2', 1,  'MCO',  'TFT', 'CHA', 'THP', '#', '#',            '110088791A', 'TUFTS HEALTH TOGETHER', 'Point32 / Tufts Health Plan', 0.0176),
('Group 1', 2,  'MCO',  'WLS', 'BMC', 'WLS', '#', '#',            '110025617D', 'WELLSENSE ESSENTIAL - MCO PLAN', 'WellSense (formerly Boston Medical Center)', 0.0108),
(NULL,      3,  'MBH',  'MBH', 'MBH', 'MBH', '#', '#',            '110031899B', 'MASSACHUSETTS BEH HLTH PRT', 'sub Mass Behavioral Health Partnership', 0.0084),
('Group 3', 4,  'ACOA', 'FLN', 'FLN', 'FLN', 'FLN-ATRIUS', 'FLN-ATRIUS', '110031449L', 'FALLON HEALTH-ATRIUS HEALTH CARE COLLABORATIVE', 'Fallon Health', 0.0210),
('Group 3', 5,  'ACOA', 'FLN', 'FLN', 'FLN', 'FLN-BERK', 'FLN-BERK', '110031449F', 'BERKSHIRE FALLON HEALTH COLLABORATIVE', 'Fallon Health', 0.0132),
('Group 3', 6,  'ACOA', 'FLN', 'FLN', 'FLN', 'FLN-REL', 'FLN-REL', '110031449G', 'FALLON 365 CARE', 'Fallon Health', 0.0194),
(NULL,      7,  'ACOA', 'HNE', 'HNE', 'HNE', 'HNE-BAY', 'HNE-BAY', '110031464B', 'BEHEALTHY PARTNERSHIP', 'Health New England', 0.0287),
(NULL,      8,  'ACOA', 'MGB', 'NHP', 'MGB', 'MGB-MGB', 'MGB-MGB', '110031467G', 'MASS GENERAL BRIGHAM HEALTH PLAN WITH MASS GENERAL', 'Mass General Brigham; Allways Health Partners, Neighborhood Health Plan', 0.0818),
('Group 2', 9,  'ACOA', 'TFT', 'CHA', 'THP', 'CHA-CHA', 'THP-CHA', '110088791E', 'TUFTS HEALTH TOGETHER WITH CHA', 'Point32 / Tufts Health Plan', 0.0178),
('Group 2', 10, 'ACOA', 'TFT', 'CHA', 'THP', 'THP-UMMH', 'THP-UMMH', '110088791G', 'TUFTS HEALTH TOGETHER WITH UMASS MEMORIAL HEALTH', 'Point32 / Tufts Health Plan', 0.0274),
('Group 1', 11, 'ACOA', 'WLS', 'BMC', 'WLS', 'BMC-BACO', 'WLS-BACO', '110104314B', 'WELLSENSE COMMUNITY ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0873),
('Group 1', 12, 'ACOA', 'WLS', 'BMC', 'WLS', 'WLS-BCHACO', 'WLS-BCHACO', '110104314H', 'WELLSENSE BOSTON CHILDRENS ACO', 'WellSense (formerly Boston Medical Center)', 0.0495),
('Group 1', 13, 'ACOA', 'WLS', 'BMC', 'WLS', 'WLS-BILH', 'WLS-BILH', '110104314I', 'WELLSENSE BILH PERFORMANCE NETWORK ACO', 'WellSense (formerly Boston Medical Center)', 0.0380),
('Group 1', 14, 'ACOA', 'WLS', 'BMC', 'WLS', 'WLS-CARE', 'WLS-CARE', '110104314F', 'WELLSENSE CARE ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0300),
('Group 1', 15, 'ACOA', 'WLS', 'BMC', 'WLS', 'WLS-EBNHC', 'WLS-EBNHC', '110104314G', 'EAST BOSTON NEIGHBORHOOD HEALTH WELLSENSE ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0141),
('Group 1', 16, 'ACOA', 'WLS', 'BMC', 'WLS', 'BMC-MERCY', 'WLS-MERCY', '110104314C', 'WELLSENSE MERCY ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0147),
('Group 1', 17, 'ACOA', 'WLS', 'BMC', 'WLS', 'BMC-SCOAST', 'WLS-SCOAST', '110104314E', 'WELLSENSE SOUTHCOAST ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0121),
('Group 1', 18, 'ACOA', 'WLS', 'BMC', 'WLS', 'BMC-SIGN', 'WLS-SIGN', '110104314D', 'WELLSENSE SIGNATURE ALLIANCE', 'WellSense (formerly Boston Medical Center)', 0.0144),
(NULL,      19, 'ICO',  'CCA', 'CCI', 'CCI', '#', '#', '110031450B', 'COMMONWEALTH CARE ALLIANCE', 'Commonwealth Care Alliance', 0.1084),
(NULL,      20, 'ICO',  'TFT', 'NWI', 'NWI', '#', '#', '110088791B', 'TUFTS HEALTH UNIFY', 'Point32 / Tufts Health Plan', 0.0189),
(NULL,      21, 'ICO',  'UHC', 'UCC', 'UCC', '#', '#', '110031447B', 'UNITEDHEALTHCARE INSURANCE COMPANY', 'United Healthcare', 0.0083),
(NULL,      22, 'SCO',  'WLS', 'BHP', 'BHP', '#', '#', '110025617H', 'WELLSENSE SENIOR CARE OPTIONS PLAN', 'WellSense (formerly Boston Medical Center)', 0.0060),
(NULL,      23, 'SCO',  'CCA', 'CCA', 'CCA', '#', '#', '110031450A', 'COMMONWEALTH CARE ALLIANCE', 'Commonwealth Care Alliance', 0.0793),
(NULL,      24, 'SCO',  'FLN', 'NAV', 'NAV', '#', '#', '110031449E', 'FALLON HEALTH', 'Fallon Health', 0.0486),
(NULL,      25, 'SCO',  'SWH', 'SWH', 'SWH', '#', '#', '110031448A', 'SENIOR WHOLE HEALTH LLC', 'Senior Whole Health by Molina Healthcare', 0.0435),
(NULL,      26, 'SCO',  'TFT', 'TFT', 'TFT', '#', '#', '110031470B', 'TUFTS HEALTH PLAN', 'Point32 / Tufts Health Plan', 0.0573),
(NULL,      27, 'SCO',  'UHC', 'UHC', 'UHC', '#', '#', '110031447A', 'UNITEDHEALTHCARE INSURANCE COMPANY', 'United Healthcare', 0.0989),
(NULL,      28, 'MBH',  'MBH', 'MBH', 'MBH', 'CCC', 'CCC', '110117145B', 'COMMUNITY CARE COOPERATIVE INC', 'sub Mass Behavioral Health Partnership', 0.0166),
(NULL,      29, 'MBH',  'MBH', 'MBH', 'MBH', 'STEWARD', 'REV', '110215092A', 'REVERE HEALTH CHOICE', 'sub Mass Behavioral Health Partnership', 0.0000),
(NULL,      30, 'MBH',  'MBH', 'MBH', 'MBH', 'REV', 'REV', '110215092A', 'REVERE HEALTH CHOICE', 'sub Mass Behavioral Health Partnership', 0.0079),
('ACO-1',   31, 'ACOA', 'TFT', 'CHA', 'TFT', 'CHA-CHICO', 'TFT-CHICO', '110088791F', 'TUFTS HEALTH TOGETHER WITH BOSTON CHILDRENS ACO', 'Tufts Health Plan', 0.0000),
('ACO-1',   32, 'ACOA', 'TFT', 'CHA', 'TFT', 'CHA-ATRIUS', 'TFT-ATRIUS', '110088791C', 'TUFTS HEALTH TOGETHER WITH ATRIUS HEALTH', 'Tufts Health Plan', 0.0000),
('ACO-1',   33, 'ACOA', 'FLN', 'FLN', 'FLN', 'FLN-WFC', 'FLN-WFC', '110031449H', 'FALLON HEALTH WITH WELLFORCE', 'Fallon Health', 0.0000),
('ACO-1',   34, 'ACOA', 'TFT', 'CHA', 'TFT', 'CHA-BIDCO', 'TFT-BIDCO', '110088791D', 'TUFTS HEALTH PUBLIC PLANS WITH BETH ISRAEL DEACONESS CARE ORGANIZATION', 'Tufts Health Plan', 0.0000),
('ACO-1',   35, 'ACOA', 'NHP', 'NHP', 'NHP', 'NHP-MVA', 'NHP-MVA', '110079357A', 'ALLWAYS HEALTH PARTNERS (FORMERLY NEIGHBORHOOD HEALTH PLAN) WITH MERRIMACK VALLEY ACO', 'Mass General Brigham Health', 0.0000),
('ACO-1',   36, 'MBH',  'MBH', 'MBH', 'MBH', 'MGBACO', 'MGBACO', '110117149B', 'MASS GENERAL BRIGHAM ACO, LLC', 'sub Mass Behavioral Health Partnership', 0.0000),

(NULL,      37, 'MCO',  'HNE', 'HNE', 'HNE', '#', '#', '110031464A', 'HEALTH NEW ENGLAND', 'Health New England', 0.0000),
(NULL,      38, 'MCO',  'NHP', 'NHP', 'NHP', '#', '#', '110031467A', 'NEIGHBORHOOD HEALTH PLAN-A', 'Neighborhood Health Plan', 0.0000),
('ACO-1',   39, 'ACOC', 'TFT', 'CHA', 'TFT', 'LAHEY', 'LAHEY', '110088791F', 'LAHEY MASSHEALTH ACO', 'Beth Israel Lahey Health', 0.0000)
;