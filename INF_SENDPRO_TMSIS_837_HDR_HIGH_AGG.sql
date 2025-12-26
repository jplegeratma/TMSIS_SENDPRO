DROP VIEW INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG_PCT;

CREATE VIEW INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG_PCT AS

select RUN_DATE, MCO, Types, PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC, MEASURE, Criteria, SUM_VALID_REC_CNT, SUM_TMSIS_REC_CNT, SUM_REC_CNT, 
    CASE WHEN SUM_TMSIS_REC_CNT = 0 THEN NULL ELSE SUM_VALID_REC_CNT/SUM_TMSIS_REC_CNT END AS PCT_VALID 
from (
select RUN_DATE, MCO, Types, PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC, MEASURE, Criteria, SUM(VALID_REC_CNT) AS SUM_VALID_REC_CNT, 
SUM(TMSIS_REC_CNT) AS SUM_TMSIS_REC_CNT, SUM(REC_CNT) AS SUM_REC_CNT
FROM (
select RUN_DATE, CDE_ENC_MCO AS MCO, 'Measure' AS Types, PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC, MEASURE, BENCHMARK_THRESHOLD AS Criteria, Type, 
CASE WHEN TYPE IN ('VALID') THEN REC_CNT ELSE 0 END AS VALID_REC_CNT,
CASE WHEN TYPE IN ('VALID','NULL','INVALID') THEN REC_CNT ELSE 0 END AS TMSIS_REC_CNT,
REC_CNT
from MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG
)
GROUP BY RUN_DATE, MCO, Types, PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC, MEASURE, Criteria
)
order by MCO, MEASURE, RUN_DATE
;

DROP VIEW INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG;

CREATE VIEW INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG AS

SELECT DISTINCT RUN_DATE, A.CDE_ENC_MCO, CLAIM_TYPE, MEASURE, TYPE, REC_CNT,
L.BENCHMARK_THRESHOLD, L.PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC
FROM (

SELECT DISTINCT RUN_DATE, CDE_ENC_MCO, CLAIM_TYPE, MEASURE, TYPE, REC_CNT
FROM (
    SELECT RUN_DATE, CDE_ENC_MCO, CLAIM_TYPE, MEASURE, TYPE, COUNT(TYPE) AS REC_CNT
    FROM (
        SELECT RUN_DATE, CDE_ENC_MCO, CLAIM_TYPE,MEASURE, TYPE
        FROM (
            SELECT
                RUN_DATE,
                CDE_ENC_MCO, 
                CLAIM_TYPE,
                PATIENTSTATUSCODE1X AS Patient_Status_Code,
                MEMBERID1X AS MSIS_Identification_Number,
                ADJUDICATIONDATEHDRX AS Adjudication_Date_Header,
                ADJUDICATIONDATEDTLX AS Adjudication_Date_Detail,
                PAIDHDRSNOLINES1X AS Paid_Hdrs_No_Lines,
                DENIEDHDRSNOLINES1X AS Denied_Hdrs_No_Lines,
                PAIDHDRSNONONDENIEDLINES1X AS Paid_Hdrs_No_Non_Denied_Lines,
                FROMSERVICEDATE1X AS Beginning_Date_of_Service,
                TOSERVICEDATE1X AS Ending_Date_of_Service,
                PRESCRIPTIONFILLDATE1X AS Prescription_Fill_Date,
                BILLINGPROVIDERNPI1X AS Billing_Provider_NPI,
                BILLINGPROVIDERINTERNALID1X AS Billing_Provider_PIDSL,
                CLAIMBILLEDAMOUNT1X AS Billed_Amount,
                ACCOMREVENUECODE1X AS Accomodation_Revenue_Code,
--                AMTPAIDMCARESCHIP1X AS Amount_Paid_Medicare_SChip,
                AMTPAIDMCAREMEDICAID1X AS Amount_Paid_Medicare_Medicaid,
                AMTPAIDMCAREHDRLTXOVER1X AS Amount_Paid_Medicare_LT_Xover,
                AMTPAIDCODEDMCAREHDRXOVER1X AS Amount_Paid_Medicare_XOver_Missing,
                AMTPAIDCODEDMCAREHDRNONXOVER1X AS Amount_Paid_Medicare_Non_XOver_WData,
                ATTENDINGPROVIDERINTERNALID1X AS Attending_Provider_Internal_ID,
                ATTENDINGPROVIDERNPI1X AS Attending_Provider_NPI,
                TYPEOFADMISSION1X AS Admission_Type_Code,
--                CLAIMBILLEDAMOUNTRX1X AS Billed_Amount_RX,
                BILLINGPROVIDERTAXONOMY1X AS Billing_Provider_Taxonomy,
                BILLINGPROVIDERTYPE1X AS Billing_Provider_Type,
                BRANDGENERICIND1X AS Brand_Generic_Ind,
                COMPOUNDDRUGIND1X AS Compound_Drug_Ind,
                MEDICAIDCOVINPATIENTDAYS1X AS Medicaid_Covered_Inpatient_Days,
                PRESCRIBINGPROVIDERINTERNALID1X AS Prescribing_Provider_Internal_ID,
                PRESCRIBINGPROVIDERNPI1X AS Prescribing_Provider_NPI,
                REBATEELIGIBLEIND1X AS Rebate_Eligible_Indicator,
                REFERRINGPROVIDERINTERNALID1X AS Referring_Provider_Internal_ID,
                REFERRINGPROVIDERNPI1X AS Referring_Provider_NPI,
                SERVICINGPROVIDERINTERNALID1X AS Servicing_Provider_PIDSL,
                CLAIMALLOWABLEAMOUNT1X AS Allowed_Amount
            FROM MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837_HDR
        )
        UNPIVOT (
            TYPE
            FOR MEASURE IN (
                Patient_Status_Code,
                MSIS_Identification_Number,
                Adjudication_Date_Header,
                Adjudication_Date_Detail,
                Paid_Hdrs_No_Lines,
                Denied_Hdrs_No_Lines,
                Paid_Hdrs_No_Non_Denied_Lines,
                Beginning_Date_of_Service,
                Ending_Date_of_Service,
                Prescription_Fill_Date,
                Billing_Provider_NPI,
                Billing_Provider_PIDSL,
                Billed_Amount,
                Accomodation_Revenue_Code,
--                Amount_Paid_Medicare_SChip,
                Amount_Paid_Medicare_Medicaid,
                Amount_Paid_Medicare_LT_Xover,
                Amount_Paid_Medicare_XOver_Missing,
                Amount_Paid_Medicare_Non_XOver_WData,
                Attending_Provider_Internal_ID,
                Attending_Provider_NPI,
                Admission_Type_Code,
--                Billed_Amount_RX,
                Billing_Provider_Taxonomy,
                Billing_Provider_Type,
                Brand_Generic_Ind,
                Compound_Drug_Ind,
                Medicaid_Covered_Inpatient_Days,
                Prescribing_Provider_Internal_ID,
                Prescribing_Provider_NPI,
                Rebate_Eligible_Indicator,
                Referring_Provider_Internal_ID,
                Referring_Provider_NPI,
                Servicing_Provider_PIDSL,
                Allowed_Amount
            )
        ) AS I
    )
    GROUP BY RUN_DATE, CDE_ENC_MCO, CLAIM_TYPE, MEASURE, TYPE
)
ORDER BY RUN_DATE, CDE_ENC_MCO, CLAIM_TYPE, MEASURE, TYPE

) AS A
LEFT JOIN MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_LOOKUP L ON A.MEASURE = L.BENCHMARK;


