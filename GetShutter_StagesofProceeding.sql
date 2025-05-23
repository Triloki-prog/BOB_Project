USE [BOB_LEGAL_PLUS_TEST]
GO
/****** Object:  StoredProcedure [dbo].[GetShutter_StagesofProceeding]    Script Date: 03-12-2024 15:33:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [dbo].[GetShutter_StagesofProceeding]

--------GetShutter_StagesofProceeding @CaseEntityId='10198',@TimeKey=24602

@CaseEntityId	INT ='',
@TimeKey		INT,
@ScreenMenuId	smallint=0,
@ShutterMenuId smallint=0,
@SecurityEntityId INT=0,
@ParentColumnValue INT=0
AS 


--    DECLARE   

--@CaseEntityId	INT ='490094',
--@TimeKey		INT=27172,
--@ScreenMenuId	smallint=9002,
--@ShutterMenuId smallint=500,
--@SecurityEntityId INT=0,
--@ParentColumnValue INT=0

BEGIN
		DECLARE 
		@CustomerId					    VARCHAR(50),
		@CustomerName				    VARCHAR(200),
		@ConstitutionName				VARCHAR(100),
		@CaseReferenceNumber		    VARCHAR(150),
		@PrincipalLedgerBalance 	    DECIMAL(18,2)	=	0.00,
		@UnappliedInterest			    DECIMAL(18,2)	=	0.00,
		@LegalExpenses				    DECIMAL(18,2)	=	0.00,
		@Other						    DECIMAL(18,2)	=	0.00,
		@Total						    DECIMAL(18,2)	=	0.00,
		@CustomerEntityId			    INT,
		@AccountEntityId			    VARCHAR(250),
		@Branchcode					    VARCHAR(100),
		@BranchName					    VARCHAR(100),
		@Employeeid					    VARCHAR(50),
		@EmployeeName				    VARCHAR(50),
		@NPADt						    VARCHAR(10),
		@Bankingarrangement			    VARCHAR(10),
		@Consortium_Name				VARCHAR(50)	,		
		@OSBalance					    DECIMAL(18,2),
		@DemANDNoticeDate			    VARCHAR(10),
		@FiledByAlt_Key				    Varchar(10),
		@ComplaintFiledByShortNameEnum	VARCHAR(20),
		@AppealNo						VARCHAR(40),
		@FilExePetDt					VARCHAR(10),
		@AcceptanceDate					VARCHAR(10),
		@ParticualrsSoughtOnDt			VARCHAR(10),
		@FixedInvestigationDt			VARCHAR(20),
		@DateAdmittedOn					VARCHAR(20),
		@PermissionSoughtdate			VARCHAR(10),
		@DtofFirstDisb					VARCHAR(10),		
		@NextHearingDt					VARCHAR(10),
		@SerNoticeDt                	VARCHAR(10),
		@DemANDNoticeDt					VARCHAR(10),
		@ComplaintFiledDt				VARCHAR(10),
		@DtRti          				VARCHAR(10),
		@DocExpiryDate					DATE,
		@NtDishonourRcvdDt				VARCHAR(10),
		@DecreeDate						VARCHAR(10),
		@PossessionSecAsSETDt			VARCHAR(10),
		@JudgementDate					VARCHAR(10),
		@CustomerSinceDt				VARCHAR(10),
		@ClaimTotal                     DECIMAL(18,2),
		@SuitAmount						DECIMAL(18,2),
		@CustomerACID					VARCHAR(250),
		@DtofApplicationNCLT			VARCHAR(20),
		@WithdrawalStage  				VARCHAR(100),
		@ArbitrationOrderDate          VARCHAR(100),
		@CRESAIRegNo					VARCHAR(20),
		@BIDSecurityEntityId				INT	=@SecurityEntityId,
		@PossessiontakingDt				VARCHAR(10),
		@BorrNDate						VARCHAR(10),
		@Ac_DocumentDt					VARCHAR(10),
		@CurrentStageName				VARCHAR(100),
		@TitleOfCase					VARCHAR(300),
		@SecurityNature					VARCHAR(15),
		@AppealOrderDt					VARCHAR(10),
		@RemainingOs					Decimal(18,2),
		@PermissionLetterDate			VARCHAR(10),
		@DtService						varchar(10),
		@RecallNoticeDate				varchar(10),
		@FillingAplDt		            Varchar(10),
		--@NextHearingDt						varchar(10)
		@RecallnoticedatePDR			VARCHAR(10),
		@SummonIssueDate				VARCHAR(10),
		@ArbProceedingNo				VARCHAR(10),
		@ArbitrationInitiatedBy			VARCHAR(10)= 'Bank',
		@BOOrderDate					varchar(10),
		@DtAward						VARCHAR(10),
		@SummonsSerDt					VARCHAR(10),
		@SummonsSerDt_Suit				Varchar(10),
		@DefendantRelationship			varchar(50),
		@WritpetitionJudgmentdate		varchar(10),
		@DtLiquidationOrder				varchar(10),
		@AppealOrderDate				varchar(10),
		@AppellateAuthorityFiledBy		VARCHAR(10),
		@Placeofposting					varchar(100),
		@Add1							varchar(100),
		@Add2							varchar(100),
		@Add3							varchar(100),
		@CityShortName					varchar(50)	,
		@PinCode						varchar(10)	,
		@DistrictName					varchar(50)	,
		@StateName						varchar(50)	,
		@StdCode						varchar(10)	,
		@PhoneNo						varchar(26)	,
		@STD_Code_Off					varchar(10)	,
		@PhoneNo_Off					varchar(26),
		@ISPermission					varchar(2),
		@CaseTypeFlag					varchar(2),
		@ServProvider					varchar(60),
		@FiledBy						varchar(10),
		@ConsentLetterDt				varchar(10),
		@JudgmentDtCivilStAgnB			varchar(10),
		@ConsumerJudgmentDt				varchar(10),
		@CaseType						varchar(100),
		@TitleOFCaseWP					varchar(100),
		@ComplaintDtFiled				varchar(10),
		@FinalOrderDate					varchar(10),
		@FiledByWritPet					varchar(10),
		@PrevStage						varchar(50),
		@CriminalJudgementDate			varchar(10),
		@AppealAdmittedDt				varchar(10),
		@CivilSuitAgnBHearingDtVal		varchar(10),
		@DRTCourtName					varchar(50),
		@CourtLOC						varchar(50),
		@SymbolicPossessionDt			varchar(10),
		@PhysicalPossessionDt			varchar(10),
		@AwardDate						varchar(10),
		@CourtOrderDt					varchar(10),
		@WPSCFiledBy					varchar(15),
		@Designation					varchar(50),
		@ComPoliceStationDt				varchar(10),
		@ApproachDecisionDt				varchar(10),
		@OrderJudgmentDt				varchar(10),
		@SuitAppNo						varchar(20),
		@ArbitrationEntityId			int,
		@NiactJudgementDt				varchar(10),
		@AppealDecisionDt				varchar(10),
		@DecreeAmount					decimal(18,2),
		@ComplainID						varchar(50),
		@CriminialSummonsServicedDt		varchar(10),
		@ShowcauseNoticeDtls			varchar(50),
		@EnquiryConclusionDt			varchar(10),
		@MaxDate						varchar(10),
		@MaxServiceDate					varchar(10),
		@WritPetitionDt					varchar(10),
		@WritPetitionNo					NVARCHAR(30),
		@WritPetitionAdmittedDt			varchar(10),
		@JudgementDt					varchar(10),
		@WritPetitionRejectedDt			varchar(10),
		@BankRuptOrderDate				varchar(10),
		@AOQTDt							varchar(10),
		@SuitNextHearingdate			varchar(10),
		@EPDate							varchar(10),
		@ValSeizedAssetdt				varchar(10),
		@JudgmentAwardDt				varchar(10),
		@CGIT                           varchar(20),
		@SuitDt							varchar(20),
		@AppearanceDt					varchar(20),
		@WrittenStmFillingDt			varchar(20),
		@FramingOfIsuuesDt				varchar(20),

		@MaxOrderDate					varchar(10),
		@Sec25JudgementDt				varchar(10),
		@AppealAdmittedDtDRAT           varchar(10),
		@FramingOfIssueDt               varchar(10),
		@ArbiProceeding					varchar(20),
		@AppointmentDt					varchar(20),
		@CurrentStageDate				varchar(20),
		@SaleDisposalDt  				varchar(20),
		@FiledByReviewPet				varchar(20),
		@FiledByWritPetOfficer			varchar(20),
		@RealizeAmt                     decimal(18,2),
	    @SaleCertDt                     varchar(10),
		@SaleConfirmationDt             varchar(10),
		@RecoveryCharge					decimal(13,2),
		@AmountClaimed					decimal(13,2),
		@ComplaintSuitNo				varchar(50),
		@CaseTypeCode					SMALLINT,
		@TentativeDate				    DATE,
		@DateOfDecision					DATE,
		@OrderStatus                    varchar(50),
		@CriminalOrderStatus            varchar(50),
		@nextdate                       date,
		@OrderStatusfor138			varchar(50),
		@DtfilingCounterPetitioner		date,
		@AmtClaimUnderEP					varchar(50)
		,@CourtName						Varchar(200)
		,@CourtNameAlt_Key				Varchar(50)
		,@CourtNameAlt_Key_Adinterim	Varchar(50)
		,@CourtLocation					Varchar(200)
		,@TotalAC_Balance				Decimal(18,2)
		,@ApplicationAdmittedDt				VARCHAR(10)
		,@WarrantDt							date
		,@NoOfArbitrator					int	
		,@SummonsServiceDt					date
		,@EP_valDt							date
		,@DtofNoticeofInvocationofArbitoBorrowers date
		,@EP_ValMessage varchar(max)
		,@AdinterimCourtLOC       Varchar(50)
		,@AdinterimCourtName		VARCHAR(50)
		,@Suit_AcceptanceDate       Varchar(10)
		,@PreDecreeDate				VARCHAR(50)
	    ,@CompromiseStartDt				VARCHAR(50)
		,@LokAdalatMaxDate Varchar(10)
		,@NIACTOrderDate    Varchar(10)
		,@NoofExpert        VARCHAR(50)
		,@OrderStatusForCivil   VARCHAR(50)
		,@RevDeptNoticeDt  Varchar(10)
		,@PDR_NextHearingDt Varchar(10)
		,@Insolvancyhearingdate date
		,@PoliceNextHearingDt date
		,@RepresentationDt  date

		 ,@AppearanceDate date
		--,@Hearing             VARCHAR(10)
		,@ApliMMDMDt	date
		,@YearDt			Date
		,@NextRemarkDate Varchar(10)
		,@NextJudgementDate Varchar(10)
		,@FinalStatus_Alt_Key INT
		,@RCDate   Varchar(10)
		,@RCAmt		Decimal(18,2)
		,@TypeOfLegalAction varchar(50)
		,@OtherCourtName VARCHAR(500)
		,@OtherCourtLocation VARCHAR(500)
		,@CourtLocationAlt_Key  int
		PRINT 1
		PRINT @CaseEntityId
		PRINT 'Amol'

		
print 'Add new line '



		Declare @IsHearingEntered bit = 0,
						@HearingDt     varchar(50)
					

	/*Common Column for all*/
		SELECT @YearDt=DATEADD(YEAR,-2,CAST(GETDATE() AS DATE))

			select @ApliMMDMDt=ApliMMDMDt from Legal.SRFPossessionDtls where CaseEntityId=@CaseEntityId and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

			select @CourtName=ISNULL(B.LegalCourtNameAlt_key,'NA'),@CourtLocation=ISNULL(CourtLocation,'NA') from legal.InterimMeasureDtls A		
				INNER JOIN legal.DimLegalCourtName B
					ON A.CourtNameAlt_Key=B.LegalCourtNameAlt_key
				WHERE A.CaseEntityId=@CaseEntityId

		 IF @ShutterMenuId IN(571)
			BEGIN

				SELECT @CaseEntityId=CaseEntityId FROM legal.SRFBasicDtls where SRF_EntityId=@CaseEntityId --aND EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
				--SELECT @CaseEntityId as amol
			END
		SELECT @CustomerId=CustomerId,@CustomerName=NAme,@CustomerEntityId=CustomerEntityId,@Branchcode=Branchcode--,@CaseReferenceNumber=caseno
from SysDataUpdationStatus where ID=@CaseEntityId

--SELECT  @CustomerName, @CaseEntityId

SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode	



		SELECT @CaseReferenceNumber=ISNULL(c.CaseNo,b.OnlineCaseNo) FROM legal.PermissionDetails A
			INNER JOIN legal.PlaintAdmissionDetails B
				ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
				AND a.CaseEntityId=B.CaseEntityId
			INNER JOIN SysDataUpdationStatus c
				on c.ID=a.CaseEntityId



   select @RevDeptNoticeDt=convert(varchar(10),RevDeptNoticeDt,103) from legal.PDRDtls 
   where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
   AND CustomerEntityId =@CustomerEntityId




SELECT @AccountEntityId=AccountEntityId FROM LEGAL.PermissionDetails where CaseEntityId=@CaseEntityId
		 print @AccountEntityId
		print 'customerentityid'
		print @CustomerEntityId
/*GET AccountEntityID from account data in case of Case other than Sec-25 and Sec-138, Arbitation*/
		IF NOT EXISTS(SELECT 1 FROM LEGAL.PermissionDetails where (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey and CaseEntityId =@CaseEntityId AND PermissionNatureAlt_Key IN(125,130)))
		-----
			BEGIN
				SELECT @AccountEntityId = STUFF((SELECT ',' +CAST(AccountEntityId AS VARCHAR(10)) FROM AdvAcBasicDetail M1 WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey ) AND CustomerEntityId=@CustomerEntityId
								FOR XML PATH('')),1,1,'')   
								FROM AdvAcBasicDetail M2 WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey ) AND CustomerEntityId=@CustomerEntityId
				IF LEFT(LTRIM(RTRIM(@AccountEntityId)),1)=',' SET @AccountEntityId=RIGHT(@AccountEntityId,LEN(@AccountEntityId)-1)
			END



		SELECT @ComplainID=CaseNo FROM SysDataUpdationStatus
				where ID=@CaseEntityId
			IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 

			 DROP TABLE #Temp
			 --SELECT @AccountEntityId=AccountEntityId FROM LEGAL.PermissionDetails


				

