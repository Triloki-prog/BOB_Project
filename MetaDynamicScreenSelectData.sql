
/****** Object:  StoredProcedure [dbo].[MetaDynamicScreenSelectData]    Script Date: 10/1/2024 3:44:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MetaDynamicScreenSelectData]
--declare
	 @MenuId			INT=1000,
	 @TimeKey			INT=24726,
	 @Mode				TINYINT=2,
	 @BaseColumnValue	VARCHAR(50) = '5078',
	 @ParentColumnValue VARCHAR(50) = '23631',
	 @TabId				INT='0'
	 AS 
BEGIN
	/*DECLARATION OF LOCAN VARIABLES FOR FURTHER USE*/
	DECLARE @SQL VARCHAR(MAX),
			@TableName varchar(500),
			@TableWithSchema varchar(50),
			@TableWithSchema_Mod varchar(50),
			@Schema varchar(5),
			@BaseColumn varchar(50),
			@EntityKey VARCHAR(50),
			@ChangeFields VARCHAR(200),
			@ParentColumn varchar(50)=''
	IF @Mode=1 SET @BaseColumnValue=0
	
	PRINT 'A1'
	/*START FOR CREATE THE TEMP TABLE FOR SELECT THE DATA*/

		/*FIND THE TABLES USED IN MENU FOR GET THE COLUMN LIST TO CREATE TEMP TABLE  */
		SET @TableName=(SELECT ','+ SourceTable 
		FROM MetaDynamicScreenField WHERE MenuID=@MenuId 
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND SkipColumnInQuery='N' AND ValidCode='Y'
		GROUP BY SourceTable
		FOR XML PATH(''))

		print @TableName
	
		/*REMOVE COMM FROM DFIRST POSITION*/
		SET @TableName=RIGHT(@TableName,LEN(@TableName)-1)

		/*FIND THE LIST OF COLUMNS USED IN ABOBE @TableName  VARIABLES FOR FIND THE COLUMNS AND KEEP IN TEMP TABLE*/
		IF  OBJECT_ID('Tempdb..#TmmpQry') IS NOT NULL
			DROP TABLE #TmmpQry

		CREATE TABLE #TmmpQry ( ColDtl VARCHAR(100))
		
	
		INSERT INTO #TmmpQry

		SELECT  distinct A.COLUMN_NAME +  ' '+ a.DATA_TYPE+ ''+
							(CASE 
								WHEN A.DATA_TYPE IN ('VARCHAR','NVARCHAR','CHAR') 
									THEN  +'('+cast(A.CHARACTER_MAXIMUM_LENGTH  as varchar(4))+')'
								WHEN a.DATA_TYPE IN ('decimal','numeric') 
									THEN  +'('+cast(A.NUMERIC_PRECISION as varchar(4))+','+CAST(A.NUMERIC_SCALE as varchar(2))+')'
								ELSE '' END
							)
								AS ColDtl
			
				FROM [INFORMATION_SCHEMA].[COLUMNS] A
					--INNER JOIN SYS.types B ON B.system_type_id=A.system_type_id
					INNER JOIN MetaDynamicScreenField C
							ON (C.ControlName=A.COLUMN_NAME)
							AND C.MenuID=@MenuId 
							AND SkipColumnInQuery='N'  AND ValidCode='Y'
						--INNER JOIN SYS.objects D
						--	ON D.object_id=A.object_id
						--	AND SCHEMA_NAME(D.SCHEMA_ID) NOT IN ('LEGALVW')
					inner join (SELECT SourceTable 
									FROM MetaDynamicScreenField WHERE MenuID=@MenuId 
										AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
										AND SkipColumnInQuery='N' AND ValidCode='Y'
									GROUP BY SourceTable
								  ) m
								  on a.TABLE_NAME=m.SourceTable
				WHERE 
				--OBJECT_NAME(A.OBJECT_iD) 
				--		IN (SELECT SourceTable 
				--					FROM MetaDynamicScreenField WHERE MenuID=@MenuId 
				--						AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
				--						AND SkipColumnInQuery='N' AND ValidCode='Y'
				--					GROUP BY SourceTable
				--			)
					  ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
					AND A.COLUMN_NAME NOT IN('EntityKey','D2Ktimestamp' ,'AuthorisationStatus','EffectiveFromTimeKey','EffectiveToTimeKey','CreatedBy','DateCreated','ModifiedBy','DateModified','ApprovedBy')
					AND A.COLUMN_NAME <>'sysname'

         PRINT 'A2'
		--SELECT * FROM #TmmpQry
	
		PRINT 2222222222
		DECLARE @ColName VARCHAR(MAX)
		/*MERGED ALL THE COLUMNS WITH COMMA(,) SEPARATED FOR FURTHER USE*/	
		SELECT @ColName=STUFF((SELECT ','+ColDtl 
						FROM #TmmpQry M1
							--where M1.MasterTable=M2.MasterTable
						FOR XML PATH('')),1,1,'')   
				FROM #TmmpQry M2
		PRINT @ColName

		/*CREATE TEMP TABLE FOR INSERT THE OUTPUT FOR SELECT DATA*/
			IF  OBJECT_ID('Tempdb..#TmpSelData') IS NOT NULL
				DROP TABLE #TmpSelData

		SET @ColName=REPLACE(@ColName,'(-1)','(MAX)')

		CREATE TABLE  #TmpSelData (EntityKey INT)
			SET @SQL= 'ALTER TABLE #TmpSelData ADD '+@ColName 	
		EXEC (@SQL)
		PRINT 'A3'
		ALTER TABLE #TmpSelData ADD AuthorisationStatus varchar(2), IsMainTable cHAR(1),CreatedModifiedBy VARCHAR(20),ChangeFields  VARCHAR(200), D2Ktimestamp INT
	/*END OF CREATE TEMP TABLE FOR SELECT THE DATA*/
	--select * from #TmpSelData
		/* FIND THE FLAG FOR TAB USING IN SCREEN OR NOT*/
	DECLARE  @TabApplicable BIT=0
	SELECT @TabApplicable=1  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0
	IF @TabApplicable=1 and @TabId=0
		BEGIN
			SELECT @TabId=MIN(ParentcontrolID)  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
		END


	/* FIND THE BASE COLUMN AND PARENT COLUMN */
	SELECT @TableName =SourceTable from  MetaDynamicScreenField where MenuId=@MenuID GROUP BY SourceTable
	SELECT @BaseColumn = ControlName from MetaDynamicScreenField where MenuId=@MenuID  AND ValidCode='Y'
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND BaseColumnType='BASE'
	SELECT  @ParentColumn= SourceColumn from MetaDynamicScreenField where MenuId=@MenuID  AND ValidCode='Y'
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND BaseColumnType='PARENT'
PRINT 'A4'
					
	/* FIND THE TABLE NAME WITH SCHEMA*/
	SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
	PRINT 'TableName' +@TableName
	SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1
	PRINT 'EntityKey'
	PRINT 'EntityKey'+@EntityKey


	/* CREATE TEMP TABLE FOR MAIN DATA SELECT*/
		IF OBJECT_ID('Tempdb..#TmpDataSelect') IS NOT NULL
			DROP TABLE #TmpDataSelect
	

	/* CREATE TEMP TABLE MAINTAIN THE ISAINTABLE, AUTH STATUS AND CREATED_MODIFIED BY */
		IF  OBJECT_ID('Tempdb..#TmpAuthStatus') IS NOT NULL
			DROP TABLE #TmpAuthStatus
		CREATE TABLE #TmpAuthStatus (IsMainTable CHAR(1), AuthorisationStatus VARCHAR(2), CreatedModifiedBy VARCHAR(20))
		
	/* CREATE TEMP TABLE KEEP THE UNIQUE SOURCE TABLE */
		IF OBJECT_ID('Tempdb..#TmpSrcTable') IS NOT NULL
			DROP TABLE #TmpSrcTable

		CREATE TABLE #TmpSrcTable
			(RowId TINYINT ,SourceTable varchar(50))

	/* FIRST INSERTING BASE TABLE ON FIRST (1) SEQUENCE */
	--INSERT INTO #TmpSrcTable
		--SELECT 1, SourceTable FROM MetaDynamicScreenField 
		--WHERE MenuID=@MenuId AND BaseColumnType='BASE'
		--		AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
