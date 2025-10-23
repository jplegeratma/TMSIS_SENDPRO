-- TMSIS 837I EXTRACT SCRIPT

-- DROP TABLE MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837I;

-- CREATE TABLE MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837I AS

-- TRUNCATE TABLE MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837I;

--INSERT INTO MHTEAM.DWDQ.INF_B_SENDPRO_TMSIS_837I
SELECT DISTINCT
    RUN_DATE,
    NUM_ICN,
    NUM_DTL,
    CDE_ENTITY_MODEL,
    CDE_ENC_MCO,
    CDE_ENC_ACO,
    ID_SUBMITTER,
    DOS_FROM_DT,
    Claim_Type,
    CDE_CLM_STATUS,
    CDE_CLM_DISPOSITION,
    IND_OFFSET,
    WH_FROM_DT,
    MD_BATCH_SEQ,


/*
2.001.31	Measure	Critical	 % of claims for which Patient Status is NOT 'still a patient' but are missing Discharge Date	5%	
IP	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims- claims missing Discharge Date and Patient Status is NOT 'still a patient' 	IN SENDPRO TARGET DASHBOARD

from SCO
case when Claim_Type IN('I','O') AND cde_patient_status not in ('+', '-', ' ') then 1 else 0 end as CDE_PATIENT_STATUS1,
case when (Claim_Type='I' AND substr(cde_type_of_bill_enc,1,2) <> '21' and SUBSTR(DSC_PATIENT_STATUS,1,2) NOT BETWEEN '30' AND '39')
AND (MX.DISCHARGE_DT IS NOT NULL and discharge_dt >= admit_dt) THEN 1 else 0 end DISCHARGE_DT1,

?? showuld we be using just 1 or 0 for valid/invalid or should we do VALID/INVALID/NOT APP/NULL ?

*/

-- DI
    CASE WHEN Claim_Type IN ('I')
    AND CDE_CLM_DISPOSITION IN ('O','R')
    AND IND_CROSSOVER = 'N'
    AND CDE_CLM_STATUS = 'P'
	AND PatientStatusCode IS NOT NULL
    AND PatientStatusCode IN (SELECT CDE_CHAR FROM MHDWQA.NW.NW_SUP_CODE_REF WHERE CDE_GROUP = 'CDE_PATIENT_STATUS' AND CDE_CHAR NOT IN ('#','**','+','-','$','  '))
    AND PatientStatusCode <> '30' -- STILL PATIENT
    AND (DISCHARGE_DT IS NOT NULL and DISCHARGE_DT >= ADMIT_DT)
        THEN 1 ELSE 0 END PatientStatusCode1,

--  Ex
    CASE WHEN Claim_Type NOT IN ('I') 
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN PatientStatusCode IS NULL THEN 'NULL'
        WHEN PatientStatusCode NOT IN (SELECT CDE_CHAR FROM MHDWQA.NW.NW_SUP_CODE_REF WHERE CDE_GROUP = 'CDE_PATIENT_STATUS' 
            AND CDE_CHAR NOT IN ('#','**','+','-','$','  '))
        THEN 'NULL'
        WHEN (PatientStatusCode <> '30') AND (DISCHARGE_DT IS NULL OR DISCHARGE_DT < ADMIT_DT) THEN 'INVALID'
        ELSE 'VALID'
    END AS PatientStatusCode1X,

/*

2.001.32	Measure	Critical	 % missing: MSIS-IDENTIFICATION-NUM	2%	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims - claims missing: MSIS-IDENTIFICATION-NUM	SIMILAR IN SENDPRO TARGET DASHBOARD
*/

    CASE WHEN Claim_Type NOT IN ('I','O','M','L','H','P','Q') 
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN FACT_MEM_SEQ IS NULL AND DTL_FACT_MEM_SEQ IS NULL THEN 'NULL'
        WHEN FACT_MEM_SEQ <= 0 AND DTL_FACT_MEM_SEQ <= 0 THEN 'INVALID'
		WHEN  (
              ( NOT EXISTS (SELECT ID_MEDICAID from MHDWQA.NW.NW_MEMBER mem WHERE FACT_MEM_SEQ = mem.MEM_SEQ AND ID_MEDICAID NOT IN ('#','+','-',' ')) )
          AND ( NOT EXISTS (SELECT ID_MEDICAID from MHDWQA.NW.NW_MEMBER mem WHERE DTL_FACT_MEM_SEQ = mem.MEM_SEQ AND ID_MEDICAID NOT IN ('#','+','-',' '))) 
             )
        THEN 'INVALID'
        ELSE 'VALID'
    END AS MemberID1X,

/*
2.001.33	Measure	Critical	% of claim lines with no corresponding claim header	0%	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounters, Original and Replacement, Non-Crossover, Paid Claims - claim lines with no corresponding claim header	Rima to check but this might be fixed with SendPro structure

?? this is not at the claim line level... we are at the claim level with line details joined in... so we can just see if there are any lines without a header... 
if there is no header there will be no rows returned

    CASE WHEN Claim_Type NOT IN ('I','O','M','L','P') 
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'Y'
        OR CDE_CLM_STATUS != 'P'
    THEN 'NOT APP'


select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
RIGHT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    ON inst.NUM_ICN = dtl.NUM_ICN
WHERE inst.NUM_ICN IS NULL;

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
WHERE NOT EXISTS (
    SELECT inst.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
    WHERE inst.NUM_ICN = dtl.NUM_ICN
);

*/


/*
2.001.36	Measure	Critical	 % of claim header record segments missing ADJUDICATION-DATE	0%	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claim, 
claim header record segments missing ADJUDICATION-DATE	
Record segment just references the line, header or other segment table used. So this just means claim headers.

?? WH_FROM_DT 

from Final
54	MPT_SENDPRO_Validate_Adjudication_Date	NCPDP:
    Step 1: Lookup SENDPRO.RAW_SPRO_NCPDP_CLAIM OrigClm based on SENDPRO.RAW_SPRO_NCPDP_CLAIM newClaim. TransIDCrossRef = OrigClm. TransID and Obtain AdjudicationDate
    Step 2: If newClaim.AdjudicationDate > OrigClm. AdjudicationDate Then 1 else 0 end

from RAW
left join MHDWQA.SENDPRO.RAW_SPRO_837I_CLAIM_SVCLN_ADJUDICATION_DTL as a
on  h."FileName" = a."FileName"
-- and h."SubmitterID"        = a."SubmitterID"
and h."PatientControlNum"  = a."PatientControlNum"
and d."NumDtl"             = a."NumDtl"

*/




/*
2.001.37	Measure	Critical	% of claim line record segments missing ADJUDICATION-DATE	0%	"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claim line record segments missing ADJUDICATION-DATE	"JPR - We should dicuss.  I was thinking keep at month level. Also, there are too many metrics so we need a rollup dashboard that can be drill in to the measure by priority.  See Moch Up Sheet.
Record segment just references the line, header or other segment table used. So this just means claim headers."

?? WH_FROM_DT 

*/


/*
2.001.38	Measure	Critical	 % of claim headers that have no corresponding claim lines	0%	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claim headers that have no corresponding claim lines	Define this in regards to SendPro and exceptions

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    ON inst.NUM_ICN = dtl.NUM_ICN
WHERE dtl.NUM_ICN IS NULL;

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE NOT EXISTS (
    SELECT dtl.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    WHERE inst.NUM_ICN = dtl.NUM_ICN
);

*/


/*
2.001.39	Measure	Critical	 % of denied claim headers that have no corresponding claim lines	0%	
"IP LT OT RX"	
This measure should show % of denied claim headers that have no corresponding claim lines	Define this in regards to SendPro and exceptions

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE CDE_CLM_STATUS = 'D';

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    ON inst.NUM_ICN = dtl.NUM_ICN
WHERE dtl.NUM_ICN IS NULL
AND inst.CDE_CLM_STATUS = 'D';

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE NOT EXISTS (
    SELECT dtl.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    WHERE inst.NUM_ICN = dtl.NUM_ICN
)
AND inst.CDE_CLM_STATUS = 'D';

*/