DROP VIEW INF_SENDPRO_TMSIS_837_HDR_SUMMARY_VIEW;
create view MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_HDR_SUMMARY_VIEW(
	MCO,
	SO,
	PRIORITY,
	MEASURES,
	CURRENT_STATUS,
	JAN_2025,
	FEB_2025,
	MAR_2025,
	APR_2025,
	MAY_2025,
	JUN_2025,
	JUL_2025,
	AUG_2025,
	SEP_2025,
	OCT_2025,
	NOV_2025,
	DEC_2025
) as
select * from (

-- True Up Pass
select * from (
select 
    MCO,
    1 AS SO,
    'True Up Pass %' AS Priority,
    NULL AS Measures,
    MAX(CASE WHEN RUN_DATE = '2025-06-30' THEN PCT_VALID ELSE 0 END) AS Current_Status,    
    MAX(CASE WHEN RUN_DATE = '2025-01-31' THEN PCT_VALID ELSE 0 END) AS Jan_2025,
    MAX(CASE WHEN RUN_DATE = '2025-02-28' THEN PCT_VALID ELSE 0 END) AS Feb_2025,
    MAX(CASE WHEN RUN_DATE = '2025-03-31' THEN PCT_VALID ELSE 0 END) AS Mar_2025,
    MAX(CASE WHEN RUN_DATE = '2025-04-30' THEN PCT_VALID ELSE 0 END) AS Apr_2025,
    MAX(CASE WHEN RUN_DATE = '2025-05-31' THEN PCT_VALID ELSE 0 END) AS May_2025,
    MAX(CASE WHEN RUN_DATE = '2025-06-30' THEN PCT_VALID ELSE 0 END) AS Jun_2025,
    MAX(CASE WHEN RUN_DATE = '2025-07-31' THEN PCT_VALID ELSE 0 END) AS Jul_2025,
    MAX(CASE WHEN RUN_DATE = '2025-08-31' THEN PCT_VALID ELSE 0 END) AS Aug_2025,
    MAX(CASE WHEN RUN_DATE = '2025-09-30' THEN PCT_VALID ELSE 0 END) AS Sep_2025,    
    MAX(CASE WHEN RUN_DATE = '2025-10-31' THEN PCT_VALID ELSE 0 END) AS Oct_2025,    
    MAX(CASE WHEN RUN_DATE = '2025-11-30' THEN PCT_VALID ELSE 0 END) AS Nov_2025,    
    MAX(CASE WHEN RUN_DATE = '2025-12-31' THEN PCT_VALID ELSE 0 END) AS Dec_2025    
from (
---
select RUN_DATE, MCO, CASE WHEN SUM_TMSIS_REC_CNT = 0 THEN NULL ELSE SUM_VALID_REC_CNT/SUM_TMSIS_REC_CNT END AS PCT_VALID,
from (
select RUN_DATE, MCO, SUM(VALID_REC_CNT) AS SUM_VALID_REC_CNT, 
SUM(TMSIS_REC_CNT) AS SUM_TMSIS_REC_CNT  
FROM (
select RUN_DATE, CDE_ENC_MCO AS MCO, PRIORITY, MEASURE, BENCHMARK_THRESHOLD AS Criteria, 
CASE WHEN TYPE IN ('VALID') THEN REC_CNT ELSE 0 END AS VALID_REC_CNT,
CASE WHEN TYPE IN ('VALID','NULL','INVALID') THEN REC_CNT ELSE 0 END AS TMSIS_REC_CNT
from MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG
)
GROUP BY RUN_DATE, MCO
)
order by MCO
---
)
GROUP BY MCO, Priority, Measures
order by MCO

) -- True Up Pass
 
UNION
-- Prioritys

select * from (
SELECT 
    MCO,
    CASE 
        WHEN PRIORITY = 'Critical' THEN 2
        WHEN PRIORITY = 'High'     THEN 3
        WHEN PRIORITY = 'Medium'   THEN 4
        ELSE 5
        END SO
        ,
    CASE 
        WHEN PRIORITY = 'Critical' THEN 'TMSIS Critical'
        WHEN PRIORITY = 'High'     THEN 'TMSIS High'
        WHEN PRIORITY = 'Medium'   THEN 'TMSIS Other(Med)'
        ELSE 'NOT SET'
        END Priority
        ,
    MEAS_COUNT MEASURES,
    -- replace this date with either a paramater or calc
    SUM(CASE WHEN RUN_DATE = '2025-06-30' THEN PF_SUM ELSE 0 END) AS Current_Status,    
    
    SUM(CASE WHEN RUN_DATE = '2025-01-31' THEN PF_SUM ELSE 0 END) AS Jan_2025,
    SUM(CASE WHEN RUN_DATE = '2025-02-28' THEN PF_SUM ELSE 0 END) AS Feb_2025,
    SUM(CASE WHEN RUN_DATE = '2025-03-31' THEN PF_SUM ELSE 0 END) AS Mar_2025,
    SUM(CASE WHEN RUN_DATE = '2025-04-30' THEN PF_SUM ELSE 0 END) AS Apr_2025,
    SUM(CASE WHEN RUN_DATE = '2025-05-31' THEN PF_SUM ELSE 0 END) AS May_2025,
    SUM(CASE WHEN RUN_DATE = '2025-06-30' THEN PF_SUM ELSE 0 END) AS Jun_2025,
    SUM(CASE WHEN RUN_DATE = '2025-07-31' THEN PF_SUM ELSE 0 END) AS Jul_2025,
    SUM(CASE WHEN RUN_DATE = '2025-08-31' THEN PF_SUM ELSE 0 END) AS Aug_2025,
    SUM(CASE WHEN RUN_DATE = '2025-09-30' THEN PF_SUM ELSE 0 END) AS Sep_2025,    
    SUM(CASE WHEN RUN_DATE = '2025-10-31' THEN PF_SUM ELSE 0 END) AS Oct_2025,    
    SUM(CASE WHEN RUN_DATE = '2025-11-30' THEN PF_SUM ELSE 0 END) AS Nov_2025,    
    SUM(CASE WHEN RUN_DATE = '2025-12-31' THEN PF_SUM ELSE 0 END) AS Dev_2025    
FROM (
    select RUN_DATE, MCO, PRIORITY, count(MEASURE) MEAS_COUNT, SUM(PASS_FAIL) PF_SUM
    from (
        select RUN_DATE, MCO, PRIORITY, MEASURE,
        CASE WHEN PCT_VALID >= CRITERIA THEN 1 ELSE 0 END PASS_FAIL
        from MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG_PCT
    )
    group by RUN_DATE, MCO, PRIORITY
)
GROUP BY MCO, PRIORITY, MEAS_COUNT
ORDER BY MCO, PRIORITY

) -- Prioritys

) -- select * from
ORDER BY MCO, SO
;

