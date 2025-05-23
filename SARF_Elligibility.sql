
/****** Object:  StoredProcedure [dbo].[SARF_Elligibility]    Script Date: 13-12-2024 11:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SARF_Elligibility]
	@DynamicGrp	AS	VARCHAR(20),
	@AdminValue	AS	varchar(Max),
	@TimeKey	AS	INT,
	@Flag		AS	INT=0,
	@CustomerID	VARCHAR(30)='',
	@CustName 	VARCHAR(100)='',
	@CustType   VARCHAR(30)=''

AS


--DECLARE
--	@DynamicGrp	AS	VARCHAR(20)='bo',
--	@AdminValue	AS	varchar(Max)='0',
--	@TimeKey	AS	INT=49999,
--	@Flag		AS	INT=0

--select 26360+68735

SET NOCOUNT ON;
IF (OBJECT_ID('tempdb..#TempBranch') IS NOT NULL)
					DROP TABLE #TempBranch

SELECT DISTINCT	QRYBRANCH.BranchCode	INTO #TempBranch

FROM	DBO.QRYBRANCH 
WHERE	(EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
		(	 (@AdminValue='0') OR
			 (@DynamicGrp='ZO' AND ZoneCode IN (SELECT * FROM DBO.SPLIT(@AdminValue,','))) OR
			 (@DynamicGrp='RO' AND RegionCode IN (SELECT * FROM DBO.SPLIT(@AdminValue,','))) OR
			 (@DynamicGrp='BO' AND BranchCode IN (SELECT * FROM DBO.SPLIT(@AdminValue,',')))
		)			
OPTION(RECOMPILE)
CREATE UNIQUE CLUSTERED INDEX IX_BRANCHKEY ON #TempBranch(BranchCode)


-----------
IF (OBJECT_ID('tempdb..#AC_DATA') IS NOT NULL)
					DROP TABLE #AC_DATA

SELECT Customerid,CustomerName,ABD.CustomerEntityId,ABD.BranchCode,AccountEntityId,GLProductAlt_Key ,CurrentLimit
	INTO #AC_DATA
FROM AdvAcBasicDetail ABD
	INNER JOIN CustomerBasicDetail CBD
		ON ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey
		AND CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey
		AND CBD.CustomerEntityId=ABD.CustomerEntityId
	INNER JOIN #TempBranch BR
		ON ABD.BranchCode=BR.BranchCode
	WHERE (CBD.CustomerId=CASE WHEN @CustomerID<>'' THEN @CustomerID ELSE CBD.CustomerId END)
	--------------- ADDED BY SATWAJI AS ON 13/12/2023 FOR CUSTOMER NAME FILTERATION IF BRACKETS ARE COMING IN CUSTOMER NAME ----------------------------------------------------------
		AND ((REPLACE(REPLACE(REPLACE(REPLACE(CustomerName,'[',''),']',''),'(',''),')','') LIKE CASE WHEN @CustName<>'' THEN '%'+REPLACE(REPLACE(REPLACE(REPLACE(@CustName,'[',''),']',''),'(',''),')','')+'%' ELSE REPLACE(REPLACE(REPLACE(REPLACE(CustomerName,'[',''),']',''),'(',''),')','') END))
		 --AND (CustomerName LIKE CASE WHEN @CustName<>'' THEN '%'+@CustName+'%' ELSE CustomerName END)
		 AND CustType= CASE WHEN @CustType <>'' THEN @CustType ELSE CustType END
-------------


DECLARE @Date DATE = (SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)
-------------------------CUSTOMER WISE TOTAL (FOR CHECKING ALL AC TOTAL IS >100000)
IF (OBJECT_ID('tempdb..#ACBAL') IS NOT NULL)
					DROP TABLE #ACBAL

SELECT	ACBD.CustomerEntityId,
		SUM(ISNULL(ACBAL.Total,0))					AS	Total,
		SUM(ISNULL(ACBD.CurrentLimit,0))			AS	CurrentLimit

INTO	#ACBAL
FROM	#AC_DATA	ACBD

INNER JOIN LEGALVW.AdvAcOtherBalanceDetail ACBAL	ON	ACBD.AccountEntityId=ACBAL.AccountEntityID
														AND ACBAL.EffectiveFromTimeKey<=@TimeKey
														AND ACBAL.EffectiveToTimeKey>=@TimeKey
														--AND ACBD.EffectiveFromTimeKey<=@TimeKey
														--AND ACBD.EffectiveToTimeKey>=@TimeKey
GROUP BY ACBD.CustomerEntityId
HAVING SUM(ISNULL(Total,0))>100000 
--AND  (SUM(ISNULL(Total,0))>(0.2)*SUM(ISNULL(ACBD.CurrentLimit,0))) comment this code as per new SARFAESI LOGIC SHARED BY BANK AS ON 14102024

OPTION(RECOMPILE)


-------------------------Eligible Customers Securities And Accounts Data ()
IF (OBJECT_ID('tempdb..#Eligible_Data') IS NOT NULL)
					DROP TABLE #Eligible_Data

SELECT	TB.BranchCode,
		ACBD.CustomerEntityId,
		ACBD.AccountEntityId,
		ACSD.SecurityEntityID
		--ACBAL.Total

INTO	#Eligible_Data
		
FROM	#TempBranch TB

INNER JOIN #AC_DATA	ACBD					ON	ACBD.BranchCode=TB.BranchCode
														--AND ACBD.EffectiveFromTimeKey<=@TimeKey
														--AND ACBD.EffectiveToTimeKey>=@TimeKey
INNER JOIN DIMGLPRODUCT GLP
													ON (GLP.EffectiveFromTimeKey<=@TimeKey AND GLP.EffectiveToTimeKey>=@TimeKey)
													AND GLP.GLProductAlt_Key=ACBD.GLProductAlt_Key
													AND GLP.ProductCode NOT IN('CC003')  ---ADD NEW FILER FOR PRODUCT CODE AS PER NEW LOGIC SHARED BY BANK AS ON 
													--AND ISNULL(GLP.SarfElligible,'Y')='Y'	 comment this code as per new SARFAESI LOGIC SHARED BY BANK AS ON 14102024
														--AND ACBD.GLProductAlt_Key NOT IN 
														--(
														--		25,51,54,55,56,56,57,58,59,60,61,62,63,64,65,66,88,89,93,110,111,112,113,131
														--		,132,133,135,136,137,138,139,140,141,165,166,167,176,177,179,184,185,188,200,210,211,214
														--		,231,233,234,236,237,243,251,252,253,254,255,256,257,258,259,260,261,262,263,264,291,294
														--		,295,297,299,300,313,314,315,316,317,318,319,320,321,322,323,328,334,335,337,339,342,343
														--		,357,358,362,363,369,370,372,375,379,390,415,417,418,419,425,429,437,440,453,467,468,470
														--		,476,494,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532
														--		,534,544,547,553,554,555,556,557,558,559,560,561,562,563,564,565,570,571,572,573,595,596
														--		,597,598,599,600,601,602,603,604,605,606,607,617,620,622,660,661,663,669,681,686,687,692
														--		,698,701,727,728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746
														--		,748,750,759,762,763,764,765,766,767,768,769,770,771,772,773,774,775,776,777,778,779,780
														--		,781,782,783,784,785,786,788,789,790,791,794,800,801,814,819,821,822,823,824,825,831,839
														--		,851,858,861,864,872,873,878,879,888,889,890,909,911,918,920,921,922,923,934,946,947,949
														--)
														
INNER JOIN AdvSecurityValueDetail ACSD				ON	ACSD.AccountEntityId=ACBD.AccountEntityId
														AND ACSD.EffectiveFromTimeKey<=@TimeKey
														AND ACSD.EffectiveToTimeKey>=@TimeKey
														--AND ISNULL(ACSD.CurrentValue,0)>0    ----commented as on 13/12/2024 as discussed with bank JP SHARMA
														--------COMMENTED BY TRILOKI AS DISCUSSED WITH BANK AS ON 03/09/2024
														--AND ACSD.SecurityAlt_Key NOT IN (145,150,260,320,445,446,447,450,455,460,480,484,486,545,565,701,750,990,991,1234
														--									---added 03/09/2024 
														--									,423,433,435,436
														--								) 

INNER JOIN DimSecurity	DS							ON	DS.SecurityAlt_Key=ACSD.SecurityAlt_Key
														AND DS.EffectiveFromTimeKey<=@TimeKey
														AND DS.EffectiveToTimeKey>=@TimeKey
														--------COMMENTED BY TRILOKI AS DISCUSSED WITH BANK AS ON 03/09/2024														
														--AND ISNULL(SecurityGroup,'')<>'ASSIGNMENT'
														--AND ISNULL(SecurityGroup,'')<>'PLEDGE'
														----------------------------------
														--AND ISNULL(DS.SecurityGroup,'')<>'LIEN'
														--AND ISNULL(DS.SecurityGroup,'')<>'UNCHARGED'
														--AND ISNULL(DS.SecurityGroup,'')<>'UNSECURED'

														------ADDED NEW LOGIC AS DISCUSSED WITH BANK AS ON 03/09/2024
														--AND ISNULL(SecurityGroup,'') IN ('HYPOTHECATION','MORTGAGE')

INNER JOIN AdvCustNpaDetail							ON	AdvCustNpaDetail.CustomerEntityId=ACBD.CustomerEntityId
														AND AdvCustNpaDetail.EffectiveFromTimeKey <= @TimeKey 
														AND AdvCustNpaDetail.EffectiveToTimeKey >= @TimeKey
														AND AdvCustNpaDetail.NPADt IS NOT NULL

INNER JOIN #ACBAL	ACBAL							ON	ACBAL.CustomerEntityId=ACBD.CustomerEntityId
														
---COMMENTED BELOW LOGIC FOR SECURITY FILTER AS ON 14/10/2024
--WHERE (ISNULL(DS.SecurityGroup,'') IN ('HYPOTHECATION','MORTGAGE')
--OR ISNULL(ACSD.SecurityNature,'') IN ('HYPOTHECATION','MORTGAGE')
--OR ISNULL(DS.SecurityName,'') like '%HYPO%' OR ISNULL(DS.SecurityName,'') like '%MORTGAGE%')

WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024

GROUP BY	TB.BranchCode,
			ACBD.CustomerEntityId,
			ACBD.AccountEntityId,
			ACSD.SecurityEntityID

OPTION (RECOMPILE)

------------Possestion
IF (OBJECT_ID('tempdb..#Possestion') IS NOT NULL)
					DROP TABLE #Possestion

SELECT	DISTINCT
		B.CustomerEntityId,
		B.AccountEntityId,
		A.SecurityEntityId,
		A.PossessionNoticeDt,
		A.PhysicalPossessionDt,
		A.SymbolicPossessionDt

INTO	#Possestion

FROM	LEGALVW.SRFPossessionDtls	A
INNER JOIN AdvSecurityValueDetail	B			ON	A.SecurityEntityID=B.SecurityEntityID
													AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
													AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
													AND	A.PossessionNoticeDt IS NOT NULL
													AND (A.PhysicalPossessionDt IS NOT NULL OR 
														 A.SymbolicPossessionDt IS NOT NULL OR 
														 A.PossesionTaken='Y')


--INSERT INTO #Eligible_Data(BranchCode,CustomerEntityId,AccountEntityId,SecurityEntityID)

--SELECT 'ABCD' AS BranchCode,CustomerEntityId,AccountEntityId,SecurityEntityId FROM #Possestion WHERE SecurityEntityID NOT IN (SELECT SecurityEntityID FROM #Eligible_Data )



IF (OBJECT_ID('tempdb..#FinalData') IS NOT NULL)
					DROP TABLE #FinalData

SELECT * INTO #FinalData FROM (
SELECT	Data.BranchCode,
		Data.CustomerEntityId,
		Data.AccountEntityId,
		Data.SecurityEntityID,
		0		AS	CaseEntityID,
		NULL	AS	DemandNoticeDt,
		NULL	AS	PossestionType,
		NULL	AS	PossesionDt,
		NULL	AS	PossessionNoticeDt,
		1		AS	Flag


FROM #Eligible_Data Data


LEFT JOIN LEGALVW.PermissionDetails					ON	Data.CustomerEntityId=PermissionDetails.CustomerEntityId
														AND PermissionDetails.EffectiveFromTimeKey<=@TimeKey
														AND PermissionDetails.EffectiveToTimeKey>=@TimeKey
														AND PermissionDetails.PermissionNatureAlt_Key=120

LEFT JOIN	LEGALVW.SRFBasicDtls					ON	SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId
														AND SRFBasicDtls.EffectiveFromTimeKey <= @TimeKey 
														AND SRFBasicDtls.EffectiveToTimeKey >= @TimeKey
														AND SRFBasicDtls.DemandNoticeDt<=@Date

WHERE SRFBasicDtls.CaseEntityId IS NULL  AND @Flag<>2

GROUP BY	Data.BranchCode,
			Data.CustomerEntityId,
			Data.AccountEntityId,
			Data.SecurityEntityID


UNION ALL

SELECT	TB.BranchCode
		,ACBD.CustomerEntityId
		,ACBD.AccountEntityId
		,Sec.SecurityEntityID
		,PermissionDetails.CaseEntityId
		,SRFBasicDtls.DemandNoticeDt
		,CASE	WHEN	Possestion.PhysicalPossessionDt IS NOT NULL
				THEN	'P'
				WHEN	Possestion.SecurityEntityID IS NOT NULL
				THEN	'S'
				END																		AS	PossestionType
		,CASE	WHEN	Possestion.SecurityEntityID IS NOT NULL
				THEN	ISNULL(PhysicalPossessionDt,ISNULL(SymbolicPossessionDt,ISNULL(PossessionNoticeDt,NPADt)))
				END																		AS	PossesionDt
		,PossessionNoticeDt																AS	PossessionNoticeDt

		,2																				AS	Flag

FROM	#TempBranch TB
INNER JOIN #AC_DATA    ACBD 											ON  ACBD.BranchCode=TB.BranchCode 
																				--AND ACBD.EffectiveFromTimeKey <= @TimeKey
																				--AND ACBD.EffectiveToTimeKey >= @TimeKey

--INNER JOIN CustomerBasicDetail	CBD												ON	CBD.CustomerEntityId=ACBD.CustomerEntityId
--																				AND CBD.EffectiveFromTimeKey <= @TimeKey 
--																				AND CBD.EffectiveToTimeKey >= @TimeKey


INNER JOIN AdvCustNpaDetail														ON	AdvCustNpaDetail.CustomerEntityId=ACBD.CustomerEntityId
																				AND AdvCustNpaDetail.EffectiveFromTimeKey <= @TimeKey 
																				AND AdvCustNpaDetail.EffectiveToTimeKey >= @TimeKey
																				AND AdvCustNpaDetail.NPADt IS NOT NULL

INNER JOIN	LEGALVW.PermissionDetails											ON	PermissionDetails.CustomerEntityID=ACBD.CustomerEntityID
																				AND PermissionDetails.EffectiveFromTimeKey <= @TimeKey 
																				AND PermissionDetails.EffectiveToTimeKey >= @TimeKey
																				AND PermissionDetails.PermissionNatureAlt_Key = 120 

INNER JOIN	LEGALVW.SRFBasicDtls												ON	SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId
																				AND SRFBasicDtls.EffectiveFromTimeKey <= @TimeKey 
																				AND SRFBasicDtls.EffectiveToTimeKey >= @TimeKey
																				AND SRFBasicDtls.DemandNoticeDt <=@Date

left JOIN #Eligible_Data	Sec													ON	Sec.AccountEntityId=ACBD.AccountEntityId


LEFT JOIN  #Possestion	 Possestion												ON	Possestion.SecurityEntityID=Sec.SecurityEntityId
																				

WHERE @Flag<>1

GROUP BY	TB.BranchCode
			,ACBD.CustomerEntityId
			,ACBD.AccountEntityId
			,Sec.SecurityEntityID
			,PermissionDetails.CaseEntityId
			,PhysicalPossessionDt
			,SymbolicPossessionDt
			,PossessionNoticeDt
			,NPADt
			,Possestion.SecurityEntityId
			,SRFBasicDtls.DemandNoticeDt
			,PossessionNoticeDt
)A
OPTION (RECOMPILE)
 

--DELETE A
--FROM #FinalData A
--INNER JOIN	AdvCustOtherDetail B						ON	A.CustomerEntityId=B.CustomerEntityId
--															AND B.EffectiveFromTimeKey <= @TimeKey 
--															AND B.EffectiveToTimeKey >= @TimeKey
--															AND	(B.FraudNotioced='Y')




--DELETE A
--FROM #FinalData A
--INNER JOIN	LEGAL.CustSrfMeetingCondition B			ON	A.CustomerEntityId=B.CustomerEntityId
--															AND B.EffectiveFromTimeKey <= @TimeKey 
--															AND B.EffectiveToTimeKey >= @TimeKey
--															AND B.CustomerEntityId IS NOT NULL
--															AND B.BankConf='R'

--DELETE A
--FROM #FinalData A
--INNER JOIN	LEGALVW.ProceedingCompromiseDtls B			ON	A.CustomerEntityId=B.CustomerEntityId
--															AND B.EffectiveFromTimeKey <= @TimeKey 
--															AND B.EffectiveToTimeKey >= @TimeKey
--															AND B.CustomerEntityId IS NOT NULL	


--DELETE A
--FROM #FinalData A
--INNER JOIN	LEGALVW.InsolvencyDtls B					ON	A.CustomerEntityId=B.CustomerEntityId
--															AND B.EffectiveFromTimeKey <= @TimeKey 
--															AND B.EffectiveToTimeKey >= @TimeKey
--															AND B.CustomerEntityId IS NOT NULL	

--DELETE A
--FROM #FinalData A
--INNER JOIN	AdvCustConsortiumDetail B					ON	A.CustomerEntityId=B.CustomerEntityId
--															AND B.EffectiveFromTimeKey <= @TimeKey 
--															AND B.EffectiveToTimeKey >= @TimeKey
--															AND B.ConsortiumBankAlt_Key=201
--															AND B.ParticipationType='Memeber'


SELECT * FROM #FinalData