/*
2.001.40	Measure	Critical	 % of denied claim lines that have no corresponding claim header	0%	
"IP LT OT RX"	
This measure should show % of denied claim lines that have no corresponding claim header	Define this in regards to SendPro and exceptions

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
WHERE CDE_CLM_STATUS = 'D';

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
RIGHT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    ON inst.NUM_ICN = dtl.NUM_ICN
WHERE inst.NUM_ICN IS NULL
AND dtl.CDE_CLM_STATUS = 'D';

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
WHERE NOT EXISTS (
    SELECT inst.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
    WHERE inst.NUM_ICN = dtl.NUM_ICN
)
AND dtl.CDE_CLM_STATUS = 'D';

*/


/*
2.001.41	Measure	Critical	 % of claim headers that have no corresponding non-denied claim lines	0%	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claim headers that have no corresponding non-denied claim lines	Define this in regards to SendPro and exceptions

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE CDE_CLM_STATUS != 'D';

select count(1)
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE NOT EXISTS (
    SELECT dtl.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    WHERE inst.NUM_ICN = dtl.NUM_ICN
    AND dtl.CDE_CLM_STATUS != 'D'
);

-- validation

select *
from MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
where dtl.NUM_ICN in (

select inst.NUM_ICN
FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
WHERE NOT EXISTS (
    SELECT dtl.NUM_ICN 
    FROM MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    WHERE inst.NUM_ICN = dtl.NUM_ICN
    AND dtl.CDE_CLM_STATUS != 'D'
)

and dtl.CDE_CLM_STATUS != 'D'
);

*/


/*
2.001.42	Measure	Critical	 % of claims missing BEGINNING-DATE-OF-SERVICE	2%	
"LT IP OT"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claims missing BEGINNING-DATE-OF-SERVICE	

-- this is taken from Final
*/

    CASE WHEN Claim_Type NOT IN ('I','O','M','L','H') 
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN DOS_FROM_DT IS NULL AND DTL_DOS_FROM_DT IS NULL THEN 'NULL'
        WHEN DOS_FROM_DT = '1900-01-01' AND DTL_DOS_FROM_DT = '1900-01-01' THEN 'INVALID'
        ELSE 'VALID'
    END AS FromServiceDate1X,

/*
2.001.43	Measure	Critical	 % of claims missing: ENDING-DATE-OF-SERVICE	2%	
"LT IP OT"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claims missing: ENDING-DATE-OF-SERVICE	

-- this is taken from Final
*/

    CASE WHEN Claim_Type NOT IN ('I','O','M','L','H') 
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN DOS_TO_DT IS NULL AND DTL_DOS_TO_DT IS NULL THEN 'NULL'
        WHEN DOS_TO_DT = '1900-01-01' AND DTL_DOS_TO_DT = '1900-01-01' THEN 'INVALID'
        ELSE 'VALID'
    END AS ToServiceDate1X,


/*
2.001.44	Measure	Critical	 % of claims missing: PRESCRIPTION-FILL-DATE	2%	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims, claims missing: PRESCRIPTION-FILL-DATE	

?? DTE_DISPENSE not in SPRO_B_ENC_CLAIM_PHRM_LEG_HIST
Either use ADJUDICATION_DT or DOS_FROM_DT?

*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN DOS_FROM_DT IS NULL THEN 'NULL'
        WHEN DOS_FROM_DT = '1900-01-01' THEN 'INVALID'
        ELSE 'VALID'
    END AS PrescriptionFillDate1X,


/*
2.001.01	Measure	High	 % of claim headers with Billing Provider NPI Number in an invalid format	<= 1%	
RX	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Adjustment, Paid Claims, claim headers with invalid formatting of Billing Provider NPI within.	
*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
         WHEN 
         (
               ((billing_ProviderNPI IS NULL) OR billing_ProviderNPI IN ('0','000000000','0000000000') ) 
           AND ((dtl_billing_ProviderNPI IS NULL) OR dtl_billing_ProviderNPI IN ('0','000000000','0000000000') )
         )            
            THEN 'NULL'
		 WHEN 
         (
              (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = billing_ProviderNPI))
          AND (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = dtl_billing_ProviderNPI)) 
         )
         THEN 'INVALID'
         ELSE 'VALID' 
    END AS BillingProviderNPI1X,

/*
2.001.06	Measure	High	% missing: BILLING-PROV-NUM 	<= 2% missing	
"IP OT RX"	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Billing Provider PID/SL.	

Final - Target
56	MPT_SENDPRO_ProviderPIDSL_Valid	Validity of  PIDSL is determined by performing a look up to the following tables 
    1.	SENDPRO.SPRO_B_ENC837_PROVIDER_HIST on the field ID_PROVIDER
    If valid then 1 else 0

?? Validate how this validates PIDSL
*/


    CASE WHEN Claim_Type NOT IN ('I','O','M','H','P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
         WHEN (billing_ProviderInternalId IS NULL) AND (dtl_billing_ProviderInternalId IS NULL) THEN 'NULL'
		 WHEN ( 
               (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = billing_ProviderInternalId) )
           AND (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = dtl_billing_ProviderInternalId) )
         )
         THEN 'INVALID'
         ELSE 'VALID' 
    END AS BillingProviderInternalId1X,


