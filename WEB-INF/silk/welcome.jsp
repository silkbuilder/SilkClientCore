<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<silk:App title="Index App" timeout="false" >

	<style>
		#centeredBox {
			width: 100%;
			position: absolute;
			top: 25%;
		}		
	</style>
	
	<div id="centeredBox" >
		<div class="text-center" >
			<h3 id="hostName" class="text-center" >SilkClient</h3>
			<p>&nbsp;</p>
			<h5>Expecting code synchronization.</h5>
			<p>&nbsp;</p>
			<p><i class="fa-solid fa-face-smile-wink fa-2xl" style="color:orange;"></i></p>
			<p>&nbsp;</p>
		</div>
	</div>

	<silk:JQcode>
		$("#hostName").html("SilkClient @ "+window.location.hostname);
	</silk:JQcode>

</silk:App>
