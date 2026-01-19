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
	silkLangID int generated always as identity primary key,
	langID char(2),
	langName varchar2(50),
	enName varchar2(50),
	status smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkSession
-- ------------------------------------------------------
create table silkSession (
	silkSessionID int generated always as identity primary key,
	silkAccessID int,
	silkUserID int,
	ipAddress varchar2(50),
	httpSession varchar2(255),
	sessionToken varchar2(500),
	sessionType smallint default 0,
	sessionDate timestamp,
	lastTransactionDate timestamp,
	deviceType varchar2(20),
	userAgent varchar2(255),
	disabled smallint default 0
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
	silkAccessID int generated always as identity primary key,
	silkDeviceID int,
	accessToken varchar2(500),
	silkUserID int,
	securePIN varchar2(10),
	creationDate timestamp default CURRENT_TIMESTAMP,
	lastAccess timestamp,
	status smallint default 0
);

create index silkAccess_silkDeviceID on silkAccess(silkDeviceID);
create index silkAccess_accessToken on silkAccess(accessToken);
create index silkAccess_silkUserID on silkAccess(silkUserID);

-- ------------------------------------------------------
-- TABLE: silkDevice
-- ------------------------------------------------------
create table silkDevice (
	silkDeviceID int generated always as identity primary key,
	deviceToken varchar2(255),
	creationDate timestamp default CURRENT_TIMESTAMP,
	lastAccess timestamp,
	agent varchar2(255),
	status smallint default 0
);

create index silkDevice_deviceToken on silkDevice(deviceToken);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int generated always as identity primary key,
	groupName varchar2(50),
	tagName varchar2(50),
	tagType smallint default 0,
	tagIntValue smallint,
	content clob,
	position smallint default 0
);

create index silkTag_groupName on silkTag(groupName);
create index silkTag_tagName on silkTag(tagName);

-- ------------------------------------------------------
-- TABLE: silkLog
-- ------------------------------------------------------
create table silkLog (
	silkLogID int generated always as identity primary key,
	tableName varchar2(100),
	pkValue int,
	status smallint,
	operationAction varchar2(50),
	operationDate timestamp,
	operationUser int 
);

create index silkLog_tableName on silkLog(tableName);
create index silkLog_pkValue on silkLog(pkValue);

-- ------------------------------------------------------
-- PROGRAM: readLanguage
-- ------------------------------------------------------
create or replace function readLanguage (dataText nvarchar2, lang char)
return nvarchar2
is
	startTag nvarchar2(20);
	endTag nvarchar2(20);
	startPos smallint;
	endPos smallint;
    lang2 char(2);
begin

	--
	-- If dataText is empty returns
	--
	if length(dataText)=0 then
		return '';
	end if;

	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if instr(dataText, '<lang-')=0 then
		return dataText;
	end if;

	-- 
	-- Creates received lang tag
	--
	startTag := '<lang-'||lang||'>';
	endTag := '</lang-'||lang||'>';

	--
	-- Search tag in dataText
	--
	startPos := instr(dataText, startTag);
	
	if startPos=0 then
		--
		-- If lang does not exist search for english as base language
		--
		startTag := '<lang-en>';
		endTag := '</lang-en>';

		--
		-- Search tag in dataText
		--
		startPos := instr(dataText, startTag);
	end if;

	if startPos=0 then
		--
		-- If lang does not exist search for any existing language
		--
		startPos := instr(dataText, '<lang-');
		
		if startPos=0 then
			return '';
		end if;
		
		lang2 := substr(dataText,startPos+6,2);
		startTag := '<lang-'||lang2||'>';
		endTag := '</lang-'||lang2||'>';
		
	end if;	

	startPos := startPos+length(startTag);
	endPos := instr(dataText, endTag)-startPos;
	
	return substr(dataText,startPos,endPos);

end;
/

-- ------------------------------------------------------
-- PROGRAM: writeLanguage
-- ------------------------------------------------------
create or replace function writeLanguage (oldEntry nvarchar2, dataText nvarchar2, lang char)
return nvarchar2
is
	startTag nvarchar2(20);
	endTag nvarchar2(20);
	startPos smallint;
	endPos smallint;
    oldText nvarchar2(32767);
begin

	-- -----------
	-- If old text is null it is set to empty.
	-- -----------
	oldText := coalesce(oldEntry,'');
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if instr(oldText,'<lang-')=0 then
		return oldText;
	end if;

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	startTag := '<lang-'||lang||'>';
	endTag := '</lang-'||lang||'>';

	-- -----------
	-- Finds the position of the open lang tag.
	-- -----------
	startPos := instr(oldText, startTag);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if startPos=0 then
		return oldText||startTag||dataText||endTag;
	end if;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	startPos := startPos+length(startTag)-1;
	endPos := length(oldText) - instr(oldText, endTag) + 1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return substr(oldText,1,startPos)||dataText||substr(oldText,-1*endPos,endPos);

end;
/

-- ------------------------------------------------------
-- VIEW: silkVariable
-- ------------------------------------------------------
create view silkVariable as
select
	groupName,
	tagIntValue as value,
	content as label,
	tagName as keyValue,
	position
from silkTag
where tagType=1;


-- ======================================================
-- SQL script end
-- ======================================================