/*
2.001.21	Measure	High	% missing: TOT-BILLED-AMT	<= 2% missing	
"IP LT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Total Billed Amount	

from Dashboard Data Needed
The total amount should be the sum of each of the billed amounts submitted at the claim detail level.

If TYPE-OF-CLAIM = "4"(Medicaid or Medicaid-expansion Service Tracking Claim), then TOT-BILLED-AMT must = "00000000".
If TYPE-OF-CLAIM = 3, C, W (encounter record) this field should either be zero-filled or contain the amount paid by the plan to the provider. 

?? validating header AMT_BILLED = SUM of detail AMT_BILLED will require procesing at higher level of detail

?? TYPE-OF-CLAIM
?? If we assume that this is encounter record then the Target logic should be ok - except for header to detail check

*/

    CASE WHEN Claim_Type NOT IN ('I','L','P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
    WHEN AMT_BILLED IS NULL AND DTL_AMT_BILLED IS NULL THEN 'NULL'
    WHEN AMT_BILLED < 0 OR DTL_AMT_BILLED < 0 THEN 'INVALID'
    ELSE 'VALID'
END AS ClaimBilledAmount1X,


/*
2.001.22	Measure	High	% of claim headers with any accommodation revenue codes	>= 85% present	
IP	
This measure should show % of Medicaid Encounter: Original, Non-Crossover, Paid Claims, claim headers with Accomodation Rev Codes	


from Dashboard Data Needed
NW_B_REVENUE_CODE.CDE_REVENUE
Join on REV_SEQ from SPRO_B_ENC_INST_INFO_DTL_HIST
Accomodation Revenue Code Values = 100-219

from Target
24	MPT_SENDPRO_ServiceLineRevenueCode_Valid	If valid based on the lookup against the CDE_CHAR from NW_SUP_CODE_REF where CDE_GROUP='CDE_REVENUE'  then 1 else 0

?? This is at the claim header level but uses detail revenue codes... so if any detail line has a valid code then the header is valid? And needs to be aggregated.
*/

    CASE WHEN Claim_Type NOT IN ('I')
        OR CDE_CLM_DISPOSITION NOT IN ('O')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN DTL_REV_SEQ IS NULL THEN 'NULL'
    WHEN DTL_REV_SEQ NOT IN (SELECT REV_SEQ FROM MHDWQA.NW.NW_B_REVENUE_CODE WHERE REV_SEQ = DTL_REV_SEQ AND CDE_REVENUE BETWEEN '100' AND '219') THEN 'INVALID'
    ELSE 'VALID'
    END AS RevenueCode1X,

/*
2.001.23	Measure	High	% of claim headers with Total Medicaid Paid Amount = $0 or missing	<= 10% missing	
IP	
This measure should show % of S-CHIP Encounter: Original, Non-Crossover, Paid Claims, claim headers with Total Medicaid Paid Amount of $0 or are missing. 	

*/

    CASE WHEN Claim_Type NOT IN ('I','L')
        OR CDE_CLM_DISPOSITION NOT IN ('O')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN AMT_PAID_MCARE IS NULL OR AMT_PAID_MCARE <= 0 THEN 'INVALID' 
    ELSE 'VALID'
    END AS AmtPaidMcareHdr1X,


/*
2.001.24	Measure	High	% of claim headers with Total Medicaid Paid Amount = $0 or missing	<= 10% missing	
IP	
This measure should show % of S-CHIP Encounter: Original, Non-Crossover, Paid Claims, claim headers with Total Medicaid Paid Amount of $0 or are missing. 	

?? Assuming this is for DTL, otherwise this is the same as 2.001.23
*/

    CASE WHEN Claim_Type NOT IN ('I','L')
        OR CDE_CLM_DISPOSITION NOT IN ('O')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN DTL_AMT_PAID_MCARE IS NULL OR DTL_AMT_PAID_MCARE <= 0 THEN 'INVALID' 
    ELSE 'VALID'
    END AS AmtPaidMcareDtl1X,


/*
2.001.25	Measure	High	% of claim headers with Total Medicaid Paid Amount = $0 or missing - non-Crossover Paid claims	<= 10% missing	
LT 	
This measure should show % of Medicaid Encounter: Original, non-Crossover, Paid Claims, claim headers with Total Medicaid Paid Amount of $0 or are missing.	

?? same as 23 but for LT - adding LT to 23
*/


/*
2.001.26	Measure	High	% of claim headers with Total Medicaid Paid Amount = $0 or missing - Crossover Paid claims	<= 40% missing	
LT 	
This measure should show % of Medicaid Encounter: Original, Crossover, Paid Claims, claim headers with Total Medicaid Paid Amount of $0 or are missing.	

LT Crossover
*/

    CASE WHEN Claim_Type NOT IN ('L')
        OR CDE_CLM_DISPOSITION NOT IN ('O')
        OR IND_CROSSOVER = 'Y'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN AMT_PAID_MCARE IS NULL OR AMT_PAID_MCARE <= 0 THEN 'INVALID' 
    ELSE 'VALID'
    END AS AmtPaidMcareHdrLTXOver1X,

/*
2.001.29	Measure	High	% of crossover claim headers where MEDICARE-PAID-AMT, TOT-MEDICARE-COINS-AMT, and TOT-MEDICARE-DEDUCTIBLE-AMT are 0 or missing	<= 10% missing	
"IP LT OT"	
This measure should show % of Medicaid and S-CHIP Encounter: Non-void, Crossover, Paid Claims, claim headers where MEDICARE-PAID-AMT, TOT-MEDICARE-COINS-AMT, and TOT-MEDICARE-DEDUCTIBLE-AMT are 0 or missing.	

*/

    CASE WHEN Claim_Type NOT IN ('I','L','O','M','H')
        OR CDE_CLM_DISPOSITION IN ('V')
        OR IND_CROSSOVER = 'Y'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN (  (AMT_PAID_MCARE IS NULL OR AMT_PAID_MCARE <= 0) 
        AND (AMT_COINSURANCE_MCARE IS NULL OR AMT_COINSURANCE_MCARE <= 0)
        AND (AMT_DEDUCT_MCARE IS NULL OR AMT_DEDUCT_MCARE <= 0)
        ) THEN 'INVALID' 
    ELSE 'VALID'
    END AS AmtPaidCoDedMcareHdrXOver1X,

/*
2.001.30	Measure	High	% of non-crossover encounter claims where MEDICARE-PAID-AMT, TOT-MEDICARE-COINS-AMT, or TOT-MEDICARE-DEDUCTIBLE-AMT is non-zero	<= .01% present	
"IP LT OT RX"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Non-Crossover, Paid Claims  where MEDICARE-PAID-AMT, TOT-MEDICARE-COINS-AMT, and TOT-MEDICARE-DEDUCTIBLE-AMT is not 0.	
*/

    CASE WHEN Claim_Type NOT IN ('I','L','O','M','H','P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN (  (AMT_PAID_MCARE > 0) 
        OR  (AMT_COINSURANCE_MCARE > 0)
        OR  (AMT_DEDUCT_MCARE > 0)
        ) THEN 'INVALID' 
    ELSE 'VALID'
    END AS AmtPaidCoDedMcareHdrNonXOver1X,

/*
2.001.00	Measure	Medium	Average # ancillary codes on claims with ancillary codes	5-18 Ancillary codes	
IP	
This measure should show the AVE # of ancillary codes on Medicaid and S-CHIP Encounter: Original and Adjustment, Paid Claims with ancillary codes	

??What are the ancillary codes?
*/


/*
2.001.02	Measure	Medium	 % missing: ADMITTING-PROV-NUM	<= 2% missing	
IP	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing an Admitting Provider PID/SL.	

from dashboard data needed
ATTENDING_ENC_PRV_SEQ
Use this SEQ to match the ENC_PRV_SEQ in the SPRO_B_ENC_PROVIDER_HIST table and select ID_NPI for ADMITTING-PROV-NPI_NUM
*/


    CASE WHEN Claim_Type NOT IN ('I')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- like Target
        WHEN (attending_ProviderInternalId IS NULL) AND (dtl_attending_ProviderInternalId IS NULL) THEN 'NULL'
    	WHEN ( 
               (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = attending_ProviderInternalId) )
           AND (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = dtl_attending_ProviderInternalId) )
         )
         THEN 'INVALID'
         ELSE 'VALID' 
    END AS AttendingProviderInternalId1X,

/*
2.001.03	Measure	Medium	% missing: ADMITTING-PROV-NPI-NUM	<= 2% missing	
IP	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing an Admitting Provider NPI.	
*/

    CASE WHEN Claim_Type NOT IN ('I')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- like Target
         WHEN 
         (
               ((attending_ProviderNPI IS NULL) OR attending_ProviderNPI IN ('0','000000000','0000000000') ) 
           AND ((dtl_attending_ProviderNPI IS NULL) OR dtl_attending_ProviderNPI IN ('0','000000000','0000000000') )
         )            
            THEN 'NULL'
		 WHEN 
         (
              (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = attending_ProviderNPI))
          AND (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = dtl_attending_ProviderNPI)) 
         )
         THEN 'INVALID'
         ELSE 'VALID' 
    END AS AttendingProviderNPI1X,

/*
2.001.04	Measure	Medium	% missing: ADMISSION-TYPE 	<= 2% missing	
IP	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing an Admission Type.	

from final - target
38	MPT_SENDPRO_TypeOfAdmission_Valid	If valid based on the lookup against the CDE_CHAR from NW_SUP_CODE_REF where CDE_GROUP= ‘CDE_ADMIT_TYPE' for Type Of Admission

*/

    CASE WHEN Claim_Type NOT IN ('I')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'

-- from Final - Target
        WHEN CDE_ADMIT_TYPE IS NULL THEN 'NULL'
        WHEN CDE_ADMIT_TYPE NOT IN (SELECT CDE_CHAR FROM MHDWQA.NW.NW_SUP_CODE_REF WHERE CDE_GROUP = 'CDE_ADMIT_TYPE' AND CDE_CHAR NOT IN ('#','**','+','-','$','  ')) THEN 'INVALID'
        ELSE 'VALID'
    END AS TypeOfAdmission1X,

