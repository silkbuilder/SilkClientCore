<!-- MAIN INDEX -->
<!--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    This work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
 -->
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Enumeration" %>
<%

	// DO NOT MODIFY THIS FILE
	// IT WILL BE RELOADED ON UPDATES

	String silkSessionToken = (String) session.getAttribute("silkSessionToken");
	String contextPath = (String) session.getAttribute("contextPath");
	String requestURL = (String) session.getAttribute("_requestURL");
	String redirect = (String) session.getAttribute("_redirect");

	Enumeration<String> attributes = session.getAttributeNames();
	while (attributes.hasMoreElements()) {
		String attribute = attributes.nextElement();
		if( attribute.substring(0, 1).equals("^") ){
			request.setAttribute(attribute.substring(1), ""+request.getSession().getAttribute(attribute));
		}
	}
	
	String menuLink = "";
	String loginLink = "WEB-INF/silk/welcome.jsp";

	if( silkSessionToken!=null ){
		if( redirect==null ){
			request.setAttribute("silkTarget","service"); %>
			<jsp:include page="<%= menuLink %>" />
<%		}else{
			session.setAttribute("_redirect",null);
			response.sendRedirect(requestURL);
		}
	}else{
		request.setAttribute("silkTarget","link"); %>
		<jsp:include page="<%= loginLink %>" />
<%	} %>
