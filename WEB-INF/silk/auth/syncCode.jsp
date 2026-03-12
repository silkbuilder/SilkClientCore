<%@page contentType="application/json;charset=UTF-8"%>
<%@ page import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.FileTool,
		com.oopsclick.silk.utils.Http,
		com.oopsclick.silk.utils.Tool64,
		com.oopsclick.silk.utils.JsonQuery,
		com.oopsclick.silk.utils.SilkPath,
		java.util.ArrayList,
		java.util.List,
		java.util.Map,
		java.io.*
	"
%>
<%

	/*
	 * Check Authentication token
	 */
	String authenticationToken = Http.getRequestBearerToken(request);
	if( authenticationToken==null ){
		response.sendError(401);
		out.println("{\"result\":0, \"code\":401, \"message\":\"Unauthorized\"}");
		return;
	}

	/*
	 * Define the system's workspace path
	 */
	String realPath = SilkPath.getRealPath(request);
	String silkPath = realPath + "WEB-INF/workspace/";
	
	/*
	 * Load sync token
	 */
	String syncToken = FileTool.readFile(realPath+"/WEB-INF/sync.token");
	if( syncToken.equals("")){
		response.sendError(401);
		out.println("{\"result\":0, \"code\":401, \"message\":\"Sync Token not found.\"}");
		return;
	}

	/*
	 * Compare provided token with system token
	 */
	String result="Unauthorized";
	if( authenticationToken.equals(syncToken) ){
		result="Authenticated";
	}else{
		response.sendError(401);
		out.println("{\"result\":0, \"code\":401, \"message\":\"Unauthorized\"}");
		return;
	}

	/*
	 * Get code from service body and decode base64
	 */
	String code = Http.getRequestBody(request);
	code = Tool64.base64toString(code);
	//System.out.println(body);
    
	/*
	 * Load code into a JsonQuery object
	 */
	JsonQuery jq = new JsonQuery(code);

	/*
	 * Define clean status
	 */
	boolean clean = jq.getBoolean("$.system.clean");

	/* ==========================================================
	 * System
	 */
	if( clean ){
		
		String menuLink = jq.getString("$.system.menuLink");
		String loginLink = jq.getString("$.system.loginLink");
		int pos = 0;
		String container = "";
		
		/*
		 * Set menuLink
		 */
		if( !menuLink.isEmpty() ){
			container = menuLink.substring(1);
			pos = container.indexOf("/");
			container = container.substring(0,pos);
			container = FileTool.readFile(silkPath+container+".conf");
			menuLink = "WEB-INF/workspace/"+container+menuLink.substring(pos+1,menuLink.length());
		}
		
		/*
		 * Set loginLink
		 */
		if( !loginLink.isEmpty() ){
			container = loginLink.substring(1);
			pos = container.indexOf("/");
			container = container.substring(0,pos);
			container = FileTool.readFile(silkPath+container+".conf");
			loginLink = "WEB-INF/workspace/"+container+loginLink.substring(pos+1,loginLink.length());
		}
		
		/*
		 * Replace menuLink and/or loginLik into index.jsp
		 */
		String indexCode = "";
		String[] lines = FileTool.readFile(realPath+"index.jsp").split("\n");
		for( String line : lines ){
			if( line.contains("String menuLink") && !menuLink.isEmpty() ){
				line = "\tString menuLink = \""+menuLink+"\";";
			}
			if( line.contains("String loginLink") && !loginLink.isEmpty() ){
				line = "\tString loginLink = \""+loginLink+"\";";
			}
			indexCode += line+"\n";
		}
		FileTool.writeFile(realPath,"index.jsp",indexCode);
		
	}
	
	/* ----------------------------------------------------------
	 * Theme
	 */
	if( clean ){
		String themePath = realPath+"silk/theme/";
		List<String> themeList = jq.getList("$.themeList");
		for (Object item : themeList) {
			Map<String,String> map = (Map<String,String>) item;
			
			String itemPath = map.get("path");
			String content = map.get("content");
			
			FileTool.writeFile(themePath, itemPath, content);
		}
	}
	
	/* ----------------------------------------------------------
	 * Container List
	 */
	List<String> containerList = jq.getList("$.containerList");
	for (Object item : containerList) {

		Map<String,String> map = (Map<String,String>) item;

		String containerID = map.get("containerID");
		String containerName = map.get("containerName");
		String cleanContainer = map.get("clean");

		if( cleanContainer.equals("1") ){
			FileTool.createCleanFolder(silkPath, containerID);
		}else{
			FileTool.createFolder(silkPath+containerID);
		}

		FileTool.writeFile(silkPath, containerName+".conf", containerID );
	}

	/* ----------------------------------------------------------
	 * Code List
	 */
	List<String> codeList = jq.getList("$.codeList");
	for (Object item : codeList) {
		
		Map<String,String> map = (Map<String,String>) item;
	
		// Print all elements of List
		String filePath = map.get("filePath");
		String fileName = map.get("fileName");
		String fileContent = map.get("fileContent");

		FileTool.writeFile(silkPath+filePath,fileName,fileContent);
        
	}
	
	/* ----------------------------------------------------------
	 * Tag List
	 */
	DataProvider tagDP = new DataProvider("/../silk/service/orm/silkTag", session);

	if( clean ){
		tagDP.exec("cleanTags");
	}
	
	tagDP.select("tagList");
	
	int count = 0;
	tagDP.cleanOperation();
	
	List<String> tagList = jq.getList("$.tagList");
	for (Object item : tagList) {
		
		Map<String,Object> map = (Map<String,Object>) item;

		String groupName = (String) map.get("groupName");
		String tagName = (String) map.get("tagName");
		int tagType = (Integer) map.get("tagType");
		int tagIntValue = (Integer) map.get("tagIntValue");
		String content = (String) map.get("content");
		int position = (Integer) map.get("position");

		String tagUnique = tagType+tagName;
		if( tagType==1  ) tagUnique = groupName+tagIntValue;
			
		String silkTagID  = (String) tagDP.findItem("tagUnique", tagUnique, "silkTagID");
		
		if( silkTagID==null ){
			tagDP.setOperationAction(count,"insert");
			tagDP.setOperationItem(count, "groupName", groupName);
			tagDP.setOperationItem(count, "tagName", tagName);
			tagDP.setOperationItem(count, "tagType", tagType);
			tagDP.setOperationItem(count, "tagIntValue", tagIntValue);
			tagDP.setOperationItem(count, "content", content);
			tagDP.setOperationItem(count, "position", position);
		}else{
			tagDP.setOperationAction(count,"update");
			tagDP.setOperationItem(count, "silkTagID", silkTagID);
			tagDP.setOperationItem(count, "groupName", groupName);
			tagDP.setOperationItem(count, "tagName", tagName);
			tagDP.setOperationItem(count, "tagType", tagType);
			tagDP.setOperationItem(count, "tagIntValue", tagIntValue);
			tagDP.setOperationItem(count, "content", content);
			tagDP.setOperationItem(count, "position", position);
		}
		count++;
	}
	tagDP.batch();
	
	/* ----------------------------------------------------------
	 * Language
	 */
	DataProvider langDP = new DataProvider("/../silk/service/orm/silkLang", session);
	
	if( clean ){
		langDP.exec("cleanLang");
	}
	
	langDP.select("systemLang");
	
	count = 0;
	langDP.cleanOperation();
	
	List<String> langList = jq.getList("$.langList");
	for (Object item : langList) {
		
		Map<String,Object> map = (Map<String,Object>) item;

		String langID = (String) map.get("langID");
		String langName = (String) map.get("langName");
		String enName = (String) map.get("enName");

		String silkLangID  = (String) langDP.findItem("langID", langID, "silkLangID");

		if( silkLangID==null ){
			langDP.setOperationAction(count,"insert");
			langDP.setOperationItem(count, "langID", langID);
			langDP.setOperationItem(count, "langName", langName);
			langDP.setOperationItem(count, "enName", enName);
		}else{
			langDP.setOperationAction(count,"update");
			langDP.setOperationItem(count, "silkLangID", silkLangID);
			langDP.setOperationItem(count, "langID", langID);
			langDP.setOperationItem(count, "langName", langName);
			langDP.setOperationItem(count, "enName", enName);
		}
		count++;
	}
	langDP.batch();

	/* ----------------------------------------------------------
	 * Email Tamplates
	 * Verifies it is pro version
	 */
	File file = new File(realPath+"WEB-INF/silk/SilkBuilderIDE/silkDeveloper.orm");
	if( file.exists() ){
		DataProvider mailDP = new DataProvider("/../silk/service/orm/silkEmail", session);
	
		if( clean ){
			mailDP.exec("cleanTemplate");
		}
	
		mailDP.select("templateList");
	
		count = 0;
		mailDP.cleanOperation();
		
		List<String> emailList = jq.getList("$.emailList");
		for (Object item : emailList) {
			
			Map<String,Object> map = (Map<String,Object>) item;
	
			String emailUUID = (String) map.get("emailUUID");
			String langID = (String) map.get("langID");
			String wrapper = (String) map.get("wrapper");
			String sentFrom = (String) map.get("sentFrom");
			String replyTo = (String) map.get("replyTo");
			String copyTo = (String) map.get("copyTo");
			String blindTo = (String) map.get("blindTo");
			String subject = (String) map.get("subject");
			String message = (String) map.get("message");
	
			String silkEmailID  = (String) mailDP.findItem("searchID", emailUUID+langID, "silkEmailID");
	
			if( silkEmailID==null ){
				mailDP.setOperationAction(count,"insert");
			}else{
				mailDP.setOperationAction(count,"update");
				mailDP.setOperationItem(count, "silkEmailID", silkEmailID);
			}
	
			mailDP.setOperationItem(count, "emailUUID", emailUUID);
			mailDP.setOperationItem(count, "langID", langID);
			mailDP.setOperationItem(count, "wrapper", wrapper);
			mailDP.setOperationItem(count, "sentFrom", sentFrom);
			mailDP.setOperationItem(count, "replyTo", replyTo);
			mailDP.setOperationItem(count, "copyTo", copyTo);
			mailDP.setOperationItem(count, "blindTo", blindTo);
			mailDP.setOperationItem(count, "subject", subject);
			mailDP.setOperationItem(count, "message", message);
				
			count++;
		}
		mailDP.batch();
	}
			
	/* ---------------------------------------------------------- */
	result = "Completed";
	
%>
{
    "result" : 1,
	"code" : 200,
	"message" : <%= result %>
}