/*
2.001.05	Measure	Medium	 % missing: BILLED-AMT 	<= 2% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing the BILLED-AMT	

from Final - Target
55	MPT_SENDPRO_Validate_BilledAmount	If BILLED-AMT is null or less than zero then 0 else 1

?? This is similar to 2.001.21 but for RX only

*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
    WHEN AMT_BILLED IS NULL AND DTL_AMT_BILLED IS NULL THEN 'NULL'
    WHEN AMT_BILLED < 0 OR DTL_AMT_BILLED < 0 THEN 'INVALID'
    ELSE 'VALID'
END AS ClaimBilledAmount1X,
    
/*
2.001.07	Measure	Medium	 % missing: BILLING-PROV-TAXONOMY	<= 2% missing	
"IP LT OT"	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Billing Provider Taxonomy.	

*/

    CASE WHEN Claim_Type NOT IN ('I','L','O','M','H')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
		 WHEN 
         (
             (NOT EXISTS (SELECT tax.CDE_ENC_TAXONOMY from mhdwqa.SENDPRO.spro_b_enc_provider_hist as prv
         LEFT JOIN mhdwqa.SENDPRO.spro_b_enc_provider_taxonomy_hist tax ON prv.ENC_PRV_SEQ = tax.ENC_PRV_SEQ
         where BILLING_ENC_PRV_SEQ = prv.ENC_PRV_SEQ AND tax.CDE_ENC_TAXONOMY IS NOT NULL AND tax.CDE_ENC_TAXONOMY NOT IN ('#','+','-')))

         AND (NOT EXISTS (SELECT tax.CDE_ENC_TAXONOMY from mhdwqa.SENDPRO.spro_b_enc_provider_hist as prv
         LEFT JOIN mhdwqa.SENDPRO.spro_b_enc_provider_taxonomy_hist tax ON prv.ENC_PRV_SEQ = tax.ENC_PRV_SEQ
         where DTL_BILLING_ENC_PRV_SEQ = prv.ENC_PRV_SEQ AND tax.CDE_ENC_TAXONOMY IS NOT NULL AND tax.CDE_ENC_TAXONOMY NOT IN ('#','+','-')))
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS BillingProviderTaxonomy1X,

/*
2.001.08	Measure	Medium	 % missing: BILLING-PROV-TYPE 	<= 10% missing	
OT	
This measure should show the % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Billing Provider Type.	

from dashboard data needed

"All:
SPRO_B_ENC_PROVIDER_HIST.ENC_PRV_SEQ
SPRO_B_ENC_PROVIDER_HIST.CDE_ENC_PROV_TYPE
Phys:
SPRO_B_ENC_CLAIM_PROF_LEG_HIST.BILLING_ENC_PRV_SEQ
Dental:
SPRO_B_ENC_CLAIM_DNTL_LEG_HIST.BILLING_ENC_PRV_SEQ
OutP:
SPRO_B_ENC_CLAIM_INST_LEG_HIST.BILLING_ENC_PRV_SEQ"	

"Use the BILLING_ENC_PRV_SEQ from the SPRO_B_ENC_CLAIM_PROF_LEG_HIST, SPRO_B_ENC_CLAIM_DNTL_LEG_HIST, and  SPRO_B_ENC_CLAIM_INST_LEG_HIST tables 
to match the ENC_PRV_SEQ in the SPRO_B_ENC_PROVIDER_HIST table and select CDE_ENC_PROV_TYPE for the BILLING-PROV-TYPE
Use current Prov_Type crosswalk to map to CMS valid value.

If multiple values, pick the first one"

?? used Final code but logic may be more thorough

*/

    CASE WHEN Claim_Type NOT IN ('O','M','H')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target for Serving Provider Type
		 WHEN 
         (
              (NOT EXISTS (SELECT prv.CDE_ENC_PROV_TYPE from mhdwqa.SENDPRO.spro_b_enc_provider_hist as prv
         where BILLING_ENC_PRV_SEQ = prv.ENC_PRV_SEQ AND prv.CDE_ENC_PROV_TYPE IS NOT NULL AND prv.CDE_ENC_PROV_TYPE NOT IN ('#','+','-')))
          AND (NOT EXISTS (SELECT prv.CDE_ENC_PROV_TYPE from mhdwqa.SENDPRO.spro_b_enc_provider_hist as prv
            where DTL_BILLING_ENC_PRV_SEQ = prv.ENC_PRV_SEQ AND prv.CDE_ENC_PROV_TYPE IS NOT NULL AND prv.CDE_ENC_PROV_TYPE NOT IN ('#','+','-')))
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS BillingProviderType1X,


/*
2.001.09	Measure	Medium	 % missing: BRAND-GENERIC-IND 	<= 10% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing BRAND-GENERIC-IND	

?? how about standardizing this to 'Y' or 'N'  OR 'B' or 'G'
IND_GENERIC
*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
        WHEN (IND_GENERIC IS NULL) OR IND_GENERIC NOT IN ('Y','N','B','G')  THEN 'INVALID'
        ELSE 'VALID'
        END AS BrandGenericInd1X,

/*
2.001.10	Measure	Medium	% missing: COMPOUND-DRUG-IND 	1-99% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing COMPOUND-DRUG-IND	

A Claim_Type 'Q' indicates a compund drug claim. Shall we use this as an indicator of compund drugs?
Code as 1(compound) Claim_Type=Q. Else code as 0

?? Couuld add:

50	MPT_SENDPRO_NDC_Valid_ALL	If valid based on lookup to the column CDE_NDC from "NW_B_DRUG" then 1 else 0

CASE
    WHEN (IND_SCRIPT_OT = 'O') OR (DTL_CDE_NDC IS NULL) THEN 'NOT APP'
    WHEN NOT EXISTS (SELECT CDE_NDC FROM MHDWQA.NW.NW_B_DRUG WHERE CDE_NDC = DTL_CDE_NDC AND CDE_NDC NOT IN ('#','**','+','-','$','  ')) 
	THEN 'INVALID'
    ELSE 'VALID'
END AS CompoundNDC1X,

*/

    CASE WHEN Claim_Type NOT IN ('Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'

    WHEN (IND_SCRIPT_OT = 'O') OR (DTL_CDE_NDC IS NULL) THEN 'NOT APP'
    WHEN NOT EXISTS (SELECT CDE_NDC FROM MHDWQA.NW.NW_B_DRUG WHERE CDE_NDC = DTL_CDE_NDC AND CDE_NDC NOT IN ('#','**','+','-','$','  ')) 
	THEN 'INVALID'


        ELSE 'VALID'
    END AS CompoundDrugInd1X,


/*
2.001.11	Measure	Medium	 % missing: DISPENSING-PRESCRIPTION-DRUG-PROV-NUM	<= 2% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Dispensing PID/SL	

?? Have Billing and Prescribing - is Dispensing same as Billing?
*/


/*
2.001.12	Measure	Medium	% missing: MEDICAID-COV-INPATIENT-DAYS	<= 2% missing	
IP	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing MEDICAID-COV-INPATIENT-DAYS	

SPRO_B_ENC_CLAIM_INST_LEG_HIST.NUM_DAYS_COVD

*/

    CASE WHEN Claim_Type NOT IN ('I')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
    WHEN NUM_DAYS_COVD IS NULL OR NUM_DAYS_COVD < 0 THEN 'INVALID'
    ELSE 'VALID'
    END AS MedicaidCovInpatientDays1X,

/*
2.001.13	Measure	Medium	 % missing: PRESCRIBING-PROV-NUM 	<= 10% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Prescribing Provider PID/SL	
*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- From Target
         WHEN (prescribing_ProviderInternalId IS NULL) THEN 'NULL'
		 WHEN 
         (
              (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = prescribing_ProviderInternalId)) 
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS PrescribingProviderInternalId1X,

/*
2.001.14	Measure	Medium	 % missing: PRESCRIBING-PROV-NPI-NUM 	<= 2% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Prescribing Provider NPI	
*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- From Target
         WHEN 
                ((prescribing_ProviderNPI IS NULL) OR prescribing_ProviderNPI IN ('0','000000000','0000000000')) 
         THEN 'NULL'
            
         WHEN 
              (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = prescribing_ProviderNPI))
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS PrescribingProviderNPI1X,

/*
2.001.15	Measure	Medium	% missing: REVENUE-CHARGE 	<= 2% missing	
"IP LP"	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing REVENUE-CHARGE	

From dashboard data needed

IP	SPRO_B_ENC_INST_INFO_DTL_HIST.AMT_BILLED
LT	SPRO_B_ENC_INST_INFO_DTL_HIST.AMT_SVC_LINE_CHARGE

?? SVCLINECHARGEAMT
only found in STG_B_ENC_PROF_INFO_DTL_SCRUB_* tables

Otherwise same as Amt_Billed - 2.001.21
*/



/*
2.001.16	Measure	Medium	% missing: REBATE-ELIGIBLE-INDICATOR 	<= 20% missing	
RX	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing REBATE-ELIGIBLE-INDICATOR	

?? Where REBATE is found:

MHDWQA	NW	NW_B_ENC_ATTRIBUTE	IND_ENC_REBATE
MHDWQA	NW	NW_B_ENC_DENIED_CLAIM	REBATE_INDICATOR

MHDWQA	NW	NW_ENC_ATTRIBUTE	IND_ENC_REBATE
MHDWQA	NW	NW_ENC_DENIED_CLAIM	REBATE_INDICATOR

MHDWQA	NW	ODS_ENCOUNTER	REBATE_INDICATOR
MHDWQA	NW	ODS_ENCOUNTER_VW	REBATE_INDICATOR

MHDWQA	SENDPRO	RAW_SPRO_NCPDP_CLAIM	PatientFormRebateAmt
MHDWQA	SENDPRO	RAW_SPRO_NCPDP_COMPOUND_DTL	CompndRebateAmt

MHDWQA	SENDPRO	SPRO_B_ENC_CLAIM_PHRM_LEG_HIST	AMT_PATIENT_FORM_REBATE
MHDWQA	SENDPRO	SPRO_B_ENC_PHRM_DRUG_ATTRIBUTE	AMT_COMPND_REBATE

MHDWQA	SENDPRO	STG_ENC_PHRM_DRUG_ATTR_STAGE	AMT_COMPND_REBATE
MHDWQA	SENDPRO	STG_ENC_PHRM_LEG_INS	AMT_PATIENT_FORM_REBATE
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB	ORIG_PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB	PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_1	ORIG_PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_1	PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_2	ORIG_PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_2	PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_3	ORIG_PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_SCRUB_3	PATIENT_FORM_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_CLAIM_STAGE	AMT_PATIENT_FORM_REBATE
MHDWQA	SENDPRO	STG_SPRO_PHRM_DRUG_ATTR	AMT_COMPND_REBATE
MHDWQA	SENDPRO	STG_SPRO_PHRM_DRUG_ATTR_DTL	COMPND_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_DRUG_ATTR_DTL	ORIG_COMPND_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_DRUG_ATTR_HDR	COMPND_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_DRUG_ATTR_HDR	ORIG_COMPND_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_DTL_SCRUB	COMPND_REBATE_AMT
MHDWQA	SENDPRO	STG_SPRO_PHRM_DTL_SCRUB_1	COMPND_REBATE_AMT

Using SPRO_B_ENC_CLAIM_PHRM_LEG_HIST.AMT_PATIENT_FORM_REBATE

*/

    CASE WHEN Claim_Type NOT IN ('P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'

         WHEN AMT_PATIENT_FORM_REBATE IS NULL THEN NULL
         WHEN AMT_PATIENT_FORM_REBATE < 0 THEN 'INVALID'
         ELSE 'VALID'  
         END AS RebateEligibleInd1X,

/*
2.001.17	Measure	Medium	% missing: REFERRING-PROV-NUM 	<= 98% missing	
OT	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Referring Provider PID/SL	
*/

    CASE WHEN Claim_Type NOT IN ('O','M','H')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'

-- From Target Servicing Provider Internal ID
         WHEN (Referring_ProviderInternalId IS NULL) AND (dtl_referring_ProviderInternalId IS NULL)THEN 'NULL'
		 WHEN 
         (
              (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = Referring_ProviderInternalId)) 
          AND (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = dtl_referring_ProviderInternalId))
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS ReferringProviderInternalId1X,

/*
2.001.18	Measure	Medium	% missing: REFERRING-PROV-NPI-NUM	>= 90% present	
IP	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Referring Provider NPI	
*/

    CASE WHEN Claim_Type NOT IN ('O','M','H')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'

-- From Target Servicing Provider NPI
         WHEN 
         (
                ((Referring_ProviderNPI IS NULL) OR Referring_ProviderNPI IN ('0','000000000','0000000000')) 
            AND ((dtl_referring_ProviderNPI IS NULL) OR dtl_referring_ProviderNPI IN ('0','000000000','0000000000'))
         )            
         THEN 'NULL'
            
         WHEN 
         (
              (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = Referring_ProviderNPI)) 
          AND (NOT EXISTS (SELECT ID_NPI from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ID_NPI NOT IN ('#','+','-') AND ID_NPI = dtl_referring_ProviderNPI))
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS ReferringProviderNPI1X,


/*
2.001.19	Measure	Medium	% missing: SERVICING-PROV-NUM	<= 10% missing	
OT	
This measure should show % of Medicaid and S-CHIP Encounter: Original and Replacement, Paid Claims missing Servicing Provider PID/SL	
*/

    CASE WHEN Claim_Type NOT IN ('O','M','H')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- From Target Servicing Provider Internal ID
         WHEN (servicing_ProviderInternalId IS NULL) AND (dtl_servicing_ProviderInternalId IS NULL)THEN 'NULL'
		 WHEN 
         (
              (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = servicing_ProviderInternalId)) 
          AND (NOT EXISTS (SELECT ENC_PROV_ID from mhdwqa.SENDPRO.spro_b_enc_provider_hist where ENC_PROV_ID NOT IN ('#','+','-') AND ENC_PROV_ID = dtl_servicing_ProviderInternalId))
         )
         THEN 'INVALID'
         ELSE 'VALID' 
         END AS ServicingProviderInternalId1X,

/*
2.001.20	Measure	Medium	% missing: TOT-ALLOWED-AMT 	<= 2% missing	
"IP LT OT RX"	
This measure should show % of IP, LT, OT, and RX claims missing Total Allowed Amount 	
*/

    CASE WHEN Claim_Type NOT IN ('I','L','O','M','H','P','Q')
        OR CDE_CLM_DISPOSITION NOT IN ('O','R')
        --OR IND_CROSSOVER = 'N'
        OR CDE_CLM_STATUS != 'P'
        THEN 'NOT APP'
-- from Target
    WHEN AMT_ALLOWED IS NULL AND DTL_AMT_ALLOWED IS NULL THEN 'NULL'
    WHEN AMT_ALLOWED <= 0 OR DTL_AMT_ALLOWED <= 0 THEN 'INVALID'
    ELSE 'VALID'
END AS ClaimAllowableAmount1X,

------

CASE WHEN Claim_Type = 'I' THEN 1 ELSE 0 END INPAT,
CASE WHEN Claim_Type = 'O' THEN 1 ELSE 0 END OUTPAT,
CASE WHEN Claim_Type = 'L' THEN 1 ELSE 0 END LTC,
CASE WHEN Claim_Type = 'M' THEN 1 ELSE 0 END PROF,
CASE WHEN Claim_Type = 'H' THEN 1 ELSE 0 END HOME,
CASE WHEN Claim_Type = 'D' THEN 1 ELSE 0 END DENT,
CASE WHEN Claim_Type = 'P' THEN 1 ELSE 0 END PHARM,
CASE WHEN Claim_Type = 'Q' THEN 1 ELSE 0 END COMPOUND,
CASE WHEN Claim_Type NOT IN  ('P', 'Q') THEN 1 ELSE 0 END AS NON_PHARM,

1 as TOT_REX

FROM (

select DISTINCT
    CURRENT_DATE()                 AS RUN_DATE,
    inst.NUM_ICN,
    inst.CDE_ENTITY_MODEL,
    inst.CDE_ENC_MCO,
    inst.CDE_ENC_ACO,
    inst.ID_SUBMITTER,
    inst.DOS_FROM_DT,
    inst.CDE_CLM_TYPE              AS Claim_Type,
    inst.CDE_CLM_STATUS,
    inst.CDE_CLM_DISPOSITION,
    inst.IND_OFFSET,
    inst.IND_CROSSOVER,
    inst.WH_FROM_DT,
    inst.MD_BATCH_SEQ,

    inst.CDE_BILL_FREQ,
    inst.CDE_CONTRACT_TYPE,
    inst.AMT_ALLOWED,
    inst.AMT_PAID,
    inst.AMT_BILLED,
    inst.AMT_PAID_MCARE,
    inst.AMT_COINSURANCE_MCARE,
    inst.AMT_COPAY_MCARE,
    inst.AMT_DEDUCT_MCARE,
    inst.NUM_DAYS_COVD,

    inst.DOS_TO_DT,
    DATE(inst.ADMIT_DT_TM)         AS ADMIT_DT,
    inst.MEM_SEQ                   AS FACT_MEM_SEQ,
    inst.QTY_UNITS_BILLED,
    DATE(inst.DISCHARGE_DT_TM)     AS DISCHARGE_DT,
    inst.CDE_ADMIT_TYPE,
    inst.CDE_ADMIT_SOURCE,
    inst.CDE_PATIENT_STATUS        AS PatientStatusCode,
    inst.CDE_TYPE_OF_BILL,
    inst.DIAGRP_SEQ,
 
    inst.BILLING_ENC_PRV_SEQ,
    inst.SERVICING_ENC_PRV_SEQ,
    NULL                           AS CDE_PLACE_OF_SERVICE,
  
    --RX
    NULL                           AS ADJUDICATION_DT,
    NULL                           AS IND_GENERIC,
    NULL                           AS PROC_SEQ,
    NULL                           AS CDE_REC_STATUS,
    NULL                           AS PHRM_CDE_NDC,
    NULL                           AS IND_SCRIPT_OT,
    NULL                           AS SCRIPT_WRITTEN_DT,
    NULL                           AS CDE_DAWPROD_SEL,
    NULL                           AS AMT_DISP_FEE,
    NULL                           AS NUM_SCRIPT_SERV_REF,
    NULL                           AS CDE_PRESC_ORIG,
    NULL                           AS QTY_DISPD,
    NULL                           AS DTL_CDE_NDC,

    prov_billing.ENC_PROV_ID       AS billing_ProviderInternalId,
    prov_billing.ID_NPI            AS billing_ProviderNPI,

    prov_servicing.ENC_PROV_ID     AS servicing_ProviderInternalId,
    prov_servicing.ID_NPI          AS servicing_ProviderNPI,

    prov_attending.ENC_PROV_ID     AS attending_ProviderInternalId,
    prov_attending.ID_NPI          AS attending_ProviderNPI,

    prov_referring.ENC_PROV_ID     AS referring_ProviderInternalId,
    prov_referring.ID_NPI          AS referring_ProviderNPI,
    
    NULL                           AS prescribing_ProviderInternalId,
    NULL                           AS prescribing_ProviderNPI,

    dtl.NUM_DTL,
    dtl.CDE_CLM_STATUS DTL_CLM_STATUS,
    dtl.IND_OFFSET                 AS DTL_IND_OFFSET,
 
    dtl.PROC_SEQ,
    dtl.PROCMFRGRP_SEQ,

    dtl.AMT_ALLOWED                AS DTL_AMT_ALLOWED,
    dtl.AMT_PAID                   AS DTL_AMT_PAID,
    dtl.AMT_BILLED                 AS DTL_AMT_BILLED,
    dtl.AMT_PAID_MCARE             AS DTL_AMT_PAID_MCARE,
    dtl.AMT_COINSURANCE_MCARE      AS DTL_AMT_COINSURANCE_MCARE,
    dtl.AMT_COPAY_MCARE            AS DTL_AMT_COPAY_MCARE,
    dtl.AMT_DEDUCT_MCARE           AS DTL_AMT_DEDUCT_MCARE,

    dtl.BILLING_ENC_PRV_SEQ        AS DTL_BILLING_ENC_PRV_SEQ,
    dtl.SERVICING_ENC_PRV_SEQ      AS DTL_SERVICING_ENC_PRV_SEQ,
    dtl.REFERRING_ENC_PRV_SEQ      AS DTL_REFERRING_ENC_PRV_SEQ,
    dtl.DOS_FROM_DT                AS DTL_DOS_FROM_DT,
    dtl.DOS_TO_DT                  AS DTL_DOS_TO_DT,
    dtl.MEM_SEQ                    AS DTL_FACT_MEM_SEQ,
    dtl.QTY_UNITS_BILLED           AS DTL_QTY_UNITS_BILLED,
    DATE(dtl.DISCHARGE_DT)         AS DTL_DISCHARGE_DT,

    dtl.REV_SEQ                    AS DTL_REV_SEQ,

    dtl_prov_billing.ENC_PROV_ID   AS dtl_billing_ProviderInternalId,
    dtl_prov_billing.ID_NPI        AS dtl_billing_ProviderNPI,

    dtl_prov_servicing.ENC_PROV_ID AS dtl_servicing_ProviderInternalId,
    dtl_prov_servicing.ID_NPI      AS dtl_servicing_ProviderNPI,
  
    dtl_prov_referring.ENC_PROV_ID AS dtl_referring_ProviderInternalId,
    dtl_prov_referring.ID_NPI      AS dtl_referring_ProviderNPI

FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_INST_LEG_HIST inst
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_INST_INFO_DTL_HIST dtl
    ON inst.NUM_ICN = dtl.NUM_ICN
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_billing
    ON inst.BILLING_ENC_PRV_SEQ = prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_servicing
    ON inst.SERVICING_ENC_PRV_SEQ = prov_servicing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_attending
    ON inst.ATTENDING_ENC_PRV_SEQ = prov_attending.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_referring
    ON inst.REFERRING_ENC_PRV_SEQ = prov_referring.ENC_PRV_SEQ

LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_billing
    ON DTL_BILLING_ENC_PRV_SEQ = dtl_prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_servicing
    ON DTL_SERVICING_ENC_PRV_SEQ = dtl_prov_servicing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_referring
    ON DTL_REFERRING_ENC_PRV_SEQ = dtl_prov_referring.ENC_PRV_SEQ

WHERE inst.IND_OFFSET = 'N' AND DTL_IND_OFFSET = 'N'

UNION

select DISTINCT
    CURRENT_DATE()                 AS RUN_DATE,
    prof.NUM_ICN,
    prof.CDE_ENTITY_MODEL,
    prof.CDE_ENC_MCO,
    prof.CDE_ENC_ACO,
    prof.ID_SUBMITTER,
    prof.DOS_FROM_DT,
    prof.CDE_CLM_TYPE              AS Claim_Type,
    prof.CDE_CLM_STATUS,
    prof.CDE_CLM_DISPOSITION,
    prof.IND_OFFSET,
    prof.IND_CROSSOVER,
    prof.WH_FROM_DT,
    prof.MD_BATCH_SEQ,

    prof.CDE_BILL_FREQ,
    prof.CDE_CONTRACT_TYPE,
    prof.AMT_ALLOWED,
    prof.AMT_PAID,
    prof.AMT_BILLED,
    prof.AMT_PAID_MCARE,
    prof.AMT_COINSURANCE_MCARE,
    prof.AMT_COPAY_MCARE,
    prof.AMT_DEDUCT_MCARE,
    NULL                           AS NUM_DAYS_COVD,

    prof.DOS_TO_DT,
    DATE(prof.ADMIT_DT_TM)         AS ADMIT_DT,
    prof.MEM_SEQ                   AS FACT_MEM_SEQ,
    prof.QTY_UNITS_BILLED,
    DATE(prof.DISCHARGE_DT)        AS DISCHARGE_DT,
    NULL                           AS CDE_ADMIT_TYPE,
    NULL                           AS CDE_ADMIT_SOURCE,
    NULL                           AS PatientStatusCode, -- AS CDE_PATIENT_STATUS
    NULL                           AS CDE_TYPE_OF_BILL,
    prof.DIAGRP_SEQ,

    prof.BILLING_ENC_PRV_SEQ,
    prof.SERVICING_ENC_PRV_SEQ,
    prof.CDE_PLACE_OF_SERVICE,

    --RX
    NULL                           AS ADJUDICATION_DT,
    NULL                           AS IND_GENERIC,
    NULL                           AS PROC_SEQ,
    NULL                           AS CDE_REC_STATUS,
    NULL                           AS PHRM_CDE_NDC,
    NULL                           AS IND_SCRIPT_OT,
    NULL                           AS SCRIPT_WRITTEN_DT,
    NULL                           AS CDE_DAWPROD_SEL,
    NULL                           AS AMT_DISP_FEE,
    NULL                           AS NUM_SCRIPT_SERV_REF,
    NULL                           AS CDE_PRESC_ORIG,
    NULL                           AS QTY_DISPD,
    NULL                           AS DTL_CDE_NDC,
  
    prov_billing.ENC_PROV_ID       AS billing_ProviderInternalId,
    prov_billing.ID_NPI            AS billing_ProviderNPI,

    prov_servicing.ENC_PROV_ID     AS servicing_ProviderInternalId,
    prov_servicing.ID_NPI          AS servicing_ProviderNPI,

    NULL                           AS attending_ProviderInternalId,
    NULL                           AS attending_ProviderNPI,

    prov_referring.ENC_PROV_ID     AS referring_ProviderInternalId,
    prov_referring.ID_NPI          AS referring_ProviderNPI,
    
    NULL                           AS prescribing_ProviderInternalId,
    NULL                           AS prescribing_ProviderNPI,

    dtl.NUM_DTL,
    dtl.CDE_CLM_STATUS DTL_CLM_STATUS,
    dtl.IND_OFFSET                 AS DTL_IND_OFFSET,
    
    dtl.PROC_SEQ,
    dtl.PROCMFRGRP_SEQ,

    dtl.AMT_ALLOWED                AS DTL_AMT_ALLOWED,
    dtl.AMT_PAID                   AS DTL_AMT_PAID,
    dtl.AMT_BILLED                 AS DTL_AMT_BILLED,
    dtl.AMT_PAID_MCARE             AS DTL_AMT_PAID_MCARE,
    dtl.AMT_COINSURANCE_MCARE      AS DTL_AMT_COINSURANCE_MCARE,
    dtl.AMT_COPAY_MCARE            AS DTL_AMT_COPAY_MCARE,
    dtl.AMT_DEDUCT_MCARE           AS DTL_AMT_DEDUCT_MCARE,
    
    dtl.BILLING_ENC_PRV_SEQ        AS DTL_BILLING_ENC_PRV_SEQ,
    dtl.SERVICING_ENC_PRV_SEQ      AS DTL_SERVICING_ENC_PRV_SEQ,
    dtl.REFERRING_ENC_PRV_SEQ      AS DTL_REFERRING_ENC_PRV_SEQ,
    dtl.DOS_FROM_DT                AS DTL_DOS_FROM_DT,
    dtl.DOS_TO_DT                  AS DTL_DOS_TO_DT,
    dtl.MEM_SEQ                    AS DTL_FACT_MEM_SEQ,
    dtl.QTY_UNITS_BILLED           AS DTL_QTY_UNITS_BILLED,
    NULL                           AS DTL_DISCHARGE_DT,

    NULL                           AS DTL_REV_SEQ,
    
    dtl_prov_billing.ENC_PROV_ID   AS dtl_billing_ProviderInternalId,
    dtl_prov_billing.ID_NPI        AS dtl_billing_ProviderNPI,

    dtl_prov_servicing.ENC_PROV_ID AS dtl_servicing_ProviderInternalId,
    dtl_prov_servicing.ID_NPI      AS dtl_servicing_ProviderNPI,

    dtl_prov_referring.ENC_PROV_ID AS dtl_referring_ProviderInternalId,
    dtl_prov_referring.ID_NPI      AS dtl_referring_ProviderNPI

FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_PROF_LEG_HIST prof
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROF_INFO_DTL_HIST dtl
    ON prof.NUM_ICN = dtl.NUM_ICN
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_billing
    ON prof.BILLING_ENC_PRV_SEQ = prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_servicing
    ON prof.SERVICING_ENC_PRV_SEQ = prov_servicing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_referring
    ON prof.REFERRING_ENC_PRV_SEQ = prov_referring.ENC_PRV_SEQ

LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_billing
    ON DTL_BILLING_ENC_PRV_SEQ = dtl_prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_servicing
    ON DTL_SERVICING_ENC_PRV_SEQ = dtl_prov_servicing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_referring
    ON DTL_SERVICING_ENC_PRV_SEQ = dtl_prov_referring.ENC_PRV_SEQ

WHERE prof.IND_OFFSET = 'N'

UNION

select DISTINCT
    CURRENT_DATE()                 AS RUN_DATE,
    dntl.NUM_ICN,
    dntl.CDE_ENTITY_MODEL,
    dntl.CDE_ENC_MCO,
    dntl.CDE_ENC_ACO,
    dntl.ID_SUBMITTER,
    dntl.DOS_FROM_DT,
    dntl.CDE_CLM_TYPE              AS Claim_Type,
    dntl.CDE_CLM_STATUS,
    dntl.CDE_CLM_DISPOSITION,
    dntl.IND_OFFSET,
    dntl.IND_CROSSOVER,
    dntl.WH_FROM_DT,
    dntl.MD_BATCH_SEQ,

    dntl.CDE_BILL_FREQ,
    dntl.CDE_CONTRACT_TYPE,
    NULL                           AS AMT_ALLOWED,
    dntl.AMT_PAID,
    dntl.AMT_BILLED,
    dntl.AMT_PAID_MCARE,
    dntl.AMT_COINSURANCE_MCARE,
    dntl.AMT_COPAY_MCARE,
    dntl.AMT_DEDUCT_MCARE,
    NULL                           AS NUM_DAYS_COVD,
    
    dntl.DOS_TO_DT,
    NULL                           AS ADMIT_DT,
    dntl.MEM_SEQ                   AS FACT_MEM_SEQ,
    dntl.QTY_UNITS_BILLED,
    NULL                           AS DISCHARGE_DT,
    NULL                           AS CDE_ADMIT_TYPE,
    NULL                           AS CDE_ADMIT_SOURCE,
    NULL                           AS PatientStatusCode, -- AS CDE_PATIENT_STATUS
    NULL                           AS CDE_TYPE_OF_BILL,
    dntl.DIAGRP_SEQ,

    dntl.BILLING_ENC_PRV_SEQ,
    dntl.SERVICING_ENC_PRV_SEQ,
    dntl.CDE_PLACE_OF_SERVICE,

    --RX
    NULL                           AS ADJUDICATION_DT,
    NULL                           AS IND_GENERIC,
    NULL                           AS PROC_SEQ,
    NULL                           AS CDE_REC_STATUS,
    NULL                           AS PHRM_CDE_NDC,
    NULL                           AS IND_SCRIPT_OT,
    NULL                           AS SCRIPT_WRITTEN_DT,
    NULL                           AS CDE_DAWPROD_SEL,
    NULL                           AS AMT_DISP_FEE,
    NULL                           AS NUM_SCRIPT_SERV_REF,
    NULL                           AS CDE_PRESC_ORIG,
    NULL                           AS QTY_DISPD,
    NULL                           AS DTL_CDE_NDC,

    prov_billing.ENC_PROV_ID       AS billing_ProviderInternalId,
    prov_billing.ID_NPI            AS billing_ProviderNPI,

    prov_servicing.ENC_PROV_ID     AS servicing_ProviderInternalId,
    prov_servicing.ID_NPI          AS servicing_ProviderNPI,

    NULL                           AS attending_ProviderInternalId,
    NULL                           AS attending_ProviderNPI,

    prov_referring.ENC_PROV_ID     AS referring_ProviderInternalId,
    prov_referring.ID_NPI          AS referring_ProviderNPI,

    NULL                           AS prescribing_ProviderInternalId,
    NULL                           AS prescribing_ProviderNPI,

    dtl.NUM_DTL,
    dtl.CDE_CLM_STATUS             AS DTL_CLM_STATUS,
    dtl.IND_OFFSET                 AS DTL_IND_OFFSET,

    dtl.PROC_SEQ,
    dtl.PROCMFRGRP_SEQ,

    NULL                           AS DTL_AMT_ALLOWED,
    dtl.AMT_PAID                   AS DTL_AMT_PAID,
    dtl.AMT_BILLED                 AS DTL_AMT_BILLED,
    dtl.AMT_PAID_MCARE             AS DTL_AMT_PAID_MCARE,
    dtl.AMT_COINSURANCE_MCARE      AS DTL_AMT_COINSURANCE_MCARE,
    dtl.AMT_COPAY_MCARE            AS DTL_AMT_COPAY_MCARE,
    dtl.AMT_DEDUCT_MCARE           AS DTL_AMT_DEDUCT_MCARE,

    dtl.BILLING_ENC_PRV_SEQ        AS DTL_BILLING_ENC_PRV_SEQ,
    dtl.SERVICING_ENC_PRV_SEQ      AS DTL_SERVICING_ENC_PRV_SEQ,
    NULL                           AS DTL_REFERRING_ENC_PRV_SEQ,
    dtl.DOS_FROM_DT                AS DTL_DOS_FROM_DT,
    dtl.DOS_TO_DT                  AS DTL_DOS_TO_DT,
    dtl.MEM_SEQ                    AS DTL_FACT_MEM_SEQ,
    dtl.QTY_UNITS_BILLED           AS DTL_QTY_UNITS_BILLED,
    NULL                           AS DTL_DISCHARGE_DT,

    NULL AS DTL_REV_SEQ,
    
    dtl_prov_billing.ENC_PROV_ID   AS dtl_billing_ProviderInternalId,
    dtl_prov_billing.ID_NPI        AS dtl_billing_ProviderNPI,

    dtl_prov_servicing.ENC_PROV_ID AS dtl_servicing_ProviderInternalId,
    dtl_prov_servicing.ID_NPI      AS dtl_servicing_ProviderNPI,

    NULL                           AS dtl_referring_ProviderInternalId,
    NULL                           AS dtl_referring_ProviderNPI

FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_DNTL_LEG_HIST dntl
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_DNTL_INFO_DTL_HIST dtl
    ON dntl.NUM_ICN = dtl.NUM_ICN
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_billing
    ON dntl.BILLING_ENC_PRV_SEQ = prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_servicing
    ON dntl.SERVICING_ENC_PRV_SEQ = prov_servicing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_referring
    ON dntl.REFERRING_ENC_PRV_SEQ = prov_referring.ENC_PRV_SEQ

LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_billing
    ON DTL_BILLING_ENC_PRV_SEQ = dtl_prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST dtl_prov_servicing
    ON DTL_SERVICING_ENC_PRV_SEQ = dtl_prov_servicing.ENC_PRV_SEQ

WHERE dntl.IND_OFFSET = 'N'

UNION

select DISTINCT
    CURRENT_DATE() AS RUN_DATE,
    phrm.NUM_ICN,
    phrm.CDE_ENTITY_MODEL,
    phrm.CDE_ENC_MCO,
    phrm.CDE_ENC_ACO,
    NULL AS ID_SUBMITTER,
    phrm.DOS_FROM_DT,
    phrm.CDE_CLM_TYPE              AS Claim_Type,
    phrm.CDE_CLM_STATUS,
    phrm.CDE_CLM_DISPOSITION,
    phrm.IND_OFFSET,
    phrm.IND_CROSSOVER,
    phrm.WH_FROM_DT,
    phrm.MD_BATCH_SEQ,

    NULL                           AS CDE_BILL_FREQ,
    NULL                           AS CDE_CONTRACT_TYPE,
    phrm.AMT_ALLOWED,
    phrm.AMT_PAID,
    phrm.AMT_BILLED,
    phrm.AMT_PAID_MCARE,
    phrm.AMT_COINSURANCE_MCARE,
    phrm.AMT_COPAY_MCARE,
    phrm.AMT_DEDUCT_MCARE,
    NULL                           AS NUM_DAYS_COVD,
    
    phrm.DOS_TO_DT,
    NULL                           AS ADMIT_DT,
    phrm.MEM_SEQ                   AS FACT_MEM_SEQ,
    phrm.QTY_UNITS_BILLED,
    NULL                           AS DISCHARGE_DT,
    NULL                           AS CDE_ADMIT_TYPE,
    NULL                           AS CDE_ADMIT_SOURCE,
    NULL                           AS PatientStatusCode, -- AS CDE_PATIENT_STATUS
    NULL                           AS CDE_TYPE_OF_BILL,
    phrm.DIAGRP_SEQ,

    phrm.BILLING_ENC_PRV_SEQ,
    NULL                           AS SERVICING_ENC_PRV_SEQ,
    NULL                           AS CDE_PLACE_OF_SERVICE,

    --RX
    DATE(ADJUDICATION_DT_TM)       AS ADJUDICATION_DT,
    IND_GENERIC,
    phrm.PROC_SEQ,
    phrm.CDE_REC_STATUS,
    phrm.CDE_NDC AS PHRM_CDE_NDC,
    phrm.IND_SCRIPT_OT,
    phrm.SCRIPT_WRITTEN_DT,
    phrm.CDE_DAWPROD_SEL,
    phrm.AMT_DISP_FEE,
    phrm.NUM_SCRIPT_SERV_REF,
    phrm.CDE_PRESC_ORIG,
    phrm.QTY_DISPD,
    dtl.CDE_NDC                    AS DTL_CDE_NDC,

    prov_billing.ENC_PROV_ID AS billing_ProviderInternalId,
    prov_billing.ID_NPI AS billing_ProviderNPI,

    NULL                           AS servicing_ProviderInternalId,
    NULL                           AS servicing_ProviderNPI,

    NULL                           AS attending_ProviderInternalId,
    NULL                           AS attending_ProviderNPI,

    NULL                           AS referring_ProviderInternalId,
    NULL                           AS referring_ProviderNPI,
    
    prov_prescribing.ENC_PROV_ID   AS prescribing_ProviderInternalId,
    prov_prescribing.ID_NPI        AS prescribing_ProviderNPI,

    CASE WHEN dtl.NUM_DTL IS NULL THEN 0 ELSE dtl.NUM_DTL END AS NUM_DTL,
    NULL                           AS DTL_CLM_STATUS,
    dtl.IND_OFFSET                 AS DTL_IND_OFFSET,
    
    NULL                           AS PROC_SEQ,
    NULL                           AS PROCMFRGRP_SEQ,

    NULL                           AS DTL_AMT_ALLOWED,
    NULL                           AS DTL_AMT_PAID,
    NULL                           AS DTL_AMT_BILLED,
    NULL                           AS DTL_AMT_PAID_MCARE,
    NULL                           AS DTL_AMT_COINSURANCE_MCARE,
    NULL                           AS DTL_AMT_COPAY_MCARE,
    NULL                           AS DTL_AMT_DEDUCT_MCARE,

    NULL                           AS DTL_BILLING_ENC_PRV_SEQ,
    NULL                           AS DTL_SERVICING_ENC_PRV_SEQ,
    NULL                           AS DTL_REFERRING_ENC_PRV_SEQ,
    NULL                           AS DTL_DOS_FROM_DT,
    NULL                           AS DTL_DOS_TO_DT,
    NULL                           AS DTL_FACT_MEM_SEQ,
    dtl.QTY_UNITS_BILLED           AS DTL_QTY_UNITS_BILLED,   
    NULL                           AS DTL_DISCHARGE_DT,

    NULL                           AS DTL_REV_SEQ,

    NULL                           AS dtl_billing_ProviderInternalId,
    NULL                           AS dtl_billing_ProviderNPI,
    NULL                           AS dtl_servicing_ProviderInternalId,
    NULL                           AS dtl_servicing_ProviderNPI,
    NULL                           AS dtl_referring_ProviderInternalId,
    NULL                           AS dtl_referring_ProviderNPI


FROM MHDWQA.SENDPRO.SPRO_B_ENC_CLAIM_PHRM_LEG_HIST phrm
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PHRM_INFO_DTL_HIST dtl
    ON phrm.NUM_ICN = dtl.NUM_ICN
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_billing
    ON phrm.BILLING_ENC_PRV_SEQ = prov_billing.ENC_PRV_SEQ
LEFT JOIN MHDWQA.SENDPRO.SPRO_B_ENC_PROVIDER_HIST prov_prescribing
    ON phrm.PRESCRIBING_ENC_PRV_SEQ = prov_prescribing.ENC_PRV_SEQ

WHERE phrm.IND_OFFSET = 'N'
  );
