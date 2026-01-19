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
	silkLangID int primary key auto_increment,
	langID char(2),
	langName varchar(50),
	enName varchar(50),
	status tinyint default 0
);

-- ------------------------------------------------------
-- TABLE: silkSession
-- ------------------------------------------------------
create table silkSession (
	silkSessionID int primary key auto_increment,
	silkAccessID int,
	silkUserID int,
	ipAddress varchar(50),
	httpSession varchar(255),
	sessionToken varchar(500),
	sessionType tinyint default 0,
	sessionDate timestamp,
	lastTransactionDate timestamp,
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
	silkAccessID int primary key auto_increment,
	silkDeviceID int,
	accessToken varchar(500),
	silkUserID int,
	securePIN varchar(10),
	creationDate timestamp default CURRENT_TIMESTAMP,
	lastAccess timestamp,
	status tinyint default 0
);

create index silkAccess_silkDeviceID on silkAccess(silkDeviceID);
create index silkAccess_accessToken on silkAccess(accessToken);
create index silkAccess_silkUserID on silkAccess(silkUserID);

-- ------------------------------------------------------
-- TABLE: silkDevice
-- ------------------------------------------------------
create table silkDevice (
	silkDeviceID int primary key auto_increment,
	deviceToken varchar(255),
	creationDate timestamp default CURRENT_TIMESTAMP,
	lastAccess timestamp,
	agent varchar(255),
	status tinyint default 0
);

create index silkDevice_deviceToken on silkDevice(deviceToken);

-- ------------------------------------------------------
-- TABLE: silkTag
-- ------------------------------------------------------
create table silkTag (
	silkTagID int primary key auto_increment,
	groupName varchar(50),
	tagName varchar(50),
	tagType tinyint default 0,
	tagIntValue tinyint,
	content text,
	position tinyint default 0
);

create index silkTag_groupName on silkTag(groupName);
create index silkTag_tagName on silkTag(tagName);

-- ------------------------------------------------------
-- TABLE: silkLog
-- ------------------------------------------------------
create table silkLog (
	silkLogID int primary key auto_increment,
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
DELIMITER //
CREATE FUNCTION readLanguage(dataText text,lang VARCHAR(10))
RETURNS text DETERMINISTIC
BEGIN
	Declare startTag VARCHAR(20);
	Declare endTag VARCHAR(20);
	Declare startPos INT;
	Declare endPos INT;

	--
	-- If dataText is empty returns
	--
	if Length(dataText)=0 then
		return '';
	end if;

	--
	-- If dataText does not have lang tag it returns the existing text
	--
	if instr(dataText,'<lang-')=0 then
		return dataText;
	end if;

	-- 
	-- Creates received lang tag
	--
	set startTag = concat('<lang-',lang,'>');
	set endTag = concat('</lang-',lang,'>');

	--
	-- Search tag in dataText
	--
	set startPos = instr(dataText,startTag);
	
	if startPos=0 then
		--
		-- If lang does not exist search for english as base language
		--
		set startTag = '<lang-en>';
		set endTag = '</lang-en>';

		--
		-- Search tag in dataText
		--
		set startPos = instr(dataText,startTag);
	end if;

	if startPos=0 then
		--
		-- If lang does not exist search for any existing language
		--
		set startPos = instr(dataText,'<lang-');
		
		if startPos=0 then
			Return '';
		end if;
		
		set lang = substring(dataText,startPos+6,2);
		set startTag = concat('<lang-',lang,'>');
		set endTag = concat('</lang-',lang,'>');
		
	end if;	

	set startPos = startPos+Length(startTag);
	set endPos = instr(dataText,endTag)-startPos;

	return substring(dataText,startPos,endPos);
	
end//
DELIMITER ;

-- ------------------------------------------------------
-- PROGRAM: writeLanguage
-- ------------------------------------------------------
DELIMITER //
CREATE FUNCTION writeLanguage(oldText text, dataText text,lang VARCHAR(10))
RETURNS text DETERMINISTIC
BEGIN
	Declare startTag VARCHAR(20);
	Declare endTag VARCHAR(20);
	Declare startPos INT;
	Declare endPos INT;

	-- -----------
	-- If old text is null it is set to empty.
	-- -----------
	set oldText = coalesce(oldText,'');
	
	-- -----------
	-- Initializes the tag limits.
	-- -----------
	set startTag = concat('<lang-',lang,'>');
	set endTag = concat('</lang-',lang,'>');

	-- -----------
	-- Finds the position of the open lang tag.
	-- -----------
	set startPos = instr(startTag,oldText);

	-- -----------
	-- If open lang tag does not exist the new languate is added to the end and returns.
	-- -----------
	if startPos=0 then
		return concat(oldText,startTag,dataText,endTag);
	end if;

	-- -----------
	-- Find the position of the close lang tag.
	-- -----------
	set startPos = startPos+char_length(startTag)-1;
	set endPos = char_length(oldText) - instr(oldText,endTag)+1;

	-- -----------
	-- Replaces the existing lang text with the new one.
	-- -----------
	Return concat(left(oldText,startPos),dataText,right(oldText,endPos));

END//
DELIMITER ;

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