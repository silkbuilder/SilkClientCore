<%@ page import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.SilkPath
	"
%><%
	
	/*
	 * Loading Device Token
	 */
	String accessToken = request.getHeader("accessToken");
	String sessionToken = (String) session.getAttribute("sessionToken");
	
	if( accessToken!=null ){
		/*
		 * Validating Device Token
		 */
		DataProvider accessDP = new DataProvider("/../silk/service/orm/silkAccess");
		accessDP.setParameter("accessToken", accessToken );
		accessDP.exec("logout");
	}
	
	if( sessionToken!=null ){
		/*
		 * Logout session Token
		 */
		DataProvider sessionDP = new DataProvider("/../silk/service/orm/silkSession");
		sessionDP.setParameter("sessionToken", sessionToken);
		sessionDP.exec("disableToken");
	}
	
	/*
	 * Clear session
	 */
	try {
	    session.invalidate();
	}catch(Exception e){}
	
	/*
	 * Redirect to context path
	 */
	String contextPath = SilkPath.getContextPath(request);

	if( contextPath==null ) contextPath="/";
	response.sendRedirect(contextPath);
	
%>