select @customerAcId = isnull(@customerAcId+',','') + CustomerACID  from AdvAcBasicDetail A
INNER JOIN legal.permissiondetails p on (P.EffectiveFromTimeKey<=@TimeKey and P.EffectiveToTimeKey>=@TimeKey) 
AND (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey) AND p.CustomerEntityId=a.CustomerEntityId AND p.CaseEntityId=@CaseEntityId
INNER JOIN CustomerBasicDetail C ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey) 
AND (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey) 
AND C.CustomerId=@CustomerId AND C.CustomerEntityId=A.CustomerEntityId 

 --select @customerAcId
			--select distinct a.AccountEntityId,CustomerACID,p.CustomerEntityId,caseEntityid into #Temp from AdvAcBasicDetail a inner join (
			--SELECT Items FROM [dbo].[Split](@AccountEntityId,','))b  on  a.AccountEntityId=cast(b.Items as int)
			--Inner join legal.permissiondetails p on p.CustomerEntityId=a.CustomerEntityId 
			--	PRINT 'Amol'
			--SELECT @CustomerAcID=CustomerACID
			--		FROM(
					
			--( SELECT  ([1]+ isnull(' , ' +[2],'') + isnull(' , ' +[3],'') + isnull(' , ' +[4],'') + isnull(' , ' +[5],'') + isnull(' , ' +[6],''))   AS CustomerACID   
			--								FROM (SELECT CustomerEntityid,CustomerACID,ROW_NUMBER() OVER(PARTITION BY  CustomerEntityId
			--								Order By  CustomerEntityId) A FROM  #temp where  CAseEntityid =@CaseEntityID ) PVT
			--								PIVOT  ( MIN (PVT.CustomerACID) FOR A IN ( [1],[2],[3],[4],[5],[6])) AS Buff) )g
			



			------------------------------------------------
			Print 11
	/*GET AccountEntityID from account data in case of Case other than Sec-25 and Sec-138, Arbitation*/
		IF NOT EXISTS(SELECT 1 FROM LEGAL.PermissionDetails where (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey and CaseEntityId =@CaseEntityId AND PermissionNatureAlt_Key IN(125,130)))
		-----
			BEGIN
				SELECT @AccountEntityId = STUFF((SELECT ',' +CAST(AccountEntityId AS VARCHAR(10)) FROM AdvAcBasicDetail M1 WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey ) AND CustomerEntityId=@CustomerEntityId
								FOR XML PATH('')),1,1,'')   
								FROM AdvAcBasicDetail M2 WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey ) AND CustomerEntityId=@CustomerEntityId
				IF LEFT(LTRIM(RTRIM(@AccountEntityId)),1)=',' SET @AccountEntityId=RIGHT(@AccountEntityId,LEN(@AccountEntityId)-1)
			END

			/*Added after discussion*/
			SELECT	 
				 @PrincipalLedgerBalance=	SUM(ISNULL(Principal ,0)) 
				,@UnappliedInterest=		SUM(ISNULL(UnapplInt ,0))	
				,@LegalExpenses=			SUM(ISNULL(Expenses	 ,0))
				,@Other=					SUM(ISNULL(Other	 ,0))
				,@Total=					SUM(ISNULL(Total	 ,0))
			FROM
			(			
				SELECT Principal,UnapplInt,Expenses,Other,Total FROM LEGAL.AdvAcOtherBalanceDetail 
				WHERE CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )--@AccountEntityId
				AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
			)

		UNION

	    SELECT	 A.Principal,A.UnapplInt,A.Expenses,A.Other,A.Total FROM  AdvAcOtherBalanceDetail_mOD A  
		INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM AdvAcOtherBalanceDetail_mOD
		           WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',')) AND AuthorisationStatus IN ('NP','MP','DP','RM')
				   GROUP BY CustomerEntityId,AccountEntityId,AuthorisationStatus
					)B ON B.EntityKey=A.EntityKey
					      AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		WHERE A.CustomerEntityID =@CustomerEntityId AND A.AccountEntityID IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,','))
		
		)S
			SELECT @Ac_DocumentDt=CONVERT(VARCHAR(10),Ac_DocumentDt,103)
				FROM CURDAT.AdvAcBasicDetail WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and CustomerEntityId=@CustomerEntityId

				SELECT @CaseReferenceNumber=G.CaseNo
							,@AcceptanceDate=CONVERT(VARCHAR(10), G.CompliaintDate,103)
						
						FROM 
						(
							SELECT case  when CaseType=135 then SEC.ComplaintSuitFiledDt 
										 WHEN CASETYPE=130 THEN NI.ComplaintDt 
										 WHEN CASETYPE IN(100,105,120) THEN PD.AcceptanceDate 
										 WHEN CaseType=240 THEN OD.ComplaintDt
										 when CaseType in(220,225)  THEN ccd.SuitDt
										  WHEN CaseType=215 THEN	Cc.ComplaintDt
										  WHEN CaseType=230 THEN  CCDT.ComplaintFiledDt
									 END [CompliaintDate],S.CaseNo,S.ParentEntityID from SysDataUpdationStatus S 
							LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN (Select top 1 ComplaintDt,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  from  legal.NIACTDtls where CaseEntityId=@CaseEntityId order by datecreated desc)NI ON NI.CaseEntityId=S.PARENTENTITYID AND  (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN legal.PlaintAdmissionDetails PD ON PD.CASEENTITYID=s.PARENTENTITYID	AND  (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN LEGAL.OmbudsmanDtls OD ON OD.CaseEntityId=S.ParentEntityID AND (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey)	
							LEFT JOIn LEGAL.CivilCaseDtls ccd on ccd.caseEntityid=S.ParentEntityID	AND (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)	
							Left Join Legal.ConsumerComplaintDtls cc on cc.caseEntityid=S.ParentEntityID	AND (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN legal.CriminalCaseDtls CCDT ON CCDT.caseEntityid=S.ParentEntityID	AND (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey)		
							LEFT JOIN LEGAL.ArbitrationDtls AD ON AD.caseEntityid=S.ParentEntityID	AND (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
							 where  S.ParentEntityID=@CaseEntityId
						 )G


					select @AOQTDt=convert(varchar(10),AOQTDt,103)
					from legal.ExecDecreeDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  CaseEntityId =@CaseEntityId


					
					SELECT @AppealAdmittedDt=Convert(varchar(10),AppealAdmittedDt,103)
				FROM(
		
		        SELECT A.AppealAdmittedDt  FROM LEGAL.AppealDetail  a
				 WHERE(a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey) AND
	             A.CaseEntityId=@CaseEntityId	
		        
		        UNION
		        
		        SELECT 	A.AppealAdmittedDt  FROM LEGAL.AppealDetail_Mod A
		        INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM LEGAL.AppealDetail_Mod
								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
		        				AND CaseEntityId=@CaseEntityId AND AuthorisationStatus IN ('NP','MP','DP','RM')
		        				GROUP BY CaseEntityId,AuthorisationStatus
		        			)B	ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
									AND A.EntityKey=B.EntityKey  
						 )Q


			select @AppealAdmittedDtDRAT=convert(varchar(10),AppealAdmittedDt,103) 
			from legal.InsolBnkrptAppealDetail 
			where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 

			select @AppealAdmittedDt=convert(varchar(10),AppealAdmittedDt,103) 
			from legal.InsolBnkrptAppealDetail 
			WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 

			select 	@AppealDecisionDt=convert(varchar(10),AppealDecisionDt,103) from legal.ServiceCaseDtls 
			where CaseEntityId=@CaseEntityId 
			and  DateCreated=(SELECT MAX(DateCreated)DateCreated FROM legal.ServiceCaseDtls 
								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 																
								)  

			select 	@RepresentationDt=RepresentationDt--convert(varchar(10),RepresentationDt,103)
			--RepresentationDt
			 from legal.ServiceCaseDtls 
			where CaseEntityId=@CaseEntityId 
			and  DateCreated=(SELECT MAX(DateCreated)DateCreated FROM legal.ServiceCaseDtls 
								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 																
								)  

	Print 25
	
		/*Total Account Balance Customer wise*/

				select @TotalAC_Balance=SUM(Balance) from LEGAL.PermissionDetails PD
								INNER JOIN CustomerBasicDetail CBD
									ON (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
									AND (PD.EffectiveFromTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)
									AND PD.CustomerEntityId=CBD.CustomerEntityId	
								INNER JOIN AdvAcBasicDetail ABD
									ON ABD.CustomerEntityId=CBD.CustomerEntityId
							INNER JOIN AdvAcBalanceDetail AABD
								ON (AABD.EffectiveFromTimeKey<=@TimeKey AND AABD.EffectiveToTimeKey>=@TimeKey)
								AND ABD.AccountEntityId=AABD.AccountEntityId
								WHERE PD.CaseEntityId=@CaseEntityId
							group by CBD.CustomerId
			

			SELECT @AppealNo=AppealNo
				FROM(
				
				        SELECT A.AppealNo  FROM LEGAL.AppealDetail  a
						 WHERE(a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey) and
				        																				
				         a.CaseEntityId=@CaseEntityId	
				        
				        UNION
				        
				        SELECT 	A.AppealNo  FROM LEGAL.AppealDetail_Mod A
				        INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM LEGAL.AppealDetail_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
				        				AND CaseEntityId=@CaseEntityId AND AuthorisationStatus IN ('NP','MP','DP','RM')
				        				GROUP BY CaseEntityId,AuthorisationStatus
				        			)B	ON A.EntityKey=B.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						WHERE A.CaseEntityId=@CaseEntityId
					 )Q			

			 IF  @ShutterMenuId NOT IN (3640)
				BEGIN
					SELECT @AppealOrderDate=convert(varchar(10),A.OrderDate,103) FROM SysDataUpdationDetails s
					LEFT JOIN (SELECT StageAlt_Key FROM SysDataUpdationDetails WHERE CaseEntityId =@CaseEntityId AND MenuId=@ShutterMenuId) G ON G.StageAlt_Key=S.NextStageAlt_Key AND MenuId<>@ShutterMenuId
					INNER JOIN lEGAL.AppealDetail A ON  A.CaseEntityId =@CaseEntityId Where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				END
			ELSE IF @ShutterMenuId IN (3640)
				BEGIN
					SELECT @AppealOrderDate=convert(varchar(10),A.OrderDate,103) FROM lEGAL.AppealDetail A   Where A.CaseEntityId =@CaseEntityId AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND A.MenuId=2011
				END

			SELECT @AppearanceDt= CONVERT(VARCHAR(10),AppearanceDt,103)					
			FROM legal.CivilCaseDtls
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


			SELECT @PDR_NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
			FROM legal.HearingDtls
			where EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId
	


			SELECT @AppellateAuthorityFiledBy=BOFurtureRecourseAlt_Key
			FROM 
			(SELECT BOFurtureRecourseAlt_Key FROM legal.OmbudsmanDtls 
			WHERE CaseEntityId = @CaseEntityId and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey))g

			select @AppointmentDt = convert(varchar(10),AppointmentDt,103) 
			from AssignedCaseDetail 
			where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 



		--------------	

					SELECT @NoofExpert = NoofExpert 
				FROM LEGAL.ArbitrationDtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId



-------------------------------------


			select @ArbiProceeding=ArbiProceeding
		
			from (
				select case when ResponsebyBorrowers='Y' then 'Regular'
							when ResponsebyBorrowers='N' then 'Ex Party'
						end ArbiProceeding
				from legal.ArbitrationDtls
				where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId
			)g

			SELECT @ArbitrationOrderDate=convert(varchar(10),OrderDate,103) from legal.InsolBnkrptAppealDetail where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 

			SELECT @ArbProceedingNo = ArbProceedingNo 
				FROM LEGAL.ArbitrationDtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId

			SELECT @BankRuptOrderDate=convert(varchar(10),OrderDate,103) from legal.BankruptcyDtls where  CaseEntityId = @CaseEntityId 
			AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


			SELECT @BOOrderDate=convert(varchar(10),BOOrderDate,103) from legal.OmbudsmanDtls where 
			(EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and CaseEntityId=@CaseEntityId

			SET @CGIT='CGIT Cum Labour Court'

			SELECT @CivilSuitAgnBHearingDtVal=convert(varchar(10),HearingDt,103) 
			FROM (
					SELECT HearingDt FROM legal.HearingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.HearingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
										) 
						AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
				)g
						

				SELECT @ClaimTotal =Sum(ISNULL(claimtotal,0))
				FROM legal.AdvAcCaseWiseBalanceDetail WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  CustomerEntityId =@CustomerEntityId
				group by CustomerEntityId

				SELECT @ParticualrsSoughtOnDt = CONVERT(VARCHAR(10),ParticualrsSoughtOnDt,103),
						@FixedInvestigationDt = CONVERT(VARCHAR(10),FixedInvestigationDt,103) ,
						@ComplaintFiledDt =CONVERT(VARCHAR(10),ComplaintFiledDt,103),
						@CourtOrderDt=Convert(varchar(10),CourtOrderDt,103),
						@ComPoliceStationDt=convert(varchar(10),ComPoliceStationDt,103),
						@CriminialSummonsServicedDt=Convert(varchar(10),SummonsServicedDt,103)
						  FROM (
									SELECT ParticualrsSoughtOnDt,FixedInvestigationDt,ComplaintFiledDt,CourtOrderDt,ComPoliceStationDt,SummonsServicedDt FROM legal.CriminalCaseDtls 
									WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
									AND CaseEntityId = @CaseEntityId 
									UNION
									SELECT A.ParticualrsSoughtOnDt,FixedInvestigationDt,ComplaintFiledDt,CourtOrderDt,ComPoliceStationDt,SummonsServicedDt FROM legal.CriminalCaseDtls_Mod A
									INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
													WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
						       						AND CaseEntityId = @CaseEntityId 
						       						GROUP BY 	CaseEntityId,AuthorisationStatus
												)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						                 WHERE A.CaseEntityId=@CaseEntityId
						 )G



			  SELECT @ConsentLetterDt=Convert(varchar(10),ConsentLetterDt,103) 
			  from AdvCustConsortiumDetail 
			  where DateCreated=(select MAX(DateCreated)datecreated from AdvCustConsortiumDetail where CustomerEntityId=@CustomerEntityId and ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey))

			  SELECT @ConsumerJudgmentDt=convert(VARCHAR(10),JudgmentDt,103),@ComplaintDtFiled=Convert(VARCHAR(10),ComplaintDtFiled,103) 
					FROM legal.ConsumerComplaintDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND CaseEntityId = @CaseEntityId 


			select @CurrentStageDate = convert(varchar(10),CurrentStageDate,103) 
			from legal.ArbitrationProceedingDtls 
			where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 


				SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
				LEFT JOIN Dimstages S on S.StagesAlt_Key=D.CurrentStageAlt_key 
				where ID=@CaseEntityId 


				SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
				FROM [CURDAT].[CustomerBasicDetail] WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
				CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId  


					SET @DateAdmittedOn='24/03/2010'
				--SELECT @DateAdmittedOn = DateAdmittedOn FROM legal.CriminalCaseDtls WHERE CaseEntityId = @CaseEntityId AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

				--SELECT @DateAdmittedOn = CONVERT(VARCHAR(10),DateAdmittedOn,103)  FROM legal.AppealDetail WHERE CaseEntityId = @CaseEntityId AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

				 SELECT @DemANDNoticeDate= CONVERT(VARCHAR(10),DemandNoticeDt,103) 
					FROM( 	
						SELECT DemandNoticeDt FROM legal.SRFBasicDtls --ExecutionRCDtls 
						WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	
								 AND CaseEntityId = @CaseEntityId
						  	 AND ISNULL(AuthorisationStatus,'A')='A' 
					   UNION
					   SELECT A.DemandNoticeDt FROM legal.SRFBasicDtls_Mod A
					   INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SRFBasicDtls_Mod
										WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					   														  AND CaseEntityId = @CaseEntityId
																			  AND AuthorisationStatus IN ('NP','MP','DP','RM') 
					   			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
																					AND B.EntityKey=A.EntityKey 
					             WHERE A.CaseEntityId=@CaseEntityId
					 )G		



				Select @DecreeAmount = DecreeAmount
				from legal.JudgementDtls
				WHERE CaseEntityId = @CaseEntityId 
				AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)



				
				Select @PreDecreeDate = PreDecreeDate
				from legal.JudgementDtls
				WHERE CaseEntityId = @CaseEntityId 
				AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)




				SELECT @DecreeDate =CONVERT(VARCHAR(10),DecreeDate,103) 
				 FROM (
							SELECT DecreeDate FROM legal.JudgementDtls 
							WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
							AND CaseEntityId = @CaseEntityId 
							UNION
							SELECT A.DecreeDate FROM legal.JudgementDtls_Mod A
							INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.JudgementDtls_Mod
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       									AND CaseEntityId = @CaseEntityId 
		       									GROUP BY 	CaseEntityId,AuthorisationStatus
										)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
												WHERE A.CaseEntityId=@CaseEntityId
					 )G 	

				 SELECT @DocExpiryDate=DocExpiryDate from legal.PermissionDetails where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
					

					select @DtAward=CONVERT(VARCHAR(10),DtAward,103)
					from legal.ArbitrationDtls
					where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId


				SELECT @DtofApplicationNCLT=CONVERT(VARCHAR(10),DtofApplicationNCLT,103) ,@DtLiquidationOrder=DtLiquidationOrder
				FROM legal.InsolvencyDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
				AND CaseEntityId=@CaseEntityId


			
				  	SELECT @DtofFirstDisb= CONVERT(VARCHAR(10),MAX(DtofFirstDisb),103) FROM CURDAT.AdvAcBasicDetail
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and CustomerEntityId=@CustomerEntityId	
			
				  	SELECT @Ac_DocumentDt=CONVERT(VARCHAR(10),Ac_DocumentDt,103)  FROM CURDAT.AdvAcBasicDetail
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and CustomerEntityId=@CustomerEntityId	




				SET @DtRti='2005-05-15' 



				select @EPDate=convert(varchar(10),EPDate,103)
				from legal.ExecDecreeDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  CaseEntityId =@CaseEntityId


				SELECT @FilExePetDt=CONVERT(VARCHAR(10),AcceptanceDate,103) FROM legal.plaintadmissiondetails 
					WHERE( EffectiveFROMTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)
					AND CaseEntityId=@CaseEntityId 
					 
					IF @FilExePetDt is null or @FilExePetDt=''
					BEGIN 
							SELECT  @FilExePetDt= CONVERT(VARCHAR(10),MIN(AppealFiledOnDt),103) 
							FROM legal.appealdetail WHERE( EffectiveFROMTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)
												AND CaseEntityId=@CaseEntityId  
					END		

					SELECT @FillingAplDt =CONVERT(VARCHAR(10),FillingAplDt,103) 
					FROM legal.PDRDtls WHERE CaseEntityID=@CaseEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


					/*FiledByRevPet*/
						SELECT @FiledBy=ParameterName,@FinalOrderDate=CONVERT(VARCHAR(10),FinalOrderDate,103)  FROM legal.RevPetiDtls R
						LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername LIKE'%DimFiledbyAgnBank%') d 
									ON (R.EffectiveFromTimeKey<=@TimeKey  AND R.EffectiveToTimeKey>=@TimeKey) AND
										r.RevPFiledByB=d.ParameterAlt_Key
					/*FiledByRevPet*/		

					
					SELECT @FramingOfIssueDt=CONVERT(VARCHAR(10),FramingOfIssueDt,103) FROM LEGAL.ServiceCaseOtherDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId			
			  


			  	SELECT @HearingDt= CONVERT(VARCHAR(10),MAX(HearingDt),103)  FROM legal.hearingdtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId
				and MenuId=@ShutterMenuId


				SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
				FROM (
						SELECT JudgementDate FROM legal.SuitProceedingDtls 
						WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
										) 
						AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and JudgementDate is not null and ScreenMenuId =@ShutterMenuId
						UNION
						SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
						INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							AND CaseEntityId = @CaseEntityId 
		       							GROUP BY 	CaseEntityId,AuthorisationStatus
							 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and JudgementDate is not null and ScreenMenuId =@ShutterMenuId
				)G

				





					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												---and ScreenMenuId < @ShutterMenuId
												AND CASE WHEN  ScreenMenuId>@ShutterMenuId   THEN 1 
														 WHEN  ScreenMenuId<@ShutterMenuId  THEN 1 
													END=1
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G  
				 
				 

				 IF @ShutterMenuId=4001  
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=4000
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=4000
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   
					END
				


					 IF @ShutterMenuId=551  
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=550
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=550
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   
					END

					
					


		

				

				 select @JudgementDt=convert(varchar(10),JudgementDt,103) from legal.Sec25Dtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and caseentityid=@CaseEntityID 


				 Select @JudgmentDtCivilStAgnB=convert(varchar(10),JudgmentDt,103) from LEGAL.CivilCaseDtls where caseentityid=@CaseEntityID and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


				  
					Select @MaxOrderDate=convert(varchar(10),MaxDate,103)
					 from (
					 select MaxDate=(
							SELECT MAX(MAXDATE)MAXDATE FROM 
								(
									 SELECT  (select MAX(myval) from (values (JudgmentDt),(OrderDate),(FinalOrderDate)) as D(myval)) AS 'MaxDate'
					 FROM legal.AppealDetail cc
					 LEFT JOIN legal.RevPetiDtls RP ON CC.CaseEntityID=RP.CaseEntityId AND (RP.EffectiveFromTimeKey<=@timeKey AND RP.EffectiveToTimeKey>=@timeKey)
					 AND (cc.EffectiveFromTimeKey<=@timeKey AND cc.EffectiveToTimeKey>=@timeKey)
					 LEFT JOIN legal.ConsumerComplaintDtls A ON A.CaseEntityId=CC.CaseEntityId AND (A.EffectiveFromTimeKey<=@timeKey AND A.EffectiveToTimeKey>=@timeKey)
					 WHERE  A.CaseEntityId=@CaseEntityId 
								)A	
						 
						 ))g

				
				Select @MaxServiceDate=convert(varchar(10),MaxDate,103)
				 from(
				  select MaxDate=(
					 SELECT MAX(MaxDate)MaxDate FROM 
						(
							 SELECT  (select MAX(myval) from (values (EnquiryConclusionDt),(AppealDecisionDt),(ApproachDecisionDt),(DtofServiceShowcauseNotice)) as D(myval)) AS 'MaxDate'
								FROM
								legal.ServiceCaseDtls where  CaseEntityID=@caseEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								and EntityKey=(Select Max(EntityKey)EntityKey from legal.ServiceCaseDtls where CaseEntityID=@caseEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								)
						)A 
				   
				   ))g


				   /*SummonsSerDt*/
						SELECT @SummonsSerDt=convert(varchar(10),SummonsSerDt,103),@NiactJudgementDt=convert(varchar(10),JudgementDt,103)
						FROM legal.NIACTDtls NI 
						WHERE ( EffectiveFROMTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)AND CaseEntityId=@CaseEntityId  
					/*SummonsSerDt*/

				

					SELECT @NPADt=CONVERT(VARCHAR(10),NPADt,103) FROM
					(
						SELECT D.NPADt FROM AdvCustNPADetail  D
						WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) AND D.CustomerEntityId=@CustomerEntityId AND ISNULL(D.AuthorisationStatus,'A')='A'
						UNION
						SELECT A.NPADt FROM AdvCustNPAdetail_Mod A
						INNER JOIN(		SELECT MAX(D.EntityKey)EntityKey FROM AdvCustNPAdetail_Mod D
										WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) 
										AND D.CustomerEntityId=@CustomerEntityId AND D.AuthorisationStatus IN('NP','MP','DP','RM')
										GROUP BY D.CustomerEntityId,D.AuthorisationStatus
								   )B ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND A.EntityKey=B.EntityKey
						
						WHERE A.CustomerEntityId=@CustomerEntityId			
					)U


					SELECT @NtDishonourRcvdDt =CONVERT(VARCHAR(10),NtDishonourRcvdDt,103) 
					 FROM (
					SELECT NtDishonourRcvdDt FROM legal.ChequeDtls 
					WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
					AND CaseEntityId = @CaseEntityId 
					UNION
					SELECT A.NtDishonourRcvdDt FROM legal.ChequeDtls_Mod A
					INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM legal.ChequeDtls_Mod
									WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       						AND CaseEntityId = @CaseEntityId 
		       						GROUP BY 	CaseEntityId,AuthorisationStatus
								)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
									WHERE A.CaseEntityId=@CaseEntityId
					 )G 



					 select @OrderJudgmentDt=convert(varchar(10),OrderJudgmentDt,103) 
						from legal.ArbitrationSettingAwardDtls 
						where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
					SELECT @SuitAppNo=ISNULL(SuitAppNo,0)  
					FROM 
					(
						SELECT SuitAppNo FROM LEGAL.PlaintAdmissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
						UNION
						SELECT SuitAppNo FROM legal.PlaintAdmissionDetails_Mod A
								 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
								 WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       					 AND CaseEntityId = @CaseEntityId 
		       					 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								 WHERE A.CaseEntityId=@CaseEntityId
								 GROUP BY SuitAppNo
					) A



					-------------
					
			  	SELECT @NextRemarkDate= CONVERT(VARCHAR(10),MAX(RemarkDt),103)  FROM legal.SuitProceedingDtls 
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId
				and ScreenMenuId < @ShutterMenuId

				IF @ShutterMenuId=4001
					BEGIN
							SELECT @NextRemarkDate= CONVERT(VARCHAR(10),MAX(RemarkDt),103)  FROM legal.SuitProceedingDtls 
							WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CaseEntityId=@CaseEntityId
							and ScreenMenuId=4000 AND ScreenMenuId < @ShutterMenuId
					END




					----------------

					 --select @ApplicationAdmittedDt=convert(varchar(10),ApplicationAdmittedDt,103) 
						--from legal.ArbitrationSettingAwardDtls 
						--where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
						if (@ShutterMenuId=1130)
						(
						 select @ApplicationAdmittedDt=convert(varchar(10),ApplicationAdmittedDt,103) 
						from legal.ArbitrationSettingAwardDtls 
						where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
						)


					


						--------------------

					/* @OSBalance*/
					SELECT @OSBalance=SUM(ISNULL(Balance ,0)) 
					FROM(

						SELECT B.Balance  FROM AdvAcBasicDetail A INNER JOIN  AdvAcBalanceDetail  B  ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						                                                                                           AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
																												   AND A.AccountEntityId=B.AccountEntityId AND ISNULL(B.AuthorisationStatus,'A')='A'AND ISNULL(A.AuthorisationStatus,'A')='A'
						WHERE B.AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )

						UNION

						 SELECT D.Balance FROM 

						 (
							SELECT CustomerEntityId,AccountEntityId
							FROM  AdvAcBasicDetail B INNER JOIN (
							SELECT MAX(B.Ac_Key)Ac_Key FROM AdvAcBasicDetail B
							WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
							 AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') AND B.AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )
							GROUP BY B.CustomerEntityId,B.AuthorisationStatus,AccountEntityId
						)A  ON B.Ac_Key=A.Ac_Key AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
					 )C  INNER  JOIN 

					 (
					 
					 SELECT AccountEntityId,Balance FROM AdvAcBalanceDetail_Mod B
					 INNER JOIN 
					 (
						SELECT MAX(B.EntityKey)EntityKey FROM AdvAcBalanceDetail_Mod B 
						WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
						AND B.AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') ) AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
						GROUP BY B.AuthorisationStatus,AccountEntityId
					 )A    ON A.EntityKey=B.EntityKey AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)

					 )D    ON C.AccountEntityId=D.AccountEntityId

					 WHERE C.CustomerEntityId=@CustomerEntityId AND D.AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )
					 )F
				 /* @OSBalance*/



				 SELECT @PermissionLetterDate=CONVERT(varchar(10),A.PermissionLetterDate,103) FROM
					  (		
					  
					  SELECT PermissionLetterDate 
					  FROM LEGAL.PermissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
															AND CaseEntityId = @CaseEntityId 
															AND ISNULL(AuthorisationStatus,'A')='A' 
														
					 UNION
					 
					 SELECT PermissionLetterDate FROM legal.PermissionDetails_Mod A
					   INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
					                WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
					   			       AND CaseEntityId = @CaseEntityId 
									   AND AuthorisationStatus IN ('NP','MP','DP','RM')
					   			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  
								 ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
					             WHERE A.CaseEntityId=@CaseEntityId															
				 )A


				 
				 SELECT	@PermissionSoughtdate=convert(varchar(10),A.PermissionSoughtdate,103) FROM (
							SELECT CustomerEntityId,Branchcode,PermissionSoughtdate FROM LEGAL.PermissionDetails 
										WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
							UNION
								SELECT CustomerEntityId,A.Branchcode,A.PermissionSoughtdate FROM legal.PermissionDetails_Mod A
									INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
												 WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       									 AND CaseEntityId = @CaseEntityId 
		       									 GROUP BY 	CaseEntityId,AuthorisationStatus
												 )B  
									ON B.EntityKey=A.EntityKey 
									WHERE A.CaseEntityId=@CaseEntityId							
				)A


				select @SymbolicPossessionDt=convert(varchar(10),SymbolicPossessionDt,103),@PhysicalPossessionDt=convert(varchar(10),PhysicalPossessionDt,103)
				 from legal.SRFPossessionDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  CaseEntityId =@CaseEntityId 



				 ---- PossessionSecAsSETDt
						SELECT @PossessionSecAsSETDt =CONVERT(VARCHAR(10),PossessionSecAsSETDt,103)
						  FROM (
									SELECT PossessionSecAsSETDt FROM legal.SRFPossessionDtls 
									WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
									AND CaseEntityId = @CaseEntityId 
									UNION
									SELECT A.PossessionSecAsSETDt FROM legal.SRFPossessionDtls_Mod A
									INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM legal.SRFPossessionDtls_Mod
													WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
						       						AND CaseEntityId = @CaseEntityId 
						       						GROUP BY 	CaseEntityId,AuthorisationStatus
												)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
													WHERE A.CaseEntityId=@CaseEntityId
						      )G 




					SELECT @RealizeAmt=RealizeAmt FROM
					 lEGAL.RealizedDtls where  CaseEntityId =@CaseEntityId and EntityKey=(select max(EntityKey)entitykey from lEGAL.RealizedDtls where CaseEntityId=@CaseEntityId )

					
					 

					SELECT @RecallnoticedatePDR=CONVERT(VARCHAR(10),RecallNoticeDate,103) from legal.PermissionDetails pd
					INNER JOIN CURDAT.AdvCustOtherDetail AC ON (AC.EffectiveFROMTimeKey<=@TimeKey AND AC.EffectiveToTimeKey>=@TimeKey)
															AND (pd.EffectiveFROMTimeKey<=@TimeKey AND pd.EffectiveToTimeKey>=@TimeKey)
															AND  AC.CustomerEntityId=PD.CustomerEntityId 
					WHERE CaseEntityId IS NOT NULL and CaseEntityId=@CaseEntityId
				

					-------------------

				SELECT @SaleDisposalDt=CONVERT(VARCHAR(10),SaleDisposalDt,103) FROM LEGAL.SRFBidingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId

				-----------------------
				 select @Sec25JudgementDt=convert(varchar(10),JudgementDt,103) from(
						select JudgementDt from legal.Sec25Dtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and caseentityid=@CaseEntityID 
					)g

					------------------------
				if (@ShutterMenuId <> 860)
				BEGIN	
				if (@ShutterMenuId=590 )
				(
						SELECT	
					@SecurityEntityId=SecurityEntityId
				
					FROM (SELECT SecurityEntityId
						
						FROM legal.SRFPossessionDtls
						WHERE datecreated=(
						SELECT max(datecreated) 
						FROM legal.SRFPossessionDtls
						WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey and caseentityid=@caseentityid) 
			
					)A
				)
				
				
					
				else 
				(
					SELECT	
					@SecurityEntityId=SecurityEntityId,
					@BorrNDate=Convert(varchar(10),BorrNDate,103),
					@DtService=Convert(varchar(10),DtService,103),
					@PossessiontakingDt=Convert(varchar(10),PossessiontakingDt,103),
					@ValSeizedAssetdt=convert(varchar(10),ValSeizedAssetdt,103)
					FROM (SELECT SecurityEntityId,
							BorrNDate,
							DtService,
							PossessiontakingDt,
							ValSeizedAssetdt
						FROM legal.SecurityDisposalDtls
						WHERE datecreated=(
						SELECT max(datecreated) 
						FROM legal.SecurityDisposalDtls
						WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey and caseentityid=@caseentityid) 
			
					)A
					)
					END

					---- SerNoticeDt
					SELECT @SerNoticeDt =CONVERT(VARCHAR(10),SerNoticeDt,103) 
					 FROM (
							SELECT SerNoticeDt FROM legal.DefendantServiceNoticeDtls 
						    WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
							AND CaseEntityId = @CaseEntityId 
							UNION
							SELECT A.SerNoticeDt FROM legal.DefendantServiceNoticeDtls_Mod A
							INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM legal.DefendantServiceNoticeDtls_Mod
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
					       						AND CaseEntityId = @CaseEntityId 
					       			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					                 WHERE A.CaseEntityId=@CaseEntityId
					      )G


			------------------------

					SELECT @SuitAppNo=ISNULL(SuitAppNo,0),@SuitAmount=ISNULL(SuitAmount,0)  
					 FROM 
						(
							SELECT SuitAmount,SuitAppNo FROM LEGAL.PlaintAdmissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
							UNION
							SELECT SuitAmount,SuitAppNo FROM legal.PlaintAdmissionDetails_Mod A
								   INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
								   WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       					   AND CaseEntityId = @CaseEntityId 
		       					  GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
		                          WHERE A.CaseEntityId=@CaseEntityId
								  GROUP BY SuitAmount,SuitAppNo
						) A


				---------------------------

				SELECT @SuitDt=CONVERT(VARCHAR(10),SuitDt,103)
					,@WrittenStmFillingDt=CONVERT(VARCHAR(10),WrittenStmFillingDt,103)
					--,@FramingOfIsuuesDt=CONVERT(VARCHAR(10),FramingOfIsuuesDt,103)
				FROM legal.CivilCaseDtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId

               -------------------------

			   SELECT @Insolvancyhearingdate= MAX(HearingDt) FROM legal.hearingdtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId  and MenuId=@ShutterMenuId and ParentEntityId=@ParentColumnValue


				 SELECT @AppearanceDate= MAX(AppearanceDate) FROM legal.SuitWStatementDtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId  and ScreenMenuID=@ShutterMenuId and SuitProcEntityId=@ParentColumnValue


			   ---------------
			   
		
			 --  	SELECT max (@nextdate=CONVERT(VARCHAR(10),NextHearingDt,103)
					
					
				--FROM legal.hearingdtls
				--WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				--AND CaseEntityId=@CaseEntityId


				SELECT @nextdate= MAX(NextHearingDt) FROM legal.hearingdtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId



				---------------------
				SELECT @PoliceNextHearingDt= MAX(NextHearingDt) FROM legal.hearingdtls
				WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CaseEntityId=@CaseEntityId


			------------------------------

			

			--SELECT @SuitNextHearingdate =CONVERT(VARCHAR(10),NextHearingDt,103) 
			--FROM (
			--		SELECT NextHearingDt FROM legal.SuitProceedingDtls 
			--		WHERE DateCreated=(
			--								SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
			--								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
			--								AND CaseEntityId=@CaseEntityId 
											
			--							) 
			--			AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
		 --      UNION
		 --      SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
		 --      INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
			--					WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --      							AND CaseEntityId = @CaseEntityId 
			--							--and ScreenMenuId < @ShutterMenuId
										
		 --      					GROUP BY 	CaseEntityId,AuthorisationStatus
			--			 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
			--					WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
		 --     )G   
		 
			SELECT @SuitNextHearingdate =CONVERT(VARCHAR(10),NextHearingDt,103) 
			FROM (
					SELECT NextHearingDt FROM legal.SuitProceedingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND 
											CaseEntityId=@CaseEntityId 
											--and ScreenMenuId < @ShutterMenuId --commented by amol
											AND CASE WHEN  ScreenMenuId>@ShutterMenuId   THEN 1 
														 WHEN  ScreenMenuId<@ShutterMenuId  THEN 1 
													END=1
										) 
						AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
		       UNION
		       SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
		       INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							AND CaseEntityId = @CaseEntityId 
										AND CASE WHEN  ScreenMenuId>@ShutterMenuId   THEN 1 
														 WHEN  ScreenMenuId<@ShutterMenuId  THEN 1 
													END=1
										--and ScreenMenuId < @ShutterMenuId
		       					GROUP BY 	CaseEntityId,AuthorisationStatus
						 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
		      )G   

			   IF @ShutterMenuId=4000
				BEGIN

					SELECT @SuitNextHearingdate =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
					SELECT NextHearingDt FROM legal.SuitProceedingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND 
											CaseEntityId=@CaseEntityId 
											and ScreenMenuId =520 --commented by amol
										) 
								AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					   UNION
					   SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
					   INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
					   							AND CaseEntityId = @CaseEntityId and ScreenMenuId=520
					   					GROUP BY 	CaseEntityId,AuthorisationStatus
								 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
					  )G   
				END

				IF @ShutterMenuId=550
				BEGIN
				
					
					SELECT @SuitNextHearingdate =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
					SELECT NextHearingDt FROM legal.SuitProceedingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND 
											CaseEntityId=@CaseEntityId 
											and ScreenMenuId =4000 --commented by amol
										) 
								AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					   UNION
					   SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
					   INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
					   							AND CaseEntityId = @CaseEntityId and ScreenMenuId=4000
					   					GROUP BY 	CaseEntityId,AuthorisationStatus
								 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
					  )G   
				END
				
				-------Added new menuid as 500 to set current stage date for first time as on 18/03/2024
					IF @ShutterMenuId in(500,480)
				BEGIN
					SELECT @NextHearingDt =CONVERT(VARCHAR(10),GETDATE(),103) 
						
					
				END

				------
				IF @ShutterMenuId=520
				BEGIN

					SELECT @SuitNextHearingdate =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
					SELECT NextHearingDt FROM legal.SuitProceedingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND 
											CaseEntityId=@CaseEntityId 
											and ScreenMenuId =500 --commented by amol
										) 
								AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					   UNION
					   SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
					   INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
					   							AND CaseEntityId = @CaseEntityId and ScreenMenuId=500
					   					GROUP BY 	CaseEntityId,AuthorisationStatus
								 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
					  )G   
				END
			  --------------------------

			  
			SELECT @SummonIssueDate=CONVERT(VARCHAR(10),SummonIssueDate,103) FROM LEGAL.SuitSummService WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


			-----------------------------

			  
			SELECT @SummonsSerDt_Suit=CONVERT(VARCHAR(10),SummServiceDate,103) FROM LEGAL.SuitSummService WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


			-----------------------------

			 SELECT @TitleOfCase=TitleOfCase
					 FROM
						( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
							AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1 --commented bty amol
						)G

				-----------------------------

			SELECT @Total= Total FROM LEGAL.AdvAcOtherBalanceDetail 
			WHERE CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )--@AccountEntityId
			AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


			---------------------------------------
			--Add & Comment by Vasundhara
			--	SELECT @WritPetitionAdmittedDt=CONVERT(VARCHAR(10),WritPetitionAdmittedDt,103)
			
			--FROM legal.WritPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--		AND CaseEntityId=@CaseEntityId

						SELECT @WritPetitionAdmittedDt=CONVERT(VARCHAR(10),AppealAdmittedDt,103)
			
			FROM legal.AppealDetail WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId
					--End Here




			--------------------------------
			SELECT @SummonsServiceDt=SummonsServiceDt
			from legal.Sec25Dtls where CaseEntityId=@CaseEntityId
			and 
			(EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)






			---------------------------------

				SELECT @WarrantDt=WarrantDt
			from legal.Sec25Dtls where CaseEntityId=@CaseEntityId
			and 
			(EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

			--------------------------------

	







			----------------------------------------

			SELECT @WritpetitionJudgmentdate=CONVERT(VARCHAR(10),judgementDt,103),@WritPetitionRejectedDt=CONVERT(VARCHAR(10),WritPetitionRejectedDt,103),
					@WritPetitionDt=CONVERT(VARCHAR(10),WritPetitionDt,103),@WritPetitionNo=WritPetitionNo,@JudgementDt=CONVERT(VARCHAR(10),JudgementDt,103)
			FROM legal.WritPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId






			/*OrderDate*/
			SELECT @AppealOrderDt= CONVERT(VARCHAR(10),OrderDate,103)
				FROM(
		
		        SELECT A.OrderDate  FROM LEGAL.AppealDetail  a
				 WHERE(a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey) AND
	             A.CaseEntityId=@CaseEntityId	
		        
		        UNION
		        
		        SELECT 	A.OrderDate FROM LEGAL.AppealDetail_Mod A
		        INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM LEGAL.AppealDetail_Mod
								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
		        				AND CaseEntityId=@CaseEntityId AND AuthorisationStatus IN ('NP','MP','DP','RM')
		        				GROUP BY CaseEntityId,AuthorisationStatus
		        			)B	ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
									AND A.EntityKey=B.EntityKey  
		        			
		        LEFT JOIN (SELECT * FROM DimParameter WHERE DimParameterName like '%DimApplicant%') C  ON (C.EffectiveFROMTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey) 
																											AND A.FiledByAlt_Key=C.ParameterAlt_Key
																											WHERE A.CaseEntityId=@CaseEntityId
		                                            																							
				 )Q






		/*ED Validation and message*/

		
			select  @EP_valDt=EP_valDt,@EP_ValMessage=EP_ValMessage
			from (
			select OrderDate EP_valDt ,CASE WHEN ISNULL(CONVERT(VARCHAR(10),OrderDate,103),'01/01/1900')<>'01/01/1900' THEN 'Date of EP should be greater then or equal to Date of Order from Appeal to HC and less then or equal to Current Date' END EP_ValMessage
			from legal.AppealDetail
			 where CaseEntityId=@CaseEntityId
			 AND (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			 and MenuID=2009 
			 UNION
			select OrderDate EP_valDt ,CASE WHEN ISNULL(CONVERT(VARCHAR(10),OrderDate,103),'01/01/1900')<>'01/01/1900' THEN 'Date of EP should be greater then or equal to Date of Order from Appeal to SC and less then or equal to Current Date' END EP_ValMessage
			from legal.AppealDetail
			 where CaseEntityId=@CaseEntityId
			  AND (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			 AND  MenuID=2010 
			
			UNION
			
			select OrderJudgmentDt EP_valDt,CASE WHEN ISNULL(CONVERT(VARCHAR(10),OrderJudgmentDt,103),'01/01/1900')<>'01/01/1900' THEN 'Date of EP should be greater then or equal to Date of Award from Arbitration Award and less then or equal to Current Date' END EP_ValMessage
			from legal.ArbitrationSettingAwardDtls
			where CaseEntityId=@CaseEntityId
			 AND (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			
			UNION
			
			select DtAward EP_valDt,CASE WHEN ISNULL(CONVERT(VARCHAR(10),DtAward,103),'01/01/1900')<>'01/01/1900' THEN 'Date of EP should be greater then or equal to Date of Judgment from Setting Aside an Award and less then or equal to Current Date' END EP_ValMessage
			from legal.ArbitrationDtls
			where (EffectiveFROMTimeKey<=49999 AND EffectiveToTimeKey>=49999)
			AND CaseEntityId=@CaseEntityId
			 AND (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			)a


		print 'reema'
	
	SELECT @OrderStatus=max(a.LegalJugFavorAgName)  FROM  LEGAL.AppealDetail B   
				LEFT JOIN legal.DimLegalJugFavorAg A
				ON (a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
						and A.LegalJugFavorAgAlt_Key=B.PrayerAltKey
			WHERE  CaseEntityId =@CaseEntityId and
			 (b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey)




	------=======================================------------------------------------
		--IF @ShutterMenuId IN(3400,710,3410,1510,3040)
		--	BEGIN
		--		SELECT	@PermissionSoughtdate=A.PermissionSoughtdate FROM (
		--					SELECT CustomerEntityId,Branchcode,PermissionSoughtdate FROM LEGAL.PermissionDetails 
		--								WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
		--					UNION
		--						SELECT CustomerEntityId,A.Branchcode,A.PermissionSoughtdate FROM legal.PermissionDetails_Mod A
		--							INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
		--										 WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		--       									 AND CaseEntityId = @CaseEntityId 
		--       									 GROUP BY 	CaseEntityId,AuthorisationStatus
		--										 )B  
		--							ON B.EntityKey=A.EntityKey 
		--							WHERE A.CaseEntityId=@CaseEntityId							
		--		)A
				
		--	END
	
	-----------------------
	


			 IF @ShutterMenuId IN(510,511,520,12115,12120,12280,12300,12310,790,780,500)
			BEGIN


					SELECT @CaseReferenceNumber=G.CaseNo
							,@AcceptanceDate=G.CompliaintDate
							,@CourtLOC=ADM.CourtLOC
							,@DRTCourtName=LegalCourtName

						FROM 
						(
							SELECT case  when CaseType=135 then SEC.ComplaintSuitFiledDt 
										 WHEN CASETYPE=130 THEN NI.ComplaintDt 
										 WHEN CASETYPE IN(100,105,120) THEN PD.AcceptanceDate 
										 WHEN CaseType=240 THEN OD.ComplaintDt
										 when CaseType in(220,225)  THEN ccd.SuitDt
										  WHEN CaseType=215 THEN	Cc.ComplaintDt
										  WHEN CaseType=230 THEN  CCDT.ComplaintFiledDt
									 END [CompliaintDate],S.CaseNo,S.ParentEntityID from SysDataUpdationStatus S 
							LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN (Select top 1 ComplaintDt,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  from  legal.NIACTDtls where CaseEntityId=@CaseEntityId order by datecreated desc)NI ON NI.CaseEntityId=S.PARENTENTITYID AND  (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN legal.PlaintAdmissionDetails PD ON PD.CASEENTITYID=s.PARENTENTITYID	AND  (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN LEGAL.OmbudsmanDtls OD ON OD.CaseEntityId=S.ParentEntityID AND (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey)	
							LEFT JOIn LEGAL.CivilCaseDtls ccd on ccd.caseEntityid=S.ParentEntityID	AND (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)	
							Left Join Legal.ConsumerComplaintDtls cc on cc.caseEntityid=S.ParentEntityID	AND (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN legal.CriminalCaseDtls CCDT ON CCDT.caseEntityid=S.ParentEntityID	AND (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey)		
							LEFT JOIN LEGAL.ArbitrationDtls AD ON AD.caseEntityid=S.ParentEntityID	AND (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
							 where  S.ParentEntityID=@CaseEntityId
						 )G
						INNER JOIN legal.SuitProceedingDtls SPD
							ON(SPD.EffectiveFromTimeKey<=@TimeKey AND SPD.EffectiveToTimeKey>=@TimeKey)
							AND SPD.CaseEntityId=G.ParentEntityID
						INNER JOIN legal.AdmissionDtls ADM
							ON (ADM.EffectiveFromTimeKey<=@TimeKey AND ADM.EffectiveToTimeKey>=@TimeKey)
							AND ADM.SuitProcEntityId=SPD.SuitProcEntityId 							
						LEft join legal.DimLegalCourtName DLCN 
							ON(DLCN.EffectiveFromTimeKey<=@TimeKey AND DLCN.EffectiveToTimeKey>=@TimeKey)
							AND DLCN.LegalCourtNameAlt_key=ADM.CourtNameAlt_Key
						where SPD.CaseEntityId=@CaseEntityId AND SPD.screenmenuid In (480,500)
				SELECT @ComplaintSuitNo=CaseNo FROM SysDataUpdationStatus

				SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
			END	

			--ELSE IF @ShutterMenuId IN(540)
			--BEGIN
			--	SELECT @NPADt=CONVERT(VARCHAR(10),NPADt,103) FROM
			--		(
			--			SELECT D.NPADt FROM AdvCustNPADetail  D
			--			WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) AND D.CustomerEntityId=@CustomerEntityId AND ISNULL(D.AuthorisationStatus,'A')='A'
			--			UNION
			--			SELECT A.NPADt FROM AdvCustNPAdetail_Mod A
			--			INNER JOIN(		SELECT MAX(D.EntityKey)EntityKey FROM AdvCustNPAdetail_Mod D
			--							WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) 
			--							AND D.CustomerEntityId=@CustomerEntityId AND D.AuthorisationStatus IN('NP','MP','DP','RM')
			--							GROUP BY D.CustomerEntityId,D.AuthorisationStatus
			--					   )B ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND A.EntityKey=B.EntityKey
						
			--			WHERE A.CustomerEntityId=@CustomerEntityId			
			--		)U
				
			--END


			ELSE IF @ShutterMenuId IN (12490)
			 BEGIN
				 select @LokAdalatMaxDate=CASE WHEN SDS.CaseType in(100,105) THEN ISNULL(CONVERT(varchar(10),SPD.MaxDate,103),CONVERT(varchar(10),PD.MaxDate,103)) END from SysDataUpdationStatus SDS	
				LEFT JOIN (
							SELECT CaseEntityId,
								(SELECT Max(permiDt) 
									 FROM (VALUES (PermissionSoughtdate), (LattestAckDate), (DocExpiryDate),(PermissionLetterDate),(RO_PermissionDt),(ZO_PermissionDt)) AS value(permiDt)) as [MaxDate]
									 FROM legal.PermissionDetails
									where CaseEntityId=@CaseEntityId
						  )PD on sds.ID=PD.CaseEntityId
				
				LEFT JOIN
						(
							SELECT CaseEntityId,
							(SELECT Max(permiDt) 
								 FROM (VALUES (AckReceivedDate), (DateGivenToAdv), (SentApprovalDate),(PlaintRecdDate),(ReplyDate)
								 ,(ApprovedDate),(OrgDocAppHandDate),(AdvAckDate),(PlaintCourtFileDate),(BorrNoticeDate),(AcceptanceDate),(LegalNoticeDate)) AS value(permiDt)) as [MaxDate]
								FROM legal.PlaintAdmissionDetails
								where CaseEntityId=@CaseEntityId
						)PLNT ON PLNT.CaseEntityId=SDS.ID
				
				LEFT JOIN 
					(
						SELECT CaseEntityId,
						 (SELECT Max(permiDt) 
						 FROM (VALUES (NextHearingDt), (RemarkDt), (JudgementDate)) AS value(permiDt)) as [MaxDate]
							FROM legal.SuitProceedingDtls
									where CaseEntityId=@CaseEntityId
								)SPD ON SPD.CaseEntityId=SDS.ID
							
						where sds.id=@CaseEntityId
				
			 END
			 ------------------
			ELSE IF @ShutterMenuId IN(570,590,571)
			BEGIN

				SELECT @Consortium_Name=G.Consortium_Name
				FROM(
						SELECT DC.Consortium_Name
						FROM CURDAT.AdvCustOtherDetail ACOD  
						LEFT JOIN DimBankingArrangement	DC	
								ON (ACOD.EffectiveFromTimeKey<=@TimeKey AND ACOD.EffectiveToTimeKey>=@TimeKey)
								AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
								AND DC.ConsortiumAlt_Key=ACOD.BankingArrangement											
						WHERE ACOD.CustomerEntityId=@CustomerEntityId AND ISNULL(ACOD.AuthorisationStatus,'A')='A'
 
 						UNION
 
 						SELECT Consortium_Name 
							FROM 
 								(
 									SELECT EmployeeID,BankingArrangement,CustomerEntityId,b.RecallNoticeDate,DC.Consortium_Name,Designation
 										FROM  AdvCustOtherDetail_Mod B 
												INNER JOIN (
 													SELECT MAX(B.EntityKey)EntityKey,RecallNoticeDate FROM AdvCustOtherDetail_Mod B
 													WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
 									AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
 													GROUP BY B.CustomerEntityId,B.AuthorisationStatus,RecallNoticeDate
 												)A  ON B.EntityKey=A.EntityKey AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
												LEFT JOIN DimBankingArrangement DC	
													ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
													AND DC.ConsortiumAlt_Key=B.BankingArrangement						
 												WHERE  B.CustomerEntityId=@CustomerEntityId
 								)C  
						)G




						-------------

								 
			
			SELECT	@Total=SUM(ISNULL(Total	 ,0))
			FROM
			(			
				SELECT Total FROM LEGAL.AdvAcOtherBalanceDetail 
				WHERE CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )--@AccountEntityId
				AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
			)

		UNION

	    SELECT	 A.Total FROM  AdvAcOtherBalanceDetail_mOD A  
		INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM AdvAcOtherBalanceDetail_mOD
		           WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',')) AND AuthorisationStatus IN ('NP','MP','DP','RM')
				   GROUP BY CustomerEntityId,AccountEntityId,AuthorisationStatus
					)B ON B.EntityKey=A.EntityKey
					      AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		WHERE A.CustomerEntityID =@CustomerEntityId AND A.AccountEntityID IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,','))
		
		)S
		

		 -----



		 ------------------ADDED LOGIC FOR TENTATIV DATE AS ON 03/12/2024
		 	
				IF (OBJECT_ID('tempdb..#DefendantService') IS NOT NULL)  
				DROP TABLE #DefendantService  
				  
				SELECT  
					D.CaseEntityId  
					,MAX(D.NoticeAcknowledgedDt) As NoticeAcknowledgedDt 
					,MAX(D.SerNoticeDt) As SerNoticeDt
					,MAX(D.DtofNewsPaperPublication) As DtofNewsPaperPublicationEnglish
					,MAX(D.DtofNewsPaperPublicationvernacular) As DtofNewsPaperPublicationVernacular	
				INTO #DefendantService  
				FROM [legal].[DefendantServiceNoticeDtls]  D  INNER JOIN legal.SRFBasicDtls Srf
				ON d.CaseEntityId = srf.CaseEntityId
					AND  srf.EffectiveFromTimeKey <= @TimeKey AND srf.EffectiveToTimeKey >= @TimeKey 
					AND  D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
				WHERE Srf.CaseEntityId=@CaseEntityId
				GROUP BY D.CaseEntityId-----,NoticeAcknowledgedDt  
				  
				  
				
				
				
				SELECT    
				    @TentativeDate=  DATEADD(DAY,60,MAX(maxDate.MaxValue))  --As NoticeAcknowledgedDt
				FROM 
				    #DefendantService d
				OUTER APPLY (
				    SELECT 
				        MAX(v.DateValue) AS MaxValue
				    FROM 
				        (VALUES 
				            (d.NoticeAcknowledgedDt), 
				            (d.SerNoticeDt), 
				            (d.DtofNewsPaperPublicationEnglish),  -- Ensure this is the correct name
				            (d.DtofNewsPaperPublicationVernacular)  -- Ensure this is the correct name
				        ) AS v(DateValue)
				    WHERE 
				        v.DateValue IS NOT NULL
				) AS maxDate;
				
				

				------------COMMENTED BELWO CODE TO FIND TENTATIVE DATE AS ON 03/12/2024
						/*TentativeDate*/  ---AS PER DISCUSS WITH SAURABH
						
						--SELECT @TentativeDate=DATEADD(DAY,60,MAX(TentativeDate)) FROM
						--(

						----NoticeAcknowledgedDt Validation added by suggestion came from BOB Site
						--		SELECT MAX(NoticeAcknowledgedDt) AS TentativeDate   FROM LEGAL.DefendantServiceNoticeDtls WHERE NoticeAcknowledgedDt IS NOT NULL
						--		And (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						--		And CaseEntityID=@CaseEntityId
						--		 --GROUP BY CaseEntityId

						-------------------------------------------------------------


							--SELECT MAX(DtofNewsPaperPublication) AS TentativeDate ,CaseEntityId  FROM LEGAL.DefendantServiceNoticeDtls WHERE DtofNewsPaperPublication IS NOT NULL
							--And (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--And CaseEntityID=@CaseEntityId
							-- GROUP BY CaseEntityId
						 --   UNION
							--SELECT MAX(DtofPasting) AS TentativeDate,CaseEntityId FROM LEGAL.DefendantServiceNoticeDtls WHERE DtofPasting IS NOT NULL
							--And (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--And CaseEntityID=@CaseEntityId
							-- GROUP BY CaseEntityId
						 --   UNION
							--SELECT MAX(SerNoticeDt) TentativeDate,CaseEntityId   FROM LEGAL.DefendantServiceNoticeDtls WHERE SerNoticeDt IS NOT NULL 
							--And (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--And CaseEntityID=@CaseEntityId
							--GROUP BY CaseEntityId
						 --   UNION
							--SELECT MAX(DtObjectionRcvdFBorrower)AS TentativeDate,CaseEntityId  FROM LEGAL.DefendantServiceNoticeDtls WHERE DtObjectionRcvdFBorrower IS NOT NULL 
							--And (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						 --   And CaseEntityID=@CaseEntityId
							--GROUP BY CaseEntityId
						
						--)A --WHERE A.CaseEntityID=@CaseEntityId
						
						/*TentativeDate*/
			END

			ELSE IF @ShutterMenuId IN(730,740)
			BEGIN 
				SELECT @CriminalJudgementDate=JudgementDate 
					FROM legal.CriminalCaseDtls
					WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId  				
			END

			--ELSE IF @ShutterMenuId IN(750,7050)
			--BEGIN
			--		--select @OrderJudgmentDt=convert(varchar(10),OrderJudgmentDt,103) 
			--		--	from legal.ArbitrationSettingAwardDtls 
			--		--	where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
			--		--SELECT @SuitAppNo=ISNULL(SuitAppNo,0)  
			--		--FROM 
			--		--(
			--		--	SELECT SuitAppNo FROM LEGAL.PlaintAdmissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
			--		--	UNION
			--		--	SELECT SuitAppNo FROM legal.PlaintAdmissionDetails_Mod A
			--		--			 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
			--		--			 WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --  --    					 AND CaseEntityId = @CaseEntityId 
		 --  --    					 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
			--		--			 WHERE A.CaseEntityId=@CaseEntityId
			--		--			 GROUP BY SuitAppNo
			--		--) A

			--		 SELECT @TitleOfCase=TitleOfCase
			--		 FROM
			--			( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
			--				AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
			--			)G
			--END


			ELSE IF @ShutterMenuId in(760,7810,770,3670,800,1330,11215,1200,12060,12065,12070,12075,12270,12320,13110,12000)
			BEGIN
				 --SELECT @TitleOfCase=TitleOfCase
					-- FROM
					--	( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
					--		AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
					--	)G

				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 

				
				SELECT @WritPetitionNo=WritPetitionNo FROM legal.WritPetitionDtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
			END


		

			--ELSE IF @ShutterMenuId in(860,9003,9004)
			ELSE IF @ShutterMenuId in('860')
			BEGIN 
				PRINT 'In MenuId 860 with sec.Id' 
				PRINT @SecurityEntityId
					select @SymbolicPossessionDt=convert(varchar(10),SymbolicPossessionDt,103),@PhysicalPossessionDt=convert(varchar(10),PhysicalPossessionDt,103)
					from legal.SRFPossessionDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND  CaseEntityId =@CaseEntityId AND SecurityEntityId=@SecurityEntityId

				--SELECT	
				--	@SecurityEntityId=SecurityEntityId,
				--	@BorrNDate=Convert(varchar(10),BorrNDate,103),
				--	@DtService=Convert(varchar(10),DtService,103),
				--	@PossessiontakingDt=Convert(varchar(10),PossessiontakingDt,103)
				--	--@ValSeizedAssetdt=convert(varchar(10),ValSeizedAssetdt,103)
				--FROM (SELECT SecurityEntityId,
				--		BorrNDate,
				--		DtService,
				--		PossessiontakingDt
				--		--ValSeizedAssetdt
				--	FROM legal.SecurityDisposalDtls
				--	WHERE datecreated=(
				--	SELECT max(datecreated) 
				--	FROM legal.SecurityDisposalDtls
				--	WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey and caseentityid=@caseentityid) 
			
				--)A
			END
			

			ELSE IF @ShutterMenuId IN(1210,3640,9003,9004,2012)
			BEGIN 
				SELECT	
					@SecurityEntityId=SecurityEntityId	
					FROM (SELECT SecurityEntityId					
							 FROM legal.SecurityDisposalDtls
								 WHERE datecreated=(
														SELECT max(datecreated) 
														FROM legal.SecurityDisposalDtls
														WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey and caseentityid=@caseentityid
													) 
							)A
					SELECT @SecurityNature=SecurityNature
						FROM
						(
							SELECT SecurityNature FROM AdvSecurityValueDetail WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId   
																					AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						)G
			END

			--ELSE IF @ShutterMenuId IN(1230,12310)
			--BEGIN
			--	SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
			--	FROM [CURDAT].[CustomerBasicDetail] WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--END

	

			ELSE IF @ShutterMenuId IN(1340,1350)
			BEGIN
				 SELECT @Employeeid=EmployeeID FROM CURDAT.AdvCustOtherDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND CustomerEntityId=@CustomerEntityId
				 SELECT @EmployeeName=EmployeeName FROM legal.CriminalCaseEmpInvolvedtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
			END

			--ELSE IF @ShutterMenuId IN(1401,1402)
			--BEGIN
				
			-- select @JudgementDt=convert(varchar(10),JudgementDt,103) from legal.Sec25Dtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and caseentityid=@CaseEntityID 

			--END

			ELSE IF @ShutterMenuId in(1405,1406,1200,12060,12065,12070,12075,12050)
			BEGIN
						--select @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
						--	FROM (
						--	SELECT JudgementDate FROM legal.SuitProceedingDtls 
						--	WHERE DateCreated=(
						--							SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
						--							WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
						--						) 
						--		AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
						--	UNION
						--	SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
						--	INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
						--						WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
						--								AND CaseEntityId = @CaseEntityId 
						--						GROUP BY 	CaseEntityId,AuthorisationStatus
						--				 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						--						WHERE A.CaseEntityId=@CaseEntityId and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
						-- )G
						SELECT @WritPetitionNo=WritPetitionNo FROM legal.WritPetitionDtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
					 SELECT @Employeeid=EmployeeID FROM CURDAT.AdvCustOtherDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND CustomerEntityId=@CustomerEntityId
					
					 --SELECT @SuitAppNo=ISNULL(SuitAppNo,0)  
					 --FROM 
						--(
						--	SELECT SuitAmount,SuitAppNo FROM LEGAL.PlaintAdmissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(AuthorisationStatus,'A')='A' AND CaseEntityId = @CaseEntityId 
						--	UNION
						--	SELECT SuitAmount,SuitAppNo FROM legal.PlaintAdmissionDetails_Mod A
						--		   INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
						--		   WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		    --   					   AND CaseEntityId = @CaseEntityId 
		    --   					  GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
		    --                      WHERE A.CaseEntityId=@CaseEntityId
						--		  GROUP BY SuitAmount,SuitAppNo
						--) A
			END

			ELSE IF @ShutterMenuId IN(2008,3660,3650,3680,12080,12270,2013)
			BEGIN
				  --SELECT @TitleOfCase=TitleOfCase
					 --FROM
					 --( 
						-- SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
						--   AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
						-- )G

						 
						-- 	  SELECT @TitleOfCaseWP=CustomerName from 
						--( SELECT CustomerName FROM legal.writPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
						--   AND CaseEntityId=@CaseEntityId and EntityKey=(select max(EntityKey)EntityKey from  legal.writPetitionDtls where CaseEntityId=@CaseEntityId and menuid=3610 )
					--)G
					SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId
		
			END

			ELSE IF @ShutterMenuId IN(2010)
			BEGIN
				select @ArbitrationEntityId=ArbitrationEntityId from legal.ArbitrationDtls
					where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId
				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId
			END

			ELSE IF @ShutterMenuId IN(2011)
			BEGIN
				
					SELECT @SecurityNature=SecurityNature
						FROM
						(
							SELECT SecurityNature FROM AdvSecurityValueDetail WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId   
																					AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						)G
					select @OrderStatus=(case  when CAST(PrayerAltKey AS VARCHAR(50))='2' then 'Bank''s Favor' when  CAST(PrayerAltKey AS VARCHAR(50))='3' then 'Bank''s Against' else  CAST(PrayerAltKey AS VARCHAR(50)) end )  from legal.AppealDetail 
					where CaseEntityId=@CaseEntityId and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			END

		


			ELSE IF @ShutterMenuId IN(2014,2015,2016,3010,2017,3420,3425,11215,2009,11215,2019)
			BEGIN
					SELECT @ComplainID=CaseNo FROM SysDataUpdationStatus
					where ID=@CaseEntityId
				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId
				select @CaseType=PermissionNatureAlt_Key from legal.PermissionDetails where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
				
				SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
		select @RemainingOs=(isnull(RemainingOs,0))
		from legal.ExecDecreeDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  CaseEntityId =@CaseEntityId

			END
			
			ELSE IF @ShutterMenuId IN(3180,3200)
			BEGIN
				
				select @CaseTypeCode=PermissionNatureAlt_Key from legal.PermissionDetails where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
			
				 IF @CaseTypeCode IN(235,515)
					BEGIN
						 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimFiledbyAgnBank')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  							
					END
	
				ELSE IF @CaseTypeCode =220
					BEGIN						
						  Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimFiledbyAgnBank')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(220)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  
					END

				ELSE IF @CaseTypeCode =130
					BEGIN
						Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimLegalAppealBy')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType=130
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid						
					END

				ELSE IF @CaseTypeCode  in (105,205,100)
					BEGIN
						 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimLegalAppealBy')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (105,205,100)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
											
					END


							ELSE IF @CaseTypeCode  in (215)
					BEGIN
						 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='Dimfiledbank')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (215)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
						
					END
				ELSE IF @CaseTypeCode in (135)
					BEGIN
						  Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimLegalAppealBy')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(135)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
						 						
					END

				ELSE IF @CaseTypeCode =225
					BEGIN
						 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimFiledByAppeal')d  --  DimLegalAppealByCivil
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(225)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
						
					END

				ELSE IF @CaseTypeCode=230
					BEGIN
						  Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimLegalAppealBy')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(230)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid						 
						
					END

				ELSE IF @CaseTypeCode =150
					BEGIN
						  Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
						 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimApplicant')d
						 on d.parameteralt_key=a.FiledByAlt_Key
						  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(150)
						 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
						 						
					END
		

				IF @ShutterMenuId IN(3200,13110)
				BEGIN			
					--SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
					--LEFT JOIN Dimstages S on S.StagesAlt_Key=D.CurrentStageAlt_key 
					--where ID=@CaseEntityId 

					SELECT @WritPetitionNo=WritPetitionNo FROM legal.WritPetitionDtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
				END
			END

			IF @ShutterMenuId IN(3190)
			BEGIN
				 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
				 left join (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername='DimFiledbyAgnBank')d
				 on d.parameteralt_key=a.FiledByAlt_Key
				  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
				 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

				--SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
				--LEFT JOIN Dimstages S on S.StagesAlt_Key=D.CurrentStageAlt_key 
				--where ID=@CaseEntityId 
			END

			ELSE IF @ShutterMenuId IN(3400,3410)
			BEGIN
				

				SELECT @BranchName=BranchName FROM DimBranch WHERE BranchCode=@Branchcode

			END


			

			ELSE IF @ShutterMenuId IN(3440,3450,3430)
			BEGIN
				--SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
				--FROM [CURDAT].[CustomerBasicDetail] WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

				SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
			END

			-----------------ADDED BY VIDYA
	  ELSE	IF @ShutterMenuId=3470
			BEGIN
			SELECT @EmployeeID=E.EmployeeID,@Designation=Designation
		
    		FROM(
 
			SELECT EmployeeID,--B.EmployeeName,
			Designation
 
			FROM CURDAT.AdvCustOtherDetail 												
			WHERE CustomerEntityId=@CustomerEntityId AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND ISNULL(AuthorisationStatus,'A')='A'
    
    

 
 			UNION
 
			SELECT C.EmployeeID,--D.EmployeeName ,
			Designation FROM 
			(
				SELECT EmployeeID,Designation
				FROM  AdvCustOtherDetail_Mod B INNER JOIN (
				SELECT MAX(B.EntityKey)EntityKey,RecallNoticeDate FROM AdvCustOtherDetail_Mod B
				WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
				 AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
				GROUP BY B.CustomerEntityId,B.AuthorisationStatus,RecallNoticeDate
			)A  ON B.EntityKey=A.EntityKey AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
							
			 WHERE  B.CustomerEntityId=@CustomerEntityId
			)C  
		)E
		select   @WPSCFiledBy=FiledBy
			from (select  Case when PermissionNatureAlt_Key=205 then 'Award Staff' 
													when PermissionNatureAlt_Key=210 then 'Officer' end [FiledBy]
													from legal.permissiondetails 
													WHERE CaseEntityID=@CaseEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
													)g
	    
		
		END

		ELSE IF @ShutterMenuId=3480
		BEGIN
		SELECT @WritPetitionNo=WritPetitionNo FROM legal.WritPetitionDtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
		 SELECT @TitleOfCaseWP=CustomerName from 
						( SELECT CustomerName FROM legal.writPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
						   AND CaseEntityId=@CaseEntityId and EntityKey=(select max(EntityKey)EntityKey from  legal.writPetitionDtls where CaseEntityId=@CaseEntityId and menuid=3610 ))G
		select @FiledByWritPet=FiledBy 
		from 
		(Select case WHEN PrayerStatusAltKey=1 and PostJudStatusAlt_Key in(254,255,256,257) THEN 'Customer' 
					WHEN PrayerStatusAltKey=2 and PostJudStatusAlt_Key in(254,255,256,257) THEN 'Bank'
				end as FiledBy
		 from legal.WritPetitionDtls 
		 Where MenuId=3610 
			AND CaseEntityId=@CaseEntityID 
			and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey ))g
		END

		ELSE IF @ShutterMenuId in(3590,3600)

		BEGIN
			SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
			SELECT @Employeeid=EmployeeID FROM CURDAT.AdvCustOtherDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND CustomerEntityId=@CustomerEntityId
		    SELECT @EmployeeName=EmployeeName FROM legal.CriminalCaseEmpInvolvedtls WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId

			Select @DefendantRelationship =RelationEntitiesName from
			CustomerBasicdetail C
			LEFT JOIN  AdvAcRelations AA ON(AA.EffectiveFROMTimeKey<=@Timekey AND aa.EffectiveToTimeKey>=@Timekey) AND AA.CustomerEntityID=C.CustomerEntityID 
			  
			LEFT JOIN DimRelationEntities DR ON (DR.EffectiveFromTimeKey<=@Timekey AND dr.EffectiveToTimeKey>=@Timekey)
										AND  AA.RelationTypeAlt_Key=DR.RelationEntitiesAlt_Key
		where (C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey) AND C.CustomerEntityID=@CustomerEntityID
	
		END 
		ELSE IF @ShutterMenuId in(3630,9002)
		 BEGIN

				
		 	SELECT	 
				 @PrincipalLedgerBalance=	SUM(ISNULL(Principal ,0)) 
				,@UnappliedInterest=		SUM(ISNULL(UnapplInt ,0))	
				,@LegalExpenses=			SUM(ISNULL(Expenses	 ,0))
				,@Other=					SUM(ISNULL(Other	 ,0))
				,@Total=					SUM(ISNULL(Total	 ,0))
			FROM
			(			
				SELECT Principal,UnapplInt,Expenses,Other,Total FROM LEGAL.AdvAcOtherBalanceDetail 
				WHERE CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )--@AccountEntityId
				AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
			)

		UNION

	    SELECT	 A.Principal,A.UnapplInt,A.Expenses,A.Other,A.Total FROM  AdvAcOtherBalanceDetail_mOD A  
		INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM AdvAcOtherBalanceDetail_mOD
		           WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',')) AND AuthorisationStatus IN ('NP','MP','DP','RM')
				   GROUP BY CustomerEntityId,AccountEntityId,AuthorisationStatus
					)B ON B.EntityKey=A.EntityKey
					      AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		WHERE A.CustomerEntityID =@CustomerEntityId AND A.AccountEntityID IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,','))
		
		)S
		 END

		

		ELSE IF @ShutterMenuId=3460
		BEGIN
		
		SELECT	@RecoveryCharge=(cast(Total as float)*0.10)
		FROM
		(			
		SELECT Total FROM LEGAL.AdvAcOtherBalanceDetail 
		WHERE CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',') )--@AccountEntityId
		AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

		UNION

	    SELECT	Total FROM  AdvAcOtherBalanceDetail_mOD A  
		INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM AdvAcOtherBalanceDetail_mOD
		           WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND CustomerEntityId =@CustomerEntityId AND AccountEntityId IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,',')) AND AuthorisationStatus IN ('NP','MP','DP','RM')
				   GROUP BY CustomerEntityId,AccountEntityId,AuthorisationStatus
					)B ON B.EntityKey=A.EntityKey
					      AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		WHERE A.CustomerEntityID =@CustomerEntityId AND A.AccountEntityID IN (SELECT Items FROM [dbo].[Split](@AccountEntityId,','))
		
		)S

		select @AmountClaimed=@RecoveryCharge+@Total

   

		END


		------Sonali



					

 --ELSE IF @ShutterMenuId IN (590,601)
	--BEGIN
		
			
	--	 SELECT @DemANDNoticeDate= CONVERT(VARCHAR(10),DemandNoticeDt,103) 
	--		FROM( 	
	--					SELECT DemandNoticeDt FROM legal.SRFBasicDtls --ExecutionRCDtls 
	--					WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	
	--							 AND CaseEntityId = @CaseEntityId
	--					  	 AND ISNULL(AuthorisationStatus,'A')='A' 
	--				   UNION
	--				   SELECT A.DemandNoticeDt FROM legal.SRFBasicDtls_Mod A
	--				   INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SRFBasicDtls_Mod
	--									WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
	--				   														  AND CaseEntityId = @CaseEntityId
	--																		  AND AuthorisationStatus IN ('NP','MP','DP','RM') 
	--				   			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
	--																				AND B.EntityKey=A.EntityKey 
	--				             WHERE A.CaseEntityId=@CaseEntityId
	--	       )G												


	--END

