
/****** Object:  StoredProcedure [dbo].[SARFAESI_Dashboard_GRID_New]    Script Date: 17-10-2024 14:45:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE  [dbo].[SARFAESI_Dashboard_GRID_New]
        
      @UserLoginId    AS VARCHAR(50)
     ,@TimeKey	      AS INT
     ,@Screen         AS VARCHAR(20)
     ,@Location       AS varchar(10)
     ,@LocationCode   AS varchar(Max)
	 ,@SecurityType INT =1

   AS


--DECLARE   
--@UserLoginId VARCHAR(50)='gmho123'  
--,@TimeKey AS INT=49999  
--,@Screen    AS VARCHAR(20)='SARFAESI'  
--,@Location varchar(10)='ZO'  
--,@LocationCode varchar(Max)=N'103'
--,@SecurityType INT =3


 SET NOCOUNT ON; 

BEGIN
  
 
DECLARE @UserLocationCode varchar(MAX),@UserLocation Varchar(MAX)  
  
  
IF (ISNULL(@Location,'')='' OR ISNULL(@LocationCode,'')='')  
    BEGIN   
     Select @UserLocation=UserLocation,@UserLocationCode=UserLocationCode from DimUserInfo   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  UserLoginID=@UserLoginId  
    END  
	ELSE 
	BEGIN
	SELECT @UserLocation=@Location,@UserLocationCode=@LocationCode 
	END
  
DECLARE @CurrentDate DATE = (SELECT Date FROM SYSDAYMATRIX WHERE TIMEKEY =@TimeKey)  
print  @UserLocationCode   
print @UserLocation  
  
  

   
IF (OBJECT_ID('tempdb..#TempBr') IS NOT NULL)   
DROP TABLE #TempBr  
  
SELECT DISTINCT DimBranch.BranchCode,  
  DimBranch.BranchCode2,  DimBranch.BranchName ,
  
  LTRIM(RTRIM(REPLACE(DimRegion.RegionName,'REGION',''))) AS RegionShortName,  
  DimBranch.BranchRegionAlt_Key,  
  
  LTRIM(RTRIM(REPLACE(DimZone.ZoneName,'ZONE',''))) AS ZoneShortName,  
  DimBranch.BranchZoneAlt_Key  
  
  INTO #TempBr  
  
FROM DimBranch  
  
INNER JOIN DimZone      ON DimBranch.BranchZoneAlt_Key=DimZone.ZoneAlt_Key  
           AND DimBranch.EffectiveFromTimeKey<=@TimeKey  
           AND DimBranch.EffectiveToTimeKey>=@TimeKey  
           AND DimZone.EffectiveFromTimeKey<=@TimeKey  
           AND DimZone.EffectiveToTimeKey>=@TimeKey  
  
INNER JOIN DimRegion     ON DimBranch.BranchRegionAlt_Key=DimRegion.RegionAlt_Key  
           AND DimRegion.EffectiveFromTimeKey<=@TimeKey  
           AND DimRegion.EffectiveToTimeKey>=@TimeKey  
  
  
WHERE (@UserLocation='HO') OR  
  (@UserLocation='ZO' AND DimBranch.BranchZoneAlt_Key IN(SELECT * FROM dbo.Split(@UserLocationCode,','))) OR  
  (@UserLocation='RO' AND DimBranch.BranchRegionAlt_Key IN(SELECT * FROM dbo.Split(@UserLocationCode,','))) OR  
  (@UserLocation='BO' AND DimBranch.BranchCode IN(SELECT * FROM dbo.Split(@UserLocationCode,',')))  
  
OPTION (RECOMPILE)  
  
CREATE UNIQUE CLUSTERED INDEX IX_BRANCHKEY ON #TempBr(BranchCode)  

--------------------------------------------------------  
IF (OBJECT_ID('tempdb..#EligibleData_16') IS NOT NULL)  
     DROP TABLE #EligibleData_16  
  
CREATE TABLE #EligibleData_16 ([BranchCode] [VARCHAR](10) NULL,   
		  BranchName  [VARCHAR](100) NULL,
		  RegionAlt_key [VARCHAR](10),	  RegionName  [VARCHAR](100) NULL, 
		  ZoneAlt_key [VARCHAR](10) ,	  ZoneName  [VARCHAR](100) NULL,
		  CustomerId [VARCHAR](250) NULL,CustomerName [VARCHAR](250) NULL,
          [CustomerEntityId]     [INT] NULL,  
          [AccountEntityId]     [INT] NULL,  
          [SecurityEntityID]     [INT] NULL,  
          [CaseEntityID]      [INT] NULL,  
          [DemandNoticeDt]      [DATE] NULL,  
          [PossestionType]      [CHAR](1) NULL,  
          [PossesionDt]   [DATE] NULL,  
          [PossessionNoticeDt]     [DATE] NULL,  
          [Flag]                   [INT] NULL,  
          [total]                  [decimal](30,2)  
            )  
  
INSERT INTO #EligibleData_16  
  (
	 BranchCode,BranchName,RegionAlt_key,RegionName,ZoneAlt_key,ZoneName,CustomerId,CustomerName
	,CustomerEntityId
	,AccountEntityId
	,SecurityEntityID
	,CaseEntityId
	,DemandNoticeDt
	,PossestionType
	,PossesionDt
	,PossessionNoticeDt
	,Flag
	,Total
  )
  select 
  a.BranchCode,b.BranchName,b.BranchRegionAlt_Key,b.RegionShortName,b.BranchZoneAlt_Key,b.ZoneShortName
  ,cbd.Customerid, cbd.CustomerName
	,a.CustomerEntityId
	,AccountEntityId
	,SecurityEntityID
	,CaseEntityID
	,DemandNoticeDt
	,PossestionType
	,PossesionDt
	,PossessionNoticeDt
	,a.Flag
	,Null
	
  from SrfEligibleDashboard a
	INNER JOIN #TempBr b
		ON a.BranchCode=b.BranchCode 
	INNER JOIN curdat.customerbasicdetail cbd ON a.customerentityid = cbd.customerentityid	
	AND cbd.effectivetotimekey = 49999
--	where ISNULL(SecurityEntityID,'')<>''




--select 'mmm',* from #EligibleData_16 order by customerid

		
CREATE  CLUSTERED INDEX IX_eligibleData ON #EligibleData_16(CustomerEntityId)  
  
CREATE NONCLUSTERED INDEX IX_CustomerEntityId ON #EligibleData_16(BranchCode)  
         INCLUDE (    AccountEntityId  
            ,SecurityEntityID  
            ,Total  
            )  
	
  
  
  IF (OBJECT_ID('tempdb..#AllData') IS NOT NULL)  
     DROP TABLE #AllData  
   CREATE TABLE #AllData(
	    TotEligibleAccountSystem VARCHAR(20) --- CustomerEntityId 
	,   NPABalance DECIMAL(18,2)
	,   Tot13_2_IneligibleAccount  INT
	,   TotEligbleAccount INT
	,   [13_2_NoticeIssued]	 INT
	,   [13_2_NoticeNOTIssued]	 INT
	,   [13_2_NoticeAcknowledged]	 INT
	,   [13_2_NoticeNOTAcknowledge]	INT
	,   [13_2_NoticeNOTAcknowledge_20DAYS] INT
	,   NoticeAcknowleged_60days INT
	,   NoticeAcknowleged_NOT60days INT
	,   Symbolic_PossessionTaken	 INT
	,   Tot13_4_NOT_taken_Ineligible INT
	,  [60days_Symbolic_Possession_NOTtaken]  INT
	,   SymbolicPossessionTaken_PaperPublicationDone INT
	,   SymbolicPossessionTaken_PaperPublicationNOTDone	INT
	,	PossessionNoticeServicePending 	INT
	,   PaperPublicationDone_DMApplied	INT
	,   PaperPublicationDone_DMNotApplied	INT
	,   DMOrderReceived	 INT
	,   DMAppliedNOTReceived	 INT
	,   PhysicalPossessionTaken	 INT
	,   PhysicalPossessionNOTtaken	INT
	,   AuctionNoticePublished	INT
	,   PhysicalPossessionTaken_AuctionNOTPublished	INT
	,   AuctionDateLapsed	INT
	,   ReauctionPublished 	INT
	,   ReauctionNOTpublished INT
	,   StayOrder	INT
	,   Litigation	INT
	,   Fraud	INT
	,   Consortium	INT
	,   Restructure	INT
	,   OTS INT
	,   CustomerEntityId INT
	,   AccountEntityId INT
	,   SecurityEntityID INT
	,   Withdrawal VARCHAR(10)
	,   Branchcode VARCHAR(10)
	,	BranchName VARCHAR(100)
	,	RegionAlt_key VARCHAR(10) , RegionName VARCHAR(100)
	,	ZoneAlt_key VARCHAR(10), ZoneName VARCHAR(100), CaseEntityId INT, CustomerId VARCHAR(50), CustomerName VARCHAR(250)
	,   IneligibleRemarks VARCHAR(MAX)
	,[13_2_NoticeIssuedDt] varchar(10)
	,[Dateofacknowledgement] VARCHAR(10)
)



CREATE  CLUSTERED INDEX IX_AllData ON #AllData(CustomerEntityId)  



IF @SecurityType =1 
BEGIN
  INSERT INTO #AllData (CustomerEntityId,AccountEntityId,--SecurityEntityID,
  TotEligibleAccountSystem,Branchcode,BranchName,RegionAlt_key,
						RegionName,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName)
  
  
  SELECT DISTINCT EData.CustomerEntityId,EData.AccountEntityId,--SecurityEntityID,
   EData.CustomerEntityId,BranchCode,BranchName,RegionAlt_key,RegionName
					,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName
    FROM #EligibleData_16 EData
	INNER JOIN AdvSecurityValueDetail ADvSec  ON EData.CustomerEntityId = ADvSec.CustomerEntityId
	INNER JOIN DimSecurity DS ON ADvSec.SecurityAlt_Key = DS.SecurityAlt_Key 
	AND (ADvSec.EffectiveFromTimeKey<=49999 AND  ADvSec.EffectiveToTimeKey>=49999) 
	AND (DS.EffectiveFromTimeKey<=49999 AND  DS.EffectiveToTimeKey>=49999) 
	--WHERE (SecurityGroup IN('MORTGAGE' ,'Hypothecation')
	--OR ISNULL(ADvSec.SecurityNature,'') IN ('HYPOTHECATION','MORTGAGE')
	--OR ISNULL(DS.SecurityName,'') like '%HYPO%' OR ISNULL(DS.SecurityName,'') like '%MORTGAGE%')

		WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024


END


IF @SecurityType =2 
BEGIN

  INSERT INTO #AllData (CustomerEntityId,AccountEntityId,--SecurityEntityID,
  TotEligibleAccountSystem,Branchcode,BranchName,RegionAlt_key,
						RegionName,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName)
  
	SELECT distinct EData.CustomerEntityId,EData.AccountEntityId,--SecurityEntityID,
   EData.CustomerEntityId,BranchCode,BranchName,RegionAlt_key,RegionName
					,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName
	FROM #EligibleData_16 EData
	INNER JOIN AdvSecurityValueDetail ADvSec  ON EData.CustomerEntityId = ADvSec.CustomerEntityId
	INNER JOIN DimSecurity DS ON ADvSec.SecurityAlt_Key = DS.SecurityAlt_Key 
	AND (ADvSec.EffectiveFromTimeKey<=49999 AND  ADvSec.EffectiveToTimeKey>=49999) 
	AND (DS.EffectiveFromTimeKey<=49999 AND  DS.EffectiveToTimeKey>=49999) 
	--WHERE (DS.SecurityGroup IN('HYPOTHECATION' )
	--OR ISNULL(ADvSec.SecurityNature,'') IN ('HYPOTHECATION')
	--OR ISNULL(DS.SecurityName,'') like '%HYPO%' )
	 --WHERE DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation')
	 --AND DS.SecurityAlt_Key IN (101,105,110,111,112,113,114,115,118,120,125,130,135,140,155,1005,1006,1007)-- movable

	 	WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
		AND DS.Movable='Y'

	END  

 IF @SecurityType =3 
BEGIN


  INSERT INTO #AllData (CustomerEntityId,AccountEntityId,--SecurityEntityID,
  TotEligibleAccountSystem,Branchcode,BranchName,RegionAlt_key,
						RegionName,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName)
 SELECT distinct EData.CustomerEntityId,EData.AccountEntityId,--SecurityEntityID,
   EData.CustomerEntityId,BranchCode,BranchName,RegionAlt_key,RegionName
					,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName
FROM #EligibleData_16 EData
INNER JOIN AdvSecurityValueDetail ADvSec  ON EData.CustomerEntityId = ADvSec.CustomerEntityId
INNER JOIN DimSecurity DS ON ADvSec.SecurityAlt_Key = DS.SecurityAlt_Key 
AND (ADvSec.EffectiveFromTimeKey<=49999 AND  ADvSec.EffectiveToTimeKey>=49999) 
AND (DS.EffectiveFromTimeKey<=49999 AND  DS.EffectiveToTimeKey>=49999) 
--WHERE (DS.SecurityGroup IN('MORTGAGE' ) 
--OR ISNULL(ADvSec.SecurityNature,'') IN ('MORTGAGE')
--OR ISNULL(DS.SecurityName,'') like '%MORTGAGE%')
 --WHERE --DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation') AND 
 -- DS.SecurityAlt_Key IN (125,135,201,202,205,206,209,210,215,
--216,219,220,223,224,225,226,229,230,232,236,238,241,242,243,244,245,
--246,248,237,992,993,999,1262)-- immovable


WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
		AND DS.Immovable='Y'

END  
   	 ------------ NPA Balance --------------

   	IF OBJECT_ID('TEMPDB..#TMP_BalanceData') IS NOT NULL
				DROP TABLE #TMP_BalanceData
 

 SELECT Distinct  T.CustomerEntityId ,BalanceSum  
 	INTO #TMP_BalanceData
 FROM (
		SELECT CBD.CustomerEntityId,CBD.CustomerId,CBD.CustomerName,SUM(ISNULL(BAL.Balance,0)) AS BalanceSum
	
		FROM CustomerBasicDetail CBD WITH(NOLOCK)
		INNER JOIN AdvAcBasicDetail ABD WITH(NOLOCK)
		ON CBD.CustomerEntityId=ABD.CustomerEntityId
		AND ABD.EffectiveToTimeKey=49999
		INNER JOIN AdvAcBalanceDetail BAL WITH(NOLOCK)
		ON ABD.AccountEntityId=BAL.AccountEntityId
		AND BAL.EffectiveToTimeKey=49999
		
		WHERE CBD.EffectiveToTimeKey=49999
		AND CBD.CustType<>'OTHERS' 
		GROUP BY CBD.CustomerEntityId,CBD.CustomerId,CBD.CustomerName
		)T
		INNER JOIN #EligibleData_16 SR 
		ON T.CustomerEntityId = SR.CustomerEntityId 
	


		OPTION (RECOMPILE) 


		--------------- Insert NPA Balance for ELigible Customers ----------------------

		UPDATE A  
		SET NPABalance = T.BalanceSum
		FROM #TMP_BalanceData T INNER JOIN #AllData A 
		ON  T.CustomerEntityId = A.CustomerEntityId

		 

	 ----------------------------Mark Withdrawal Customers ------------------


		UPDATE #AllData
		SET Withdrawal = CASE WHEN B.CaseEntityId IS NOT NULL THEN 1 ELSE 0 END     
		FROM #AllData A  
		INNER JOIN LEGALVW.PermissionDetails   ON PermissionDetails.CustomerEntityID=A.CustomerEntityID  
							AND PermissionDetails.EffectiveFromTimeKey <= 49999   
							AND PermissionDetails.EffectiveToTimeKey >= 49999  
							AND PermissionDetails.PermissionNatureAlt_Key = 120  
  
		LEFT JOIN legal.WithdrawalDtls  B  ON PermissionDetails.CaseEntityId=B.CaseEntityId  
							AND B.EffectiveFromTimeKey <= 49999   
							AND B.EffectiveToTimeKey >= 49999  

	OPTION (RECOMPILE)

	----------------------------Mark Ineligible customer ------------------------------

 
		 UPDATE A 
		 SET  Tot13_2_IneligibleAccount =CASE WHEN B.CustomerEntityId IS NOT NULL  THEN A.CustomerEntityId ELSE NULL END     
		FROM #AllData A  
		LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
					   AND B.EffectiveFromTimeKey <= 49999   
					   AND B.EffectiveToTimeKey >= 49999  
					   AND B.BankConf='R'  
					--   AND B.CustomerEntityId IS NOT NULL  
		LEFT JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
					   AND C.EffectiveFromTimeKey <= 49999   
					   AND C.EffectiveToTimeKey >= 49999  
              
		OPTION (RECOMPILE)

		

----------------------------Mark eligible account ------------------------------

	UPDATE A 
	SET  TotEligbleAccount =	CASE WHEN ISNULL(Tot13_2_IneligibleAccount,'') = '' THEN A.CustomerEntityId  
									 WHEN ISNULL(Tot13_2_IneligibleAccount,'') <> '' THEN NULL END
	FROM #AllData A  


		
---------------------------------- 13(2) Demand Notice Issued----------------------------

   	IF OBJECT_ID('TEMPDB..#DemandNotice') IS NOT NULL
				DROP TABLE #DemandNotice


SELECT CBD.CustomerEntityID,MAX(SRFBsc.DemandNoticeDt) DemandNoticeDt  INTO #DemandNotice 

FROM #AllData CBD

LEFT JOIN LEGALVW.PermissionDetails  ON PermissionDetails.CustomerEntityID=CBD.CustomerEntityID  
                    AND PermissionDetails.EffectiveFromTimeKey <= 49999   
                    AND PermissionDetails.EffectiveToTimeKey >= 49999  
                    AND PermissionDetails.PermissionNatureAlt_Key = 120   
  
LEFT JOIN LEGALVW.SRFBasicDtls  SRFBsc ON SRFBsc.CaseEntityId=PermissionDetails.CaseEntityId  
                    AND SRFBsc.EffectiveFromTimeKey <= 49999   
                    AND SRFBsc.EffectiveToTimeKey >= 49999  
 -- WHERE CBD.TotEligbleAccount IS NOT NULL
  GROUP  BY CBD.CustomerEntityID



--UPDATE #AllData
--SET [13_2_NoticeIssued] = CASE WHEN ISNULL(SRFBsc.DemandNoticeDt,'')<>'' 
--						--  AND CBD.TotEligbleAccount IS NOT NULL     --- excluding the ineligible accounts 
--						  THEN cbd.CustomerEntityID 
--						  ELSE NULL END
--, [13_2_NoticeIssuedDt] =SRFBsc.DemandNoticeDt
--FROM  #AllData CBD     
--LEFT JOIN #DemandNotice SRFBsc ON  CBD.CustomerEntityId = SRFBsc.CustomerEntityId
  

  

UPDATE #AllData
SET [13_2_NoticeIssued] = CASE WHEN ISNULL(SRFBsc.DemandNoticeDt,'')<>'' 
						--  AND CBD.TotEligbleAccount IS NOT NULL     --- excluding the ineligible accounts 
						  THEN cbd.CustomerEntityID 
							ELSE NULL END
, [13_2_NoticeIssuedDt] =SRFBsc.DemandNoticeDt

FROM  #AllData CBD     
LEFT JOIN #DemandNotice SRFBsc ON  CBD.CustomerEntityId = SRFBsc.CustomerEntityId
  


---------------------------------- 13(2) Demand Notice NOT Issued ----------------------------


	UPDATE A 
	SET  [13_2_NoticeNOTIssued] =	CASE WHEN ISNULL([13_2_NoticeIssued],'') = '' THEN CustomerEntityID  
										 WHEN ISNULL([13_2_NoticeIssued],'') <> ''  THEN NULL END
	FROM #AllData A  
	WHERE  A.TotEligbleAccount IS NOT NULL     --- excluding the ineligible accounts  

	
  

IF (OBJECT_ID('tempdb..#Possession') IS NOT NULL)  
     DROP TABLE #Possession  
  
  
SELECT DISTINCT  
  B.CustomerEntityId,  
  MAX(A.PossessionNoticeDt)  AS PossessionNoticeDt,  
  MAX(A.PhysicalPossessionDt)  AS PhysicalPossessionDt,  
  MAX(A.SymbolicPossessionDt)  AS SymbolicPossessionDt,  
  MAX(A.ApliMMDMDt)    AS ApliMMDMDt,  
  MAX(A.DecisionDt)    AS DecisionDt,  
  MAX(A.DtPossnNoticePaper)       AS  DtPossnNoticePaper,  
  MAX(A.DtPossnNoticePaperVer)    AS  DtPossnNoticePaperVer  
  ,MAX(DMApproached)DMApproached  
  ,max(ApplicationAgAction)ApplicationAgAction  
  ,MAX(C.DemandNoticeDt)DemandNoticeDt
   ,MAX(A.PossesionNoticeServiceDt) PossesionNoticeServiceDt -- 12062024
  ,A.SecurityEntityId,B.AccountEntityId,A.CaseEntityId
INTO #Possession  
  
FROM LEGAL.SRFPossessionDtls A  
INNER JOIN AdvSecurityValueDetail B   ON A.SecurityEntityID=B.SecurityEntityID  
             AND A.EffectiveFromTimeKey<=49999 AND A.EffectiveToTimeKey>=49999  
             AND B.EffectiveFromTimeKey<=49999 AND B.EffectiveToTimeKey>=49999  
             AND A.PossessionNoticeDt<GETDATE()  
INNER JOIN dbo.DimSecurity DS ON DS.SecurityAlt_key = B.SecurityAlt_key
 AND DS.EffectiveFromTimeKey<=49999 AND DS.EffectiveToTimeKey>=49999   
 INNER JOIN  LEGALVW.SRFBasicDtls C ON C.CustomerEntityId = B.CustomerEntityId
 WHERE  B.CustomerEntityId IN (SELECT DISTINCT CustomerEntityId FROM #AllData )
 --AND 1 =  CASE WHEN (@SecurityType = 2 AND  DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation')
	-- AND DS.SecurityAlt_Key IN (101,105,110,111,112,113,114,115,118,120,125,130,135,140,155,1005,1006,1007) )THEN 1-- movable

	-- WHEN ( @SecurityType = 3 AND  DS.SecurityAlt_Key IN (125,135,201,202,205,206,209,210,215,
	--		216,219,220,223,224,225,226,229,230,232,236,238,241,242,243,244,245,246,248,237,992,993,999,1262) ) THEN 1

	-- WHEN @SecurityType = 1 THEN 1 END

	AND 1 =  CASE WHEN (@SecurityType = 2 
					---------LOGIC CHNAGES BY TRILOKI 
					--AND ( DS.SecurityGroup IN('Hypothecation' )
					--OR ISNULL(B.SecurityNature,'') IN ('HYPOTHECATION')
					--OR ISNULL(DS.SecurityName,'') like '%HYPO%' )
						
			--AND  DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation')
			-- AND DS.SecurityAlt_Key IN (101,105,110,111,112,113,114,115,118,120,125,130,135,140,155,1005,1006,1007) 
	 
			AND DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
			and DS.movable='Y'

	 )THEN 1-- movable

	 WHEN ( @SecurityType = 3 AND  ---LOGIC CHNAGES BY TRILOKI 
						--(DS.SecurityGroup IN('MORTGAGE' ) 
						--OR ISNULL(B.SecurityNature,'') IN ('MORTGAGE')
						--OR ISNULL(DS.SecurityName,'') like '%MORTGAGE%')					
			--DS.SecurityAlt_Key IN (125,135,201,202,205,206,209,210,215,
			--216,219,220,223,224,225,226,229,230,232,236,238,241,242,243,244,245,246,248,237,992,993,999,1262
			-----added new alt key by triloki
			--,235,247
			--) 
				DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
			AND DS.Immovable='Y'
			) THEN 1

	 WHEN @SecurityType = 1
		-----ADDED NEW LOGIC BY TRILOKI
	 --and ( SecurityGroup IN('MORTGAGE' ,'Hypothecation')
		--						OR ISNULL(B.SecurityNature,'') IN ('HYPOTHECATION','MORTGAGE')
		--						OR ISNULL(DS.SecurityName,'') like '%HYPO%' OR ISNULL(DS.SecurityName,'') like '%MORTGAGE%')

		 AND DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024

	 THEN 1 END


GROUP BY B.CustomerEntityId  ,A.SecurityEntityId,B.AccountEntityId,A.CaseEntityId
  
OPTION (RECOMPILE)  


--select *From #Possession where CustomerEntityId =91


IF (OBJECT_ID('tempdb..#BIDINGS') IS NOT NULL)  
     DROP TABLE #BIDINGS  
  
SELECT  SRFBidingDtls.CaseEntityId  
        ,MAX(NextSaleDisposalDt)NextSaleDisposalDt  
  ,MAX(SaleNoticeDt)SaleNoticeDt   
  ,MAX(SaleDisposalDt)SaleDisposalDt  
   
 INTO #BIDINGS   
FROM [legal].SRFBidingDtls  
INNER JOIN LEGALVW.SRFBasicDtls ON  SRFBidingDtls.CaseEntityId =SRFBasicDtls.CaseEntityId  
AND SRFBidingDtls.EffectiveFromTimeKey <= 49999   
AND SRFBidingDtls.EffectiveToTimeKey >= 49999   
AND SRFBasicDtls.EffectiveFromTimeKey <= 49999   
AND SRFBasicDtls.EffectiveToTimeKey >= 49999   
  
GROUP BY SRFBidingDtls.CaseEntityId  
  
OPTION (RECOMPILE) 

 
--  IF (OBJECT_ID('tempdb..#DefendantServiceNoticeDtls') IS NOT NULL)  
-- DROP TABLE #DefendantServiceNoticeDtls  
  
--SELECT  
--D.CaseEntityId,  
--MAX(NoticeAcknowledgedDt)NoticeAcknowledgedDt  
--INTO #DefendantServiceNoticeDtls  
--FROM [legal].[DefendantServiceNoticeDtls]  D  INNER JOIN #AllData A  ON A.CaseEntityId = D.CaseEntityId
--WHERE EffectiveFromTimeKey <= 49999 AND EffectiveToTimeKey >= 49999 ---AND NoticeAcknowledgedDt IS NULL  
  
--GROUP BY D.CaseEntityId-----,NoticeAcknowledgedDt  
  
   IF (OBJECT_ID('tempdb..#DefendantServiceNoticeDtls') IS NOT NULL)  
 DROP TABLE #DefendantServiceNoticeDtls  
  
SELECT  
D.CaseEntityId,  
MAX(NoticeAcknowledgedDt)NoticeAcknowledgedDt  
INTO #DefendantServiceNoticeDtls  
FROM [legal].[DefendantServiceNoticeDtls]  D  INNER JOIN legal.SRFBasicDtls Srf
ON d.CaseEntityId = srf.CaseEntityId
AND  srf.EffectiveFromTimeKey <= @TimeKey AND srf.EffectiveToTimeKey >= @TimeKey 
AND  D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey 
INNER JOIN #AllData A  ON A.CustomerEntityId = srf.CustomerEntityId
GROUP BY D.CaseEntityId-----,NoticeAcknowledgedDt  
  
   

 IF (OBJECT_ID('tempdb..#SrfDtls') IS NOT NULL)  
 DROP TABLE #SrfDtls

 SELECT [13_2_NoticeIssued],SRFBasicDtls.DemandNoticeDt ,A.CustomerEntityId,SRFBasicDtls.CaseEntityId
 INTO #SrfDtls
 from LEGALVW.SRFBasicDtls SRFBasicDtls
 INNER JOIN #AllData A ON  A.CustomerEntityId = SRFBasicDtls.CustomerEntityId
   AND SRFBasicDtls.EffectiveFromTimeKey <= 49999 AND SRFBasicDtls.EffectiveToTimeKey >= 49999  
 WHERE ISNULL(SRFBasicDtls.DemandNoticeDt,'') <>''

  

OPTION(RECOMPILE)  
-----------------------------------------Notice Acknowledge----------------------------------

UPDATE #AllData
SET [13_2_NoticeIssued] = CASE WHEN A.[13_2_NoticeIssued] IS NOT NULL AND   A.TotEligbleAccount IS NOT NULL THEN A.CustomerEntityId ELSE NULL END 
--added  16062024
, [13_2_NoticeAcknowledged] = CASE WHEN defendant.NoticeAcknowledgedDt IS NOT NULL 
								AND A.[13_2_NoticeIssued] IS NOT NULL 
								AND Tot13_2_IneligibleAccount IS NULL  --11062024
								THEN A.CustomerEntityId ELSE NULL END  -- Notice acknowledged 

, [13_2_NoticeNOTAcknowledge] = CASE WHEN defendant.NoticeAcknowledgedDt IS NULL  AND A.[13_2_NoticeIssued] IS NOT NULL
								AND Tot13_2_IneligibleAccount IS NULL  --11062024
										THEN A.CustomerEntityId ELSE NULL END  -- Notice Not acknowledged 

,[13_2_NoticeNOTAcknowledge_20DAYS] = CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											AND defendant.NoticeAcknowledgedDt IS NULL
											AND PossessionNoticeDt IS NULL
											AND Tot13_2_IneligibleAccount IS NULL  --11062024
											)
											THEN 
											CASE WHEN  DATEDIFF(dd,SRFBasicDtls.DemandNoticeDt,Getdate()) >20 THEN A.CustomerEntityId
											ELSE NULL END ELSE NULL END  
											-- Notice Not acknowledged 20 days

,[NoticeAcknowleged_60days] =			CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											 AND   defendant.NoticeAcknowledgedDt  IS NOT NULL
											 AND   PossessionNoticeDt IS NULL
											 AND Tot13_2_IneligibleAccount IS NULL  --11062024
											 )
											 THEN
											 CASE WHEN (DATEDIFF(DD,defendant.NoticeAcknowledgedDt, GETDATE())>60 ) THEN A.CustomerEntityId
											 ELSE NULL End ELSE NULL END
											 
,[NoticeAcknowleged_NOT60days] =		CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											 AND defendant.NoticeAcknowledgedDt  IS NOT NULL
											 AND PossessionNoticeDt  IS  NULL
											 AND Tot13_2_IneligibleAccount IS NULL  --11062024
											 )
											 THEN
											 CASE WHEN (DATEDIFF(DD,defendant.NoticeAcknowledgedDt, GETDATE())<60 ) THEN A.CustomerEntityId
											 ELSE NULL End ELSE NULL END 
,[Dateofacknowledgement] =  defendant.NoticeAcknowledgedDt  -- added
FROM #AllData A
LEFT JOIN LEGALVW.PermissionDetails           ON PermissionDetails.CustomerEntityID=A.CustomerEntityID  
                    AND PermissionDetails.EffectiveFromTimeKey <= 49999   
                    AND PermissionDetails.EffectiveToTimeKey >= 49999  
                    AND PermissionDetails.PermissionNatureAlt_Key = 120  
        
  LEFT JOIN #SrfDtls SRFBasicDtls ON SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId     
--LEFT JOIN LEGALVW.SRFBasicDtls            ON SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId  
--                    AND SRFBasicDtls.EffectiveFromTimeKey <= 49999   
--                    AND SRFBasicDtls.EffectiveToTimeKey >= 49999  
--                    --AND SRFBasicDtls.DemandNoticeDt <=@CurrentDate  
                                  
LEFT JOIN #DefendantServiceNoticeDtls    Defendant ON SRFBasicDtls.CaseEntityId=Defendant.CaseEntityId 
LEFT JOIN #Possession  Possession                 ON Possession.CustomerEntityID=A.CustomerEntityID  
WHERE A.Withdrawal =0 --AND A.Tot13_2_IneligibleAccount IS NULL  -- change
 
 ----Account should not be withdrawn or Ineligible


 --select Distinct customerentityid from #AllData where [13_2_NoticeNOTAcknowledge] is not null

----------------------------------[Tot13_4_NOT_taken_Ineligible]--------------------------------------------


IF (OBJECT_ID('tempdb..#PossDtl') IS NOT NULL)  
     DROP TABLE #PossDtl
	 
SELECT DISTINCT Possession.SecurityEntityId,Possession.SymbolicPossessionDt,A.CustomerEntityId,PhysicalPossessionDt
 ,SRFBasicDtls.DemandNoticeDt,PossessionNoticeDt,Possession.ApliMMDMDt,
 DtPossnNoticePaper,DtPossnNoticePaperVer,DMApproached,Possession.DecisionDt ,Bidings.NextSaleDisposalDt,
 Bidings.SaleNoticeDt,Bidings.SaleDisposalDt,Possession.AccountEntityId,Tot13_2_IneligibleAccount,
A.Branchcode,RegionAlt_key,ZoneAlt_key
,Possession.PossesionNoticeServiceDt AS PossesionNoticeServiceDt --12062024
 INTO #PossDtl
 FROM #AllData A
LEFT JOIN LEGALVW.PermissionDetails ON PermissionDetails.CustomerEntityID=A.CustomerEntityID  
		
                    AND PermissionDetails.EffectiveFromTimeKey <= 49999   
                    AND PermissionDetails.EffectiveToTimeKey >= 49999  
                    AND PermissionDetails.PermissionNatureAlt_Key = 120  
        
  
LEFT JOIN LEGALVW.SRFBasicDtls ON SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId  
                    AND SRFBasicDtls.EffectiveFromTimeKey <= 49999   
                    AND SRFBasicDtls.EffectiveToTimeKey >= 49999  
                    --AND SRFBasicDtls.DemandNoticeDt <=@CurrentDate  
                                  
LEFT JOIN #DefendantServiceNoticeDtls    Defendant ON SRFBasicDtls.CaseEntityId=Defendant.CaseEntityId  
LEFT JOIN #Possession  Possession                  ON Possession.CustomerEntityID=A.CustomerEntityID 
													AND Possession.CaseEntityId = SRFBasicDtls.CaseEntityId
									

													
LEFT JOIN #BIDINGS   Bidings                        ON SRFBasicDtls.CaseEntityId=Bidings.CaseEntityId  
where  A.Withdrawal =0 


--select SymbolicPossessionDt,PhysicalPossessionDt,* From #Possession where CustomerEntityId =91
--select * from #PossDtl where CustomerEntityId=91
---------------------------------------------------------------------------------------------------

IF (OBJECT_ID('tempdb..#PossDetails') IS NOT NULL)  
     DROP TABLE #PossDetails

	 SELECT  
	 	CASE WHEN @UserLocation = 'HO' THEN ZoneAlt_key 
				 WHEN @UserLocation = 'ZO' THEN ZoneAlt_key
				 WHEN @UserLocation = 'RO' THEN RegionAlt_key
				 WHEN @UserLocation = 'BO' THEN BranchCode END AS [LocationCode] ,

				 CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerEntityId END AS CustomerEntityId

	
	,   SUM(Symbolic_PossessionTaken)Symbolic_PossessionTaken
	,   SUM(Tot13_4_NOT_taken_Ineligible )Tot13_4_NOT_taken_Ineligible
	,   SUM([60days_Symbolic_Possession_NOTtaken])  [Symbolic_Possession_NOTtaken_60days]
	,   SUM(SymbolicPossessionTaken_PaperPublicationDone)SymbolicPossessionTaken_PaperPublicationDone
	,   SUM(SymbolicPossessionTaken_PaperPublicationNOTDone)SymbolicPossessionTaken_PaperPublicationNOTDone
	,	SUM(PossessionNoticeServicePending)PossessionNoticeServicePending
	,   SUM(PaperPublicationDone_DMApplied)PaperPublicationDone_DMApplied
	,   SUM(PaperPublicationDone_DMNotApplied)PaperPublicationDone_DMNotApplied
	,   SUM(DMOrderReceived)DMOrderReceived
	,   SUM(DMAppliedNOTReceived)	 DMAppliedNOTReceived
	,   SUM(PhysicalPossessionTaken) PhysicalPossessionTaken
	,   SUM(PhysicalPossessionNOTtaken)PhysicalPossessionNOTtaken
	,   SUM(AuctionNoticePublished)AuctionNoticePublished
	,   SUM(PhysicalPossessionTaken_AuctionNOTPublished)PhysicalPossessionTaken_AuctionNOTPublished
	,   SUM(AuctionDateLapsed)	AuctionDateLapsed
	,   SUM(ReauctionPublished)	ReauctionPublished
	
	,   SUM(ReauctionNOTpublished)ReauctionNOTpublished
	INTO #PossDetails
	FROM
		(
		SELECT  DISTINCT CustomerEntityId,Branchcode,RegionAlt_key,ZoneAlt_key,SecurityEntityId
			,CASE WHEN ISNULL(SecurityEntityId,'')<>''
				AND   ISNULL(SymbolicPossessionDt,'')<>'' 
				AND Tot13_2_IneligibleAccount IS NULL
				THEN 1 ELSE 0 END AS [Symbolic_PossessionTaken]

			  ,CASE WHEN ( Tot13_2_IneligibleAccount IS NOT NULL AND ISNULL(DemandNoticeDt ,'')<>'' 
				AND ISNULL(PossessionNoticeDt,'')='' )THEN 1 ELSE 0 END AS [Tot13_4_NOT_taken_Ineligible]

			,CASE WHEN ISNULL(DemandNoticeDt ,'')<>''    AND ISNULL(PossessionNoticeDt,'')='' AND Tot13_2_IneligibleAccount IS NULL
				THEN CASE WHEN (DATEDIFF(DD,DemandNoticeDt, GETDATE())>60 )
				
				THEN 1 ELSE 0 End ELSE 0 END 
				AS [60days_Symbolic_Possession_NOTtaken]

			,CASE WHEN (SymbolicPossessionDt IS NOT NULL 
				AND (DtPossnNoticePaper IS NOT NULL AND DtPossnNoticePaperVer IS NOT NULL)) 
				AND Tot13_2_IneligibleAccount IS NULL  THEN 1 ELSE 0 END
				AS [SymbolicPossessionTaken_PaperPublicationDone]

			,CASE WHEN (SymbolicPossessionDt IS NOT NULL 
				AND (DtPossnNoticePaper IS NULL OR DtPossnNoticePaperVer IS NULL))   
				AND Tot13_2_IneligibleAccount IS NULL
				THEN 1 ELSE 0 END
				AS [SymbolicPossessionTaken_PaperPublicationNOTDone]

			--, CASE WHEN DemandNoticeDt IS NOT NULL  AND PossessionNoticeDt IS NULL AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END
			--AS [PossessionNoticeServicePending]

				, CASE WHEN DemandNoticeDt IS NOT NULL AND SymbolicPossessionDt IS NOT NULL  AND PossesionNoticeServiceDt IS NULL 
				AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END
				AS [PossessionNoticeServicePending]  ---12062024

			,CASE WHEN ((SymbolicPossessionDt IS NOT NULL AND (DtPossnNoticePaper IS not NULL OR DtPossnNoticePaperVer IS not NULL)) 
				AND ApliMMDMDt is not null)   -- AND DMApproached='Y'
				ANd (PhysicalPossessionDt IS  NULL) AND Tot13_2_IneligibleAccount IS NULL
				THEN 1 ELSE 0 END AS [PaperPublicationDone_DMApplied]

			,CASE WHEN ((SymbolicPossessionDt IS NOT NULL AND (DtPossnNoticePaper IS not NULL AND DtPossnNoticePaperVer IS not NULL))  
				AND (DMApproached='N'  and ApliMMDMDt is NULL)  
				ANd (PhysicalPossessionDt IS  NULL)) AND Tot13_2_IneligibleAccount IS NULL
				THEN 1 ELSE 0 END
				AS [PaperPublicationDone_DMNotApplied] 

				,CASE WHEN (DMApproached='Y' AND ApliMMDMDt IS NOT NULL  
				AND DecisionDt IS NOT NULL --AND PhysicalPossessionDt IS NOT NULL
				) AND Tot13_2_IneligibleAccount IS NULL  
				THEN 1 ELSE 0 END AS [DMOrderReceived]
	
				,CASE WHEN (DMApproached='Y' AND ApliMMDMDt IS NOT NULL  
				AND DecisionDt IS  NULL --AND PhysicalPossessionDt IS NOT NULL
				)  AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END 
				AS [DMAppliedNOTReceived]
	
			--,CASE WHEN (DMApproached='Y' AND ApliMMDMDt IS NOT NULL  
			--	AND DecisionDt IS NOT NULL AND PhysicalPossessionDt IS NOT NULL) AND Tot13_2_IneligibleAccount IS NULL  THEN 1 ELSE 0 END AS [DMOrderReceived]--- need to check
	
			--,CASE WHEN (DMApproached='N' AND ApliMMDMDt IS NULL  
			--AND DecisionDt IS NOT NULL AND PhysicalPossessionDt IS NOT NULL)  AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END AS [DMAppliedNOTReceived]--- need to check
	
			
			, CASE WHEN (PhysicalPossessionDt is not null AND NextSaleDisposalDt IS NULL AND
														SaleNoticeDt IS NULL)   AND Tot13_2_IneligibleAccount IS NULL
			 THEN 1 ELSE 0 END [PhysicalPossessionTaken]
	
			, CASE WHEN ISNULL(PossessionNoticeDt,'')<>'' AND ISNULL(PhysicalPossessionDt,'')='' 
			AND Tot13_2_IneligibleAccount IS NULL
			THEN 1 ELSE 0 END  [PhysicalPossessionNOTtaken]

			, CASE WHEN (NextSaleDisposalDt IS NOT NULL AND	SaleNoticeDt IS NOT NULL AND SaleDisposalDt IS NULL )
			AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END [AuctionNoticePublished]

			,CASE WHEN  (PhysicalPossessionDt is not null   AND NextSaleDisposalDt    IS  NULL)
			AND	SaleNoticeDt IS NULL AND Tot13_2_IneligibleAccount IS NULL
			THEN 1 ELSE 0 END [PhysicalPossessionTaken_AuctionNOTPublished]

			, CASE WHEN SaleDisposalDt	Is Null AND NextSaleDisposalDt	Is Not Null    
			AND (NextSaleDisposalDt < GETDATE()) AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END [AuctionDateLapsed]
						
			,   CASE WHEN (SaleNoticeDt IS NOT NULL AND NextSaleDisposalDt IS  NOT NULL			 
			AND SaleDisposalDt IS NOT NULL)  AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END [ReauctionPublished]

			,   CASE WHEN (SaleNoticeDt IS NOT NULL AND NextSaleDisposalDt IS  NULL			 
			AND SaleDisposalDt IS NULL)  AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END [ReauctionNOTpublished]

			,SymbolicPossessionDt --added
			,DtPossnNoticePaperVer -- added
			,ApliMMDMDt -- added
			,DecisionDt --added
			,PhysicalPossessionDt --added
			,SaleNoticeDt -- added
			, NextSaleDisposalDt --added

			FROM #PossDtl 
		) Tab
	
	GROUP BY CASE WHEN @UserLocation = 'HO' THEN ZoneAlt_key 
				 WHEN @UserLocation = 'ZO' THEN ZoneAlt_key
				 WHEN @UserLocation = 'RO' THEN RegionAlt_key
				 WHEN @UserLocation = 'BO' THEN BranchCode END 

			,CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerEntityId END 
		
		
		
------------------------------------- Reject Reason wise column -----------------------------------
------------------------------------- Stay Order ----------------------------------------

UPDATE A
SET StayOrder =  CASE WHEN B.ReasonAlt_Key IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
               AND B.CustomerEntityId IS NOT NULL  
               AND B.BankConf='R'  
			   AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
              
  
INNER JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
               AND C.EffectiveFromTimeKey <= @TimeKey   
               AND C.EffectiveToTimeKey >= @TimeKey  
 WHERE     B.ReasonAlt_Key        =6 AND  A.Withdrawal =0
  

------------------------------------- Litigation -----------------------------------------

UPDATE A
SET Litigation =  CASE WHEN B.ReasonAlt_Key IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
               AND B.CustomerEntityId IS NOT NULL  
               AND B.BankConf='R'  
               AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
  
INNER JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
               AND C.EffectiveFromTimeKey <= @TimeKey   
               AND C.EffectiveToTimeKey >= @TimeKey  
 WHERE     B.ReasonAlt_Key        =3 AND  A.Withdrawal =0
 



-------------------------------------Consortium---------------------------------------

UPDATE A
SET Consortium =  CASE WHEN B.ReasonAlt_Key IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
               AND B.CustomerEntityId IS NOT NULL  
               AND B.BankConf='R'  
			   AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
              
  
INNER JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
               AND C.EffectiveFromTimeKey <= @TimeKey   
               AND C.EffectiveToTimeKey >= @TimeKey  
 WHERE     B.ReasonAlt_Key        =10 AND  A.Withdrawal =0
 
 -------------------------------------Restructure---------------------------

UPDATE A
SET Restructure =  CASE WHEN B.ReasonAlt_Key IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
               AND B.CustomerEntityId IS NOT NULL  
               AND B.BankConf='R' 
			   AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
              
  
INNER JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
               AND C.EffectiveFromTimeKey <= @TimeKey   
               AND C.EffectiveToTimeKey >= @TimeKey  
 WHERE     B.ReasonAlt_Key        =5 AND  A.Withdrawal =0

 -----------------------------------OTS-------------------------------

UPDATE A
SET OTS =  CASE WHEN B.ReasonAlt_Key IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN LEGAL.CustSrfMeetingCondition B   ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
               AND B.CustomerEntityId IS NOT NULL  
               AND B.BankConf='R'  
               AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
  
INNER JOIN LEGAL.DimSrfReason C      ON C.ReasonAlt_Key=B.ReasonAlt_Key  
               AND C.EffectiveFromTimeKey <= @TimeKey   
               AND C.EffectiveToTimeKey >= @TimeKey  
 WHERE     B.ReasonAlt_Key        =7 AND  A.Withdrawal =0
 
-------------------------------------	Fraud ------------------------------------------

UPDATE A
SET Fraud =  CASE WHEN B.CustomerEntityId IS NOT NULL THEN A.CustomerEntityId ELSE NULL END
FROM #AllData  A
LEFT JOIN AdvCustOtherDetail B  ON A.CustomerEntityId=B.CustomerEntityId  
               AND B.EffectiveFromTimeKey <= @TimeKey   
               AND B.EffectiveToTimeKey >= @TimeKey  
			  -- AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
			   AND (FraudAccoStatus='Y' OR FraudNotioced='Y')   
			   WHERE   A.Withdrawal =0

   
 
   ---------------------------------------------------------------------------------------
   IF (OBJECT_ID('tempdb..#FinalData') IS NOT NULL)   
	DROP TABLE #FinalData

  
  SELECT	ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,
				CASE WHEN @UserLocation = 'HO' THEN A.ZoneAlt_key 
				 WHEN @UserLocation = 'ZO' THEN A.ZoneAlt_key
				 WHEN @UserLocation = 'RO' THEN A.RegionAlt_key
				 WHEN @UserLocation = 'BO' THEN A.BranchCode END AS [LocationCode] ,

				 CASE WHEN @UserLocation = 'HO' THEN A.ZoneName 
				 WHEN @UserLocation = 'ZO' THEN A.ZoneName
				 WHEN @UserLocation = 'RO' THEN A.RegionName
				 WHEN @UserLocation = 'BO' THEN A.BranchName END AS [LocationName] ,

				 
				 CASE WHEN @UserLocation = 'HO' THEN 'HO' 
				 WHEN @UserLocation = 'ZO' THEN 'ZO'
				 WHEN @UserLocation = 'RO' THEN 'RO'
				 WHEN @UserLocation = 'BO' THEN 'BO' END AS [Location] ,

				 CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerId END AS CustomerId,

				  CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerName END AS CustomerName,


				
				COUNT(DISTINCT TotEligibleAccountSystem) TotEligibleAccountSystem,  
				SUM (DISTINCT NPABalance)NPABalance,
				COUNT(DISTINCT Tot13_2_IneligibleAccount)Tot13_2_IneligibleAccount,
				COUNT(DISTINCT TotEligbleAccount)TotEligbleAccount,
				COUNT(DISTINCT [13_2_NoticeIssued])[NoticeIssued_13_2],
				COUNT(DISTINCT [13_2_NoticeNOTIssued])[NoticeNOTIssued_13_2],
	
				COUNT(DISTINCT [13_2_NoticeAcknowledged]) AS [NoticeAcknowledged_13_2],
				COUNT(DISTINCT [13_2_NoticeNOTAcknowledge]) AS [NoticeNOTAcknowledge_13_2],
				COUNT(DISTINCT [13_2_NoticeNOTAcknowledge_20DAYS]) AS [NoticeNOTAcknowledge_13_2_20DAYS] ,
				COUNT(DISTINCT NoticeAcknowleged_60days) NoticeAcknowleged_60days,
				COUNT(DISTINCT NoticeAcknowleged_NOT60days) NoticeAcknowleged_NOT60days
				
				--SUM(Symbolic_PossessionTaken) Symbolic_PossessionTaken,
				--SUM(Tot13_4_NOT_taken_Ineligible) Tot13_4_NOT_taken_Ineligible,
				--SUM([60days_Symbolic_Possession_NOTtaken])  AS [Symbolic_Possession_NOTtaken_60days],
				--SUM(SymbolicPossessionTaken_PaperPublicationDone) AS SymbolicPossessionTaken_PaperPublicationDone,
				--SUM(SymbolicPossessionTaken_PaperPublicationNOTDone) AS SymbolicPossessionTaken_PaperPublicationNOTDone,
				--SUM(PossessionNoticeServicePending) AS  PossessionNoticeServicePending,
				--SUM(PaperPublicationDone_DMApplied) AS PaperPublicationDone_DMApplied,
				--SUM(PaperPublicationDone_DMNotApplied) AS PaperPublicationDone_DMNotApplied,
				--SUM(DMOrderReceived) AS DMOrderReceived,
				--SUM(DMAppliedNOTReceived) AS DMAppliedNOTReceived,
				--SUM(PhysicalPossessionTaken) AS PhysicalPossessionTaken,
				--SUM(PhysicalPossessionNOTtaken) AS PhysicalPossessionNOTtaken,
			 --   ISNULL(SUM(AuctionNoticePublished),0) AS AuctionNoticePublished,
				--ISNULL(SUM(PhysicalPossessionTaken_AuctionNOTPublished),0) AS PhysicalPossessionTaken_AuctionNOTPublished,
				--ISNULL(SUM(AuctionDateLapsed),0) AS AuctionDateLapsed
				--,ISNULL(SUM(ReauctionPublished),0)As ReauctionPublished
				--,ISNULL(SUM(ReauctionNOTpublished),0) AS ReauctionNOTpublished

				,COUNT(DISTINCT StayOrder) AS StayOrder
				,COUNT(DISTINCT Litigation) AS Litigation
				,COUNT(DISTINCT Fraud) AS Fraud
				,COUNT(DISTINCT Consortium) AS Consortium
				,COUNT(DISTINCT Restructure) AS Restructure
				,COUNT(DISTINCT OTS) AS OTS
			
			   ,CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN A.CustomerEntityId END AS CustomerEntityId,
				  CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN RegionAlt_key END AS RegionCode,
				  CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN ZoneAlt_key END AS ZoneCode,
				 
				 CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN BranchCode END AS BranchCode
	INTO #FinalData
	From #AllData A 
	
	WHERE ISNULL(Withdrawal,0) =0

	GROUP BY CASE WHEN @UserLocation = 'HO' THEN A.ZoneAlt_key 
				 WHEN @UserLocation = 'ZO' THEN A.ZoneAlt_key
				 WHEN @UserLocation = 'RO' THEN A.RegionAlt_key
				 WHEN @UserLocation = 'BO' THEN A.BranchCode END, 
				 
			  CASE WHEN @UserLocation = 'HO' THEN A.ZoneName
				 WHEN @UserLocation = 'ZO' THEN A.ZoneName
				 WHEN @UserLocation = 'RO' THEN A.RegionName
				 WHEN @UserLocation = 'BO' THEN A.BranchName END ,

			 CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerId END ,

			CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN CustomerName END 

			,CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN A.CustomerEntityId END ,
			
			CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN RegionAlt_key END ,
		 
		   CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN ZoneAlt_key END,
				 
			CASE WHEN @UserLocation = 'HO' THEN NULL
				 WHEN @UserLocation = 'ZO' THEN NULL
				 WHEN @UserLocation = 'RO' THEN NULL
				 WHEN @UserLocation = 'BO' THEN BranchCode END
		
		
		
		ORDER BY [LocationName]

		--SELECT  *FROM #FinalData
		--select * From #PossDetails
	   
	   IF @Location IN ('RO','HO','ZO')
	   BEGIN

  SELECT SrNo,FIn.LocationCode,LocationName,Location,Fin.CustomerId,CustomerName,TotEligibleAccountSystem	
		 ,NPABalance,Tot13_2_IneligibleAccount,TotEligbleAccount,NoticeIssued_13_2,NoticeNOTIssued_13_2	,NoticeAcknowledged_13_2	
		 ,NoticeNOTAcknowledge_13_2,NoticeNOTAcknowledge_13_2_20DAYS,NoticeAcknowleged_60days,NoticeAcknowleged_NOT60days	
		 
		 ,ISNULL(Poss.Symbolic_PossessionTaken	,0)Symbolic_PossessionTaken
		 ,ISNULL(Poss.Tot13_4_NOT_taken_Ineligible,0)Tot13_4_NOT_taken_Ineligible
		 ,ISNULL(Poss.Symbolic_Possession_NOTtaken_60days	,0)Symbolic_Possession_NOTtaken_60days
		 ,ISNULL(Poss.SymbolicPossessionTaken_PaperPublicationDone	,0)SymbolicPossessionTaken_PaperPublicationDone
		 ,ISNULL(Poss.SymbolicPossessionTaken_PaperPublicationNOTDone,0)	SymbolicPossessionTaken_PaperPublicationNOTDone
		 ,ISNULL(Poss.PossessionNoticeServicePending	,0)PossessionNoticeServicePending
		 ,ISNULL(Poss.PaperPublicationDone_DMApplied	,0)PaperPublicationDone_DMApplied
		 ,ISNULL(Poss.PaperPublicationDone_DMNotApplied	,0)PaperPublicationDone_DMNotApplied
		 ,ISNULL(Poss.DMOrderReceived,0)	DMOrderReceived
		 ,ISNULL(Poss.DMAppliedNOTReceived	,0)DMAppliedNOTReceived
		 ,ISNULL(Poss.PhysicalPossessionTaken,0)	PhysicalPossessionTaken
		 ,ISNULL(Poss.PhysicalPossessionNOTtaken,0)	PhysicalPossessionNOTtaken
		 ,ISNULL(Poss.AuctionNoticePublished,0)	AuctionNoticePublished
		 ,ISNULL(Poss.PhysicalPossessionTaken_AuctionNOTPublished	,0)PhysicalPossessionTaken_AuctionNOTPublished
		 ,ISNULL(Poss.AuctionDateLapsed	,0)AuctionDateLapsed
		 ,ISNULL(Poss.ReauctionPublished,0)	ReauctionPublished
		 ,ISNULL(Poss.ReauctionNOTpublished	,0)ReauctionNOTpublished
		 ,StayOrder	,Litigation	,Fraud	,Consortium	,Restructure,OTS,Fin.CustomerEntityId,RegionCode,ZoneCode,BranchCode,@SecurityType AS SecurityType
 FROM #FinalData  Fin LEFT JOIN 
 #PossDetails Poss ON
 FIn.LocationCode = Poss.LocationCode
 ORDER BY 3,5
 END
 
 ELSE IF @Location IN ('BO')

 BEGIN
  SELECT SrNo,FIn.LocationCode,LocationName,Location,Fin.CustomerId,CustomerName,TotEligibleAccountSystem	
		 ,NPABalance,Tot13_2_IneligibleAccount,TotEligbleAccount,NoticeIssued_13_2,NoticeNOTIssued_13_2	,NoticeAcknowledged_13_2	
		 ,NoticeNOTAcknowledge_13_2,NoticeNOTAcknowledge_13_2_20DAYS,NoticeAcknowleged_60days,NoticeAcknowleged_NOT60days	
		  ,ISNULL(Poss.Symbolic_PossessionTaken	,0)Symbolic_PossessionTaken
		 ,ISNULL(Poss.Tot13_4_NOT_taken_Ineligible,0)Tot13_4_NOT_taken_Ineligible
		 ,ISNULL(Poss.Symbolic_Possession_NOTtaken_60days	,0)Symbolic_Possession_NOTtaken_60days
		 ,ISNULL(Poss.SymbolicPossessionTaken_PaperPublicationDone	,0)SymbolicPossessionTaken_PaperPublicationDone
		 ,ISNULL(Poss.SymbolicPossessionTaken_PaperPublicationNOTDone,0)	SymbolicPossessionTaken_PaperPublicationNOTDone
		 ,ISNULL(Poss.PossessionNoticeServicePending	,0)PossessionNoticeServicePending
		 ,ISNULL(Poss.PaperPublicationDone_DMApplied	,0)PaperPublicationDone_DMApplied
		 ,ISNULL(Poss.PaperPublicationDone_DMNotApplied	,0)PaperPublicationDone_DMNotApplied
		 ,ISNULL(Poss.DMOrderReceived,0)	DMOrderReceived
		 ,ISNULL(Poss.DMAppliedNOTReceived	,0)DMAppliedNOTReceived
		 ,ISNULL(Poss.PhysicalPossessionTaken,0)	PhysicalPossessionTaken
		 ,ISNULL(Poss.PhysicalPossessionNOTtaken,0)	PhysicalPossessionNOTtaken
		 ,ISNULL(Poss.AuctionNoticePublished,0)	AuctionNoticePublished
		 ,ISNULL(Poss.PhysicalPossessionTaken_AuctionNOTPublished	,0)PhysicalPossessionTaken_AuctionNOTPublished
		 ,ISNULL(Poss.AuctionDateLapsed	,0)AuctionDateLapsed
		 ,ISNULL(Poss.ReauctionPublished,0)	ReauctionPublished
		 ,ISNULL(Poss.ReauctionNOTpublished	,0)ReauctionNOTpublished	
		 ,StayOrder	,Litigation	,Fraud	,Consortium	,Restructure,OTS,Fin.CustomerEntityId,RegionCode,ZoneCode,BranchCode,@SecurityType AS SecurityType
 FROM #FinalData  Fin LEFT JOIN 
 #PossDetails Poss ON
 FIn.CustomerEntityId = Poss.CustomerEntityId
 ORDER BY 3,5

 END

END