
USE MHTEAM.DWDQ;

DROP VIEW INF_SENDPRO_TMSIS_837_UNPIV;

CREATE VIEW INF_SENDPRO_TMSIS_837_UNPIV AS

SELECT DISTINCT RUN_DATE, CLAIM_LEG_TYPE, A.CDE_ENTITY_MODEL, A.CDE_ENC_MCO, A.CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, A.MD_BATCH_SEQ, MEASURE, TYPE, REC_CNT,
--s.FILE_NAME, s.PROCESS_START_TM, 
L.BENCHMARK_THRESHOLD
FROM (

SELECT DISTINCT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MD_BATCH_SEQ, MEASURE, TYPE, REC_CNT
FROM (
    SELECT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MD_BATCH_SEQ, MEASURE, TYPE, COUNT(TYPE) AS REC_CNT
    FROM (
        SELECT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MD_BATCH_SEQ, MEASURE, TYPE
        FROM (
            SELECT
                RUN_DATE,
                CLAIM_LEG_TYPE,
                CDE_ENTITY_MODEL, 
                CDE_ENC_MCO, 
                CDE_ENC_ACO, 
                CLAIM_TYPE,
                CDE_CLM_DISPOSITION,
                CDE_CLM_STATUS,
                MD_BATCH_SEQ,
                PATIENTSTATUSCODE1X AS Patient_Status_Code,
                MEMBERID1X AS Member_ID,
                FROMSERVICEDATE1X AS Statement_Date,
                TOSERVICEDATE1X AS To_Service_Date,
                PRESCRIPTIONFILLDATE1X AS Prescription_Fill_Date,
                BILLINGPROVIDERNPI1X AS Billing_Provider_NPI,
                BILLINGPROVIDERINTERNALID1X AS Billing_Provider_Internal_Address_Location,
                CLAIMBILLEDAMOUNT1X AS Billed_Amount,
                ACCOMREVENUECODE1X AS Accomodation_Revenue_Code,
                AMTPAIDMCAREHDR1X AS Amount_Paid_Medicare_HDR,
                AMTPAIDMCAREDTL1X AS Amount_Paid_Medicare_DTL,
                AMTPAIDMCAREHDRLTXOVER1X AS Amount_Paid_Medicare_LT_Xover,
                AMTPAIDCODEDMCAREHDRXOVER1X AS Amount_Paid_Medicare_XOver_Missing,
                AMTPAIDCODEDMCAREHDRNONXOVER1X AS Amount_Paid_Medicare_Non_XOver_WData,
                ATTENDINGPROVIDERINTERNALID1X AS Attending_Provider_Internal_ID,
                ATTENDINGPROVIDERNPI1X AS Attending_Provider_NPI,
                TYPEOFADMISSION1X AS Admission_Type_Code,
                CLAIMBILLEDAMOUNTRX1X AS Billed_Amount_RX,
                BILLINGPROVIDERTAXONOMY1X AS Billing_Provider_Taxonomy,
                BILLINGPROVIDERTYPE1X AS Billing_Provider_Type,
                BRANDGENERICIND1X AS Brand_Generic_Ind,
                COMPOUNDDRUGIND1X AS Compound_Drug_Ind,
                MEDICAIDCOVINPATIENTDAYS1X Medicaid_Coverage_Inpatient_Days,
                PRESCRIBINGPROVIDERINTERNALID1X AS Prescribing_Provider_Internal_ID,
                PRESCRIBINGPROVIDERNPI1X AS Prescribing_Provider_NPI,
                REBATEELIGIBLEIND1X AS Rebate_Eligible_Indicator,
                REFERRINGPROVIDERINTERNALID1X AS Referring_Provider_Internal_ID,
                REFERRINGPROVIDERNPI1X AS Referring_Provider_NPI,
                SERVICINGPROVIDERINTERNALID1X AS Servicing_Provider_Internal_Address_Location,
                CLAIMALLOWABLEAMOUNT1X AS Allowed_Amount
            FROM MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837
        )
        UNPIVOT (
            TYPE
            FOR MEASURE IN (
                Patient_Status_Code,
                Member_ID,
                Statement_Date,
                To_Service_Date,
                Prescription_Fill_Date,
                Billing_Provider_NPI,
                Billing_Provider_Internal_Address_Location,
                Billed_Amount,
                Accomodation_Revenue_Code,
                Amount_Paid_Medicare_HDR,
                Amount_Paid_Medicare_DTL,
                Amount_Paid_Medicare_LT_Xover,
                Amount_Paid_Medicare_XOver_Missing,
                Amount_Paid_Medicare_Non_XOver_WData,
                Attending_Provider_Internal_ID,
                Attending_Provider_NPI,
                Admission_Type_Code,
                Billed_Amount_RX,
                Billing_Provider_Taxonomy,
                Billing_Provider_Type,
                Brand_Generic_Ind,
                Compound_Drug_Ind,
                Medicaid_Coverage_Inpatient_Days,
                Prescribing_Provider_Internal_ID,
                Prescribing_Provider_NPI,
                Rebate_Eligible_Indicator,
                Referring_Provider_Internal_ID,
                Referring_Provider_NPI,
                Servicing_Provider_Internal_Address_Location,
                Allowed_Amount
            )
        ) AS INF_B_SENDPRO_TMSIS_837_UNPIV
    )
    GROUP BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MD_BATCH_SEQ, MEASURE, TYPE
)
ORDER BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MD_BATCH_SEQ, MEASURE, TYPE

) AS A
--LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_STATISTIC S ON A.MD_BATCH_SEQ = s.MD_BATCH_SEQ_SPRO
LEFT JOIN MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_LOOKUP L ON A.MEASURE = L.BENCHMARK;

