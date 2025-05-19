

SELECT * INTO DimSecurity_17102024 FROM DimSecurity

alter table DimSecurity
	add SrfEligible char(1)
	,Movable char(1)
	,Immovable char(1)



UPDATE DimSecurity
	set SrfEligible='y'
	where EffectiveToTimeKey=49999
	and SecurityAlt_Key in(
110,111,112,113,114,115,118,120,125,130,135,140,145,150,155,160,165,170,201,202,205,206,209,210
,215,216,219,220,223,224,225,226,229,230,235,236,241,242,243,244,245,246,750,999
)


UPDATE DimSecurity
	set Movable='y'
	where EffectiveToTimeKey=49999
	and SecurityAlt_Key in(110,111,112,113,114,115,118,120,125,130,135,140,145,150,155,160,165,170)


UPDATE DimSecurity
	set Immovable='y'
	where EffectiveToTimeKey=49999
	and SecurityAlt_Key in(201,202,205,206,209,210,215,216,219,220,223,224,225,226,229,230,235,236,241,242,243,244,245,246,750,999)



	DECLARE @DimSecurity INT,@SecurityAlt_Key INT

	SELECT @DimSecurity=MAX(Security_Key),@SecurityAlt_Key=MAX(SecurityAlt_Key) FROM DimSecurity


	insert into DimSecurity
		(
			Security_Key
			,SecurityAlt_Key
			,SecurityName
			,SecurityShortName
			,SecurityShortNameEnum
			,SecurityGroup
			,SecurityValidCode
			,SecurityCRM
			,AssetClass
			,SecurityType
			,CurrencyType
			,CIBILSecurityCode
			,SrcSysSecurityCode			
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated			
			,IRBCollType
			,SrfEligible
			,Movable
			,Immovable
		)

	select 
			@DimSecurity+1 Security_Key
			,@SecurityAlt_Key+1  SecurityAlt_Key
			,'Mortgage on Agricultural Property Eligible for SARFAESI Action' SecurityName
			,'Mort Agri Property' SecurityShortName
			,'Mort Agri Property' SecurityShortNameEnum
			,'MORTGAGE' SecurityGroup
			,SecurityValidCode
			,SecurityCRM
			,AssetClass
			,SecurityType
			,CurrencyType
			,CIBILSecurityCode
			,203 SrcSysSecurityCode			
			,27303 EffectiveFromTimeKey
			,49999 EffectiveToTimeKey
			,'d2k' CreatedBy
			,GETDATE() DateCreated			
			,IRBCollType
			,'Y' SrfEligible
			,'N' Movable
			,'Y' Immovable                                                          
	from DimSecurity where EffectiveToTimeKey=49999 and SecurityAlt_Key=202