DROP VIEW INF_SENDPRO_TMSIS_837_AGG_DASHBOARD;

create view MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_AGG_DASHBOARD(
	CUR_DATE,
	MCO,
	TRUE_UP_PASS_PCT,
	TMSIS_CRITICAL,
	TMSIS_HIGH,
	TMSIS_MEDIUM,
	NOT_SET
) as
select
TO_DATE('20250630','YYYYMMDD') AS CUR_DATE,
MCO, 
MAX(TRUE_UP_PASS_PCT) TRUE_UP_PASS_PCT,
MAX(TMSIS_CRITICAL) TMSIS_CRITICAL, 
MAX(TMSIS_HIGH) TMSIS_HIGH, 
MAX(TMSIS_MEDIUM) TMSIS_MEDIUM, 
MAX(NOT_SET) NOT_SET
from (

select
MCO, 
"'True Up Pass %'"   AS TRUE_UP_PASS_PCT, 
"'TMSIS Critical'"   AS TMSIS_CRITICAL, 
"'TMSIS High'"       AS TMSIS_HIGH, 
"'TMSIS Other(Med)'" AS TMSIS_MEDIUM, 
"'NOT SET'"          AS NOT_SET
from INF_SENDPRO_TMSIS_837_HDR_SUMMARY_VIEW
PIVOT (
    MAX(CURRENT_STATUS) FOR PRIORITY IN ('True Up Pass %', 'TMSIS Critical', 'TMSIS High', 'TMSIS Other(Med)', 'NOT SET')
)

)
GROUP BY MCO
;

