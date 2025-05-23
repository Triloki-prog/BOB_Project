
/****** Object:  StoredProcedure [dbo].[DASHBOARD_CUSTOMER_List_New]    Script Date: 17-10-2024 14:51:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[DASHBOARD_CUSTOMER_List_New]

@UserLoginId varchar(50) ,  
@Location varchar(10),
@LocationCode varchar(MAX),
@Report INT,
@TimeKey	AS INT,
@SecurityType INT =1,
@CustomerEntityId INT =NULL

AS

--DECLARE 
--	@UserLoginId varchar(50)	='ed123' ,  
--	@Location varchar(10)='zo',
--	@LocationCode varchar(MAX)=N'103',
--	@Report INT=9,
--	@TimeKey	AS INT=49999,
--	@SecurityType INT =3
--	,@CustomerEntityId INT=0

SET NOCOUNT ON;

BEGIN

 
DECLARE @UserLoctionCode varchar(Max),@UserLocation Varchar(max)  


SELECT @CustomerEntityId = CASE WHEN @CustomerEntityId =0 THEN NULL ELSE @CustomerEntityId END
  
  
IF (ISNULL(@Location,'')='' OR ISNULL(@LocationCode,'')='')  
    BEGIN   
     Select @Location=UserLocation,@LocationCode=UserLocationCode from DimUserInfo   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  UserLoginID=@UserLoginId  
    END  
  
DECLARE @CurrentDate DATE = (SELECT Date FROM SYSDAYMATRIX WHERE TIMEKEY =@TimeKey)  
print  @Location   
print @LocationCode  
  
  

   
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
  
  
WHERE (@Location='HO') OR  
  (@Location='ZO' AND DimBranch.BranchZoneAlt_Key IN(SELECT * FROM dbo.Split(@LocationCode,','))) OR  
  (@Location='RO' AND DimBranch.BranchRegionAlt_Key IN(SELECT * FROM dbo.Split(@LocationCode,','))) OR  
  (@Location='BO' AND DimBranch.BranchCode IN(SELECT * FROM dbo.Split(@LocationCode,',')))  
  
OPTION (RECOMPILE)  
  
CREATE UNIQUE CLUSTERED INDEX IX_BRANCHKEY ON #TempBr(BranchCode)  

--select distinct 'm',ZoneShortName,BranchZoneAlt_Key  from #TempBr
--------------------------------------------------------  
IF (OBJECT_ID('tempdb..#EligibleData_16') IS NOT NULL)  
     DROP TABLE #EligibleData_16  
  
CREATE TABLE #EligibleData_16 ([BranchCode] [VARCHAR](10) NULL,   
		  BranchName  [VARCHAR](100) NULL,
		  RegionAlt_key [VARCHAR](10),	  RegionName  [VARCHAR](100) NULL, 
		  ZoneAlt_key [VARCHAR](10) ,	  ZoneName  [VARCHAR](100) NULL,
		  CustomerId [VARCHAR](250) NULL,CustomerName [VARCHAR](MAX) NULL,[CustomerEntityId]     [INT] NULL,  
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
WHERE a.CustomerEntityId=  CASE WHEN ISNULL(@CustomerEntityId,'')='' THEN a.CustomerEntityId ELSE @CustomerEntityId END 

		
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

  --INSERT INTO #AllData (CustomerEntityId,AccountEntityId,SecurityEntityID,TotEligibleAccountSystem,Branchcode,BranchName,RegionAlt_key,
		--				RegionName,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName)
  -- SELECT DISTINCT CustomerEntityId,AccountEntityId,SecurityEntityID,CustomerEntityId,BranchCode,BranchName,RegionAlt_key,RegionName
		--			,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName
  -- FROM #EligibleData_16

  

IF @SecurityType =1 
BEGIN
  INSERT INTO #AllData (CustomerEntityId,AccountEntityId,--SecurityEntityID,
  TotEligibleAccountSystem,Branchcode,BranchName,RegionAlt_key,
						RegionName,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName)
  
  
  SELECT DISTINCT Edata.CustomerEntityId,Edata.AccountEntityId,--SecurityEntityID,
   Edata.CustomerEntityId,BranchCode,BranchName,RegionAlt_key,RegionName
					,ZoneAlt_key,ZoneName,CaseEntityId,Customerid,CustomerName
  FROM #EligibleData_16 EData
	INNER JOIN AdvSecurityValueDetail ADvSec  ON EData.CustomerEntityId = ADvSec.CustomerEntityId
	INNER JOIN DimSecurity DS ON ADvSec.SecurityAlt_Key = DS.SecurityAlt_Key 
	AND (ADvSec.EffectiveFromTimeKey<=49999 AND  ADvSec.EffectiveToTimeKey>=49999) 
	AND (DS.EffectiveFromTimeKey<=49999 AND  DS.EffectiveToTimeKey>=49999) 
	--WHERE( SecurityGroup IN('MORTGAGE' ,'Hypothecation')
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
	-- --WHERE DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation')
	-- --AND DS.SecurityAlt_Key IN (101,105,110,111,112,113,114,115,118,120,125,130,135,140,155,1005,1006,1007)-- movable

	WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
	and DS.movable='Y'

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
-- WHERE --DS.SecurityGroup IN('MORTGAGE' ,'Hypothecation') AND 
-- DS.SecurityAlt_Key IN (125,135,201,202,205,206,209,210,215,
--216,219,220,223,224,225,226,229,230,232,236,238,241,242,243,244,245,
--246,248,237,992,993,999,1262,235,247)-- immovable

WHERE DS.SrfEligible='Y'   ----ADDED NEW LOGIC TO FILER SRF ELIGIBLE AS ON 14/10/2024
	and DS.Immovable='Y'

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


	----select 'with',* From #AllData where withdrwalremarks is not null
----------------------------Mark Ineligible customer ------------------------------

 
		 UPDATE A 
		 SET  Tot13_2_IneligibleAccount =CASE WHEN B.CustomerEntityId IS NOT NULL  THEN A.CustomerEntityId ELSE NULL END     
		,IneligibleRemarks = C.ReasonName
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

		

		--select 'ggg',* from #AllData where customerid = '070873824'
		
----------------------------Mark eligible account ------------------------------

	UPDATE A 
	SET  TotEligbleAccount =	CASE WHEN ISNULL(Tot13_2_IneligibleAccount,'') = '' THEN A.CustomerEntityId  
									 WHEN ISNULL(Tot13_2_IneligibleAccount,'') <> '' THEN NULL END
	FROM #AllData A  

			
		
---------------------------------- 13(2) Demand Notice Issued----------------------------
	IF OBJECT_ID('TEMPDB..#DemandNotice') IS NOT NULL
				DROP TABLE #DemandNotice


SELECT CBD.CustomerEntityID,MAX(SRFBsc.DemandNoticeDt) DemandNoticeDt INTO #DemandNotice FROM #AllData CBD

LEFT JOIN LEGALVW.PermissionDetails  ON PermissionDetails.CustomerEntityID=CBD.CustomerEntityID  
                    AND PermissionDetails.EffectiveFromTimeKey <= 49999   
                    AND PermissionDetails.EffectiveToTimeKey >= 49999  
                    AND PermissionDetails.PermissionNatureAlt_Key = 120   
  
LEFT JOIN LEGALVW.SRFBasicDtls  SRFBsc ON SRFBsc.CaseEntityId=PermissionDetails.CaseEntityId  
                    AND SRFBsc.EffectiveFromTimeKey <= 49999   
                    AND SRFBsc.EffectiveToTimeKey >= 49999  
 -- WHERE CBD.TotEligbleAccount IS NOT NULL
  GROUP  BY CBD.CustomerEntityID


 

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


  

--IF (OBJECT_ID('tempdb..#Possession') IS NOT NULL)  
--     DROP TABLE #Possession  
  
   
--SELECT DISTINCT  
--  B.CustomerEntityId,  
--  MAX(A.PossessionNoticeDt)  AS PossessionNoticeDt,  
--  MAX(A.PhysicalPossessionDt)  AS PhysicalPossessionDt,  
--  MAX(A.SymbolicPossessionDt)  AS SymbolicPossessionDt,  
--  MAX(A.ApliMMDMDt)    AS ApliMMDMDt,  
--  MAX(A.DecisionDt)    AS DecisionDt,  
--  MAX(A.DtPossnNoticePaper)       AS  DtPossnNoticePaper,  
--  MAX(A.DtPossnNoticePaperVer)    AS  DtPossnNoticePaperVer  
--  ,MAX(DMApproached)DMApproached  
--  ,max(ApplicationAgAction)ApplicationAgAction  
--  ,MAX(C.DemandNoticeDt)DemandNoticeDt
  
--  ,A.SecurityEntityId,B.AccountEntityId,A.CaseEntityId
--INTO #Possession  
  
--FROM LEGAL.SRFPossessionDtls A  
--INNER JOIN AdvSecurityValueDetail B   ON A.SecurityEntityID=B.SecurityEntityID  
--             AND A.EffectiveFromTimeKey<=49999 AND A.EffectiveToTimeKey>=49999  
--             AND B.EffectiveFromTimeKey<=49999 AND B.EffectiveToTimeKey>=49999  
--             AND A.PossessionNoticeDt<GETDATE()  
-- INNER JOIN  LEGALVW.SRFBasicDtls C ON C.CustomerEntityId = B.CustomerEntityId
-- WHERE  B.CustomerEntityId IN (SELECT DISTINCT CustomerEntityId FROM #AllData )
--GROUP BY B.CustomerEntityId  ,A.SecurityEntityId,B.AccountEntityId,A.CaseEntityId
  
--OPTION (RECOMPILE)  


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
			and DS.Immovable='Y'


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
--max(NoticeAcknowledgedDt)NoticeAcknowledgedDt  
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
  
  
OPTION(RECOMPILE) 


 IF (OBJECT_ID('tempdb..#SrfDtls') IS NOT NULL)  
 DROP TABLE #SrfDtls

 SELECT [13_2_NoticeIssued],SRFBasicDtls.DemandNoticeDt ,A.CustomerEntityId,SRFBasicDtls.CaseEntityId
 INTO #SrfDtls
 from LEGALVW.SRFBasicDtls SRFBasicDtls
 INNER JOIN #AllData A ON  A.CustomerEntityId = SRFBasicDtls.CustomerEntityId
   AND SRFBasicDtls.EffectiveFromTimeKey <= 49999 AND SRFBasicDtls.EffectiveToTimeKey >= 49999  
 WHERE ISNULL(SRFBasicDtls.DemandNoticeDt,'') <>''


-----------------------------------------Notice Acknowledge----------------------------------

UPDATE #AllData
SET [13_2_NoticeAcknowledged] = CASE WHEN defendant.NoticeAcknowledgedDt IS NOT NULL AND A.[13_2_NoticeIssued] IS NOT NULL 
								AND Tot13_2_IneligibleAccount IS NULL  --11062024
								THEN A.CustomerEntityId ELSE NULL END  -- Notice acknowledged 

, [13_2_NoticeNOTAcknowledge] = CASE WHEN defendant.NoticeAcknowledgedDt IS NULL AND A.[13_2_NoticeIssued] IS NOT NULL 
								AND Tot13_2_IneligibleAccount IS NULL --11062024
								THEN A.CustomerEntityId ELSE NULL END  -- Notice Not acknowledged 

,[13_2_NoticeNOTAcknowledge_20DAYS] = CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											AND defendant.NoticeAcknowledgedDt IS NULL
											AND PossessionNoticeDt IS NULL
											AND Tot13_2_IneligibleAccount IS NULL) --11062024
											THEN 
											CASE WHEN  DATEDIFF(dd,SRFBasicDtls.DemandNoticeDt,Getdate()) >20 THEN A.CustomerEntityId
											ELSE NULL END ELSE NULL END  
											-- Notice Not acknowledged 20 days

,[NoticeAcknowleged_60days] =			CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											 AND   defendant.NoticeAcknowledgedDt  IS NOT NULL
											 AND   PossessionNoticeDt IS NULL
											 AND Tot13_2_IneligibleAccount IS NULL)--11062024
											 THEN
											 CASE WHEN (DATEDIFF(DD,defendant.NoticeAcknowledgedDt, GETDATE())>60 ) THEN A.CustomerEntityId
											 ELSE NULL End ELSE NULL END
											 
,[NoticeAcknowleged_NOT60days] =		CASE WHEN (SRFBasicDtls.DemandNoticeDt  IS NOT NULL
											 AND defendant.NoticeAcknowledgedDt  IS NOT NULL
											 AND PossessionNoticeDt  IS  NULL
											 AND Tot13_2_IneligibleAccount IS NULL)--11062024
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
                    
                                  
LEFT JOIN #DefendantServiceNoticeDtls    Defendant ON SRFBasicDtls.CaseEntityId=Defendant.CaseEntityId 
LEFT JOIN #Possession  Possession                 ON Possession.CustomerEntityID=A.CustomerEntityID  
WHERE A.Withdrawal =0 --AND A.Tot13_2_IneligibleAccount IS NULL  --change

 
--select  DISTINCT customerid,customername,* From #AllData where customerid in ('001582959','5211')

--select 'gggg',* from #AllData where [13_2_NoticeAcknowledged]  IS NOT NULL and customerid in ('070873824')


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
LEFT JOIN LEGALVW.PermissionDetails           ON PermissionDetails.CustomerEntityID=A.CustomerEntityID  
		
                    AND PermissionDetails.EffectiveFromTimeKey <= 49999   
                    AND PermissionDetails.EffectiveToTimeKey >= 49999  
                    AND PermissionDetails.PermissionNatureAlt_Key = 120  
        
  
LEFT JOIN LEGALVW.SRFBasicDtls            ON SRFBasicDtls.CaseEntityId=PermissionDetails.CaseEntityId  
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

IF (OBJECT_ID('tempdb..#PossAllDetails') IS NOT NULL)  
     DROP TABLE #PossAllDetails
	 
	 SELECT DISTINCT CustomerEntityId,Branchcode,RegionAlt_key,ZoneAlt_key,SecurityEntityId
			,CASE WHEN ISNULL(SecurityEntityId,'')<>''
				AND   ISNULL(SymbolicPossessionDt,'')<>'' 
				AND Tot13_2_IneligibleAccount IS NULL
				THEN 1 ELSE 0 END AS [Symbolic_PossessionTaken]

			  ,CASE WHEN ( Tot13_2_IneligibleAccount IS NOT NULL -- AND ISNULL(DemandNoticeDt ,'')<>'' 
			  AND ISNULL(DemandNoticeDt ,'')<>'' 
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
				THEN 1 ELSE 0 END AS [DMOrderReceived]--- need to check
	
			,CASE WHEN (DMApproached='Y' AND ApliMMDMDt IS NOT NULL  
			AND DecisionDt IS  NULL --AND PhysicalPossessionDt IS NOT NULL
			)  AND Tot13_2_IneligibleAccount IS NULL THEN 1 ELSE 0 END 
			AS [DMAppliedNOTReceived]--- need to check


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
			INTO #PossAllDetails
			FROM #PossDtl 
			WHERE CustomerEntityId=  CASE WHEN ISNULL(@CustomerEntityId,'')='' THEN CustomerEntityId ELSE @CustomerEntityId END 
		

		
--IF (OBJECT_ID('tempdb..#PossDetails') IS NOT NULL)  
--     DROP TABLE #PossDetails

--	 SELECT  
--	 	CASE WHEN @UserLocation = 'HO' THEN ZoneAlt_key 
--				 WHEN @UserLocation = 'ZO' THEN RegionAlt_key
--				 WHEN @UserLocation = 'RO' THEN Branchcode
--				 WHEN @UserLocation = 'BO' THEN BranchCode END AS [LocationCode] ,

--				 CASE WHEN @UserLocation = 'HO' THEN NULL
--				 WHEN @UserLocation = 'ZO' THEN NULL
--				 WHEN @UserLocation = 'RO' THEN NULL
--				 WHEN @UserLocation = 'BO' THEN CustomerEntityId END AS CustomerEntityId

	
--	,   SUM(Symbolic_PossessionTaken)Symbolic_PossessionTaken
--	,   SUM(Tot13_4_NOT_taken_Ineligible )Tot13_4_NOT_taken_Ineligible
--	,   SUM([60days_Symbolic_Possession_NOTtaken])  [Symbolic_Possession_NOTtaken_60days]
--	,   SUM(SymbolicPossessionTaken_PaperPublicationDone)SymbolicPossessionTaken_PaperPublicationDone
--	,   SUM(SymbolicPossessionTaken_PaperPublicationNOTDone)SymbolicPossessionTaken_PaperPublicationNOTDone
--	,	SUM(PossessionNoticeServicePending)PossessionNoticeServicePending
--	,   SUM(PaperPublicationDone_DMApplied)PaperPublicationDone_DMApplied
--	,   SUM(PaperPublicationDone_DMNotApplied)PaperPublicationDone_DMNotApplied
--	,   SUM(DMOrderReceived)DMOrderReceived
--	,   SUM(DMAppliedNOTReceived)	 DMAppliedNOTReceived
--	,   SUM(PhysicalPossessionTaken) PhysicalPossessionTaken
--	,   SUM(PhysicalPossessionNOTtaken)PhysicalPossessionNOTtaken
--	,   SUM(AuctionNoticePublished)AuctionNoticePublished
--	,   SUM(PhysicalPossessionTaken_AuctionNOTPublished)PhysicalPossessionTaken_AuctionNOTPublished
--	,   SUM(AuctionDateLapsed)	AuctionDateLapsed
--	,   SUM(ReauctionPublished)	ReauctionPublished
	
--	,   SUM(ReauctionNOTpublished)ReauctionNOTpublished
--	INTO #PossDetails
--	FROM #PossAllDtl
		
	
--	GROUP BY CASE WHEN @UserLocation = 'HO' THEN ZoneAlt_key 
--				 WHEN @UserLocation = 'ZO' THEN RegionAlt_key
--				 WHEN @UserLocation = 'RO' THEN Branchcode
--				 WHEN @UserLocation = 'BO' THEN BranchCode END 

--			,CASE WHEN @UserLocation = 'HO' THEN NULL
--				 WHEN @UserLocation = 'ZO' THEN NULL
--				 WHEN @UserLocation = 'RO' THEN NULL
--				 WHEN @UserLocation = 'BO' THEN CustomerEntityId END 
		
		
		--select * From #PossDetails


 ---------------------------------------------------------------------------------------------------
		
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
			   --AND A.PhysicalPossessionTaken IS NULL --  Possession should not be taken
			   AND (FraudAccoStatus='Y' OR FraudNotioced='Y')   
			   WHERE   A.Withdrawal =0

			   -----------------------NPA Dt---------------------
	IF (OBJECT_ID('tempdb..#NPA') IS NOT NULL)  
     DROP TABLE #NPA

			   SELECT DISTINCT N.CustomerEntityId , N.NPADt 
			  INTO #NPA
			  FROM #ALLDATA A 
			   INNER JOIN AdvCustNPAdetail N ON 
			   A.CustomerEntityId = N.CustomerEntityId 
			   AND N.EffectiveFromTimeKey <= @TimeKey AND N.EffectiveToTimeKey >= @TimeKey 
			  
			  ------------------------- AmountOS ---------------------------
	IF (OBJECT_ID('tempdb..#Balance') IS NOT NULL)  
     DROP TABLE #Balance

			SELECT A.CustomerEntityId ,SUM(ISNULL(BAL.Balance,0)) AS BalanceOS
			INTO #Balance
			FROM #ALLDATA A 
			 INNER JOIN AdvAcBasicDetail Av ON A.CustomerEntityId = Av.CustomerEntityId
			 AND Av.EffectiveFromTimeKey <= @TimeKey AND Av.EffectiveToTimeKey >= @TimeKey 
		    
			LEFT JOIN CURDAT.AdvAcBalanceDetail BAL
			ON Av.AccountEntityId=BAL.AccountEntityId 
			AND (BAL.EffectiveFromTimeKey<=@TimeKey AND BAL.EffectiveToTimeKey>=@TimeKey)

			GROUP BY A.CustomerEntityId

			

			-------------------------------Security Value --------------------------
			IF (OBJECT_ID('tempdb..#SecVal') IS NOT NULL)  
				 DROP TABLE #SecVal

		SELECT CustomerEntityId, SUM(SecVal) SecVal INTO #SecVal  FROM(
			SELECT DISTINCT  A.CustomerEntityId, Sec.SecurityEntityID ,(ISNULL(Sec.CurrentValue,0)) AS SecVal  
			FROM #ALLDATA A 
			INNER JOIN  AdvSecurityValueDetail Sec ON A.CustomerEntityId = Sec.CustomerEntityId
			AND Sec.EffectiveFromTimeKey <= @TimeKey AND Sec.EffectiveToTimeKey >= @TimeKey -- change
			--GROUP BY A.CustomerEntityId,Sec.SecurityEntityID 
			)Sec 
			GROUP BY CustomerEntityId

		--	select 'hh',* from #SecVal
			----------------------------------------------------------------------------------------

   --IF @Report IN (1,2,3,4,5,6,7,8,9,10,27,28,29,30,31,32,33)

   --BEGIN

   IF @Report =1
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  FROM(
   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
   A.NPABalance AS AmountOS -- B.BalanceOS AS AmountOS 
   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue  ,A.CustomerEntityId
   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
   FROM #AllData A 
   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
   WHERE ISNULL(Withdrawal,0) =0 AND A.TotEligibleAccountSystem is Not null 	 
    )Tab ORDER BY CustomerName

   END

    IF @Report =2
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS -- B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue  , 
	   IneligibleRemarks as [Remakerfor13(2)Ineligible],A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.Tot13_2_IneligibleAccount is Not null 	 
	)Tab ORDER BY CustomerName

   END

    IF @Report =3
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue  ,A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.TotEligbleAccount is Not null 
	)Tab ORDER BY CustomerName

   END

    IF @Report =4
   BEGIN

  

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   [13_2_NoticeIssuedDt]  as [Dateof13(2)notice] ,A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.[13_2_NoticeIssued] is Not null  
	   AND TotEligbleAccount IS NOT NULL
	)Tab ORDER BY CustomerName

   END

    IF @Report =5
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.[13_2_NoticeNOTIssued] is Not null  
	)Tab ORDER BY CustomerName

   END

   IF @Report =6
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	   ,[Dateofacknowledgement] AS [Dateofacknowledgement],A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.[13_2_NoticeAcknowledged] is Not null
	)Tab ORDER BY CustomerName

   END
   
   IF @Report =7
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] ,A.CustomerEntityId
	   ,A.BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	
	   FROM #AllData A 
	   --INNER JOIN LEgal.PermissionDetails P ON A.CustomerEntityId = P.CustomerEntityId AND A.Branchcode = P.Branchcode AND P.PermissionNatureAlt_Key=120
	   --AND P.EffectiveToTimeKey =49999
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.[13_2_NoticeNOTAcknowledge] is Not null
	)Tab ORDER BY CustomerName

   END

    IF @Report =8
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,  CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] ,A.CustomerEntityId
	   ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	  
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.[13_2_NoticeNOTAcknowledge_20DAYS] is Not null
	)Tab ORDER BY CustomerName

   END

    IF @Report =9
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,  CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement],A.CustomerEntityId
	  ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.NoticeAcknowleged_60days is Not null
	)Tab ORDER BY CustomerName

--	select * from #AllData WHERE ISNULL(Withdrawal,0) =0 AND NoticeAcknowleged_60days is Not null

   END

    IF @Report =10
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement],A.CustomerEntityId
	  ,BranchCode,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode
	   FROM #AllData A 
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   WHERE ISNULL(Withdrawal,0) =0 AND A.NoticeAcknowleged_NOT60days is Not null
	)Tab ORDER BY CustomerName

   END
   
   IF @Report =11
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	 --  LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	 LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change

	   WHERE ISNULL(Withdrawal,0) =0 And P.Symbolic_PossessionTaken =1
	)Tab ORDER BY CustomerName

   END

   IF @Report =12
   BEGIN
   print 'hi'

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal  AS SecurityValue , --S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,A.IneligibleRemarks AS [ReasonforIneligible],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	 ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	 -- LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	-- AND P.CustomerEntityId = S.CustomerEntityId
	-- AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey 
	  WHERE ISNULL(Withdrawal,0) =0 And P.Tot13_4_NOT_taken_Ineligible =1
	)Tab ORDER BY CustomerName

   END

   IF @Report =13
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal  AS SecurityValue ,  --S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement],P.SecurityEntityID AS AssetID
	  ,A.CustomerEntityId,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	    --LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
		--AND P.CustomerEntityId = S.CustomerEntityId
		--AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.[60days_Symbolic_Possession_NOTtaken] =1
	)Tab ORDER BY CustomerName

   END

   IF @Report =14
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	    A.NPABalance AS AmountOS -- B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , DtPossnNoticePaperVer As [DateOfPaperPublication],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	 ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	 --  LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	 LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change

	 WHERE ISNULL(Withdrawal,0) =0 And  P.SymbolicPossessionTaken_PaperPublicationDone =1 
	)Tab ORDER BY CustomerName

   END

   IF @Report =15
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession],P.SecurityEntityID AS AssetID
	  ,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   --LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.SymbolicPossessionTaken_PaperPublicationNOTDone =1 
	)Tab ORDER BY CustomerName

   END
   
   IF @Report =16
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.SecVal  AS SecurityValue , --S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	 -- LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 --AND P.CustomerEntityId = S.CustomerEntityId
	 --AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.PossessionNoticeServicePending =1 
	)Tab ORDER BY CustomerName

   END

    IF @Report =17
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication],
	  CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.PaperPublicationDone_DMApplied =1
	)Tab ORDER BY CustomerName

   END

    IF @Report =18
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication]--, ApliMMDMDt AS [DateOffilingDMCMMCJM]
	  ,P.SecurityEntityID AS AssetID,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.PaperPublicationDone_DMNotApplied =1
	)Tab ORDER BY CustomerName

   END

   
    IF @Report =19
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	  ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.DMOrderReceived =1	 
	)Tab ORDER BY CustomerName

   END

   
    IF @Report =20
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,  CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	  ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	--  ,DecisionDt AS [DateOfOrderDMCMMCJM]
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   --LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.DMAppliedNOTReceived =1	 
	)Tab ORDER BY CustomerName
	END


	  IF @Report =21
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,  CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   ,P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode

	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   --LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.PhysicalPossessionTaken =1 
	)Tab ORDER BY CustomerName

   END

    IF @Report =22
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   ,P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode

	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And  P.PhysicalPossessionNOTtaken =1 
	)Tab ORDER BY CustomerName

   END

    IF @Report =23
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   , CONVERT(VARCHAR(10),SaleNoticeDt,103) AS [AuctionDate],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	 ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode

	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	--   LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.AuctionNoticePublished =1 
	)Tab ORDER BY CustomerName

   END

  IF @Report =24
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   ,CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   ,P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	   --LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	   LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.PhysicalPossessionTaken_AuctionNOTPublished =1
	)Tab ORDER BY CustomerName

   END

   IF @Report =25
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   , CONVERT(VARCHAR(10),SaleNoticeDt,103) AS [AuctionDate],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.AuctionDateLapsed =1	
	)Tab ORDER BY CustomerName

   END

    IF @Report =26
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	   A.NPABalance AS AmountOS --B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	   CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   , CONVERT(VARCHAR(10),SaleNoticeDt,103) AS [AuctionDate], CONVERT(VARCHAR(10),NextSaleDisposalDt,103) AS [REAuctiondate]
	   ,P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.ReauctionPublished =1
	)Tab ORDER BY CustomerName

   END

IF @Report =27
   BEGIN

     SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  
	 FROM(
	   SELECT DISTINCT ZoneName AS [Zone],RegionName AS Region , BranchName AS Branch, CustomerName,CustomerId,
	     A.NPABalance AS AmountOS -- B.BalanceOS AS AmountOS 
	   , CONVERT(VARCHAR(10),N.NPADt,103) AS NPADate,  S.CurrentValue AS SecurityValue ,
	   CONVERT(VARCHAR(10),[13_2_NoticeIssuedDt],103) AS [Dateof13(2)notice] 
	  , CONVERT(VARCHAR(10),[Dateofacknowledgement],103)  AS [Dateofacknowledgement]
	  ,CONVERT(VARCHAR(10),SymbolicPossessionDt,103) AS [DateOfSymbolicPossession]
	  , CONVERT(VARCHAR(10),DtPossnNoticePaperVer,103) As [DateOfPaperPublication], 
	    CONVERT(VARCHAR(10),ApliMMDMDt,103) AS [DateOffilingDMCMMCJM]
	   ,CONVERT(VARCHAR(10),DecisionDt,103) AS [DateOfOrderDMCMMCJM] 
	   , CONVERT(VARCHAR(10),PhysicalPossessionDt,103) AS [DateOfPhysicalPossession]
	   , CONVERT(VARCHAR(10),SaleNoticeDt,103) AS [AuctionDate],P.SecurityEntityID AS AssetID,A.CustomerEntityId
	   ,A.BranchCode,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode
	   FROM #AllData A INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
	   LEFT JOIN #NPA N ON A.CustomerEntityId = N.CustomerEntityId
	   LEFT JOIN #Balance B ON  A.CustomerEntityId = B.CustomerEntityId
	  -- LEFT JOIN #SecVal S ON  A.CustomerEntityId = S.CustomerEntityId
	  LEFT JOIN AdvSecurityValueDetail S ON P.SecurityEntityId = S.SecurityEntityID 
	 AND P.CustomerEntityId = S.CustomerEntityId
	 AND S.EffectiveFromTimeKey <= @TimeKey AND S.EffectiveToTimeKey >= @TimeKey -- change
	   WHERE ISNULL(Withdrawal,0) =0 And P.ReauctionNOTpublished =1
	)Tab ORDER BY CustomerName

   END

   IF @Report IN (28,29,30,31,32,33)
   BEGIN

   SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  FROM(

  SELECT  DISTINCT  BranchCode, BranchName,RegionName,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode,
  ZoneName AS ZoneShortName,CustomerId,
  CustomerEntityId,CustomerName --,'' AS AssetID
 
  FROM #AllData  A WHERE ISNULL(Withdrawal,0) =0
  
    AND 1 =  CASE 
	WHEN @Report =28 And A.StayOrder is Not null 	 THEN 1 
	WHEN @Report =29 And A.Litigation is Not null 	 THEN 1 
	WHEN @Report =30 And A.Fraud is Not null 	 THEN 1 
	WHEN @Report =31 And A.Consortium is Not null 	 THEN 1 
	WHEN @Report =32 And A.Restructure is Not null 	 THEN 1 
	WHEN @Report =33 And A.OTS is Not null 	 THEN 1 
	
  END	 
  )Tab ORDER BY 8

   END
   /*
  SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  FROM(

  SELECT  DISTINCT  BranchCode, BranchName,RegionName,RegionAlt_key AS RegionCode,ZoneAlt_key AS ZoneCode,
  ZoneName AS ZoneShortName,CustomerId,
  CustomerEntityId,CustomerName ,'' AS AssetID
 
  FROM #AllData  A WHERE ISNULL(Withdrawal,0) =0
  
    AND 1 =  CASE 
	WHEN @Report =1 And A.TotEligibleAccountSystem is Not null 	 THEN 1 
	WHEN @Report =2 And A.Tot13_2_IneligibleAccount is Not null 	 THEN 1 
	WHEN @Report =3 And A.TotEligbleAccount is Not null 	 THEN 1 
	
	WHEN @Report =4 And A.[13_2_NoticeIssued] is Not null 	 THEN 1 
	WHEN @Report =5 And A.[13_2_NoticeNOTIssued] is Not null 	 THEN 1 
	WHEN @Report =6 And A.[13_2_NoticeAcknowledged] is Not null 	 THEN 1 
	WHEN @Report =7 And A.[13_2_NoticeNOTAcknowledge] is Not null 	 THEN 1 
	WHEN @Report =8 And A.[13_2_NoticeNOTAcknowledge_20DAYS] is Not null 	 THEN 1 
	WHEN @Report =9 And A.NoticeAcknowleged_60days is Not null 	 THEN 1 
	WHEN @Report =10 And A.NoticeAcknowleged_NOT60days is Not null 	 THEN 1 
	
	WHEN @Report =28 And A.StayOrder is Not null 	 THEN 1 
	WHEN @Report =29 And A.Litigation is Not null 	 THEN 1 
	WHEN @Report =30 And A.Fraud is Not null 	 THEN 1 
	WHEN @Report =31 And A.Consortium is Not null 	 THEN 1 
	WHEN @Report =32 And A.Restructure is Not null 	 THEN 1 
	WHEN @Report =33 And A.OTS is Not null 	 THEN 1 
	
  END	 
  )Tab ORDER BY 8
  */
  --END

  --ELSE 

  ----BEGIN

  -- SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS SrNo,*  FROM(

  --SELECT  DISTINCT  A.BranchCode, BranchName,RegionName,A.RegionAlt_key AS RegionCode,A.ZoneAlt_key AS ZoneCode,
  --ZoneName AS ZoneShortName,CustomerId,
  --A.CustomerEntityId,CustomerName,P.SecurityEntityID AS  AssetID-- Custamount,demandNoticeDt
 
  --FROM #AllData  A  INNER JOIN #PossAllDetails P ON A.CustomerEntityId = P.CustomerEntityId
  --WHERE ISNULL(Withdrawal,0) =0
  
  --  AND 1 = CASE 
		--WHEN @Report =11 And P.Symbolic_PossessionTaken =1	 THEN 1 
		--WHEN @Report =12 And P.Tot13_4_NOT_taken_Ineligible =1 	 THEN 1 
		--WHEN @Report =13 And P.[60days_Symbolic_Possession_NOTtaken] =1 	 THEN 1 
		--WHEN @Report =14 And P.SymbolicPossessionTaken_PaperPublicationDone =1 	 THEN 1 
		--WHEN @Report =15 And P.SymbolicPossessionTaken_PaperPublicationNOTDone =1 	 THEN 1 
		--WHEN @Report =16 And P.PossessionNoticeServicePending =1 	 THEN 1 
		--WHEN @Report =17 And P.PaperPublicationDone_DMApplied =1 	 THEN 1 
		--WHEN @Report =18 And P.PaperPublicationDone_DMNotApplied =1 	 THEN 1 
		--WHEN @Report =19 And P.DMOrderReceived =1	 THEN 1 
		--WHEN @Report =20 And P.DMAppliedNOTReceived =1	 THEN 1 
		--WHEN @Report =21 And P.PhysicalPossessionTaken =1 	 THEN 1 
		--WHEN @Report =22 And P.PhysicalPossessionNOTtaken =1  THEN 1 
		--WHEN @Report =23 And P.AuctionNoticePublished =1 	 THEN 1 
		--WHEN @Report =24 And P.PhysicalPossessionTaken_AuctionNOTPublished =1 	 THEN 1 
		--WHEN @Report =25 And P.AuctionDateLapsed =1	 THEN 1 
		--WHEN @Report =26 And P.ReauctionPublished =1	 THEN 1 
		--WHEN @Report =27 And P.ReauctionNOTpublished =1 	 THEN 1 END
		--)Tab ORDER BY 8
  ----END

	


END