ELSE IF @ShutterMenuId =650
	 BEGIN
				
			/*CaseReferenceNumber*/	

			SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 

			IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
					BEGIN
							SELECT  @CaseReferenceNumber=CASENO
							FROM 
							(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
										 WHEN CASETYPE=130 THEN NI.ComplaintNo 
										 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
										 WHEN CaseType=240 THEN OD.ComplaintNo
										 WHEN CaseType in(220,225)			then ccd.SuitNo
										 WHEN CaseType=215 THEN	Cc.ComplSuitNo
										 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
										 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
										 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
							LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
										WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
												CaseEntityId=@caseEntityID order by datecreated DESC
									  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
											AND NI.CaseEntityId=S.PARENTENTITYID   
							LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																		 AND PD.CASEENTITYID=s.PARENTENTITYID	  
							LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) AND OD.CaseEntityId=S.ParentEntityID  				
							LEFT JOIn LEGAL.CivilCaseDtls CCD ON (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)AND ccd.caseEntityid=S.ParentEntityID	 
							Left Join Legal.ConsumerComplaintDtls CC ON (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey) AND CC.caseEntityid=S.ParentEntityID	 
							LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) AND CCDT.caseEntityid=S.ParentEntityID	 
							LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
							 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
							 AND @CaseEntityId=S.ParentEntityID )G

					END

			/*CaseReferenceNumber*/			

			/*JudgementDate*/

			--SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
			--FROM (
			--		SELECT JudgementDate FROM legal.SuitProceedingDtls 
			--		WHERE DateCreated=(
			--								SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
			--								WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
			--							) 
			--			AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
			--			AND CaseEntityId=@CaseEntityId  
			--			AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		 --      UNION

		 --      SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
		 --      INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
			--					WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --      							AND CaseEntityId = @CaseEntityId 
		 --      					GROUP BY 	CaseEntityId,AuthorisationStatus
			--			 )B  ON  (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
			--					WHERE A.CaseEntityId=@CaseEntityId AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		 --     )G	

			  /*JudgementDate*/
			  
			  /*TitleOfCase*/
			  
			  --SELECT @TitleOfCase=TitleOfCase
			  --FROM
			  --( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
			  --  AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
			  --)G
			  
			  /*TitleOfCase*/		

	 END