-- Aggregated Dashboard by MCE V2

WITH priority_sums AS (

    select RUN_DATE, MCO, PRIORITY, PF_SUM, MEAS_COUNT,
    CASE WHEN MEAS_COUNT = 0 THEN 0 ELSE PF_SUM/MEAS_COUNT END PCT_PF_MEASURE,
    PRI_VALID_REC_CNT, PRI_TMSIS_REC_CNT, PRI_ALL_REC_CNT, 
    CASE WHEN PRI_TMSIS_REC_CNT = 0 THEN 0 ELSE PRI_VALID_REC_CNT/PRI_TMSIS_REC_CNT END PCT_VALID_RECS
    from (
    select RUN_DATE, MCO, PRIORITY, count(MEASURE) MEAS_COUNT, SUM(PASS_FAIL) PF_SUM,
        SUM(SUM_VALID_REC_CNT) PRI_VALID_REC_CNT, SUM(SUM_TMSIS_REC_CNT) PRI_TMSIS_REC_CNT, SUM(SUM_REC_CNT) PRI_ALL_REC_CNT    
    from (
 
        select RUN_DATE, MCO, PRIORITY, MEASURE,
        CASE WHEN PCT_VALID >= CRITERIA THEN 1 ELSE 0 END PASS_FAIL,
        SUM_VALID_REC_CNT, SUM_TMSIS_REC_CNT, SUM_REC_CNT
        from MHTEAM.DWDQ.INF_SENDPRO_TMSIS_837_HDR_HIGH_AGG_PCT
        where run_date = to_date('2025-06-30','YYYY-MM-DD')
        order by MCO, MEASURE
        
        )
    group by RUN_DATE, MCO, PRIORITY
    order by RUN_DATE, MCO, PRIORITY
    )

) -- with pirority sums

--select * from priority_sums;

select
    a.MCO,
    TMSIS_REC_CNT,
    TMSIS_CRITICAL, 
    TMSIS_HIGH, 
    TMSIS_MEDIUM, 
    NOT_SET,
    OVERALL_STATUS 
from
(
select MCO, SUM(PRI_TMSIS_REC_CNT) TMSIS_REC_CNT
from priority_sums
group by MCO
) a
join
(
select
MCO, 
"'Critical'"   AS TMSIS_CRITICAL, 
"'High'"       AS TMSIS_HIGH, 
"'Medium'"     AS TMSIS_MEDIUM, 
"'Not Set'"    AS NOT_SET
from ( 
    select MCO, PRIORITY, PCT_PF_MEASURE
    from priority_sums
    )
  PIVOT (
    MAX(PCT_PF_MEASURE) FOR PRIORITY IN ('Critical', 'High', 'Medium', 'Not Set')
  )
)  b
on a.MCO = b.MCO
join 
(
-- overall_pct
select MCO, CASE WHEN MEAS = 0 THEN 0 ELSE PF/MEAS END OVERALL_STATUS
from ( 
    select MCO, SUM(PF_SUM) PF, SUM(MEAS_COUNT) MEAS
    from priority_sums
    group by MCO
     )
) c
on a.MCO = c.MCO

order by a.MCO

;
