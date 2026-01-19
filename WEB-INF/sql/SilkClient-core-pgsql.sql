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
	silkLangID int primary key generated always as identity,
	langID char(2),
	langName varchar(50),
	enName varchar(50),
	status smallint default 0
);

-- ------------------------------------------------------
-- TABLE: silkSession
-- ------------------------------------------------------
create table silkSession (
	silkSessionID int primary key generated always as identity,
	silkAccessID int,
	silkUserID int,
	ipAddress varchar(50),
	httpSession varchar(255),
	sessionToken varchar(500),
	sessionType smallint default 0,
	sessionDate timestamp,
	lastTransactionDate timestamp,
	deviceType varchar(20),
	userAgent varchar(255),
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
	silkAccessID int primary key generated always as identity,
	silkDeviceID int,
	accessToken varchar(500),
	silkUserID int,
	securePIN varchar(10),
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
	silkDeviceID int primary key generated always as identity,
	deviceToken varchar(255),
	creationDate timestamp default CURRENT_TIMESTAMP,
	lastAccess timestamp,
	agent varchar(255),
	status smallint default 0
);

create index silkDevice_deviceToken on silkDevice(deviceToken);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int primary key generated always as identity,
	groupName varchar(50),
	tagName varchar(50),
	tagType smallint default 0,
	tagIntValue smallint,
	content text,
	position smallint default 0
);

create index silkTag_groupName on silkTag(groupName);
create index silkTag_tagName on silkTag(tagName);

-- ------------------------------------------------------
-- TABLE: silkLog
-- ------------------------------------------------------
create table silkLog (
	silkLogID int primary key generated always as identity,
	tableName varchar(100),
	pkValue int,
	status smallint,
	operationAction varchar(50),
	operationDate timestamp,
	operationUser int 
);

create index silkLog_tableName on silkLog(tableName);
create index silkLog_pkValue on silkLog(pkValue);

-- ------------------------------------------------------
-- PROGRAM: readLanguage
-- ------------------------------------------------------
create or replace function readLanguage(dataText text, lang char(2))
   returns text
   language plpgsql
  as
$$
declare
	startTag varchar(20);
	endTag varchar(20);
	startPos smallint;
	endPos smallint;
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
	if position('<lang-' in dataText)=0 then
		return dataText;
	end if;

	-- 
	-- Creates received lang tag
	--
	startTag = concat('<lang-',lang,'>');
	endTag = concat('</lang-',lang,'>');

	--
	-- Search tag in dataText
	--
	startPos = position(startTag in dataText);
	
	if startPos=0 then
		--
		-- If lang does not exist search for english as base language
		--
		startTag = '<lang-en>';
		endTag = '</lang-en>';

		--
		-- Search tag in dataText
		--
		startPos = position(startTag in dataText);
	end if;

	if startPos=0 then
		--
		-- If lang does not exist search for any existing language
		--
		startPos = position('<lang-' in dataText);
		
		if startPos=0 then
			return '';
		end if;
		
		lang = substring(dataText,startPos+6,2);
		startTag = concat('<lang-',lang,'>');
		endTag = concat('</lang-',lang,'>');
		
	end if;	

	startPos = startPos+length(startTag);
	endPos = position(endTag in dataText)-startPos;
	
	return substring(dataText,startPos,endPos);
end;
$$;

-- ------------------------------------------------------
-- PROGRAM: writeLanguage
-- ------------------------------------------------------
create or replace function writeLanguage(oldText text, dataText text, lang char(2))
   returns text
   language plpgsql
  as
$$
declare
	startTag varchar(20);
	endTag varchar(20);
	startPos smallint;
	endPos smallint;
begin

	-- -----------
	-- If old text is null it is set to empty.
	-- -----------
	oldText = coalesce(oldText,'');
	
	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if position('<lang-' in oldText)=0 then
		return oldText;
	end if;

	-- -----------
	-- Initializes the tag limits.
	-- -----------
	startTag = concat('<lang-',lang,'>');
	endTag = concat('</lang-',lang,'>');

	-- -----------
	-- Finds the position of the open lang tag.
	-- -----------
	startPos = position(startTag in oldText);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if startPos=0 then
		return concat(oldText,startTag,dataText,endTag);
	end if;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	startPos = startPos+length(startTag)-1;
	endPos = length(oldText) - position(endTag in oldText)+1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	return concat(left(oldText,startPos),dataText,right(oldText,endPos));

end;
$$;

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