--ELSE IF @ShutterMenuId=660   
--	BEGIN
--			/*TitleOfCase*/
			
--			SELECT @TitleOfCase=TitleOfCase
--			FROM
--			( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
--			  AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
--			)G
			
--			/*TitleOfCase*/			
	--END

--ELSE IF @ShutterMenuId=670
--	 BEGIN

--			--SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
--			--LEFT JOIN Dimstages S on S.StagesAlt_Key=D.CurrentStageAlt_key 
--			--WHERE ID=@CaseEntityId 	
--	 END

ELSE IF @ShutterMenuId=710
	 BEGIN
			SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 

			select @NoOfArbitrator=NoOfArbitrator from legal.ArbitrationDtls where CaseEntityId=@CaseEntityId
and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

			IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
					BEGIN
							SELECT  @CaseReferenceNumber=CASENO
							FROM 
							(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
										 WHEN CASETYPE=130 THEN NI.ComplaintNo 
										 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
										 WHEN CaseType=240 THEN OD.ComplaintNo
										 WHEN CaseType in(220,225)			then ccd.SuitNo
										 WHEN CaseType=215 THEN	Cc.ComplSuitNo
										 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
										 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
										 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
							LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
										WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
												CaseEntityId=@caseEntityID order by datecreated DESC
									  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
											AND NI.CaseEntityId=S.PARENTENTITYID   
							LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																		 AND PD.CASEENTITYID=s.PARENTENTITYID	  
							LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) AND OD.CaseEntityId=S.ParentEntityID  				
							LEFT JOIn LEGAL.CivilCaseDtls CCD ON (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)AND ccd.caseEntityid=S.ParentEntityID	 
							Left Join Legal.ConsumerComplaintDtls CC ON (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey) AND CC.caseEntityid=S.ParentEntityID	 
							LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) AND CCDT.caseEntityid=S.ParentEntityID	 
							LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
							 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
							 AND @CaseEntityId=S.ParentEntityID )G

					END

			/*CaseReferenceNumber*/			

			/*JudgementDate*/

			--SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
			--FROM (
			--		SELECT JudgementDate FROM legal.SuitProceedingDtls 
			--		WHERE DateCreated=(
			--								SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
			--								WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
			--							) 
			--			AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
			--			AND CaseEntityId=@CaseEntityId  
			--			AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		 --      UNION

		 --      SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
		 --      INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
			--					WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --      							AND CaseEntityId = @CaseEntityId 
		 --      					GROUP BY 	CaseEntityId,AuthorisationStatus
			--			 )B  ON  (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
			--					WHERE A.CaseEntityId=@CaseEntityId AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		 --     )G	

			  /*JudgementDate*/
			  
			 
			 
			  /*PermissionSoughtdate*/
			  
			 -- SELECT @PermissionSoughtdate=CONVERT(varchar(10),A.PermissionSoughtdate,103) FROM
			 -- (		
			  
			 -- SELECT PermissionSoughtdate 
			 -- FROM LEGAL.PermissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
				--									AND CaseEntityId = @CaseEntityId 
				--									AND ISNULL(AuthorisationStatus,'A')='A' 
												
			 --UNION
			 
			 --SELECT PermissionSoughtdate FROM legal.PermissionDetails_Mod A
		  --     INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
		  --                  WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
		  --     			       AND CaseEntityId = @CaseEntityId 
				--			   AND AuthorisationStatus IN ('NP','MP','DP','RM')
		  --     			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  
				--		 ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
		  --               WHERE A.CaseEntityId=@CaseEntityId															
			 -- )A

			  /*PermissionSoughtdate*/

	 END

