<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    This work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
 --%>
 
<%@ page
	import="com.oopsclick.silk.utils.SilkSession"
	trimDirectiveWhitespaces="true"
%><%
	
	int returnValue = 0;
	String sessionOrm = "/../silk/service/orm/silkSession";

	String mode = request.getParameter("mode");
	if( mode==null ) mode="beat";
	
	String silkSessionToken = (String) session.getAttribute("silkSessionToken");
	//System.out.println( silkSessionToken );
	
	if( silkSessionToken==null){
		/*
		 * Sesssion had been disabled
		 */		
		returnValue = 1;
		
	}else if( silkSessionToken.equals("NO_SESSION") ){
		
		/*
		 * No action.
		 */
		
	}else{
		
		SilkSession silkSession = new SilkSession();
		
		if(mode.equals("disable")){
			
			/*
			 * Disables accessToken and http session
			 */
			silkSession.disableAccessTocken(silkSessionToken);
			session.setAttribute("accessToken","NO_SESSION");
			
		}else{
			
			/*
			 * Updates the lastTransactionDate
			 */
			silkSession.sessionBeat(silkSessionToken);
			
		}
	}	
	
%><%= returnValue %>