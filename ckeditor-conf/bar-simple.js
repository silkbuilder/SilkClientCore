CKEDITOR.editorConfig = function(config) {
	config.toolbar = [
		{ name: 'basicstyles', items: ['Bold', 'Italic'] },
		{ name: 'paragraph', items: ['NumberedList', 'BulletedList', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
		{ name: 'tools', items: ['Maximize'] }
	];
	config.removePlugins = 'elementspath';
	config.resize_enabled = false;
	
	var url = document.URL;
	var pos = -1;
	pos = url.indexOf("/service/");
	if( pos > -1 ){
		url = url.substring(0,pos);
	}else{
		pos = url.indexOf("/link/");
		if( pos > -1 ){
			url = url.substring(0,pos);
		}else{
			url = "";
		}
	}

	var date = new Date()
	config.contentsCss = url+"/ckeditor-conf/edit.css?a="+date.getTime();
	
};