--ELSE IF @ShutterMenuId=720
--	BEGIN
--			/*JudgementDate*/

--			SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
--			FROM (
--					SELECT JudgementDate FROM legal.SuitProceedingDtls 
--					WHERE DateCreated=(
--											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
--											WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
--										) 
--						AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
--						AND CaseEntityId=@CaseEntityId  
--						AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
--		       UNION

--		       SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
--		       INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
--								WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AuthorisationStatus IN ('NP','MP','DP','RM')
--		       							AND CaseEntityId = @CaseEntityId 
--		       					GROUP BY 	CaseEntityId,AuthorisationStatus
--						 )B  ON  (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
--								WHERE A.CaseEntityId=@CaseEntityId AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
--		      )G	

--			  /*JudgementDate*/		
--	END	


ELSE IF @ShutterMenuId IN (730,720,760,1000)
	BEGIN
			/*JudgementDate*/

			SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
			FROM (
					SELECT JudgementDate FROM legal.SuitProceedingDtls 
					WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 
										) 
						AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
						AND CaseEntityId=@CaseEntityId  
						AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		       UNION

		       SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
		       INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
								WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							AND CaseEntityId = @CaseEntityId 
		       					GROUP BY 	CaseEntityId,AuthorisationStatus
						 )B  ON  (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
								WHERE A.CaseEntityId=@CaseEntityId AND JudgementDate IS NOT NULL --and ScreenMenuId =@ShutterMenuId
		      )G	

			  /*JudgementDate*/		
	END	


	
ELSE IF @ShutterMenuId IN (890,900,910,920,3060)
	BEGIN

	 IF @ShutterMenuId IN (900)
	BEGIN
	select @CourtName=ISNULL(B.LegalCourtNameAlt_key,'NA'),@CourtLocation=ISNULL(CourtLOC,'NA') from legal.AdmissionDtls A		
				INNER JOIN legal.DimLegalCourtName B
					ON A.CourtNameAlt_Key=B.LegalCourtNameAlt_key
				WHERE A.CaseEntityId=@CaseEntityId
	set @CourtNameAlt_Key=@CourtName
	print('courtname')
	print (@CourtNameAlt_Key)
	End



			/*SuitAppNo,SuitAmount*/ --Application Number
			SELECT 	@SuitAmount=ISNULL(SuitAmount,0),@SuitAppNo=ISNULL(SuitAppNo,0)  FROM 
		(
			SELECT SuitAmount,SuitAppNo FROM LEGAL.PlaintAdmissionDetails WHERE 
																				(EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
																				AND CaseEntityId = @CaseEntityId 
																				AND ISNULL(AuthorisationStatus,'A')='A' 
																				
			UNION
			SELECT SuitAmount,SuitAppNo FROM legal.PlaintAdmissionDetails_Mod A
		       INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PlaintAdmissionDetails_Mod
		                    WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND CaseEntityId = @CaseEntityId  
									AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  ON  (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
																			 AND B.EntityKey=A.EntityKey 
		                 WHERE A.CaseEntityId=@CaseEntityId
			GROUP BY SuitAmount,SuitAppNo
		) A

		/*SuitAppNo,SuitAmount*/








		IF @ShutterMenuId IN (900,910,920)

		/*@SuitDt*/

		SELECT 
		--@SuitDt=CONVERT(VARCHAR(10),SuitDt,103)
					--@WrittenStmFillingDt=CONVERT(VARCHAR(10),WrittenStmFillingDt,103)
					@FramingOfIsuuesDt=CONVERT(VARCHAR(10),FramingOfIsuuesDt,103)
			FROM legal.CivilCaseDtls
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


			SELECT @SuitDt=CONVERT(VARCHAR(10),SuitDate,103) from legal.AdmissionDtls 
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				and CaseEntityId=@CaseEntityId


		/*@SuitDt*/		
	END	
	
ELSE IF @ShutterMenuId=930
	BEGIN
				/*PreArbitrationID*/
				SELECT @ArbitrationEntityId=ArbitrationEntityId FROM legal.ArbitrationDtls
						WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CaseEntityId=@CaseEntityId
				/*PreArbitrationID*/
				
				/*@SuitDt*/

					SELECT 
					--@SuitDt=CONVERT(VARCHAR(10),SuitDt,103)
					--		,@WrittenStmFillingDt=CONVERT(VARCHAR(10),WrittenStmFillingDt,103)
							@FramingOfIsuuesDt=CONVERT(VARCHAR(10),FramingOfIsuuesDt,103)
					FROM legal.CivilCaseDtls
					WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId

				/*@SuitDt*/					
	END	
	
ELSE IF @ShutterMenuId IN (1000,1110,1500,1510,3050,3090,3100)
	BEGIN
			/*AppealNo,OrderDate*/
			--SELECT @AppealOrderDt= CONVERT(VARCHAR(10),OrderDate,103)
			--	FROM(
		
		 --       SELECT A.OrderDate  FROM LEGAL.AppealDetail  a
			--	 WHERE(a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey) AND
	  --           A.CaseEntityId=@CaseEntityId	
		        
		 --       UNION
		        
		 --       SELECT 	A.OrderDate FROM LEGAL.AppealDetail_Mod A
		 --       INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM LEGAL.AppealDetail_Mod
			--					WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
		 --       				AND CaseEntityId=@CaseEntityId AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --       				GROUP BY CaseEntityId,AuthorisationStatus
		 --       			)B	ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
			--						AND A.EntityKey=B.EntityKey  
		        			
		 --       LEFT JOIN (SELECT * FROM DimParameter WHERE DimParameterName like '%DimApplicant%') C  ON (C.EffectiveFROMTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey) 
			--																								AND A.FiledByAlt_Key=C.ParameterAlt_Key
			--																								WHERE A.CaseEntityId=@CaseEntityId
		                                            																							
			--	 )Q

			/*AppealNo*/

			/*CaseReferenceNumber*/

			SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 

			IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
					BEGIN
							SELECT  @CaseReferenceNumber=CASENO
							FROM 
							(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
										 WHEN CASETYPE=130 THEN NI.ComplaintNo 
										 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
										 WHEN CaseType=240 THEN OD.ComplaintNo
										 WHEN CaseType in(220,225)			then ccd.SuitNo
										 WHEN CaseType=215 THEN	Cc.ComplSuitNo
										 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
										 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
										 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
							LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
							LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
										WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
												CaseEntityId=@caseEntityID order by datecreated DESC
									  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
											AND NI.CaseEntityId=S.PARENTENTITYID   
							LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																		 AND PD.CASEENTITYID=s.PARENTENTITYID	  
							LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) AND OD.CaseEntityId=S.ParentEntityID  				
							LEFT JOIn LEGAL.CivilCaseDtls CCD ON (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)AND ccd.caseEntityid=S.ParentEntityID	 
							Left Join Legal.ConsumerComplaintDtls CC ON (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey) AND CC.caseEntityid=S.ParentEntityID	 
							LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) AND CCDT.caseEntityid=S.ParentEntityID	 
							LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
							 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
							 AND @CaseEntityId=S.ParentEntityID )G

									
				  END					

				/*CaseReferenceNumber*/	
				
				/*TitleOfCase*/
			  
					--SELECT @TitleOfCase=TitleOfCase
					--FROM
					--( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
					--  AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
					--)G
			  
			  /*TitleOfCase*/
			  
			  /*DecreeDate*/	
			  
			  --SELECT @DecreeDate =CONVERT(VARCHAR(10),DecreeDate,103) 
				 --FROM (
					--		SELECT DecreeDate FROM legal.JudgementDtls 
					--		WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey	AND ISNULL(AuthorisationStatus,'A')='A'
					--		AND CaseEntityId = @CaseEntityId 
					--		UNION
					--		SELECT A.DecreeDate FROM legal.JudgementDtls_Mod A
					--		INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.JudgementDtls_Mod
					--							WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		   --    									AND CaseEntityId = @CaseEntityId 
		   --    									GROUP BY 	CaseEntityId,AuthorisationStatus
					--					)B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					--							WHERE A.CaseEntityId=@CaseEntityId
					-- )G 		
			
			 /*DecreeDate*/
				
			/* CustomerSinceDt */

			--SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
			--FROM [CURDAT].[CustomerBasicDetail] 
			--WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

			/* CustomerSinceDt */

			 /*PermissionSoughtdate*/
			  
			 -- SELECT @PermissionSoughtdate=CONVERT(varchar(10),A.PermissionSoughtdate,103) FROM
			 -- (		
			  
			 -- SELECT PermissionSoughtdate 
			 -- FROM LEGAL.PermissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
				--									AND CaseEntityId = @CaseEntityId 
				--									AND ISNULL(AuthorisationStatus,'A')='A' 
												
			 --UNION
			 
			 --SELECT PermissionSoughtdate FROM legal.PermissionDetails_Mod A
		  --     INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
		  --                  WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
		  --     			       AND CaseEntityId = @CaseEntityId 
				--			   AND AuthorisationStatus IN ('NP','MP','DP','RM')
		  --     			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  
				--		 ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
		  --               WHERE A.CaseEntityId=@CaseEntityId															
			 -- )A

			  /*PermissionSoughtdate*/
		

			END
--ELSE IF @ShutterMenuId IN (1130)

--	BEGIN
			
--			/*SecurityEntityId*/
--			SELECT	
--				@SecurityEntityId=SecurityEntityId,
--				@BorrNDate=Convert(varchar(10),BorrNDate,103),
--				@DtService=Convert(varchar(10),DtService,103),
--				@PossessiontakingDt=Convert(varchar(10),PossessiontakingDt,103)
--				--@ValSeizedAssetdt=convert(varchar(10),ValSeizedAssetdt,103)
--				FROM (SELECT SecurityEntityId,
--					BorrNDate,
--					DtService,
--					PossessiontakingDt,
--					ValSeizedAssetdt
--			  FROM legal.SecurityDisposalDtls
--			  WHERE datecreated=(
--						SELECT max(datecreated) 
--						FROM legal.SecurityDisposalDtls
--						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
--						AND caseentityid=@caseentityid
--				) 
--		)A									
			
--		/*SecurityEntityId*/

	--END

ELSE IF @ShutterMenuId IN (2001,2002,2003,2004,2007,3020,3830,4000,4010,12330,12340,12350,12360,12370,12390,12410,12400,12410,12420,12430,12440)

	BEGIN

			/*CaseReferenceNumber*/
			
						SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 
			
						IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
								BEGIN
										SELECT  @CaseReferenceNumber=CASENO
										FROM 
										(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
													 WHEN CASETYPE=130 THEN NI.ComplaintNo 
													 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
													 WHEN CaseType=240 THEN OD.ComplaintNo
													 WHEN CaseType in(220,225)			then ccd.SuitNo
													 WHEN CaseType=215 THEN	Cc.ComplSuitNo
													 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
													 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
													 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
										LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
										LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
															CaseEntityId=@caseEntityID order by datecreated DESC
												  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
														AND NI.CaseEntityId=S.PARENTENTITYID   
										LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																					 AND PD.CASEENTITYID=s.PARENTENTITYID	  
										LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) AND OD.CaseEntityId=S.ParentEntityID  				
										LEFT JOIn LEGAL.CivilCaseDtls CCD ON (ccd.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)AND ccd.caseEntityid=S.ParentEntityID	 
										Left Join Legal.ConsumerComplaintDtls CC ON (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey) AND CC.caseEntityid=S.ParentEntityID	 
										LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) AND CCDT.caseEntityid=S.ParentEntityID	 
										LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
										 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
										 AND @CaseEntityId=S.ParentEntityID )G
			
												
							  END					
			
				/*CaseReferenceNumber*/	

				--ELSE IF @ShutterMenuId=2007
				--	BEGIN
				--			/*@ComplaintDtFiled*/
				--					SELECT @ConsumerJudgmentDt=convert(VARCHAR(10),JudgmentDt,103),@ComplaintDtFiled=Convert(VARCHAR(10),ComplaintDtFiled,103) 
				--					FROM legal.ConsumerComplaintDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
				--											AND CaseEntityId = @CaseEntityId 
				--			/*@ComplaintDtFiled*/

				--	END

				--ELSE IF @ShutterMenuId=3830
				--	BEGIN
				--		/*SummonsSerDt*/
				--		SELECT @SummonsSerDt=convert(varchar(10),SummonsSerDt,103),@NiactJudgementDt=convert(varchar(10),JudgementDt,103)
				--		FROM legal.NIACTDtls NI 
				--		WHERE ( EffectiveFROMTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)AND CaseEntityId=@CaseEntityId  
				--		/*SummonsSerDt*/
				--	END	
					
			  --ELSE IF @ShutterMenuId IN (12330,12350,12360,12370,12390,12410,12400,12410,12420,12430,12440)
					--BEGIN
					--		/*TitleOfCase*/
			  
					--		SELECT @TitleOfCase=TitleOfCase
					--		FROM
					--		( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
					--		  AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
					--		)G
			  
					--	  /*TitleOfCase*/	
					--END			
							


		END	
		
		
ELSE IF @ShutterMenuId IN (2005,2006)
	BEGIN
			/*WritPetitionDt,WritPetitionNo*/
			SELECT 
					@WritPetitionDt=CONVERT(varchar(10),WritPetitionDt,103),@WritPetitionNo=WritPetitionNo
			FROM legal.WritPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											AND CaseEntityId=@CaseEntityId
			/*WritPetitionDt,WritPetitionNo*/
			
	
	END
	
