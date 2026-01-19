<%@ 
	page import="
		com.oopsclick.silk.dbo.DataProviderService,
		com.oopsclick.silk.utils.Tools,
		java.io.*,
		java.util.HashMap,
		org.json.simple.JSONObject"
 %><%
 
	response.setCharacterEncoding("UTF-8");
	response.setContentType("application/json");
 
	/*
	 * Checking if service supports direct calls
	 */
	String origin = (String) request.getHeader("origin");
	String directCalls = (String) request.getParameter("directCalls");
	if( directCalls==null ) directCalls="0";
	if( directCalls.equals("0") ){
		if( origin==null ){
			out.println("[]");
			return;
		}
	}
	
	/*
	 * Get only data if directCall is on, directCallData is off, and origing is null.
	 */
	boolean onlyData = false;
	String directCallData = (String) request.getParameter("directCallData");
	if( directCallData==null ) directCallData="0";
	if( origin==null ){
		if( directCalls.equals("1") && directCallData.equals("0") ) onlyData=true;
	}
	
	/*
	 * Request data
	 */
	DataProviderService dpService = new DataProviderService();
	String jsonReturn = "";
	try{
		
		/*
		 * Sending Request to Data Provider Service
		 */
		jsonReturn = dpService.getResponseObject(request).getJSONString(false, onlyData);
		
	}catch(Exception e){

		/*
		 * Gets information on the ORM error
		 */
		String ormPath = (String) request.getParameter("ormPath");
		if( ormPath==null ) ormPath="orm unknow";
		
		HashMap<String,Object> objMap = new HashMap<String,Object>();
		objMap.put("error", true);

		boolean devSession = (boolean) Tools.getSessionAttribute(session, "devSession", false);

		StringWriter sw = new StringWriter();
		e.printStackTrace(new PrintWriter(sw));
		String stackTrace = sw.toString();
		
		/*
		 * Report the error
		 */
		if( devSession ){
			objMap.put("stackTrace", "Silk error: "+ormPath+"\n"+stackTrace);
			System.out.println("Silk error: Error while contacting ORM service. "+ormPath+"\n"+stackTrace);
		}else{
			objMap.put("stackTrace", "Silk error: Error while contacting server. "+ormPath);
		}
		
		JSONObject jsonObject = new JSONObject(objMap);
		jsonReturn = jsonObject.toJSONString();

		System.out.println(stackTrace);
	
	}
	out.println( jsonReturn );
%>