PRINT 'A5'
	INSERT INTO #TmpSrcTable
		SELECT 1, SourceTable 
		FROM MetaDynamicScreenField A
		INNER JOIN
			(SELECT MIN(ControlID) ControlID	FROM MetaDynamicScreenField  
					WHERE MenuID=@MenuID AND  BaseColumnType='BASE' 
					AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
					AND ValidCode='Y'
				 ) B
				ON A.ControlID=B.ControlID
				AND SkipColumnInQuery='N' AND ValidCode='Y'
			WHERE MenuID=@MenuID AND  BaseColumnType='BASE' 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
				AND ValidCode='Y'
		--INSERT INTO #TmpSrcTable
		--SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		--FROM #TmmpQry WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
		--	GROUP BY SourceTable

		---SELECT * FROM #TmpSrcTable
	
			
	/* INSERT UNIQUE SOURCE TABLE FOR LOOPING PURPOSE*/
		INSERT INTO #TmpSrcTable
		SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		FROM MetaDynamicScreenField WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
			AND MenuID=@MenuId 
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND SkipColumnInQuery='N' AND ValidCode='Y'
		GROUP BY SourceTable

		----SELECT * FROM #TmpSrcTable
	
		
		--INSERT INTO #TmpSrcTable
		--SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		--FROM #TmmpQry WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
		--	GROUP BY SourceTable
		DECLARE @OrgParentColumnVal VARCHAR(50)
		SET @OrgParentColumnVal = @ParentColumnValue

		DELETE  #TmpSrcTable WHERE SourceTable IS NULL

		/* STARTING OF LOOP FOR FOR PREPARING THE SELECT DATA*/
	PRINT 'A6'	
		
		DECLARE @RowId TINYINT=1
		WHILE @RowId<=(SELECT COUNT(1) FROM #TmpSrcTable)
			BEGIN		
				PRINT 'A6.1'	
					set @ParentColumnValue= @OrgParentColumnVal
					SELECT @TableName=SourceTable from #TmpSrcTable WHERE RowId=@RowId
					SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1

					SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
					SELECT @TableWithSchema_Mod=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName+'_Mod' , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName+'_Mod'

					TRUNCATE TABLE #TmmpQry

					INSERT INTO #TmmpQry

					SELECT distinct A.COLUMN_NAME  ColDtl
					FROM [INFORMATION_SCHEMA].[COLUMNS]  A
						--INNER JOIN SYS.types B ON B.system_type_id=A.system_type_id
						INNER JOIN MetaDynamicScreenField C
								ON A.COLUMN_NAME=C.ControlName
								AND C.MENUID=@MenuId
								AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
								AND SkipColumnInQuery='N' AND ValidCode='Y'
		
					WHERE A.TABLE_NAME =@TableName
						AND A.COLUMN_NAME NOT IN('D2Ktimestamp')
					
						PRINT 'A6.2'	
					--SELECT * FROM #TmmpQry
						--PRINT 1235468

					IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl=@ParentColumn)
						BEGIN
						    PRINT 5555555555
							SET @ParentColumnValue='0'
						END

					IF @RowId=1
						BEGIN
						
							SELECT  @ColName=STUFF((
									SELECT  ' ,' +ColDtl
										FROM #TmmpQry  A1
											WHERE ColDtl<>@ParentColumn --AND ColDtl<>@BaseColumn --changes 19 jun 2017
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2

   
						
						END					
					ELSE
						BEGIN
							PRINT 88888888
							set @ColName=''
							SELECT  @ColName=STUFF((
									SELECT  ' ,A.' +ColDtl +'=B.'+ColDtl
										FROM #TmmpQry  A1
											WHERE ColDtl<>@ParentColumn AND ColDtl<>@BaseColumn
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
							
						END
							PRINT 'A6.3'	
					SET @ColName=RIGHT(@ColName,LEN(@ColName)-1)
						
					IF @RowId=1
						BEGIN
						
							SET @SQL='INSERT INTO  #TmpSelData('+ @ColName +', AuthorisationStatus,IsMainTable,  CreatedModifiedBy, ChangeFields, D2Ktimestamp)'

							SET @ColName='A.'+@ColName

							

							IF @Mode<>16 
								BEGIN	
								
												
										SET @SQL=@SQL+ ' SELECT '+ @ColName +', AuthorisationStatus,''Y'' AS IsMainTable, ISNULL(ModifiedBy,CreatedBy) AS CreatedModifiedBy, '''' ChangeFields, CAST(D2Ktimestamp AS INT) D2Ktimestamp FROM  '+@TableWithSchema +' A ' 
										SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
										SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
	
										SET @SQL=@SQL+' AND '+@BaseColumn+'='+@BaseColumnValue+' AND ISNULL(AuthorisationStatus,''A'')=''A'''									

										SET  @SQL=@SQL+ ' UNION '

										print 'MainTable'+@SQL
								   END
									print 'ModTable1'
									PRINT @TableWithSchema_Mod
									SET @SQL=@SQL+ ' SELECT '+ @ColName +', AuthorisationStatus,''N'' AS IsMainTable, ISNULL(ModifiedBy,CreatedBy) AS CreatedModifiedBy, ChangeFields ,CAST(D2Ktimestamp AS INT) D2Ktimestamp FROM  '+@TableWithSchema_Mod+' A' 
									PRINT 'ModTable2'+@SQL  
									---PRINT @EntityKey
									SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey +' FROM ' +@TableWithSchema_Mod+' B WHERE ' + CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue +' AND '  ELSE ' ' END  +@BaseColumn+'='''+@BaseColumnValue+''' AND B.AuthorisationStatus IN(''NP'',''MP'',''DP'')) B ON A.'+@EntityKey +' = B.'+@EntityKey
									PRINT 'ModTable3'+@SQL
									SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									PRINT 'ModTable4'+@SQL
									SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									PRINT 'ModTable5'+@SQL
									SET @SQL=@SQL+' AND '+@BaseColumn+'='''+@BaseColumnValue+''' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'
									PRINT 'ModTable6'+@SQL							
								  
							      EXEC (@SQL)

							  END
											
					    ELSE					  
						    BEGIN									 
									PRINT '99999999'
									SET @SQL='UPDATE A SET '+@ColName
									+' FROM #TmpSelData A '
									+' INNER JOIN '+ @TableWithSchema+ ' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									+  CASE WHEN @ParentColumn<>'' THEN ' AND B.'+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									+' AND A.'+@BaseColumn+'=B.'+@BaseColumn
									+' AND ISNULL(B.AuthorisationStatus,''A'') =''A'''
									print 'A1'+@SQL
									EXEC (@SQL)

									SET @SQL='UPDATE A SET '+@ColName
									+' FROM #TmpSelData A '
									+' INNER JOIN '+ @TableWithSchema_Mod+' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey +' FROM ' +@TableWithSchema_Mod+' B WHERE ' 
									+  CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue ELSE '' END  
									+  case when @ParentColumnValue<>'0' then ' AND ' else '' end +  @BaseColumn+'='+@BaseColumnValue+ ' AND B.AuthorisationStatus IN(''NP'',''MP'',''DP'')) C ON B.'+@EntityKey +' = C.'+@EntityKey
									+  CASE WHEN @ParentColumnValue<>'0' THEN ' AND A.'+ @ParentColumn +'= B.' +@ParentColumn ELSE '' END
									+' AND A.'+@BaseColumn+'=B.'+@BaseColumn
							
							
							    EXEC (@SQL)
						  END
								
									INSERT INTO #TmpAuthStatus
									SELECT  IsMainTable,AuthorisationStatus,CreatedModifiedBy FROM #TmpSelData 

									--IF  @RowId>1
									--	BEGIN
									--		SET @SQL='INSERT INTO  #TmpSelData('+ @ColName +
													
									--	END
			
									SET @RowId=@RowId+1
											
					END

						PRINT 'A7'	

				SELECT @ChangeFields=ChangeFields FROM #TmpSelData

				IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl LIKE 'CaseEntityID%')			
					BEGIN
						ALTER TABLE #TmpSelData ADD CaseEntityID INT
						
					END
				UPDATE #TmpSelData set CaseEntityID=@ParentColumnValue where isnull(CaseEntityID,0)=0

				IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl LIKE 'BranchCode%')			
					BEGIN
						ALTER TABLE #TmpSelData ADD BranchCode varchar(10)
					END

				declare @BrCode VARCHAR(10)
				
			SELECT @BrCode=Branchcode FROM LEGAL.PermissionDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CaseEntityId=@OrgParentColumnVal
				UPDATE #TmpSelData set BranchCode=@BrCode
				
				
			IF EXISTS(SELECT 1 FROM  #TmpAuthStatus WHERE IsMainTable='N')
				BEGIN
					UPDATE T 
						SET IsMainTable='N'
						,AuthorisationStatus=(SELECT top(1) AuthorisationStatus FROM #TmpAuthStatus)
						,CreatedModifiedBy=(SELECT top(1) CreatedModifiedBy FROM #TmpAuthStatus)
					FROM #TmpSelData T
				END 
				

			DECLARE @CreatedModifiedBy varchar(50),	@UserLocation	varchar(5),	@UserLocationCode varchar(10)
			SELECT @CreatedModifiedBy = CreatedModifiedBy FROM #TmpSelData 

			/*FIND CHANGE FIELDS*/
			DECLARE
			@SQL1 NVARCHAR(MAX)
			print 'change1234'
			SET @SQL1 =' SELECT @ChangeFields=ChangeFields
			 FROM '+@TableWithSchema_Mod+'

						WHERE '+@EntityKey+'=(SELECT MAX('+@EntityKey+') AS '+@EntityKey+' FROM '+@TableWithSchema_Mod+' WHERE (EffectiveFromTimeKey<='+CAST(@TimeKey as varchar(6))+' AND EffectiveToTimeKey>='+CAST(@TimeKey as varchar(6))+') 
												   AND ISNULL(AuthorisationStatus,''A'')=''A''
													AND  '+@BaseColumn+'='+@BaseColumnValue+'	
													
						)'					 
				
				
				print @SQL1
			--SET @SQL1=@SQL1+'AND'+CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END				

			--SELECT @SQL1
			EXECUTE sp_executesql @SQL1,N'@ChangeFields varchar(max) output',@ChangeFields OUTPUT

			/*FIND CHANGE FIELDS*/
			
			---SELECT @UserLocation =UserLocation,@UserLocationCode=UserLocationCode FROM DimUserInfo WHERE UserLoginID = @CreatedModifiedBy

			DECLARE @Casetype INT,@FinalStatus_Alt_Key INT,@JD_OrderDT date ,@Appeal_OrderDT DATE


				

			IF @MenuId=720
				BEGIN
						
						select @Casetype=CaseType from SysDataUpdationStatus
						where id=@ParentColumnValue
								

						IF @Casetype=220
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CivilCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=235
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CriminalCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=215
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.ConsumerComplaintDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 

				END 

				IF @MenuId=2007
				BEGIN
						

						select @Casetype=CaseType from SysDataUpdationStatus
						where id=@ParentColumnValue
								

						IF @Casetype=220
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CivilCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=235
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CriminalCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=215
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.ConsumerComplaintDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 

				END 

				IF @MenuId=2019
				BEGIN
						

						select @Casetype=CaseType from SysDataUpdationStatus
						where id=@ParentColumnValue
								

						IF @Casetype=220
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CivilCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=235
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.CriminalCaseDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 
						IF @Casetype=215
							BEGIN
								SELECT @FinalStatus_Alt_Key=FinalStatus_Alt_Key FROM LEGAL.ConsumerComplaintDtls			
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CaseEntityId=@ParentColumnValue
							END 

				END 

				IF @MenuId IN(720,2007,2019,3560,3550,3540)
					BEGIN
							select  @JD_OrderDT=jd.JudgmentDt
								,@Appeal_OrderDT=ad.OrderDate
							FROM legal.JudgementDtls jd																		
								left join legal.AppealDetail ad
									on ad.CaseEntityId=jd.CaseEntityId
									and (jd.EffectiveFromTimeKey<=@TimeKey and jd.EffectiveToTimeKey>=@TimeKey)
									and (ad.EffectiveFromTimeKey<=@TimeKey and ad.EffectiveToTimeKey>=@TimeKey)
									and ad.AppealEntityId in(select max(AppealEntityId)AppealEntityId from legal.AppealDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey group by CaseEntityId)
								where jd.CaseEntityId=@ParentColumnValue
					END 

		-------------------ADDED NEW MENUID LOGIC

		 IF  @MenuId=4502
		BEGIN
		

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *
				,REPLICATE('X',len(DR.ReligionName)-2)+stuff(DR.ReligionName,1,len(DR.ReligionName)-1,'X') Religion
				,REPLICATE('X',len(DC.CasteName)-2)+stuff(DC.CasteName,1,len(DC.CasteName)-1,'X') Caste	
				--,DC.CasteName Caste
				--,DR.ReligionName Religion
				FROM #TmpSelData A
					LEFT JOIN DimCaste DC 
						ON A.CasteAlt_Key=DC.CasteAlt_Key
						AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND DC.CasteAlt_Key>0
					LEFT JOIN DimReligion DR
						ON DR.ReligionAlt_Key=A.ReligionAlt_Key
						AND (DR.EffectiveFromTimeKey<=@TimeKey AND DR.EffectiveToTimeKey>=@TimeKey)
						AND DR.ReligionAlt_Key>0


					--WHERE MENUID=@MenuId
		END

		ELSE IF  @MenuId=5050
		BEGIN
		

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *
				,REPLICATE('X',len(DR.ReligionName)-2)+stuff(DR.ReligionName,1,len(DR.ReligionName)-1,'X') Religion
				,REPLICATE('X',len(DC.CasteName)-2)+stuff(DC.CasteName,1,len(DC.CasteName)-1,'X') Caste	
				--,DC.CasteName Caste
				--,DR.ReligionName Religion
				FROM #TmpSelData A
					LEFT JOIN DimCaste DC 
						ON A.CasteAlt_Key=DC.CasteAlt_Key
						AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND DC.CasteAlt_Key>0
					LEFT JOIN DimReligion DR
						ON DR.ReligionAlt_Key=A.ReligionAlt_Key
						AND (DR.EffectiveFromTimeKey<=@TimeKey AND DR.EffectiveToTimeKey>=@TimeKey)
						AND DR.ReligionAlt_Key>0


					--WHERE MENUID=@MenuId
		END

		ELSE IF  @MenuId=600 AND @TabId='631'
		BEGIN
		

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *
				,REPLICATE('X',len(DR.ReligionName)-2)+stuff(DR.ReligionName,1,len(DR.ReligionName)-1,'X') Religion
				,REPLICATE('X',len(DC.CasteName)-2)+stuff(DC.CasteName,1,len(DC.CasteName)-1,'X') Caste	
				--,DC.CasteName Caste
				--,DR.ReligionName Religion
				FROM #TmpSelData A
					LEFT JOIN DimCaste DC 
						ON A.CasteAlt_Key=DC.CasteAlt_Key
						AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND DC.CasteAlt_Key>0
					LEFT JOIN DimReligion DR
						ON DR.ReligionAlt_Key=A.ReligionAlt_Key
						AND (DR.EffectiveFromTimeKey<=@TimeKey AND DR.EffectiveToTimeKey>=@TimeKey)
						AND DR.ReligionAlt_Key>0

					--WHERE MENUID=@MenuId
		END

			ELSE IF  @MenuId=12700
		BEGIN
		

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *
				,REPLICATE('X',len(DR.ReligionName)-2)+stuff(DR.ReligionName,1,len(DR.ReligionName)-1,'X') Religion
				,REPLICATE('X',len(DC.CasteName)-2)+stuff(DC.CasteName,1,len(DC.CasteName)-1,'X') Caste	
				--,DC.CasteName Caste
				--,DR.ReligionName Religion
				FROM #TmpSelData A
					LEFT JOIN DimCaste DC 
						ON A.CasteAlt_Key=DC.CasteAlt_Key
						AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND DC.CasteAlt_Key>0
					LEFT JOIN DimReligion DR
						ON DR.ReligionAlt_Key=A.ReligionAlt_Key
						AND (DR.EffectiveFromTimeKey<=@TimeKey AND DR.EffectiveToTimeKey>=@TimeKey)
						AND DR.ReligionAlt_Key>0


					--WHERE MENUID=@MenuId
		END

			ELSE IF  @MenuId=12450
		BEGIN
		

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *
				,REPLICATE('X',len(DR.ReligionName)-2)+stuff(DR.ReligionName,1,len(DR.ReligionName)-1,'X') Religion
				,REPLICATE('X',len(DC.CasteName)-2)+stuff(DC.CasteName,1,len(DC.CasteName)-1,'X') Caste	
				--,DC.CasteName Caste
				--,DR.ReligionName Religion
				FROM #TmpSelData A
					LEFT JOIN DimCaste DC 
						ON A.CasteAlt_Key=DC.CasteAlt_Key
						AND (DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey)
						AND DC.CasteAlt_Key>0
					LEFT JOIN DimReligion DR
						ON DR.ReligionAlt_Key=A.ReligionAlt_Key
						AND (DR.EffectiveFromTimeKey<=@TimeKey AND DR.EffectiveToTimeKey>=@TimeKey)
						AND DR.ReligionAlt_Key>0


					--WHERE MENUID=@MenuId
		END

				--IF @MenuId=3560
				--BEGIN
				--			SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, A.*,@FinalStatus_Alt_Key FinalStatus_Alt_Key
				--			,jd.JudgmentDt JD_OrderDT
				--			,ad.OrderDate Appeal_OrderDT
				--			FROM #TmpSelData a
				--				left join legal.JudgementDtls jd
				--					on jd.CaseEntityId=a.CaseEntityId
				--					and (jd.EffectiveFromTimeKey<=@TimeKey and jd.EffectiveToTimeKey>=@TimeKey)
				--				left join legal.AppealDetail ad
				--					on ad.CaseEntityId=a.CaseEntityId
				--					and (ad.EffectiveFromTimeKey<=@TimeKey and ad.EffectiveToTimeKey>=@TimeKey)
				--					and ad.AppealEntityId in(select max(AppealEntityId)AppealEntityId from legal.AppealDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey group by CaseEntityId)

				--END

				--else IF @MenuId=3550
				--BEGIN
				--			SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, A.*,@FinalStatus_Alt_Key FinalStatus_Alt_Key
				--			,jd.JudgmentDt JD_OrderDT
				--			,ad.OrderDate Appeal_OrderDT
				--			FROM #TmpSelData a
				--				left join legal.JudgementDtls jd
				--					on jd.CaseEntityId=a.CaseEntityId
				--					and (jd.EffectiveFromTimeKey<=@TimeKey and jd.EffectiveToTimeKey>=@TimeKey)
				--				left join legal.AppealDetail ad
				--					on ad.CaseEntityId=a.CaseEntityId
				--					and (ad.EffectiveFromTimeKey<=@TimeKey and ad.EffectiveToTimeKey>=@TimeKey)
				--					and ad.AppealEntityId in(select max(AppealEntityId)AppealEntityId from legal.AppealDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey group by CaseEntityId)
									
				--END
				--else IF @MenuId=3540
				--BEGIN
				--			SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, A.*,@FinalStatus_Alt_Key FinalStatus_Alt_Key
				--			,jd.JudgmentDt JD_OrderDT
				--			,ad.OrderDate Appeal_OrderDT
				--			FROM #TmpSelData a
				--				left join legal.JudgementDtls jd
				--					on jd.CaseEntityId=a.CaseEntityId
				--					and (jd.EffectiveFromTimeKey<=@TimeKey and jd.EffectiveToTimeKey>=@TimeKey)
				--				left join legal.AppealDetail ad
				--					on ad.CaseEntityId=a.CaseEntityId
				--					and (ad.EffectiveFromTimeKey<=@TimeKey and ad.EffectiveToTimeKey>=@TimeKey)
				--					and ad.AppealEntityId in(select max(AppealEntityId)AppealEntityId from legal.AppealDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey group by CaseEntityId)

				--END



		--ELSE

		    -----------------------------------------------------14/05/2024
				ELSE if @MenuId=9003
			
				Begin
					Print  'kk9003'

					Update #TmpSelData Set AssetOwnerName=RelationEntityId


					
					Select  'SelectData' TableName
					,@UserLocation CreatedModifiedByLoc
					, @UserLocationCode CreatedModifiedByLocCode,
					* FROM #TmpSelData

					--EntityKey,
					--AssetOwnerName as RelationEntityId,
					--OwnerEntityId,
					--OwnerTypeAlt_Key,
					--RelationEntityId as AssetOwnerName,
					--SecurityEntityID,
					--AuthorisationStatus,
					--IsMainTable,
					--CreatedModifiedBy,
					--ChangeFields,
					--D2Ktimestamp,
					--CaseEntityID,
					--BranchCode


				END
				-------------------------------------------14/05/2024




		ELSE if @MenuId=1000
 
		Begin
		Print 'Kaps1'

		Declare @ExRC_EntityId int =0
					
					SELECT @ExRC_EntityId=max(b.ExRC_EntityId) FROM #TmpSelData A
						INNER JOIN legal.ExecutionRCDtls B
							ON A.CaseEntityId=B.CaseEntityId
						WHERE (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
						
						if isnull(@ExRC_EntityId,0)=0
							begin
								set @ExRC_EntityId=@BaseColumnValue
							end 






			SELECT 'SelectData'       TableName,	
			        @UserLocation     CreatedModifiedByLoc, 
					@UserLocationCode CreatedModifiedByLocCode, 
			        EntityKey,	
					AmtDepositedByBidderInDRT,	
					AppDate,	AppealAgainstRO,	AppSubSerAWDate,	AppSubSerDate,	ArrestWarrantDate,	AttachWarrantDate,	AttachWarrantSer,	BankReplyDate,	BankStep,	BankStepAfterArrestWarrant,	CaseEntityId,	CurrentStageRemark,	


					case when DateOfNextStage <=Getdate() and @ExRC_EntityId=a.ExRC_EntityId then Null else a.DateOfNextStage end DateOfNextStage, --DateOfNextStage,
					

					 DemandNoticeDate,	DemNoticeSer,	DemNotiSerDate,DisposalDate,	ExRC_EntityId,	FilingAffiDate,	FilingAffiPossCourtDate,FilingAffiSaleProcSerDate,	FilingAffiSubSerAWDate,	FilingAffiSubSerDate,
			         FilingAppArrestNotiDate,	FilingAppAssetDeclDate,	FilingAppSubSerDate,	FillingAffiSerAWDate,	FillingAffiSerNSPDate,	FurtherAsset,	InterestOtherCharge,	IntervenorName,	Intervention,	Others,	




			         Case when DateOfNextStage <=Getdate() and @ExRC_EntityId=a.ExRC_EntityId then a.PurposeOfNextStage else a.PresentStage end  as PresentStage, --PresentStage,	

			         Case when DateOfNextStage <=Getdate()  and @ExRC_EntityId=a.ExRC_EntityId then a.DateOfNextStage else a.PresentStageDt end  as PresentStageDt, --PresentStageDt,
			         case when DateOfNextStage <=Getdate() and @ExRC_EntityId=a.ExRC_EntityId then Null else a.PurposeOfNextStage end PurposeOfNextStage, --PurposeOfNextStage,	 





			         
			         RCAmt,	RCClosureDate,	RCDate,	RCNo,	SaleProcNotiDate,	SaleProcNotiServ,	SaleProcSerDate,	SerAttachWarrantDate,	StepByBankOutcome,	SubSerAWDate,	SubSerDemDate,	SubSerPubDate,	TakingPossValDate,	TakingPossValDateAW,	AuthorisationStatus,	IsMainTable,	CreatedModifiedBy,	ChangeFields,	D2Ktimestamp,	BranchCode,	
			         @FinalStatus_Alt_Key   FinalStatus_Alt_Key
			        ,@JD_OrderDT            JD_OrderDT 
			        ,@Appeal_OrderDT        Appeal_OrderDT
			        --,Case when DateOfNextStage <=Getdate() then DateOfNextStage else PresentStageDt end  as PresentStageDt1 
			        --,case when DateOfNextStage <=Getdate() then null else DateOfNextStage end DateOfNextStage1
					,CASE WHEN DateOfNextStage<=CAST(GETDATE() AS DATE) THEN 1 ELSE  2	 END OperationFlag   ---Added as on 11/04/2024  newly added
 
			   FROM #TmpSelData as a --WHERE MENUID=@MenuId

		END

		ELSE if @MenuId in(480,500)
			BEGIN

					Declare @SuitProcEntityId int =0
					
					SELECT @SuitProcEntityId=max(b.SuitProcEntityId) FROM #TmpSelData A
						INNER JOIN LEGAL.SuitProceedingDtls B
							ON A.CaseEntityId=B.CaseEntityId
						WHERE (b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
						
						if isnull(@SuitProcEntityId,0)=0
							begin
								set @SuitProcEntityId=@BaseColumnValue
							end 

				SELECT 'SelectData' TableName
					,@UserLocation CreatedModifiedByLoc
					, @UserLocationCode CreatedModifiedByLocCode	
					,EntityKey	
					,AdjourmentReasonAlt_Key	
					,AdjourmentSougtByAlt_Key	
					,CaseEntityId	
					,CASE WHEN @SuitProcEntityId=SuitProcEntityId and NextHearingDt<=CAST(GETDATE() AS DATE) THEN NULL ELSE  NextHearingDt	 END NextHearingDt
					,CASE WHEN @SuitProcEntityId=SuitProcEntityId and NextHearingDt<=CAST(GETDATE() AS DATE) THEN NULL ELSE  NextPostPurposeAlt_Key	 END NextPostPurposeAlt_Key	
					,OtherPurpose	
					,CASE WHEN @SuitProcEntityId=SuitProcEntityId and NextHearingDt<=CAST(GETDATE() AS DATE) THEN NextHearingDt ELSE  RemarkDt	 END  RemarkDt	
					,Remarks	
					,ScreenMenuId	
					,CASE WHEN @SuitProcEntityId=SuitProcEntityId and NextHearingDt<=CAST(GETDATE() AS DATE) THEN NextPostPurposeAlt_Key ELSE  StageAlt_Key	 END StageAlt_Key	
					,SuitProcEntityId	
					,TitleOfCase	
					,AuthorisationStatus	
					,IsMainTable	
					,CreatedModifiedBy	
					,ChangeFields	
					,D2Ktimestamp	
					,BranchCode	
					,@FinalStatus_Alt_Key FinalStatus_Alt_Key
					,@JD_OrderDT JD_OrderDT 
					,@Appeal_OrderDT Appeal_OrderDT
					,CASE WHEN NextHearingDt<=CAST(GETDATE() AS DATE) THEN 1 ELSE  2	 END OperationFlag   ---Added as on 08/04/2024 	
					FROM #TmpSelData
			END 


		ELSE

		BEGIN
		Print 'Kaps'
			SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, *,@FinalStatus_Alt_Key FinalStatus_Alt_Key
				,@JD_OrderDT JD_OrderDT ,@Appeal_OrderDT Appeal_OrderDT
			 FROM #TmpSelData --WHERE MENUID=@MenuId
		END

			SELECT 'ChangeFields' TableName,  ChngFld ControlId  FROM 
					(SELECT Split.a.value('.', 'VARCHAR(100)') AS ChngFld  
						FROM  (SELECT  CAST ('<M>' + REPLACE(@ChangeFields, ',', '</M><M>') + '</M>' AS XML) AS ChngFld 
				
							) AS A CROSS APPLY ChngFld.nodes ('/M') AS Split(a) )A
	
	
	
	
END