ELSE IF @ShutterMenuId=2018
	BEGIN

			  /*CaseReferenceNumber*/
				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 
			
						IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
								BEGIN
										SELECT  @CaseReferenceNumber=CASENO
										FROM 
										(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
													 WHEN CASETYPE=130 THEN NI.ComplaintNo 
													 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
													 WHEN CaseType=240 THEN OD.ComplaintNo
													 WHEN CaseType in(220,225)			then ccd.SuitNo
													 WHEN CaseType=215 THEN	Cc.ComplSuitNo
													 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
													 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
													 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
										LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
										LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
															CaseEntityId=@caseEntityID order by datecreated DESC
												  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
														AND NI.CaseEntityId=S.PARENTENTITYID   
										LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																					 AND PD.CASEENTITYID=s.PARENTENTITYID	  
										LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
																				AND OD.CaseEntityId=S.ParentEntityID 
																			 				
										LEFT JOIn LEGAL.CivilCaseDtls CCD ON (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)
																			AND ccd.caseEntityid=S.ParentEntityID	 

										Left Join Legal.ConsumerComplaintDtls CC ON (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) 
																					AND CC.caseEntityid=S.ParentEntityID
																						 
										LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) 
																				AND CCDT.caseEntityid=S.ParentEntityID	
																				 
										LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
										 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
										 AND @CaseEntityId=S.ParentEntityID )G

								END
			/*CaseReferenceNumber*/
					
			/* CustomerSinceDt */

			--SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
			--FROM [CURDAT].[CustomerBasicDetail] 
			--WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

			/* CustomerSinceDt */

			/*acceptanceDate*/
			
				SELECT  @acceptanceDate=convert(varchar(10),CompliaintDate,103)
					FROM 
					(SELECT case  when CaseType=135 then SEC.ComplaintSuitFiledDt 
								 WHEN CASETYPE=130 THEN NI.ComplaintDt 
								 WHEN CASETYPE IN(100,105,120) THEN PD.AcceptanceDate 
								 WHEN CaseType=240 THEN OD.ComplaintDt
								 when CaseType in(220,225)  THEN ccd.SuitDt
								  WHEN CaseType=215 THEN	Cc.ComplaintDt
								  WHEN CaseType=230 THEN  CCDT.ComplaintFiledDt
							 END [CompliaintDate] from SysDataUpdationStatus s 
					LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  
												    (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
					LEFT JOIN (SELECT TOP 1 ComplaintDt,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  
									FROM  legal.NIACTDtls 
									WHERE  (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											AND CaseEntityId=@CaseEntityId ORDER BY datecreated DESC)NI 
											ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) AND 
												NI.CaseEntityId=S.PARENTENTITYID   
												
					LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)AND	
																  PD.CASEENTITYID=s.PARENTENTITYID
																
					LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
														AND OD.CaseEntityId=S.ParentEntityID 	
					LEFT JOIn LEGAL.CivilCaseDtls ccd on CCD.caseEntityid=S.ParentEntityID	AND (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)	
					Left Join Legal.ConsumerComplaintDtls CC on CC.caseEntityid=S.ParentEntityID	AND (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey)
					LEFT JOIN legal.CriminalCaseDtls CCDT ON CCDT.caseEntityid=S.ParentEntityID	AND (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey)		
					LEFT JOIN LEGAL.ArbitrationDtls AD ON AD.caseEntityid=S.ParentEntityID	AND (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
				   WHERE  @CaseEntityId=S.ParentEntityID  )G

			/*acceptanceDate*/		
									
	END					

ELSE IF @ShutterMenuId=2019
	BEGIN
			 /*CaseReferenceNumber*/
				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 
			
						IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
								BEGIN
										SELECT  @CaseReferenceNumber=CASENO
										FROM 
										(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
													 WHEN CASETYPE=130 THEN NI.ComplaintNo 
													 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
													 WHEN CaseType=240 THEN OD.ComplaintNo
													 WHEN CaseType in(220,225)			then ccd.SuitNo
													 WHEN CaseType=215 THEN	Cc.ComplSuitNo
													 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
													 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
													 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
										LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
										LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
															CaseEntityId=@caseEntityID order by datecreated DESC
												  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
														AND NI.CaseEntityId=S.PARENTENTITYID   
										LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																					 AND PD.CASEENTITYID=s.PARENTENTITYID	  
										LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
																				AND OD.CaseEntityId=S.ParentEntityID 
																			 				
										LEFT JOIn LEGAL.CivilCaseDtls CCD ON (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)
																			AND ccd.caseEntityid=S.ParentEntityID	 

										Left Join Legal.ConsumerComplaintDtls CC ON (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) 
																					AND CC.caseEntityid=S.ParentEntityID
																						 
										LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) 
																				AND CCDT.caseEntityid=S.ParentEntityID	
																				 
										LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
										 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
										 AND @CaseEntityId=S.ParentEntityID )G

								END
			/*CaseReferenceNumber*/

			/*acceptanceDate*/
			
				SELECT  @acceptanceDate=convert(varchar(10),CompliaintDate,103)
					FROM 
					(SELECT case  when CaseType=135 then SEC.ComplaintSuitFiledDt 
								 WHEN CASETYPE=130 THEN NI.ComplaintDt 
								 WHEN CASETYPE IN(100,105,120) THEN PD.AcceptanceDate 
								 WHEN CaseType=240 THEN OD.ComplaintDt
								 when CaseType in(220,225)  THEN ccd.SuitDt
								  WHEN CaseType=215 THEN	Cc.ComplaintDt
								  WHEN CaseType=230 THEN  CCDT.ComplaintFiledDt
							 END [CompliaintDate] from SysDataUpdationStatus s 
					LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  
												    (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
					LEFT JOIN (SELECT TOP 1 ComplaintDt,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  
									FROM  legal.NIACTDtls 
									WHERE  (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											AND CaseEntityId=@CaseEntityId ORDER BY datecreated DESC)NI 
											ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) AND 
												NI.CaseEntityId=S.PARENTENTITYID   
												
					LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)AND	
																  PD.CASEENTITYID=s.PARENTENTITYID
																
					LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
														AND OD.CaseEntityId=S.ParentEntityID 	
					LEFT JOIn LEGAL.CivilCaseDtls ccd ON CCD.caseEntityid=S.ParentEntityID	AND (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)	
					Left Join Legal.ConsumerComplaintDtls CC ON CC.caseEntityid=S.ParentEntityID	AND (cc.EffectiveFROMTimeKey<=@TimeKey AND cc.EffectiveToTimeKey>=@TimeKey)
					LEFT JOIN legal.CriminalCaseDtls CCDT ON CCDT.caseEntityid=S.ParentEntityID	AND (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey)		
					LEFT JOIN LEGAL.ArbitrationDtls AD ON AD.caseEntityid=S.ParentEntityID	AND (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
				   WHERE  @CaseEntityId=S.ParentEntityID  )G

			/*acceptanceDate*/

			/*CaseType*/

			SELECT @CaseType=TypeName FROM legal.Permissiondetails pd 
			LEFT JOIN Dimtype D ON (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) AND
										D.TypeAlt_Key=pd.PermissionNatureAlt_Key 
			WHERE (PD.EffectiveFROMTimeKey<=@TimeKey AND pd.EffectiveToTimeKey>=@TimeKey) AND
										PD.CaseEntityId=@CaseEntityId 

			/*CaseType*/								
									
	

	END

ELSE IF @ShutterMenuId IN(2020,3010)
	BEGIN
				 /*CaseReferenceNumber*/
				SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 
			
						IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
								BEGIN
										SELECT  @CaseReferenceNumber=CASENO
										FROM 
										(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
													 WHEN CASETYPE=130 THEN NI.ComplaintNo 
													 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
													 WHEN CaseType=240 THEN OD.ComplaintNo
													 WHEN CaseType in(220,225)			then ccd.SuitNo
													 WHEN CaseType=215 THEN	Cc.ComplSuitNo
													 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
													 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
													 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
										LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
										LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
															CaseEntityId=@caseEntityID order by datecreated DESC
												  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
														AND NI.CaseEntityId=S.PARENTENTITYID   
										LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																					 AND PD.CASEENTITYID=s.PARENTENTITYID	  
										LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
																				AND OD.CaseEntityId=S.ParentEntityID 
																			 				
										LEFT JOIn LEGAL.CivilCaseDtls CCD ON (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)
																			AND ccd.caseEntityid=S.ParentEntityID	 

										Left Join Legal.ConsumerComplaintDtls CC ON (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) 
																					AND CC.caseEntityid=S.ParentEntityID
																						 
										LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) 
																				AND CCDT.caseEntityid=S.ParentEntityID	
																				 
										LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
										 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
										 AND @CaseEntityId=S.ParentEntityID )G

								END
			/*CaseReferenceNumber*/	

			/*acceptanceDate*/
			
				SELECT  @acceptanceDate=convert(varchar(10),CompliaintDate,103)
					FROM 
					(SELECT CASE  WHEN CaseType=135 THEN SEC.ComplaintSuitFiledDt 
								 WHEN CASETYPE=130 THEN NI.ComplaintDt 
								 WHEN CASETYPE IN(100,105,120) THEN PD.AcceptanceDate 
								 WHEN CaseType=240 THEN OD.ComplaintDt
								 WHEN CaseType IN(220,225)  THEN ccd.SuitDt
								 WHEN CaseType=215 THEN	Cc.ComplaintDt
								 WHEN CaseType=230 THEN  CCDT.ComplaintFiledDt
							 END [CompliaintDate] from SysDataUpdationStatus s 
					LEFT JOIN legal.Sec25Dtls SEC ON (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey) AND SEC.CaseEntityId=S.PARENTENTITYID   
												    
					LEFT JOIN (SELECT TOP 1 ComplaintDt,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  
									FROM  legal.NIACTDtls 
									WHERE  (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											AND CaseEntityId=@CaseEntityId ORDER BY datecreated DESC)NI 
											ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) AND 
												NI.CaseEntityId=S.PARENTENTITYID   
												
					LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey)AND	
																  PD.CASEENTITYID=s.PARENTENTITYID
																
					LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
														AND OD.CaseEntityId=S.ParentEntityID 	
					LEFT JOIn LEGAL.CivilCaseDtls CCD ON (CCD.EffectiveFROMTimeKey<=@TimeKey AND CCD.EffectiveToTimeKey>=@TimeKey) AND CCD.caseEntityid=S.ParentEntityID	 	
					Left Join Legal.ConsumerComplaintDtls CC ON (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) AND CC.caseEntityid=S.ParentEntityID  
					LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) AND CCDT.caseEntityid=S.ParentEntityID	 		
					LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
				   WHERE  @CaseEntityId=S.ParentEntityID  )G

			/*acceptanceDate*/	

			IF @ShutterMenuId=3010
				BEGIN
						/*RemainingOs*/
						SELECT @RemainingOs=(isnull(RemainingOs,0))
						FROM legal.ExecDecreeDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND  CaseEntityId =@CaseEntityId
						/*RemainingOs*/			

				END

	END

ELSE IF @ShutterMenuId IN (3030,3040,3070,3080,3090,3100,3110,3120,3130,3160,3170,3050)
	BEGIN
			--IF @ShutterMenuId IN (3030,3040,3070,3080,3090,3100,3110,3130,3160,3170,3050)
			--	BEGIN
			--			/*WithdrawalStage*/
			--			SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
			--			LEFT JOIN Dimstages S ON   (S.EffectiveFromTimeKey<=@TimeKey AND S.EffectiveToTimeKey>=@TimeKey) AND 
			--									S.StagesAlt_Key=D.CurrentStageAlt_key 
			--			WHERE	(S.EffectiveFromTimeKey<=@TimeKey AND S.EffectiveToTimeKey>=@TimeKey) AND 
			--					ID=@CaseEntityId
			--			/*WithdrawalStage*/
			--	END

				IF @ShutterMenuId=3120
					BEGIN
							SELECT @WithdrawalStage=StagesName FROM legal.CivilCaseDtls CC
							LEFT JOIN DimStages D ON (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey ) AND D.StagesAlt_Key=CC.PostJudStatusAlt_Key
							WHERE (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId 

					END			
				
				IF @ShutterMenuId IN (3030,3040,3070,3110,3120,3160,3170,3170,3050,3090,3080)
				   BEGIN
					

							/*FiledByAlt_Key*/
						
							SELECT @CaseTypeCode=PermissionNatureAlt_Key 
							FROM legal.PermissionDetails 
							WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
								
							IF @CaseTypeCode IN(235,515)
								BEGIN
										SELECT @FiledByAlt_Key=ParameterName FROM legal.AppealDetail a
										LEFT JOIN (SELECT ParameterName,ParameterAlt_Key FROM DimParameter WHERE 
													(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
													 dimparametername='DimFiledbyAgnBank')d
										ON D.parameteralt_key=A.FiledByAlt_Key
										INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
										where ( A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  
	
										Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where 
												(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
												dimparametername='DimFiledbyAgnBank')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END
	
							ELSE IF @CaseTypeCode =220
								BEGIN
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
														(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
														dimparametername='DimFiledbyAgnBank')d
											ON d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(220)
											 WHERE ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where 
														(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
														dimparametername='DimFiledbyAgnBank')d
												 on d.parameteralt_key=a.FiledByAlt_Key
											INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(220)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  
								END

							ELSE IF @CaseTypeCode =130
								BEGIN
										Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
										 dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType=130
										 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										 LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter 
										 where 
										 (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND
										 dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(130)
									 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END

							ELSE IF @CaseTypeCode  IN (105,205,100)
								BEGIN
										 Select @FiledByAlt_Key=ParameterName FROM legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key FROM DimParameter WHERE 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
										 dimparametername='DimLegalAppealBy')d
										 ON d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (105,205,100)
										 WHERE ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										
										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										  dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(105,205)
										 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode  IN (215)
								BEGIN
											Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='Dimfiledbank')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (215)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

						
											Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='Dimfiledbank')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(215)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END

							ELSE IF @CaseTypeCode IN (135)
								BEGIN
											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimLegalAppealBy')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(135)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimLegalAppealBy')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(135)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode =225
								BEGIN
											Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimFiledByAppeal')d  --  DimLegalAppealByCivil
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(225)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimFiledByAppeal')d --  DimLegalAppealByCivil
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(225)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode=230
								BEGIN
										 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
										left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										dimparametername='DimLegalAppealBy')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(230)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										
										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										dimparametername='DimLegalAppealBy')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(230)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode =150
								BEGIN
											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											 dimparametername='DimApplicant')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(150)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimApplicant')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(150)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

					/*FiledByAlt_Key*/

				END		

				IF @ShutterMenuId=3040
						BEGIN
									/*PreArbitrationId*/
									SELECT @ArbitrationEntityId=ArbitrationEntityId FROM legal.ArbitrationDtls
									WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND CaseEntityId=@CaseEntityId
									/*PreArbitrationId*/
									
									
							/*PermissionSoughtdate*/
			  
								-- SELECT @PermissionSoughtdate=CONVERT(varchar(10),A.PermissionSoughtdate,103) FROM
								-- (		
								 
								-- SELECT PermissionSoughtdate 
								-- FROM LEGAL.PermissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
								--										AND CaseEntityId = @CaseEntityId 
								--										AND ISNULL(AuthorisationStatus,'A')='A' 
																	
								--UNION
								
								--SELECT PermissionSoughtdate FROM legal.PermissionDetails_Mod A
								--  INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
								--               WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
								--  			       AND CaseEntityId = @CaseEntityId 
								--				   AND AuthorisationStatus IN ('NP','MP','DP','RM')
								--  			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  
								--			 ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
								--            WHERE A.CaseEntityId=@CaseEntityId															
								-- )A

						  /*PermissionSoughtdate*/		
						  END

				--IF @ShutterMenuId IN(3050,3090,3100)
				--		BEGIN
									
				--				/*AppealNo,OrderDate*/
				--						SELECT @AppealNo=AppealNo
				--							FROM(
		
				--						    SELECT A.AppealNo,A.OrderDate FROM LEGAL.AppealDetail  a
				--							 WHERE(a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey) AND
				--						     A.CaseEntityId=@CaseEntityId	
										    
				--						    UNION
										    
				--						    SELECT 	A.AppealNo,A.OrderDate  FROM LEGAL.AppealDetail_Mod A
				--						    INNER JOIN (	SELECT MAX(EntityKey)EntityKey FROM LEGAL.AppealDetail_Mod
				--											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
				--						    				AND CaseEntityId=@CaseEntityId AND AuthorisationStatus IN ('NP','MP','DP','RM')
				--						    				GROUP BY CaseEntityId,AuthorisationStatus
				--						    			)B	ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
				--												AND A.EntityKey=B.EntityKey  
										    			
				--						    LEFT JOIN (SELECT * FROM DimParameter WHERE DimParameterName like '%DimApplicant%') C  ON (C.EffectiveFROMTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey) 
				--																														AND A.FiledByAlt_Key=C.ParameterAlt_Key
				--																														WHERE A.CaseEntityId=@CaseEntityId
										                                        																							
				--							 )Q

				--				/*AppealNo*/
				--		END	
						
				IF @ShutterMenuId IN (3120,3350,14000)
					 BEGIN
							
							IF @ShutterMenuId IN (3350,14000)
								BEGIN
										IF @ShutterMenuId=3350
											BEGIN
													/*EmployeeName*/
													SELECT @EmployeeName=EmployeeName FROM legal.CriminalCaseEmpInvolvedtls 
																					  WHERE  (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND
																							 CaseEntityid=@CaseEntityID 
													/*EmployeeName*/
											 END			


										/*NPADt*/
										
										--SELECT @NPADt=CONVERT(VARCHAR(10),NPADt,103) FROM
										--(
										--	SELECT D.NPADt FROM AdvCustNPADetail  D
										--	WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) AND D.CustomerEntityId=@CustomerEntityId AND ISNULL(D.AuthorisationStatus,'A')='A'
										--	UNION
										--	SELECT A.NPADt FROM AdvCustNPAdetail_Mod A
										--	INNER JOIN(		SELECT MAX(D.EntityKey)EntityKey FROM AdvCustNPAdetail_Mod D
										--					WHERE (D.EffectiveFROMTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey) AND D.CustomerEntityId=@CustomerEntityId AND D.AuthorisationStatus IN('NP','MP','DP','RM')
										--					GROUP BY D.CustomerEntityId,D.AuthorisationStatus
										--			   )B ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND A.EntityKey=B.EntityKey
											
										--WHERE A.CustomerEntityId=@CustomerEntityId			
										--)U	
										
										/*NPADt*/
										
								END														
					 END	
					 







				IF @ShutterMenuId=3170
					BEGIN
							 /*CaseReferenceNumber*/
						SELECT @CaseReferenceNumber=CASENO FROM SysDataUpdationStatus WHERE ID=@CaseEntityId 
			
						IF @CaseReferenceNumber IS NULL OR @CaseReferenceNumber=''
								BEGIN
										SELECT  @CaseReferenceNumber=CASENO
										FROM 
										(SELECT CASE WHEN CaseType=135 then SEC.ComplaintSuitNo 
													 WHEN CASETYPE=130 THEN NI.ComplaintNo 
													 WHEN CASETYPE IN(100,105,120) THEN PD.SuitAppNo 
													 WHEN CaseType=240 THEN OD.ComplaintNo
													 WHEN CaseType in(220,225)			then ccd.SuitNo
													 WHEN CaseType=215 THEN	Cc.ComplSuitNo
													 WHEN CASETYPE=230 THEN CCDT.Complaint_SuitNo
													 WHEN CASETYPE=150 THEN  AD.ArbProceedingNo
													 ELSE S.CASENO END [CASENO] from SysDataUpdationStatus s 
										LEFT JOIN legal.Sec25Dtls SEC ON SEC.CaseEntityId=S.PARENTENTITYID AND  (SEC.EffectiveFROMTimeKey<=@TimeKey AND SEC.EffectiveToTimeKey>=@TimeKey)
										LEFT JOIN (SELECT TOP 1 ComplaintNo,CaseEntityId,EffectiveFROMTimeKey,EffectiveToTimeKey  FROM  legal.NIACTDtls 
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
															CaseEntityId=@caseEntityID order by datecreated DESC
												  )NI ON (NI.EffectiveFROMTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey) 
														AND NI.CaseEntityId=S.PARENTENTITYID   
										LEFT JOIN legal.PlaintAdmissionDetails PD ON (PD.EffectiveFROMTimeKey<=@TimeKey AND PD.EffectiveToTimeKey>=@TimeKey) 
																					 AND PD.CASEENTITYID=s.PARENTENTITYID	  
										LEFT JOIN LEGAL.OmbudsmanDtls OD ON (OD.EffectiveFROMTimeKey<=@TimeKey AND OD.EffectiveToTimeKey>=@TimeKey) 
																				AND OD.CaseEntityId=S.ParentEntityID 
																			 				
										LEFT JOIn LEGAL.CivilCaseDtls CCD ON (CCD.EffectiveFROMTimeKey<=@TimeKey AND ccd.EffectiveToTimeKey>=@TimeKey)
																			AND ccd.caseEntityid=S.ParentEntityID	 

										Left Join Legal.ConsumerComplaintDtls CC ON (CC.EffectiveFROMTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey) 
																					AND CC.caseEntityid=S.ParentEntityID
																						 
										LEFT JOIN legal.CriminalCaseDtls CCDT ON (CCDT.EffectiveFROMTimeKey<=@TimeKey AND CCDT.EffectiveToTimeKey>=@TimeKey) 
																				AND CCDT.caseEntityid=S.ParentEntityID	
																				 
										LEFT JOIN LEGAL.ArbitrationDtls AD ON (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey) AND AD.caseEntityid=S.ParentEntityID	 
										 WHERE  (AD.EffectiveFROMTimeKey<=@TimeKey AND AD.EffectiveToTimeKey>=@TimeKey)
										 AND @CaseEntityId=S.ParentEntityID )G
					
					END						

	END

				--IF @ShutterMenuId=3140
				--	BEGIN
				--			/*FiledByRevPet*/
				--				SELECT @FiledBy=ParameterName,@FinalOrderDate=CONVERT(VARCHAR(10),FinalOrderDate,103)  FROM legal.RevPetiDtls R
				--				LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where dimparametername LIKE'%DimFiledbyAgnBank%') d 
				--							on (R.EffectiveFromTimeKey<=@TimeKey  AND R.EffectiveToTimeKey>=@TimeKey) AND
				--								r.RevPFiledByB=d.ParameterAlt_Key
				--			/*FiledByRevPet*/		
				--	END 
	END

