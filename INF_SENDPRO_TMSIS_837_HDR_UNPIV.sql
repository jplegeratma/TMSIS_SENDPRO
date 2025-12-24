
USE MHTEAM.DWDQ;

DROP VIEW INF_SENDPRO_TMSIS_837_HDR_UNPIV;
    
CREATE VIEW INF_SENDPRO_TMSIS_837_HDR_UNPIV AS

SELECT DISTINCT RUN_DATE, CLAIM_LEG_TYPE, A.CDE_ENTITY_MODEL, A.CDE_ENC_MCO, A.CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, A.MD_BATCH_SEQ, MEASURE, TYPE, REC_CNT,
--s.FILE_NAME, s.PROCESS_START_TM, 
L.BENCHMARK_THRESHOLD, L.PRIORITY, TMSIS_CLAIM_TYPE, TMSIS_CLAIM_TYPE_DSC
FROM (

SELECT DISTINCT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MD_BATCH_SEQ, MEASURE, TYPE, REC_CNT
FROM (
    SELECT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MD_BATCH_SEQ, MEASURE, TYPE, COUNT(TYPE) AS REC_CNT
    FROM (
        SELECT RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MD_BATCH_SEQ, MEASURE, TYPE
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
                IND_CROSSOVER,
                MD_BATCH_SEQ,
                PATIENTSTATUSCODE1X AS Patient_Status_Code,
                MEMBERID1X AS MSIS_Identification_Number,
                ADJUDICATIONDATEHDRX AS Adjudication_Date_Header,
                ADJUDICATIONDATEDTLX AS Adjudication_Date_Detail,
                PAIDHDRSNOLINES1X AS Paid_Hdrs_No_Lines,
                DENIEDHDRSNOLINES1X AS Denied_Hdrs_No_Lines,
                PAIDHDRSNONONDENIEDLINES1X AS Paid_Hdrs_No_Non_Denied_Lines,
                FROMSERVICEDATE1X AS Beginning_Date_of_Service,
                TOSERVICEDATE1X AS  Ending_Date_of_Service,
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
        ) AS INF_B_SENDPRO_TMSIS_837_UNPIV
    )
    GROUP BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MD_BATCH_SEQ, MEASURE, TYPE
)
ORDER BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MD_BATCH_SEQ, MEASURE, TYPE

) AS A
--LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_STATISTIC S ON A.MD_BATCH_SEQ = s.MD_BATCH_SEQ_SPRO
LEFT JOIN MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_LOOKUP L ON A.MEASURE = L.BENCHMARK;

----------------

DROP VIEW INF_SENDPRO_TMSIS_837_HDR_UNPIV_DETAIL;

CREATE VIEW INF_SENDPRO_TMSIS_837_HDR_UNPIV_DETAIL
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
               a.IND_CROSSOVER,
               a.MD_BATCH_SEQ, 
               a.MEASURE, 
               a.TYPE, 
               a.NUM_ICN, 
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
               IND_CROSSOVER,
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
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
               IND_CROSSOVER,
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN, 
                                          RANK ()
                                            OVER (PARTITION BY RUN_DATE,
                                                               CLAIM_LEG_TYPE,
                                                               CDE_ENTITY_MODEL, 
                                                               CDE_ENC_MCO, 
                                                               CDE_ENC_ACO,
                                                               CLAIM_TYPE,
                                                               CDE_CLM_DISPOSITION,
                                                               CDE_CLM_STATUS,
                                                               IND_CROSSOVER,
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
                                                               IND_CROSSOVER,
                                                               MD_BATCH_SEQ,
                                                               MEASURE,
                                                               TYPE,
                                                               NUM_ICN)    AS rnk
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
               IND_CROSSOVER, 
               MD_BATCH_SEQ, 
               MEASURE, 
               TYPE, 
               NUM_ICN

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
                IND_CROSSOVER,
                MD_BATCH_SEQ,
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
                CLAIMALLOWABLEAMOUNT1X AS Allowed_Amount,
                NUM_ICN
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
) AS UNPIV_HDR
ORDER BY RUN_DATE, CLAIM_LEG_TYPE, CDE_ENTITY_MODEL, CDE_ENC_MCO, CDE_ENC_ACO, CLAIM_TYPE, CDE_CLM_DISPOSITION, CDE_CLM_STATUS, IND_CROSSOVER, MEASURE, TYPE

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
                                                               IND_CROSSOVER,
                                                               MEASURE,
                                                               TYPE,
                                                               NUM_ICN,
                                                               RNK
) AS A
--LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_STATISTIC S ON A.MD_BATCH_SEQ = s.MD_BATCH_SEQ_SPRO;

