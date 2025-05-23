USE [BOB_LEGAL_PLUS_TEST]
GO
/****** Object:  StoredProcedure [dbo].[SysStageBarSelect]    Script Date: 07-12-2024 19:15:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from legal.permissiondetail where 
--
---exec SysStageBarSelect 41,10211,49999
/****** Object:  StoredProcedure [dbo].[SysDataUpdation_InUp]    Script Date: 4/8/2017 3:03:03 PM ******/
ALTER  PROCEDURE [dbo].[SysStageBarSelect]
--DECLARE
	@CurrentStageAlt_Key	INT=0,
	@ID						VARCHAR(50)=0,
	@TimeKey				INT =49999
AS

--DECLARE
--	@CurrentStageAlt_Key	INT=37,
--	@ID						VARCHAR(50)='4498',
--	@TimeKey				INT =27130


	--SELECT * FROM SysDataUpdationStatus

	DECLARE @CaseEntityID INT ,@CaseStatus varchar(5)='',@CASETYPE VARCHAR(10)


	SELECT @CaseStatus = CaseStatus,@CASETYPE=CaseType FROM SysDataUpdationStatus where ID = @ID
	SELECT @CaseEntityID=@ID--CaseEntityId FROM SysDataUpdationDetails A WHERE EntityId = CAST(@ID AS INT) and CaseEntityId=@CaseEntityID  GROUP BY CaseEntityId

	--SELECT @CaseStatus
	
	--BEGIN
		/*	PREPARE PREVIOUS STAGE ,DATA*/
			IF OBJECT_ID('Tempdb..#STAGEDATA') IS nOT NULL
				DROP TABLE #STAGEDATA
	
			SELECT A.* , ROW_NUMBER() OVER(PARTITION BY A.StagesAlt_Key  ORDER BY A.StagesAlt_Key) RowId , ROW_NUMBER() OVER (ORDER BY B.StagesNameOrderKey) SNo
		
				INTO #STAGEDATA
			FROM (
			
			SELECT  --0 RowIndex,
					A.ID , 0 TypeAlt_Key,	 0 CurrentStageAlt_Key	,0 NextStageAlt_Key ,M.MenuId, A.StagesName
					,M.ActionName ViewName,Viewpath,ngController,
					M.EnableMakerChecker ,M.NonAllowOperation , 'StageBarTable' TblName 
					,3 OperationMode
					,StagesAlt_Key, B.CustomerEntityId

				FROM

				(	
					SELECT A.CaseEntityId ID, A.MenuId,b.StagesAlt_Key,StagesName,StagesGroup 
						FROM SysDataUpdationDetails A
					INNER JOIN DimStages B
						ON  (A.StageAlt_Key=B.StagesAlt_Key)
						AND StagesSubGroup='Main'
					WHERE  CaseEntityID=@CaseEntityID AND StageAlt_Key <> @CurrentStageAlt_Key
					
					UNION

				SELECT CaseEntityId ID, c.MenuId,b.StagesAlt_Key,b.StagesName, b.StagesGroup 
					FROM DimStages B
					inner join (
									SELECT C.CaseType, A.CaseEntityId,max(A.MenuId) MenuId,max(b.StagesAlt_Key) StagesAlt_Key,StagesSubGroup FROM SysDataUpdationDetails A
										INNER JOIN DimStages B
											ON (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											AND (A.StageAlt_Key=B.StagesAlt_Key)
										INNER JOIN SysDataUpdationStatus C
											ON A.CaseEntityId =C.ID
										where  CaseEntityId=@CaseEntityID
											AND StagesSubGroup='SubStage'
											--AND StageAlt_Key = @CurrentStageAlt_Key
										group by A.CaseEntityId,StagesSubGroup,C.CaseType
								
									--SELECT A.CaseEntityId,A.MenuId,b.StagesAlt_Key,StagesName,StagesSubGroup FROM SysDataUpdationDetails A
									--INNER JOIN DimStages B
									--	ON (EffectiveFromTimeKey<=24628 AND EffectiveToTimeKey>=24628)
									--	AND (A.StageAlt_Key=B.StagesAlt_Key)
									--where  CaseEntityId=@CaseEntityID
									--	AND StagesSubGroup='SubStage'
									--	--AND StageAlt_Key = @CurrentStageAlt_Key
								)c
								ON (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND C.StagesSubGroup=b.StagesShortName
								AND B.TypeAlt_Key=C.CaseType
				) A
				INNER JOIN SysDataUpdationStatus B
					ON A.ID=B.ID
				LEFT JOIN SysCRisMacMenu M
					ON M.MenuId = A.MenuId 

			UNION ALL

				SELECT TOP(1) --0 RowIndex,
					A.ID , A.CaseType TypeAlt_Key,	 A.CurrentStageAlt_key	,B.CurrentStageAlt_Key NextStageAlt_Key,B.CurrentStageMenuID MenuId,C.StagesName,M.ActionName ViewName,Viewpath,ngController,
					M.EnableMakerChecker ,M.NonAllowOperation , 'StageBarTable' TblName 
					,2 OperationMode
					,B.CurrentStageAlt_Key StagesAlt_Key
					, A.CustomerEntityId
				FROM SysDataUpdationStatus A
				INNER JOIN DimStagesMatrix B
					ON (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
					AND a.CurrentStageAlt_key=b.CurrentStageAlt_Key
					--and a.CurrentStageAlt_key=b.NextStageAlt_Key
					AND B.CurrentStageAlt_Key=@CurrentStageAlt_Key
					--AND B.NextStageMenuID IS NOT NULL
				INNER JOIN DimStages C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					AND C.StagesAlt_Key=a.CurrentStageAlt_key
				LEFT JOIN SysCRisMacMenu M
					ON M.MenuId = B.CurrentStageMenuID AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
							
				WHERE A.ID = @id AND StagesSubGroup='Main' 
				--AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus )
			UNION

			SELECT --(ROW_NUMBER() OVER (ORDER BY NextStageAlt_Key ASC)) RowIndex,
						A.ID , A.CaseType TypeAlt_Key,	A.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID MenuId,C.StagesName,M.ActionName ViewName,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation , 'StageBarTable' TblName 
						,1 OperationMode
						,B.NextStageAlt_Key StagesAlt_Key
						, A.CustomerEntityId
				FROM SysDataUpdationStatus A
				INNER JOIN DimStagesMatrix B
					ON (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
					and a.CurrentStageAlt_key=b.CurrentStageAlt_Key
					and B.NextStageAlt_Key=CASE WHEN  ISNULL(A.NextStageAlt_Key,0) = 0 AND A.CaseType NOT IN (140,145)  THEN B.NextStageAlt_Key ELSE A.NextStageAlt_Key END
					AND A.CurrentStageAlt_Key=@CurrentStageAlt_Key
					AND ISNULL(Condition,'S')='S'
					AND B.NextStageMenuID IS NOT NULL
				INNER JOIN DimStages C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					AND C.StagesAlt_Key=B.NextStageAlt_Key
				LEFT JOIN SysCRisMacMenu M
					ON M.MenuId = B.NextStageMenuID AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)

				WHERE A.ID = @Id AND StagesSubGroup='Main'
				--	AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus ) 
					GROUP BY  A.CaseType, A.ID ,A.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID,C.StagesName,M.ActionName ,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation	,A.CustomerEntityId


			 UNION
			SELECT --(ROW_NUMBER() OVER (ORDER BY NextStageAlt_Key ASC)) RowIndex,
						A.ID , A.CaseType TypeAlt_Key,	A.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID MenuId,C.StagesName,M.ActionName ViewName,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation , 'StageBarTable' TblName 
						,1 OperationMode
						,B.NextStageAlt_Key StagesAlt_Key
						, A.CustomerEntityId
				FROM SysDataUpdationStatus A
				INNER JOIN DimStagesMatrix B
					ON (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
					and a.NextStageAlt_Key=b.NextStageAlt_Key
					AND A.CurrentStageAlt_Key=@CurrentStageAlt_Key
					AND ISNULL(Condition,'S')='S'
					AND B.NextStageMenuID IS NOT NULL
				INNER JOIN DimStages C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					AND C.StagesAlt_Key=B.NextStageAlt_Key
				LEFT JOIN SysCRisMacMenu M
					ON M.MenuId = B.NextStageMenuID AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)

				WHERE A.ID = @Id AND StagesSubGroup='Main'
				--	AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus ) 
					GROUP BY A.CaseType, A.ID ,A.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID,C.StagesName,M.ActionName ,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation	,A.CustomerEntityId


			 UNION

				SELECT --(ROW_NUMBER() OVER (ORDER BY NextStageAlt_Key ASC)) RowIndex,
						A.ID , A.CaseType TypeAlt_Key,	B.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID MenuId,C.StagesName,M.ActionName ViewName,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation , 'StageBarTable' TblName 
						,1 OperationMode
						,B.NextStageAlt_Key StagesAlt_Key
						, A.CustomerEntityId
				FROM SysDataUpdationStatus A
				INNER JOIN DimStagesMatrix B
					ON (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
					and a.CurrentStageAlt_key=b.CurrentStageAlt_Key
					AND A.CurrentStageAlt_Key=@CurrentStageAlt_Key
					AND ISNULL(Condition,'C')='C'
					AND B.NextStageMenuID IS NOT NULL
				INNER JOIN DimStages C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					AND C.StagesAlt_Key=B.NextStageAlt_Key
				LEFT JOIN SysCRisMacMenu M
					ON M.MenuId = B.NextStageMenuID AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)

				WHERE A.ID = @Id AND StagesSubGroup='Main'
				--	AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus ) 
					GROUP BY  A.CaseType , A.ID ,B.CurrentStageAlt_Key	,B.NextStageAlt_Key ,B.NextStageMenuID,C.StagesName,M.ActionName ,Viewpath,ngController,
						M.EnableMakerChecker ,M.NonAllowOperation	,A.CustomerEntityId




			--/*FOR DISPLAY  MAIN STAGE HAVING SUB STAGE	*/
			UNION
			SELECT --(ROW_NUMBER() OVER (ORDER BY B.NextStageAlt_Key ASC)) RowIndex,
							A.ID , A.CaseType TypeAlt_Key,	B.CurrentStageAlt_Key	,B.NextStageAlt_Key 
							,ISNULL(C.MenuId,4999) MenuId,C.StagesName,M.ActionName ViewName
							,Viewpath,ngController,
							M.EnableMakerChecker ,M.NonAllowOperation 
							, 'StageBarTable' TblName 
							,1 OperationMode
							,B.NextStageAlt_Key StagesAlt_Key
							, A.CustomerEntityId
					----SELECT a.*
					FROM SysDataUpdationStatus A
					INNER JOIN DimStagesMatrix B
						ON (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
						and (a.CurrentStageAlt_key=b.CurrentStageAlt_Key)
						--AND a.CurrentStageAlt_key=@CurrentStageAlt_Key
						AND  @CurrentStageAlt_Key in(a.CurrentStageAlt_key,a.NextStageAlt_Key)
				
						--WHERE ID='10'
					INNER JOIN (
								SELECT  B.MenuId, B.StagesSubGroup, A.StagesName StagesName
								,StagesAlt_Key,MIN(NextStageAlt_Key) NextStageAlt_Key--,MIN(NextStageAlt_Key) NextStageAlt_Key 
								FROM DimStages A
									INNER JOIN
											( SELECT ID,
											case when CaseType=105 and  b.StagesAlt_Key in(36,37,38,39,40) Then 500
						 					 when CaseType=100 and  b.StagesAlt_Key in(9,10,11,12,13) Then 480
												ELSE B.MENUID end  MENUID
											, StagesSubGroup FROM SysDataUpdationStatus  A
												INNER JOIN DimStages  B
												ON (A.CurrentStageAlt_key = B.StagesAlt_Key or A.NextStageAlt_Key = B.StagesAlt_Key )
												WHERE StagesSubGroup='SubStage'  AND A.ID=@ID
												GROUP BY ID,MENUID, StagesSubGroup,CaseType,StagesAlt_Key
											) B
										ON (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND A.StagesShortName=B.StagesSubGroup
									INNER JOIN DimStagesMatrix  C
										ON C.CurrentStageAlt_Key=StagesAlt_Key
									GROUP BY B.MenuId, B.StagesSubGroup,StagesAlt_Key,A.StagesName
									
								)C ON 
								(C.NextStageAlt_Key=B.NextStageAlt_Key or C.StagesAlt_Key=B.NextStageAlt_Key)


					LEFT JOIN SysCRisMacMenu M
						ON M.MenuId = C.MenuId 
				
				WHERE A.ID = @ID 
				----AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus )
				GROUP BY  A.CaseType , A.ID ,B.CurrentStageAlt_Key	
				,B.NextStageAlt_Key ,C.MenuId,C.StagesName,M.ActionName ,Viewpath,ngController,
					M.EnableMakerChecker ,M.NonAllowOperation ,A.CustomerEntityId

				)	 A		
				INNER JOIN DimStages B
					ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
						AND A.StagesAlt_Key=B.StagesAlt_Key			
				order by b.StagesNameOrderKey
			
			

			---------------------------------------
			
			IF @CASETYPE IN('100','105')
				BEGIN
					print 'Triloki 12'
					--select 'tril',* from #STAGEDATA
					--IF NOT EXISTS (SELECT 1 FROM #STAGEDATA WHERE StagesName IN('Judgement','Ad Interim Order') )
						BEGIN
						 print 'triloki'
							DECLARE @SNo INT 
							SELECT @SNo=MAX(SNo)+1 FROM #STAGEDATA 
							INSERT INTO #STAGEDATA
								(
										ID	
										,TypeAlt_Key	
										,CurrentStageAlt_Key	
										,NextStageAlt_Key	
										,MenuId	
										,StagesName	
										,ViewName	
										,Viewpath	
										,ngController	
										,EnableMakerChecker	
										,NonAllowOperation	
										,TblName	
										,OperationMode	
										,StagesAlt_Key	
										,CustomerEntityId	
										,RowId	
										,SNo
								)
							
							--SELECT * FROM #STAGEDATA
								SELECT 
							A.ID , A.CaseType TypeAlt_Key,	B.StagesAlt_Key CurrentStageAlt_Key
							,NULL NextStageAlt_Key 
							, CASE WHEN A.CaseType =100 THEN '720'  WHEN A.CaseType =105 THEN '730' ELSE  ISNULL(B.MenuId,4999)	END	 MenuId
							,B.StagesName,M.ActionName ViewName
							,M.Viewpath
							,M.ngController
							,M.EnableMakerChecker 
							,M.NonAllowOperation 
							, 'StageBarTable' TblName 
							,1 OperationMode
							,B.StagesAlt_Key
							, A.CustomerEntityId
							,1 RowId	
							,@SNo SNo
							FROM SysDataUpdationStatus A
							INNER JOIN DimStages B
								ON A.CaseType=B.TypeAlt_Key
							LEFT JOIN SysCRisMacMenu M
								ON M.MenuId = CASE WHEN A.CaseType =100 THEN '720'  WHEN A.CaseType =105 THEN '730' ELSE B.MenuId	END															
							left join #STAGEDATA c
								on c.StagesName=b.StagesName							
							WHERE A.ID = @ID
							AND B.StagesName IN('Judgement','Ad Interim Order','Stay','Withdrawal')
							and c.StagesName is null
							----AND ( ISNULL(CONDITION,@CaseStatus)=@CaseStatus )
							GROUP BY  A.CaseType , A.ID ,B.StagesAlt_Key	
							 ,B.MenuId,B.StagesName,M.ActionName ,m.Viewpath,m.ngController,
								M.EnableMakerChecker ,M.NonAllowOperation ,A.CustomerEntityId

						END
				END 
			
					

		
				
				DELETE #STAGEDATA WHERE RowId>1

				----added query to udate menuid for sarfaedi screen as on 07/12/2024
				update #STAGEDATA set MenuId=570 where MenuId=571


				/*FILTERATION AND VALIDATION FOR STAFF ACCOUNTABILITY*/
				ALTER TABLE #STAGEDATA ADD StaffAccountability char(1), StageSegment varchar(20)

				
				
				UPDATE A
					SET A.StaffAccountability='Y'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.PermissionDetails P
						ON (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
						AND A.ID=P.CaseEntityId
					INNER JOIN AdvCustNPAdetail NPA
						ON (NPA.EffectiveFromTimeKey<=@TimeKey AND NPA.EffectiveToTimeKey>=@TimeKey)
						AND NPA.CustomerEntityId=P.CustomerEntityId
						AND ISNULL(NPA.StaffAccountability,'N')='Y'



					----SELECT * FROM #STAGEDATA

				UPDATE A
					SET A.StageSegment=B.StagesSegment
				FROM #STAGEDATA A
					INNER JOIN DimStages B
							ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
							AND A.NextStageAlt_Key=B.StagesAlt_Key

				/* FOR AD-INTERIM */
				UPDATE #STAGEDATA SET StageSegment='Ad-interim' WHERE StagesAlt_Key in(24,50,241,251)
						

				---SELECT * FROM #STAGEDATA

				
				DELETE #STAGEDATA	 WHERE ISNULL(StaffAccountability,'N')='N' AND StageSegment='STAFF'

				---SELECT * FROM #STAGEDATA

				/*FILTERATION AND VALIDATION FOR PERMISSION APPROOVED OR NOT*/
			
				ALTER TABLE #STAGEDATA ADD Approved char(1)

				---SELECT * FROM #STAGEDATA
				
				PRINT 'Permission'

				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.PermissionDetails B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND ISNULL(B.Approved,'N')='N'
						AND A.StagesName='Permission'

				--SELECT * FROM #STAGEDATA			
			
				PRINT 'Revision Petition'
				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.RevPetiDtls B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND ISNULL(B.Approved,'N')='N'
						AND A.StagesName LIKE '%Revision Petition%'
				
				PRINT 'Appeal'
				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.AppealDetail B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND ISNULL(B.Approved,'N')='N'
						AND A.StagesName LIKE '%Appeal%'
				
				PRINT 'Writ Petition'
				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.WritPetitionDtls B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND ISNULL(B.Approved,'N')='N'
						AND A.StagesName LIKE '%Writ Petition%'


				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.WritPetitionDtls B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND ISNULL(B.Approved,'N')='N'
						AND A.StageSegment = 'WritPetition'



				PRINT 'Stay'
				UPDATE A
					SET Approved ='N'
				FROM #STAGEDATA A
					INNER JOIN LEGAL.ProceedingStayedDtls B
						ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
						AND A.ID=B.CaseEntityId AND StayVacatedDt IS NULL
						AND A.StagesName LIKE '%Stay%'
			

				DELETE  #STAGEDATA 	WHERE SNO>(select max(SNO) from #STAGEDATA where ISNULL(Approved,'N')='N')

				
				DELETE  A
				FROM #STAGEDATA A
				INNER JOIN CustomerBasicDetail CBD
						ON (CBD.EffectiveFromTimeKey<=@TimeKey and CBD.EffectiveToTimeKey>=@TimeKey)	
						AND A.CustomerEntityId=CBD.CustomerEntityId
					INNER JOIN DimConstitution CONS
						ON (CONS.EffectiveFromTimeKey<=@TimeKey and CONS.EffectiveToTimeKey>=@TimeKey)	
						AND CONS.ConstitutionAlt_Key=CBD.ConstitutionAlt_Key
				WHERE (ConstitutionGroup NOT IN('FIRMS','PROP','INDIVIDUALS') AND StagesName LIKE 'Bankruptcy Details%')
					 OR (ConstitutionGroup IN('FIRMS','PROP','INDIVIDUALS') AND StagesName LIKE 'Insolvency%' )

			
			

				--DELETE  A
				--FROM #STAGEDATA A
				--INNER JOIN LEGAL.InsolvencyDtls B
				--		ON (B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey)	
				--		AND A.ID=B.CaseEntityId
				--WHERE (A.StagesName LIKE '%NCLAT%' or a.StagesName LIKE '%Liquidation%' )AND ISNULL(B.InsolvancyFutureRecourseAlt_Key,0)=0

				--DELETE  A
				--FROM #STAGEDATA A
				--INNER JOIN LEGAL.BankruptcyDtls B
				--		ON (B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey)	
				--		AND A.ID=B.CaseEntityId
				--WHERE A.StagesName LIKE '%DRAT%' AND ISNULL(B.FutureCourseAlt_Key,0)=0


				--DELETE  A
				--FROM #STAGEDATA A
				--INNER JOIN LEGAL.InsolBnkrptAppealDetail B
				--		ON (B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey)	
				--		AND A.ID=B.CaseEntityId
				--WHERE (A.StagesName LIKE '%DRAT%' OR A.StagesName LIKE '%NCLAT%' OR a.StagesName LIKE '%Liquidation%' ) AND ISNULL(B.PostJudStatusAlt_Key,0)=0


				--SELECT * FROM #STAGEDATA
				SELECT 
				(ROW_NUMBER() OVER(ORDER BY SNO) -1) RowIndex -- ADDED TO SHOW STAGE DEFAULT SELECTION
				,*, TblName AS TableName FROM #STAGEDATA where  ISNULL(NextStageAlt_Key,0)<>264 and StagesName<>'Recovery Action Deferred'
				ORDER BY SNo
			/**/
			







	