ELSE IF @ShutterMenuId=3150
	BEGIN
			/*WPSCFiledBy*/
			SELECT   @WPSCFiledBy=FiledBy
			FROM (SELECT  CASE WHEN PermissionNatureAlt_Key=205 THEN 'Award Staff' 
													WHEN PermissionNatureAlt_Key=210 THEN 'Officer' END [FiledBy]
													FROM legal.permissiondetails 
													WHERE CaseEntityID=@CaseEntityId  AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
													)g
			/*WPSCFiledBy*/	
			
			/*WithdrawalStage*/
						--SELECT @CurrentStageName=StagesName FROM SysDataUpdationStatus D
						--LEFT JOIN Dimstages S ON   (S.EffectiveFromTimeKey<=@TimeKey AND S.EffectiveToTimeKey>=@TimeKey) AND 
						--						S.StagesAlt_Key=D.CurrentStageAlt_key 
						--WHERE	(S.EffectiveFromTimeKey<=@TimeKey AND S.EffectiveToTimeKey>=@TimeKey) AND 
						--		ID=@CaseEntityId
			/*WithdrawalStage*/	

			/*WritPetitionDt,WritPetitionNo*/

			--SELECT @WritpetitionJudgmentdate=CONVERT(VARCHAR(10),judgementDt,103),@WritPetitionRejectedDt=CONVERT(VARCHAR(10),WritPetitionRejectedDt,103),
			--		@WritPetitionDt=CONVERT(VARCHAR(10),WritPetitionDt,103),@WritPetitionNo=WritPetitionNo,@JudgementDt=CONVERT(VARCHAR(10),JudgementDt,103)
			--FROM legal.WritPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--		AND CaseEntityId=@CaseEntityId

			/*WritPetitionDt,WritPetitionNo*/

		/*EmplyoeeId*/		
		
		SELECT @EmployeeID=E.EmployeeID,@BankingArrangement=e.BankingArrangement,
		@RecallNoticeDate=CONVERT(VARCHAR(10),RecallNoticeDate,103) ,@Consortium_Name=E.Consortium_Name,@Designation=Designation
		
    	FROM(
 
				SELECT A.EmployeeID,--B.EmployeeName,
				A.BankingArrangement,RecallNoticeDate,DC.Consortium_Name,Designation
 
				FROM CURDAT.AdvCustOtherDetail A  LEFT JOIN legal.CriminalCaseDtls B   ON  
    				                                                                             (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
 				                                                                                 AND A.CustomerEntityId=B.CustomerEntityId 
    																							 AND ISNULL(B.AuthorisationStatus,'A')='A' AND B.CaseEntityId=@CaseEntityId
												  LEFT JOIN DimBankingArrangement		DC	ON		(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
												  												AND DC.ConsortiumAlt_Key=BankingArrangement											
				WHERE (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND
						A.CustomerEntityId=@CustomerEntityId AND 
					    ISNULL(A.AuthorisationStatus,'A')='A'
 
 		UNION
 
 				SELECT C.EmployeeID,--D.EmployeeName ,
				C.BankingArrangement,RecallNoticeDate,Consortium_Name,Designation FROM 
 				(
 					SELECT EmployeeID,BankingArrangement,CustomerEntityId,b.RecallNoticeDate,DC.Consortium_Name,Designation
 					FROM  AdvCustOtherDetail_Mod B INNER JOIN (
 					SELECT MAX(B.EntityKey)EntityKey,RecallNoticeDate FROM AdvCustOtherDetail_Mod B
 					WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
 					 AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
 					GROUP BY B.CustomerEntityId,B.AuthorisationStatus,RecallNoticeDate
 				)A  ON B.EntityKey=A.EntityKey AND (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
				LEFT JOIN DimBankingArrangement		DC	ON		(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
																AND DC.ConsortiumAlt_Key=B.BankingArrangement						
 				 WHERE  B.CustomerEntityId=@CustomerEntityId
 		)C  
 
	    )E

	  /*EmplyoeeId*/
													
	END

ELSE IF @ShutterMenuId=3350
        BEGIN
                        
                        
--                        SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
--                        FROM [CURDAT].[CustomerBasicDetail] 
--                        WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND 
--                                        CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId 
                         SELECT @ConstitutionName=DC.ConstitutionName,@DefendantRelationship=CASE WHEN CBD.CustType='OTHERS' THEN M.LegalMiscSuitName ELSE CBD.CustType END ,@ServProvider=N.LegalNatureOfActivityName  FROM DimConstitution DC
                                        INNER JOIN CURDAT.CustomerBasicDetail CBD
                                                ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
                                                AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
                                                AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
                                        LEFT JOIN LEGAL.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) AND N.LegalNatureOfActivityAlt_Key=CBD.ServProviderAlt_Key
                                        LEFT JOIN LEGAL.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=CBD.NonCustTypeAlt_Key
                                                WHERE CBD.CustomerEntityId=@CustomerEntityId

                        
                                                                                
        END

ELSE IF @ShutterMenuId=3360
	BEGIN
			SELECT @PermissionLetterDate=CONVERT(varchar(10),A.PermissionLetterDate,103) FROM
			  (		
			  
			  SELECT PermissionLetterDate 
			  FROM LEGAL.PermissionDetails WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
													AND CaseEntityId = @CaseEntityId 
													AND ISNULL(AuthorisationStatus,'A')='A' 
												
			 UNION
			 
			 SELECT PermissionLetterDate FROM legal.PermissionDetails_Mod A
		       INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.PermissionDetails_Mod
		                    WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
		       			       AND CaseEntityId = @CaseEntityId 
							   AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       			 GROUP BY 	CaseEntityId,AuthorisationStatus)B  
						 ON (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND B.EntityKey=A.EntityKey 
		                 WHERE A.CaseEntityId=@CaseEntityId															
			  )A

			  SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
			SELECT @Employeeid=EmployeeID FROM CURDAT.AdvCustOtherDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND CustomerEntityId=@CustomerEntityId
	END

ELSE IF @ShutterMenuId IN (3370,3580)
	BEGIN
		  SELECT 
			@Placeofposting=ac.Placeofposting		
		   ,@Add1=C.Add1
		   ,@Add2=C.Add2
		   ,@Add3=C.Add3
		   ,@CityShortName =DCITY.CityShortName
		   ,@PinCode=C.PinCode
		   ,@DistrictName=DG.DistrictName
		   ,@StateName=DG.StateName
		   ,@StdCode=C.STD_Code_Res
           ,@PhoneNo=C.PhoneNo_Res
           ,@STD_Code_Off=C.STD_Code_Off
           ,@PhoneNo_Off=C.PhoneNo_Off	   
		   FROM CURDAT.AdvCustCommunicationDetail  C

		    LEFT JOIN DimAddressCategory ADDC   ON  (ADDC.EffectiveFromTimeKey<=@TimeKey AND ADDC.EffectiveToTimeKey>=@TimeKey)AND ADDC.AddressCategoryAlt_Key=C.AddressCategoryAlt_Key	
		    LEFT JOIN 	DimCountry        DC    ON (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey) AND DC.CountryAlt_Key=C.CountryAlt_Key
		    LEFT JOIN DimGeography      DG      ON (DG.EffectiveFromTimeKey<=@TimeKey AND DG.EffectiveToTimeKey>=@TimeKey) AND DG.DistrictAlt_Key=C.DistrictAlt_Key
		    LEFT JOIN DimCity           DCITY   ON  (DCITY.EffectiveFromTimeKey<=@TimeKey AND DCITY.EffectiveToTimeKey>=@TimeKey) AND  DCITY.CityAlt_Key=C.CityAlt_Key
			left join AdvCustOtherDetail ac		ON (AC.EffectiveFromTimeKey<=@TimeKey AND AC.EffectiveToTimeKey>=@TimeKey) AND ac.CustomerEntityId=c.CustomerEntityId

			WHERE (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)	
		      and C.CustomerEntityId=@CustomerEntityId
			  
			  	
			/*BranchName*/	
			SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode		

				

			IF @ShutterMenuId=3580
				BEGIN
						/*Placeofposting*/
						SELECT  @Placeofposting=AC.Placeofposting FROM  AdvCustOtherDetail ac	
						WHERE (ac.EffectiveFromTimeKey<=@TimeKey AND ac.EffectiveToTimeKey>=@TimeKey) 
									AND ac.CustomerEntityId=@CustomerEntityId
						/*Placeofposting*/	

						/*EmployeeID,Designation*/
						SELECT @EmployeeID=E.EmployeeID,@Designation=E.Designation
						 	FROM(
										SELECT A.EmployeeID,A.Designation
										FROM CURDAT.AdvCustOtherDetail A  										
										WHERE (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
												   AND A.CustomerEntityId=@CustomerEntityId
													AND ISNULL(A.AuthorisationStatus,'A')='A'
 										UNION
 
 										SELECT C.EmployeeID,C.Designation FROM 
 										(
 											SELECT EmployeeID,Designation
 											FROM  AdvCustOtherDetail_Mod B INNER JOIN (
 											SELECT MAX(B.EntityKey)EntityKey,RecallNoticeDate FROM AdvCustOtherDetail_Mod B
 											WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
 											 AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
 											GROUP BY B.CustomerEntityId,B.AuthorisationStatus,RecallNoticeDate
 										)A  ON (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
												AND B.EntityKey=A.EntityKey  
 										 WHERE  B.CustomerEntityId=@CustomerEntityId
 										)C  
							 )E
						/*EmployeeID,Designation*/		
				END						
			
				
													
	END

ELSE IF @ShutterMenuId IN (3490,3500,3510)
	 BEGIN
			/*Ttile of case wp*/
					  SELECT @TitleOfCaseWP=CustomerName from 
					 ( SELECT CustomerName FROM legal.writPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
					    AND CaseEntityId=@CaseEntityId and EntityKey=(SELECT MAX(EntityKey)EntityKey FROM  legal.writPetitionDtls WHERE 
						(EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey ) AND
						CaseEntityId=@CaseEntityId and menuid=3610 )
					  )G
			/*Ttile of case wp*/

		/*FiledByWritPet*/		
				
			SELECT @FiledByWritPet=FiledBy 
			FROM 
			(SELECT CASE WHEN PrayerStatusAltKey=1 and PostJudStatusAlt_Key in(254,255,256,257) THEN 'Customer' 
						WHEN PrayerStatusAltKey=2 and PostJudStatusAlt_Key in(254,255,256,257) THEN 'Bank'
					end as FiledBy
			 from legal.WritPetitionDtls 
			 Where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
				AND	MenuId=3610 
				AND CaseEntityId=@CaseEntityID 
				 )g
		/*FiledByWritPet*/

		IF @ShutterMenuId IN (3490,3510)
			BEGIN
				/*WritPetitionNo*/	
				
				SELECT @WritPetitionNo=WritPetitionNo
				FROM legal.WritPetitionDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId
					
				/*WritPetitionNo*/	
				--print(14)
				select @OrderStatus=(case  when CAST(PrayerStatusAltKey AS VARCHAR(50))='1' then 'Bank''s Favor' when  CAST(PrayerStatusAltKey AS VARCHAR(50))='2' then 'Bank''s Against' else  CAST(PrayerStatusAltKey AS VARCHAR(50)) end )  from legal.WritPetitionDtls 
				where CaseEntityId=@CaseEntityId and EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
				print(@OrderStatus)
				


			END					
					
		
	 END

ELSE IF @ShutterMenuId=3550
	BEGIN
				/*BranchName*/	
				SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode	
	END

ELSE IF @ShutterMenuId=3560
	BEGIN
			/*JudgementDate*/
			--SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
			--FROM (
			--		SELECT JudgementDate FROM legal.SuitProceedingDtls 
			--		WHERE DateCreated=(
			--								SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
			--								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
			--							) 
			--			AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
		 --      UNION
		 --      SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
		 --      INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
			--					WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --      							AND CaseEntityId = @CaseEntityId 
		 --      					GROUP BY 	CaseEntityId,AuthorisationStatus
			--			 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
			--					WHERE A.CaseEntityId=@CaseEntityId and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
		 --     )G
			  /*JudgementDate*/

			  /*BranchName*/	
				SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode	
			/*BranchName*/	
									
		
	END






ELSE IF @ShutterMenuId=3570
	BEGIN
		/*EmployeeID,Designation*/
			SELECT @EmployeeID=E.EmployeeID,@Designation=E.Designation
			 	FROM(
							SELECT A.EmployeeID,A.Designation
							FROM CURDAT.AdvCustOtherDetail A  										
							WHERE (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
									   AND A.CustomerEntityId=@CustomerEntityId
										AND ISNULL(A.AuthorisationStatus,'A')='A'
 							UNION
 
 							SELECT C.EmployeeID,C.Designation FROM 
 							(
 								SELECT EmployeeID,Designation
 								FROM  AdvCustOtherDetail_Mod B INNER JOIN (
 								SELECT MAX(B.EntityKey)EntityKey,RecallNoticeDate FROM AdvCustOtherDetail_Mod B
 								WHERE (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
 								 AND  B.CustomerEntityId=@CustomerEntityId AND B.AuthorisationStatus IN ('NP','MP','DP','RM') 
 								GROUP BY B.CustomerEntityId,B.AuthorisationStatus,RecallNoticeDate
 							)A  ON (B.EffectiveFROMTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
									AND B.EntityKey=A.EntityKey  
 							 WHERE  B.CustomerEntityId=@CustomerEntityId
 							)C  
				 )E
		/*EmployeeID,Designation*/	

		/*Placeofposting*/
		SELECT  @Placeofposting=AC.Placeofposting FROM  AdvCustOtherDetail ac	
		WHERE (ac.EffectiveFromTimeKey<=@TimeKey AND ac.EffectiveToTimeKey>=@TimeKey) 
					AND ac.CustomerEntityId=@CustomerEntityId
		/*Placeofposting*/
		
		 /*BranchName*/	

				SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode	
		/*BranchName*/	
		
		/*EmployeeName*/

		SELECT @EmployeeName=EmployeeName FROM legal.CriminalCaseEmpInvolvedtls 
		WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	 AND Caseentityid=@CaseEntityID 
		 			
		/*EmployeeName*/

	END

ELSE IF @ShutterMenuId=3520
	BEGIN
		  
		   
		   SELECT 
		   @CityShortName =DCITY.CityShortName
		   FROM CURDAT.AdvCustCommunicationDetail  C
		   LEFT JOIN DimCity    DCITY   ON  (DCITY.EffectiveFromTimeKey<=@TimeKey AND DCITY.EffectiveToTimeKey>=@TimeKey) AND  DCITY.CityAlt_Key=C.CityAlt_Key
		   WHERE (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)	
				AND C.CustomerEntityId=@CustomerEntityId 

		 /*BranchName*/
			SELECT @BranchName=BranchName FROM DimBranch WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND BranchCode= @Branchcode	
		 /*BranchName*/																										
			
	END

	ELSE IF @ShutterMenuId=12300
	BEGIN
		  

		 	SELECT @OrderStatusfor138=max(a.LegalJugFavorAgName)  FROM  LEGAL.NIACTDtls B   
				LEFT JOIN legal.DimLegalJugFavorAg A
				ON (a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
						and A.LegalJugFavorAgAlt_Key=B.PrayerStatusAltKey
			WHERE  CaseEntityId = @CaseEntityId and
			 (b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey)


			 ---Order Date---
			 SELECT @NIACTOrderDate=convert(varchar(10),JudgementDt,103) FROM legal.NIACTDtls 
			where  CaseEntityId =@CaseEntityId AND
			 (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			 -----




END


ELSE IF @ShutterMenuId IN (12005,12010,12015,12025,12020,12030,12035,12040,12045,12050,12125,12130,12155)
	BEGIN

	SELECT @ConstitutionName=DC.ConstitutionName FROM DimConstitution DC
					INNER JOIN CURDAT.CustomerBasicDetail CBD
						ON(DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						AND DC.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
						WHERE CBD.CustomerEntityId=@CustomerEntityId
			--SELECT @JudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
			--FROM (
			--		SELECT JudgementDate FROM legal.SuitProceedingDtls 
			--		WHERE DateCreated=(
			--								SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
			--								WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
			--							) 
			--			AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
		 --      UNION
		 --      SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
		 --      INNER JOIN (		SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
			--					WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		 --      							AND CaseEntityId = @CaseEntityId 
		 --      					GROUP BY 	CaseEntityId,AuthorisationStatus
			--			 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
			--					WHERE A.CaseEntityId=@CaseEntityId and JudgementDate is not null --and ScreenMenuId =@ShutterMenuId
		 --     )G

			IF @ShutterMenuId=12050
				BEGIN
						/*WritPetitionNo*/
						SELECT @WritPetitionNo=WritPetitionNo
						FROM legal.WritPetitionDtls where (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
														AND CaseEntityId=@CaseEntityId
						/*WritPetitionNo*/
				END	

			 --IF @ShutterMenuId IN (12125,12130)
				--BEGIN
				--		/*TitleOfCase*/
			  
				--			SELECT @TitleOfCase=TitleOfCase
				--			FROM
				--			( SELECT TitleOfCase FROM legal.SuitProceedingDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
				--			  AND CaseEntityId=@CaseEntityId AND StageAlt_Key=1
				--			)G
			  
				--		  /*TitleOfCase*/
				--END		

			 				
	END

--ELSE IF @ShutterMenuId=12160
--	BEGIN
--		/*AppealNo*/
		
--	END

			ELSE IF @ShutterMenuId IN(2011)
			BEGIN
				
					SELECT @SecurityNature=SecurityNature
						FROM
						(
							SELECT SecurityNature FROM AdvSecurityValueDetail WHERE CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId   
																					AND (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						)G
					select @OrderStatus=(case  when CAST(PrayerAltKey AS VARCHAR(50))='2' then 'Bank''s Favor' when  CAST(PrayerAltKey AS VARCHAR(50))='3' then 'Bank''s Against' else  CAST(PrayerAltKey AS VARCHAR(50)) end )  from legal.AppealDetail 
					where CaseEntityId=@CaseEntityId and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			END

ELSE IF @ShutterMenuId=12230
	BEGIN
				/*FiledByAlt_Key*/
							DECLARE @CaseTypeCode1 SMALLINT
							SELECT @CaseTypeCode1=PermissionNatureAlt_Key 
							FROM legal.PermissionDetails 
							WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@CaseEntityId
								
							IF @CaseTypeCode1 IN(235,515)
								BEGIN
										SELECT @FiledByAlt_Key=ParameterName FROM legal.AppealDetail a
										LEFT JOIN (SELECT ParameterName,ParameterAlt_Key FROM DimParameter WHERE 
													(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
													 dimparametername='DimFiledbyAgnBank')d
										ON D.parameteralt_key=A.FiledByAlt_Key
										INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
										where ( A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  
	
										Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where 
												(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
												dimparametername='DimFiledbyAgnBank')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(235,515)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END
	
							ELSE IF @CaseTypeCode1 =220
								BEGIN
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
														(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
														dimparametername='DimFiledbyAgnBank')d
											ON d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(220)
											 WHERE ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where 
														(EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
														dimparametername='DimFiledbyAgnBank')d
												 on d.parameteralt_key=a.FiledByAlt_Key
											INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(220)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid  
								END

							ELSE IF @CaseTypeCode1 =130
								BEGIN
										Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)AND
										 dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType=130
										 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										 LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter 
										 where 
										 (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND
										 dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(130)
									 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END

							ELSE IF @CaseTypeCode1  IN (105,205,100)
								BEGIN
										 Select @FiledByAlt_Key=ParameterName FROM legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key FROM DimParameter WHERE 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
										 dimparametername='DimLegalAppealBy')d
										 ON d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (105,205,100)
										 WHERE ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										
										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										 left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										  dimparametername='DimLegalAppealBy')d
										 on d.parameteralt_key=a.FiledByAlt_Key
										  INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(105,205)
										 where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode1  IN (215)
								BEGIN
											Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='Dimfiledbank')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in (215)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

						
											Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='Dimfiledbank')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(215)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
							END

							ELSE IF @CaseTypeCode1 IN (135)
								BEGIN
											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimLegalAppealBy')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(135)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimLegalAppealBy')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(135)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode1 =225
								BEGIN
											Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimFiledByAppeal')d  --  DimLegalAppealByCivil
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(225)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimFiledByAppeal')d --  DimLegalAppealByCivil
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(225)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode1=230
								BEGIN
										 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
										left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										dimparametername='DimLegalAppealBy')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(230)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

										
										 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
										left join (select ParameterName,ParameterAlt_Key from DimParameter where 
										 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
										dimparametername='DimLegalAppealBy')d
										on d.parameteralt_key=a.FiledByAlt_Key
										 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(230)
										where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

							ELSE IF @CaseTypeCode1=150
								BEGIN
											 Select @FiledByAlt_Key=ParameterName from legal.AppealDetail a
											LEFT JOIN (select ParameterName,ParameterAlt_Key from DimParameter where
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											   dimparametername='DimApplicant')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(150)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid

											
											 Select @ComplaintFiledByShortNameEnum=ParameterName from legal.AppealDetail a
											left join (select ParameterName,ParameterAlt_Key from DimParameter where 
											 ( EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
											dimparametername='DimApplicant')d
											on d.parameteralt_key=a.FiledByAlt_Key
											 INNER JOIN SysDataUpdationStatus  B ON (B.ID=A.CaseEntityId)AND CaseType in(150)
											where ( a.EffectiveFROMTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)AND CaseEntityId=@CaseEntityid
								END

					/*FiledByAlt_Key*/	

						/*CustomerSinceDt*/
						--SELECT @CustomerSinceDt =CONVERT(VARCHAR(10),CustomerSinceDt,103) 
						--FROM [CURDAT].[CustomerBasicDetail] 
						--WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)AND 
						--		CONVERT(VARCHAR(250),CustomerEntityId)=@CustomerEntityId 
						/*CustomerSinceDt*/
						
						/*PrevStage*/
						SELECT TOP (1) @PrevStage=StagesName 
						FROM sysdataupdationdetails s
						INNER JOIN DIMSTAGES D ON S.STAGEaLT_KEY=D.sTAGESALT_KEY  
						WHERE CrModDate<(SELECT MAX(CrModDate) FROM sysdataupdationdetails where parententityid=@CaseEntityId) AND parententityid=@CaseEntityId
						ORDER BY CrModDate DESC	
						/*PrevStage*/		


	END

--ELSE IF @ShutterMenuId=12500
--	BEGIN
--				/*DtofApplicationNCLT,DtLiquidationOrder*/
--				SELECT @DtofApplicationNCLT=CONVERT(VARCHAR(10),DtofApplicationNCLT,103) ,@DtLiquidationOrder=DtLiquidationOrder
--				FROM legal.InsolvencyDtls WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
--											AND CaseEntityId=@CaseEntityId
--				/*DtofApplicationNCLT,DtLiquidationOrder*/
--	END

ELSE IF @ShutterMenuId IN (12520,12530,12540)
	BEGIN
			/*ArbitrationId*/
			SELECT @ArbitrationEntityId=ArbitrationEntityId FROM legal.ArbitrationDtls
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					AND CaseEntityId=@CaseEntityId
			/*ArbitrationId*/			

	END

	
ELSE IF @ShutterMenuId IN (12250)
	BEGIN
	
select @DtofNoticeofInvocationofArbitoBorrowers=DtofNoticeofInvocationofArbitoBorrowers from legal.ArbitrationDtls
where 	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND CaseEntityId=@CaseEntityId 	

	END


/*DateOfDecision*/   ----Reema

SELECT @DateOfDecision=PermissionDt FROM LEGAL.PermissionDetails
WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
AND CaseEntityId=@CaseEntityId


/*DateOfDecision*/

---------------------

if(@ShutterMenuId IN (1510))
(

	SELECT distinct  @AmtClaimUnderEP=Sum(ISNULL(AmtClaimUnderEP,0)) FROM LEGAL.ExecDecreeDtls 
								where 	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND CaseEntityId=@CaseEntityId 

)








-----






		---------------------
		
			SELECT @CriminalOrderStatus=max(a.LegalJugFavorAgName)  FROM  LEGAL.Sec25Dtls B   
				LEFT JOIN legal.DimLegalJugFavorAg A
				ON (a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
						and A.LegalJugFavorAgAlt_Key=B.PrayerStatusAltKey
			WHERE  CaseEntityId = @CaseEntityId and
			 (b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey)

			 ---------------------

			
--			
			SELECT @DtfilingCounterPetitioner = DtfilingCounterPetitioner FROM LEGAL.ArbitrationDtls
			--SELECT = 
WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
AND CaseEntityId=@CaseEntityId

		-----------------
		
		IF @ShutterMenuId in (890,900,910,920)
		(
		
			SELECT @AdinterimCourtLOC=CourtLOC  FROM legal.AdmissionDtls
			WHERE CaseEntityId = @CaseEntityId and
			 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		)
			
		IF @ShutterMenuId in (890,900,910,920)
		(
		
			select @CourtNameAlt_Key_Adinterim=CourtNameAlt_Key,
			@AdinterimCourtName=(case  when DLCN.LegalCourtName='----Select---' then ''  else  DLCN.LegalCourtName end )
			from legal.AdmissionDtls ADSD
			INNER JOIN LEGAL.DimLegalCourtName DLCN
			on ADSD.CourtNameAlt_Key=DLCN.LegalCourtNameAlt_key
			where (ADSD.EffectiveFromTimeKey<=@TimeKey AND ADSD.EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId = @CaseEntityId
		)
			 set @Suit_AcceptanceDate=ISNULL(@AcceptanceDate,@SuitDt)
			
		

		
-----------

IF @ShutterMenuId IN (3210,3960)

		/*@CompromiseDt*/

		SELECT 
	
					
					@CompromiseStartDt=CONVERT(VARCHAR(10),CompromiseStartDt,103)
			FROM legal.ProceedingCompromiseDtls
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


			---------------

							IF @ShutterMenuId IN (2019)
							(
			SELECT @OrderStatusForCivil=max(a.LegalJugFavorAgName)  FROM  LEGAL.Civilcasedtls B   
				LEFT JOIN legal.DimLegalJugFavorAg A
				ON (a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
						and A.LegalJugFavorAgAlt_Key=B.OrderStatus
			WHERE  CaseEntityId =@CaseEntityId and
			 (b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey)

			 )

-----------------------------


		SELECT 
		--@SuitDt=CONVERT(VARCHAR(10),SuitDt,103)
					--@WrittenStmFillingDt=CONVERT(VARCHAR(10),WrittenStmFillingDt,103)
					@FramingOfIsuuesDt=CONVERT(VARCHAR(10),FramingOfIsuuesDt,103)
			FROM legal.CivilCaseDtls
			WHERE (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			AND CaseEntityId=@CaseEntityId


	-------------------

	 IF @ShutterMenuId=4011  
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=4010
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=4010
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   
					
					
				SELECT @NextJudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
				FROM (
						SELECT JudgementDate FROM legal.SuitProceedingDtls 
						WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
											and ScreenMenuId =4010 and JudgementDate is not null 
										) 
						AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
						AND CaseEntityId=@CaseEntityId 
						and ScreenMenuId =4010 and JudgementDate is not null 
						
						UNION
						SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
						INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							 AND CaseEntityId=@CaseEntityId 
											and ScreenMenuId =4010 and JudgementDate is not null 
		       							GROUP BY 	CaseEntityId,AuthorisationStatus
							 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							 AND CaseEntityId=@CaseEntityId 
							AND ScreenMenuId =4010 and JudgementDate is not null 
								
								
				)G



					END
					----------

					 IF @ShutterMenuId=511  
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=510
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=510
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   

				 END
----------
 IF @ShutterMenuId=531 
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=530
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=530
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   

				 END
				 -------
				  IF @ShutterMenuId=541 
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=540
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=540
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   

				 END

				 -----------------

				 	  IF @ShutterMenuId=561 
					BEGIN

					SELECT @NextHearingDt =CONVERT(VARCHAR(10),NextHearingDt,103) 
					FROM (
							SELECT NextHearingDt FROM legal.SuitProceedingDtls 
							WHERE DateCreated=(
												SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
												WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
												AND ScreenMenuId=560
												
												
											  ) 
							AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId  and NextHearingDt is not null 
					UNION
							SELECT A.NextHearingDt  FROM legal.SuitProceedingDtls_Mod A
							 INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										  AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							  AND CaseEntityId = @CaseEntityId 
										  AND ScreenMenuId=560
		       					          GROUP BY 	CaseEntityId,AuthorisationStatus
						        )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								WHERE A.CaseEntityId=@CaseEntityId and NextHearingDt is not null 
				 )G   

				 		
				SELECT @NextJudgementDate=CONVERT(VARCHAR(10),JudgementDate,103)
				FROM (
						SELECT JudgementDate FROM legal.SuitProceedingDtls 
						WHERE DateCreated=(
											SELECT MAX(DateCreated)DateCreated FROM legal.SuitProceedingDtls
											WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CaseEntityId=@CaseEntityId 
											and ScreenMenuId =560 and JudgementDate is not null 
										) 
						AND EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
						AND CaseEntityId=@CaseEntityId 
						and ScreenMenuId =560 and JudgementDate is not null 
						
						UNION
						SELECT A.JudgementDate  FROM legal.SuitProceedingDtls_Mod A
						INNER JOIN (SELECT MAX(EntityKey)EntityKey FROM legal.SuitProceedingDtls_Mod
										WHERE EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND AuthorisationStatus IN ('NP','MP','DP','RM')
		       							 AND CaseEntityId=@CaseEntityId 
											and ScreenMenuId =4010 and JudgementDate is not null 
		       							GROUP BY 	CaseEntityId,AuthorisationStatus
							 )B  ON B.EntityKey=A.EntityKey AND (A.EffectiveFROMTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							 AND CaseEntityId=@CaseEntityId 
							AND ScreenMenuId = 560 and JudgementDate is not null 
								
								
				)G





				 END

				 --------
				   IF( @ShutterMenuId=2011) 
				 		select @OrderStatus=(case  when CAST(PrayerAltKey AS VARCHAR(50))='2' then 'Bank''s Favor' when  CAST(PrayerAltKey AS VARCHAR(50))='3' then 'Bank''s Against' else  CAST(PrayerAltKey AS VARCHAR(50)) end )  from legal.AppealDetail 
					where CaseEntityId=@CaseEntityId and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)



			if @JudgementDate is null 
				begin 
						select @JudgementDate=convert(varchar(10),JudgmentDt,103) from legal.JudgementDtls where CaseEntityId=@CaseEntityId and (EffectiveFROMTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				end 





---ADDED NEW QUERY AS ON 30\12\022
		

		select @Casetype=CaseType from SysDataUpdationStatus
						where id=@CaseEntityId
								
						IF @Casetype=220
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key
								,@SuitAppNo=SuitNo
								,@TitleOfCase='Civil Suit against Bank'
								 FROM LEGAL.CivilCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@CaseEntityId
							END 
						IF @Casetype=235
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key 
								,@SuitAppNo=Complaint_SuitNo
								,@TitleOfCase='Criminal Suit against Bank'
								FROM LEGAL.CriminalCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@CaseEntityId
							END 
						IF @Casetype=215
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key 
									,@SuitAppNo=ComplSuitNo
									,@TitleOfCase='Consumer Complaint against Bank'
								FROM LEGAL.ConsumerComplaintDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@CaseEntityId
							END 





		-------added new query for suit amount and suit date from bank data as on 02/04/2024 
			If exists(select 1 from legal.PermissionDetails where (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
							and CaseEntityId=@CaseEntityId and PermissionNatureAlt_Key in(100,105)
						)
					BEGIN					
					
						SELECT @AcceptanceDate=ISNULL(CONVERT(VARCHAR(10),PA.AcceptanceDate,103),CONVERT(VARCHAR(10),SUIT_DATE,103)) 
								,@SuitAppNo=ISNULL(SuitAppNo,SUIT_REF)
								,@SuitAmount=ISNULL(SuitAmount,SUIT_AMOUNT)
								,@RCDate=ISNULL(CONVERT(VARCHAR(10),ER.RCDate,103),CONVERT(varchar(10),DECREE_DATE,103))
								,@RCAmt=ISNULL(ER.RCAmt,DECREE_AMOUNT)
								--,@TypeOfLegalAction=CASE WHEN A.SUIT_TYPE=10 THEN 105 ELSE 100 END 
						FROM LEGAL.DailySuit_DRTDataFromBank A
							INNER JOIN CURDAT.CustomerBasicDetail B	
								ON A.CUST_ID=B.CustomerId
								AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
							inner join legal.PermissionDetails pd
								on (pd.EffectiveFromTimeKey<=@TimeKey and pd.EffectiveToTimeKey>=@TimeKey)
								and pd.CustomerEntityId=b.CustomerEntityId
								and pd.CaseEntityId=@CaseEntityId
							left join legal.PlaintAdmissionDetails pa
								on (pa.EffectiveFromTimeKey<=@TimeKey and pa.EffectiveToTimeKey>=@TimeKey)
								and pa.CaseEntityId=pd.CaseEntityId
							left join legal.ExecutionRCDtls er
								on(er.EffectiveFromTimeKey<=@TimeKey and er.EffectiveToTimeKey>=@TimeKey)
								and er.CaseEntityId=pd.CaseEntityId
						WHERE CUST_ID=@CustomerId

						---------------																			

					END

					Declare @CaseType1 int

					select @CaseType1=PermissionNatureAlt_Key from legal.PermissionDetails where (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
							and CaseEntityId=@CaseEntityId 


				if @CaseType1=105
					begin
						select @CourtName=DRT.DRTName
								,@CourtLocation=B.CityName
							from legal.PermissionDetails a
							inner join legal.DimDRT_DRAT DRT
								ON (a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
								AND DRT.DRTAlt_Key=A.CourtNameAlt_Key
								AND (DRT.EffectiveFromTimeKey<=@TimeKey AND DRT.EffectiveToTimeKey>=@TimeKey)
							inner join DimCity b
								on (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)								
								and a.CourtLocationAlt_Key=b.CityAlt_Key
								where CaseEntityId=@CaseEntityId 
					end		

					if @CaseType1=100
					begin

					print 'suit type'
						select @CourtName=suit.SuitCourtName 
								,@CourtLocation= B.DistrictName 
								,@OtherCourtName=OtherCourtName
								,@OtherCourtLocation=OtherCourtLocation
								,@CourtLocationAlt_Key=a.CourtLocationAlt_Key
							from legal.PermissionDetails a
							LEFT join legal.DimSuitCourt suit
								ON (a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
								AND suit.SuitAlt_Key=A.CourtNameAlt_Key
								AND (suit.EffectiveFromTimeKey<=@TimeKey AND suit.EffectiveToTimeKey>=@TimeKey)
							LEFT join DimGeography b
								on (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)								
								and a.CourtLocationAlt_Key=b.DistrictAlt_Key
								where CaseEntityId=@CaseEntityId 

								print '@CourtName'
								print @CourtName

					end		



--select @Casetype,@FinalStatus_Alt_Key,@CaseEntityId
				 -------------
		print 'Last Select'

		----------------

		SELECT 
		 @CustomerId									CustomerId							  
		,ISNULL(@CustomerName,'NA')						CustomerName						  
		,ISNULL(@ConstitutionName,'NA')					ConstitutionName					  
		,ISNULL(@CustomerACID,'NA')						AccountId
	    ,ISNULL(@CaseType,'NA')							CaseType		  
		,ISNULL(@CaseReferenceNumber,'NA')		        CaseReferenceNumber	
		,@PossessiontakingDt				PossessiontakingDt	
		,Convert(varchar(10),@AcceptanceDate,106)				AcceptanceDate					  
		,ISNULL(@PrincipalLedgerBalance ,0.0)		PrincipalLedgerBalance 				  
		,ISNULL(@UnappliedInterest		,0.0)						UnappliedInterest					  
		,ISNULL(@LegalExpenses			,0.0)						LegalExpenses						  
		,ISNULL(@Other					,0.0)						Other								  
		,ISNULL(@Total					,0.0)						Total								  
		,ISNULL(@ClaimTotal	            ,0.0)								ClaimTotal	
		,CASE WHEN ISNULL(@ClaimTotal,0)>0  THEN CAST((@ClaimTotal*10)/100+@ClaimTotal	AS DECIMAL(16,2))	 ELSE 	 0.0 END	PDR_ClaimTotal	
		,CASE WHEN ISNULL(@ClaimTotal,0)>0  THEN CAST((@ClaimTotal*10)/100	AS DECIMAL(16,2))	 ELSE 	 0.0 END	PDR_RecoveryCharge						  
		,ISNULL(@Branchcode	,'NA')								Branchcode							  
		,ISNULL(@BranchName	,'NA')								BranchName							  
		,ISNULL(@Employeeid,'NA')                       Employeeid							  
		,ISNULL(@EmployeeName,'NA')				        EmployeeName						  
		,ISNULL(@DefendantRelationship,'NA')			DefendantRelationship				  
		,@NPADt											NPADate								  
		,ISNULL(@Bankingarrangement,'NA')				Bankingarrangement			
		,ISNULL(@Consortium_Name,'NA')				Consortium_Name						  
		,ISNULL(@OSBalance,0.0)							[BalanceO/S]						  
		,ISNULL(@SuitAmount	,0.0)						SuitAmount							  
		,@DemANDNoticeDate								DateOfDemantNotice					  
		,@FiledByAlt_Key								FiledByAlt_Key						  
		,@ComplaintFiledByShortNameEnum 	Filedby				  
		,ISNULL(@AppealNo,'NA')							AppealNo							  
		,@FilExePetDt									FilExePetDt							  					  
		,@ParticualrsSoughtOnDt							ParticualrsSoughtOnDtfrmBank				  
		,@FixedInvestigationDt				FixedInvestigationDt				  
		,@DateAdmittedOn						DateAdmittedOn						  
		,@PermissionSoughtdate				PermissionSoughtdate				  
		,@DtofFirstDisb						DtofFirstDisb						  
		,@NextHearingDt						NextHearingDt						  
	    ,@SerNoticeDt						SerNoticeDt 
		,@SummonsSerDt_Suit					SummonsSerDt_Suit			  
		,@DemANDNoticeDt 					DemANDNoticeDt 						  
		,@ComplaintFiledDt					ComplaintFiledDt					  
		,@DtRti								DtRti 				
	  											  
		,@NtDishonourRcvdDt					NtDishonourRcvdDt					  
		,@DecreeDate							   DecreeDate							  
		,@PossessionSecAsSETDt				PossessionSecAsSETDt				  
		,@JudgementDate						JudgementDate						  
		,@CustomerSinceDt					CustomerSinceDt						  
		,@DtofApplicationNCLT				DtofApplicationNCLT					  
		,ISNULL(@CRESAIRegNo				,'NA')		CRESAIRegNo							  
		,ISNULL(cast(@SecurityEntityId as varchar),'NA')	SecurityEntityId					  
						  
		,@BorrNDate						BorrNDate							  
		,@Ac_DocumentDt					Ac_DocumentDt						  
		,ISNULL(@CurrentStageName			,'NA')		WithdrawalStage						  
							  
		,ISNULL(@SecurityNature				,'NA')		TypeOFCharge						  
		,@AppealOrderDt									OrderDate							  
		,ISNULL(@RemainingOs,0)							RemainingOs							  
					  
		,@DtService										DtService							  
		,@RecallNoticeDate								RecallNoticeDate					  
		,@FillingAplDt									FillingAplDt						  
		,@NextHearingDt							NextHearingDtByScreenMenuId			  
		,@RecallnoticedatePDR					RecallnoticedatePDR					  
		,@SummonIssueDate						SummonIssueDate						  
		,ISNULL(@ArbProceedingNo			,'NA')		ArbProceedingNo						  
		,ISNULL(@ArbitrationInitiatedBy		,'NA')		   ArbitrationInitiatedBy				  
		,@BOOrderDate									BOOrderDate							  
		,@DtAward										DtAward								  
		,@SummonsSerDt									SummonsSerDt						  
		,@WritpetitionJudgmentdate						WritpetitionJudgmentdate			  
		,@DtLiquidationOrder								   DtLiquidationOrder					  
		,@AppealOrderDate								AppealOrderDate						  
		,@AppellateAuthorityFiledBy 	AppellateAuthorityFiledBy    
		,isnull (@Placeofposting			,'NA'  )	Placeofposting
		,isnull (@Add1						,'NA'  )	Add1
		,isnull (@Add2						,'NA'  )	Add2
		,isnull (@Add3						,'NA'  )	Add3				
		,isnull (@CityShortName				,'NA'  )	CityShortName	
		,isnull (@PinCode					,'NA'  )	PinCode		
		,isnull (@DistrictName				,'NA'  )	DistrictName	
		,isnull (@StateName					,'NA'  )	StateName		
		,isnull (@StdCode					,'NA'  )	StdCode		
		,isnull (@PhoneNo					,'NA'  )	PhoneNo		
		,isnull (@STD_Code_Off				,'NA'  )	STD_Code_Off	
		,isnull (@PhoneNo_Off				,'NA'  )	PhoneNo_Off	
		,@ISPermission									ISPermission
		,@CaseTypeFlag									CaseTypeFlag
		,ISNULL(@ServProvider				,'NA'  )	ServiceProvider
		,@FiledBy			FiledByRevPet
		,@ConsentLetterDt								ConsentLetterDt
		,@JudgmentDtCivilStAgnB							JudgmentDtCivilStAgnB
		,@ConsumerJudgmentDt							ConsumerJudgmentDt
		,@WithdrawalStage								CivilWithdrawalstage
		,@TitleOFCaseWP									TitleOFCaseWP
		,@ComplaintDtFiled								ComplaintDtFiled
		,@FinalOrderDate								FinalOrderDate
		,ISNULL  (@FiledByWritPet,'NA')								FiledByWritPet
		,@PrevStage										PrevStage
		,@CriminalJudgementDate							CriminalJudgementDate
		,@AppealAdmittedDt								AppealAdmittedDt
		,@CivilSuitAgnBHearingDtVal						CivilSuitAgnBHearingDtVal
		,@DRTCourtName									DRTCourtName
		,@CourtLOC										CourtLOC
		,@SymbolicPossessionDt							SymbolicPossessionDt	
		,@PhysicalPossessionDt							PhysicalPossessionDt
		,@AwardDate										AwardDate
		,@CourtOrderDt									CourtOrderDt
		,@IsHearingEntered								IsHearingEntered
		
		,@WPSCFiledBy									WPSCFiledBy
		,@Designation									Designation
		,@ComPoliceStationDt							ComPoliceStationDt
		,@OrderJudgmentDt								OrderJudgmentDt
		,ISNULL(@SuitAppNo,'NA') 										ApplicationNumber
		,@ArbitrationEntityId							PreArbitrationId
		,@NiactJudgementDt								NiactJudgementDt
		,@DecreeAmount									DecreeAmount
		,@ComplainID									ComplainID
		,@CriminialSummonsServicedDt					CriminialSummonsServicedDt
		,@ShowcauseNoticeDtls							 ShowcauseNoticeDtls
		,@EnquiryConclusionDt							 EnquiryConclusionDt
		,@AppealDecisionDt								 AppealDecisionDt	
		,@ApproachDecisionDt							 ApproachDecisionDt	
		,@MaxServiceDate								 MaxServiceDate
		,@WritPetitionDt								 WritPetitionDt
		,@WritPetitionNo								 WritPetitionNo
		,@WritPetitionAdmittedDt						WritPetitionAdmittedDt
		,@JudgementDt									JudgementDt
		,@WritPetitionRejectedDt						WritPetitionRejectedDt
		,@BankRuptOrderDate								BankRuptOrderDate
	
		,@SuitNextHearingdate							SuitNextHearingdate
		,@EPDate										EPDate
		,@ValSeizedAssetdt								ValSeizedAssetdt
		,@JudgmentAwardDt								CGITJudgmentAwardDt
		,@CGIT                                          CGITCumLabourCourt
		,@SuitDt										SuitDt
		,@AppearanceDt									AppearanceDt
		,@WrittenStmFillingDt							WrittenStmFillingDt
		,@FramingOfIsuuesDt								FramingOfIsuuesDt
		,@MaxOrderDate									MaxOrderDate
		,@Sec25JudgementDt								Sec25JudgementDt
		,@AppealAdmittedDtDRAT							AppealAdmittedDtDRAT
		,@ArbitrationOrderDate                          ArbitrationOrderDate
		,@FramingOfIssueDt                               FramingOfIssueDt
		,@ArbiProceeding								ArbiProceedingValue
		,@AppointmentDt									AppointmentDt
		,@CurrentStageDate								CurrentStageDate
		,@SaleDisposalDt                                SaleDisposalDt
		,@FiledByReviewPet								FiledByReviewPet
		,@FiledByWritPetOfficer							FiledByWritPetOfficer
		,@RealizeAmt                                    RealizeAmt
		,@SaleCertDt                                    SaleCertDt
		,@SaleConfirmationDt                            SaleConfirmationDt
		,@RecoveryCharge								RecoveryCharge
		,@AmountClaimed									AmountClaimed
	
		
		,@OrderStatus                                   OrderStatus   
		,@CriminalOrderStatus							CriminalOrderStatus			
		,@OrderStatusfor138								OrderStatusfor138
			
		,CONVERT(VARCHAR(10),@DtfilingCounterPetitioner,103)  	DtfilingCounterPetitioner			
		,@AmtClaimUnderEP								AmtClaimUnderEP		
		,@CourtName									CourtName	
		,@CourtName							CourtNameAlt_Key
		,@CourtLocation								CourtLocation	
		,@TotalAC_Balance							TotalAC_Balance		  
	  ,@ApplicationAdmittedDt                    ApplicationAdmittedDt
		,@SummonsSerDt_Suit							SummonsSerDt_Suit
		,CONVERT(Varchar(10),@SummonsServiceDt,103)	SummonsServiceDt
		,CONVERT(Varchar(10),@WarrantDt,103)				WarrantDt
		,isnull (@NoOfArbitrator			,0 )	NoOfArbitrator
		,CONVERT(VARCHAR(10),@EP_valDt,103)			EP_ValDt
		,Convert(Varchar(10),@DtofNoticeofInvocationofArbitoBorrowers,103) DtofNoticeofInvocationofArbitoBorrowers
		,ISNULL(Convert(Varchar(10),@Suit_AcceptanceDate,103),'NA') Suit_AcceptanceDate
			
		,@EP_ValMessage								EP_ValMessage
		,@AdinterimCourtLOC						    AdinterimCourtLOC	
		,@AdinterimCourtName						AdinterimCourtName
		,@CourtNameAlt_Key_Adinterim				CourtNameAlt_Key_Adinterim
		,@PreDecreeDate								InterimOrderDt
		,@CompromiseStartDt							CompromiseStartDt
	    ,@LokAdalatMaxDate							LokAdalatMaxDate
		,@NIACTOrderDate							NIACTOrderDate
		,@AOQTDt										AOQTDt
		,@NoofExpert								NoofExpert	
		,@HearingDt	                          HearingDt
		 ,@PermissionLetterDate							PermissionLetterDate
		,CONVERT(VARCHAR(10),@DateOfDecision,103)		DateOfDecision
		,@OrderStatusForCivil                        OrderStatusForCivil
		,@RevDeptNoticeDt							RevDeptNoticeDt
		,@PDR_NextHearingDt							PDR_NextHearingDt
		,CONVERT(varchar(10),max(@nextdate),103)				NextHearingdt	
		,CONVERT(varchar(10),max(@Insolvancyhearingdate),103)    InsolvancyHearingdt
		,CONVERT(varchar(10),max(@ApliMMDMDt),103)  DtApplicationtoMMCMM
		,CONVERT(VARCHAR(10),@YearDt,103)           YearDt	
		,ISNULL(@TitleOfCase				,'NA')		TitleOfCase		
		,CONVERT(varchar(10),max(@PoliceNextHearingDt),103)    PoliceNextHearingDt
		,CONVERT(varchar(10),(@RepresentationDt),103)    RepresentationDt
		,CONVERT(VARCHAR(10),@TentativeDate,103)		TentativeDate
	    ,CONVERT(varchar(10),max(@AppearanceDate),103)    AppearanceDate
		,CONVERT(varchar(10),max(@DocExpiryDate),103)    DocExpiryDate
		,CONVERT(varchar(10),max(@NextRemarkDate),103)    NextRemarkDate
		,CONVERT(varchar(10),max(@NextJudgementDate),103)    NextJudgementDate
		,@FinalStatus_Alt_Key								FinalStatus_Alt_Key	
		,ISNULL(@SuitAppNo,'NA')							SuitNumber
		-----Added new column as on 03/04/2024  data coming from source
		,@RCDate											RCDate
		,@RCAmt												RCAmt	
		--,@TypeOfLegalAction									TypeOfLegalAction
		,@OtherCourtName									OtherCourtName
		,@OtherCourtLocation								OtherCourtLocation
		,@CourtLocationAlt_Key								CourtLocationAlt_Key
					  
					  	
																				  
																							  
END