----------------

DROP VIEW INF_SENDPRO_TMSIS_837_UNPIV_DETAIL;

CREATE VIEW INF_SENDPRO_TMSIS_837_UNPIV_DETAIL
AS

SELECT DISTINCT 
               a.RUN_DATE,
               a.CLAIM_LEG_TYPE, 
               a.CDE_ENTITY_MODEL, 
               a.CDE_ENC_MCO, 
               a.CDE_ENC_ACO, 
               a.CLAIM_TYPE, 
               a.CDE_CLM_DISPOSITION, 
               a.CDE_CLM_STATUS, 
               a.MD_BATCH_SEQ, 
               a.MEASURE, 
               a.TYPE, 
               a.NUM_ICN, 
               a.NUM_DTL,
               a.RNK--,
--               s.FILE_NAME, 
--               s.PROCESS_START_TM
FROM (


-- limit rank to 10 lines
SELECT DISTINCT 
               RUN_DATE,
               CLAIM_LEG_TYPE, 
               CDE_ENTITY_MODEL, 
               CDE_ENC_MCO, 
               CDE_ENC_ACO, 
               CLAIM_TYPE, 
               CDE_CLM_DISPOSITION, 
               CDE_CLM_STATUS, 
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
               NUM_DTL,
               RNK

FROM (
-- rank
  SELECT 
               RUN_DATE, 
               CLAIM_LEG_TYPE,
               CDE_ENTITY_MODEL, 
               CDE_ENC_MCO, 
               CDE_ENC_ACO, 
               CLAIM_TYPE, 
               CDE_CLM_DISPOSITION, 
               CDE_CLM_STATUS, 
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
               NUM_DTL,
                                          RANK ()
                                            OVER (PARTITION BY RUN_DATE,
                                                               CLAIM_LEG_TYPE,
                                                               CDE_ENTITY_MODEL, 
                                                               CDE_ENC_MCO, 
                                                               CDE_ENC_ACO,
                                                               CLAIM_TYPE,
                                                               CDE_CLM_DISPOSITION,
                                                               CDE_CLM_STATUS,
                                                               MD_BATCH_SEQ,
                                                               MEASURE
                                                  ORDER BY
                                                               RUN_DATE,
                                                               CLAIM_LEG_TYPE,
                                                               CDE_ENTITY_MODEL, 
                                                               CDE_ENC_MCO, 
                                                               CDE_ENC_ACO,
                                                               CLAIM_TYPE,
                                                               CDE_CLM_DISPOSITION,
                                                               CDE_CLM_STATUS,
                                                               MD_BATCH_SEQ,
                                                               MEASURE,
                                                               TYPE,
                                                               NUM_ICN,
                                                               NUM_DTL)    AS rnk

  FROM (

-- only first claim line

SELECT 

               RUN_DATE,
               CLAIM_LEG_TYPE, 
               CDE_ENTITY_MODEL, 
               CDE_ENC_MCO, 
               CDE_ENC_ACO, 
               CLAIM_TYPE, 
               CDE_CLM_DISPOSITION, 
               CDE_CLM_STATUS, 
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
               NUM_DTL
  FROM (

-- core unpiv

        SELECT 
               RUN_DATE,
               CLAIM_LEG_TYPE, 
               CDE_ENTITY_MODEL, 
               CDE_ENC_MCO, 
               CDE_ENC_ACO, 
               CLAIM_TYPE, 
               CDE_CLM_DISPOSITION, 
               CDE_CLM_STATUS, 
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
               NUM_DTL

        FROM (
            SELECT
                RUN_DATE,
                CLAIM_LEG_TYPE,
                CDE_ENTITY_MODEL, 
                CDE_ENC_MCO, 
                CDE_ENC_ACO, 
                CLAIM_TYPE,
                CDE_CLM_DISPOSITION,
                CDE_CLM_STATUS,
                MD_BATCH_SEQ,
                PATIENTSTATUSCODE1X AS Patient_Status_Code,
                MEMBERID1X AS Member_ID,
                FROMSERVICEDATE1X AS Statement_Date,
                TOSERVICEDATE1X AS To_Service_Date,
                PRESCRIPTIONFILLDATE1X AS Prescription_Fill_Date,
                BILLINGPROVIDERNPI1X AS Billing_Provider_NPI,
                BILLINGPROVIDERINTERNALID1X AS Billing_Provider_Internal_Address_Location,
                CLAIMBILLEDAMOUNT1X AS Billed_Amount,
                ACCOMREVENUECODE1X AS Accomodation_Revenue_Code,
                AMTPAIDMCAREHDR1X AS Amount_Paid_Medicare_HDR,
                AMTPAIDMCAREDTL1X AS Amount_Paid_Medicare_DTL,
                AMTPAIDMCAREHDRLTXOVER1X AS Amount_Paid_Medicare_LT_Xover,
                AMTPAIDCODEDMCAREHDRXOVER1X AS Amount_Paid_Medicare_XOver_Missing,
                AMTPAIDCODEDMCAREHDRNONXOVER1X AS Amount_Paid_Medicare_Non_XOver_WData,
                ATTENDINGPROVIDERINTERNALID1X AS Attending_Provider_Internal_ID,
                ATTENDINGPROVIDERNPI1X AS Attending_Provider_NPI,
                TYPEOFADMISSION1X AS Admission_Type_Code,
                CLAIMBILLEDAMOUNTRX1X AS Billed_Amount_RX,
                BILLINGPROVIDERTAXONOMY1X AS Billing_Provider_Taxonomy,
                BILLINGPROVIDERTYPE1X AS Billing_Provider_Type,
                BRANDGENERICIND1X AS Brand_Generic_Ind,
                COMPOUNDDRUGIND1X AS Compound_Drug_Ind,
                MEDICAIDCOVINPATIENTDAYS1X Medicaid_Coverage_Inpatient_Days,
                PRESCRIBINGPROVIDERINTERNALID1X AS Prescribing_Provider_Internal_ID,
                PRESCRIBINGPROVIDERNPI1X AS Prescribing_Provider_NPI,
                REBATEELIGIBLEIND1X AS Rebate_Eligible_Indicator,
                REFERRINGPROVIDERINTERNALID1X AS Referring_Provider_Internal_ID,
                REFERRINGPROVIDERNPI1X AS Referring_Provider_NPI,
                SERVICINGPROVIDERINTERNALID1X AS Servicing_Provider_Internal_Address_Location,
                CLAIMALLOWABLEAMOUNT1X AS Allowed_Amount,
                NUM_ICN,
                NUM_DTL
            FROM MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837
        )
        UNPIVOT (
            TYPE
            FOR MEASURE IN (
                Patient_Status_Code,
                Member_ID,
                Statement_Date,
                To_Service_Date,
                Prescription_Fill_Date,
                Billing_Provider_NPI,
                Billing_Provider_Internal_Address_Location,
                Billed_Amount,
                Accomodation_Revenue_Code,
                Amount_Paid_Medicare_HDR,
                Amount_Paid_Medicare_DTL,
                Amount_Paid_Medicare_LT_Xover,
                Amount_Paid_Medicare_XOver_Missing,
                Amount_Paid_Medicare_Non_XOver_WData,
                Attending_Provider_Internal_ID,
                Attending_Provider_NPI,
                Admission_Type_Code,
                Billed_Amount_RX,
                Billing_Provider_Taxonomy,
                Billing_Provider_Type,
                Brand_Generic_Ind,
                Compound_Drug_Ind,
                Medicaid_Coverage_Inpatient_Days,
                Prescribing_Provider_Internal_ID,
                Prescribing_Provider_NPI,
                Rebate_Eligible_Indicator,
                Referring_Provider_Internal_ID,
                Referring_Provider_NPI,
                Servicing_Provider_Internal_Address_Location,
                Allowed_Amount
            )
) AS UNPIV_DTL
ORDER BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, MEASURE, TYPE

-- only first claim line
)
WHERE NUM_DTL = 1    
)
-- add rank
)
-- limit rank to 10 line
WHERE rnk <= 10

ORDER BY 
                                                               RUN_DATE,
                                                               CLAIM_LEG_TYPE,
                                                               CDE_ENTITY_MODEL, 
                                                               CDE_ENC_MCO, 
                                                               CDE_ENC_ACO,
                                                               CLAIM_TYPE,
                                                               CDE_CLM_DISPOSITION,
                                                               CDE_CLM_STATUS,
                                                               MEASURE,
                                                               TYPE,
                                                               NUM_ICN,
                                                               RNK
) AS A
--LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_STATISTIC S ON A.MD_BATCH_SEQ = s.MD_BATCH_SEQ_SPRO;

