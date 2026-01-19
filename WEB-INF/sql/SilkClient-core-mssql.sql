-- ======================================================
-- System: Builder Structure
-- Project: /silk-client/Data Model
-- ======================================================
-- SQL File: Data_Model_2026-01-09T20:08.sql
-- ======================================================

-- ------------------------------------------------------
-- TABLE: silkLang
-- ------------------------------------------------------
create table silkLang (
	silkLangID int primary key identity (1,1),
	langID char(2),
	langName varchar(100),
	enName varchar(50),
	status tinyint default 0
);

-- ------------------------------------------------------
-- TABLE: silkSession
-- ------------------------------------------------------
create table silkSession (
	silkSessionID int primary key identity (1,1),
	silkAccessID int,
	silkUserID int,
	ipAddress varchar(50),
	httpSession varchar(255),
	sessionToken varchar(500),
	sessionType tinyint default 0,
	sessionDate datetime,
	lastTransactionDate datetime,
	deviceType varchar(20),
	userAgent varchar(255),
	disabled tinyint default 0
);

create index silkSession_silkAccessID on silkSession(silkAccessID);
create index silkSession_silkUserID on silkSession(silkUserID);
create index silkSession_ipAddress on silkSession(ipAddress);
create index silkSession_httpSession on silkSession(httpSession);
create index silkSession_sessionToken on silkSession(sessionToken);

-- ------------------------------------------------------
-- TABLE: silkAccess
-- ------------------------------------------------------
create table silkAccess (
	silkAccessID int primary key identity (1,1),
	silkDeviceID int,
	accessToken varchar(500),
	silkUserID int,
	securePIN varchar(10),
	creationDate datetime default getDate(),
	lastAccess datetime,
	status tinyint default 0
);

create index silkAccess_silkDeviceID on silkAccess(silkDeviceID);
create index silkAccess_accessToken on silkAccess(accessToken);
create index silkAccess_silkUserID on silkAccess(silkUserID);

-- ------------------------------------------------------
-- TABLE: silkDevice
-- ------------------------------------------------------
create table silkDevice (
	silkDeviceID int primary key identity (1,1),
	deviceToken varchar(255),
	creationDate datetime default getDate(),
	lastAccess datetime,
	agent varchar(255),
	status tinyint default 0
);

create index silkDevice_deviceToken on silkDevice(deviceToken);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int primary key identity (1,1),
	groupName varchar(50),
	tagName varchar(50),
	tagType varchar(36),
	tagIntValue int,
	content nvarchar(max),
	position tinyint default 0
);

create index silkTag_groupName on silkTag(groupName);
create index silkTag_tagName on silkTag(tagName);

-- ------------------------------------------------------
-- TABLE: silkLog
-- ------------------------------------------------------
create table silkLog (
	silkLogID int primary key identity (1,1),
	tableName varchar(100),
	pkValue int,
	status smallint,
	operationAction varchar(50),
	operationDate datetime,
	operationUser int 
);

create index silkLog_tableName on silkLog(tableName);
create index silkLog_pkValue on silkLog(pkValue);

-- ------------------------------------------------------
-- PROGRAM: readLanguage
-- ------------------------------------------------------
GO
create function readLanguage (@dataText nvarchar(max), @lang nvarchar(10) )
returns nvarchar(max) as
begin
	Declare @startTag nvarchar(20);
	Declare @endTag nvarchar(20);
	Declare @startPos int;
	Declare @endPos int;
	
	--
	-- If dataText is empty returns
	--
	if Len(@dataText)=0
		return ''
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if charIndex(N'<lang-',@dataText)=0
		return @dataText
	
	-- 
	-- Creates received lang tag
	--
	set @startTag  = N'<lang-'+@lang+'>';
	set @endTag  = N'</lang-'+@lang+'>';
	
	--
	-- Search tag in dataText
	--
	set @startPos = charIndex(@startTag,@dataText);

	if @startPos=0
	begin
		--
		-- If lang does not exist search for english as base language
		--
		set @startTag  = N'<lang-en>';
		set @endTag  = N'</lang-en>';
		
		--
		-- Search tag in dataText
		--
		set @startPos = charIndex(@startTag,@dataText);
		
		if @startPos=0
		Begin
			--
			-- If lang does not exist search for any existing language
			--
			set @startPos = charIndex('<lang-',@dataText);

			if @startPos=0
				return '';
			
			set @endPos = charIndex('>',@dataText);
			
			set @lang = substring(@dataText,@startPos+6,@endPos-7);
			
			set @startTag  = N'<lang-'+@lang+'>';
			set @endTag  = N'</lang-'+@lang+'>';	
		
		End
	End	

	set @startPos = @startPos+Len(@startTag);
	set @endPos = charIndex(@endTag,@dataText)-@startPos;

	return substring(@dataText,@startPos,@endPos);

end

-- select [dbo].[readLanguage-tmp]('<lang-en>Hello</lang-en>','en');

-- ------------------------------------------------------
-- PROGRAM: writeLanguage
-- ------------------------------------------------------
GO
create function writeLanguage(@oldText nvarchar(max),@dataText nvarchar(max), @lang nvarchar(10) )
returns nvarchar(max)
as
begin
	Declare @startTag nvarchar(20);
	Declare @endTag nvarchar(20);
	Declare @startPos int;
	Declare @endPos int;
	
	-- -----------
	-- If old text is null it is set to empty.
	-- -----------

	set @oldText = isNull(@oldText,'');
	
	-- -----------
	-- If the existing text does not have the lang tag it is clear to received the new data with the tag.
	-- -----------
	if charIndex(N'<lang-',@oldText)=0
		set @oldText=''

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	set @startTag  = N'<lang-'+@lang+'>';
	set @endTag  = N'</lang-'+@lang+'>';

	-- -----------
	-- Finds the poisition of the open lang tag.
	-- -----------
	set @startPos = charIndex(@startTag,@oldText);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if @startPos=0
		return @oldText+@startTag+@dataText+@endTag;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	set @startPos = @startPos+Len(@startTag)-1;
	set @endPos = Len(@oldText)-charIndex(@endTag,@oldText)+1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return left(@oldText,@startPos)+@dataText+right(@oldText,@endPos);

end;

-- ------------------------------------------------------
-- VIEW: silkVariable
-- ------------------------------------------------------
GO
create view silkVariable as
select
	groupName,
	tagIntValue as value,
	content as label,
	tagName as keyValue,
	position
from silkTag
where tagType=1;
GO


-- ======================================================
-- SQL script end
-- ======================================================