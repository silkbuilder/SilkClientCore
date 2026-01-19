CKEDITOR.editorConfig = function(config) {
	config.toolbar = [
		{ name: 'document', items: ['Print'] }
	];

	config.removePlugins = 'elementspath';
	config.resize_enabled = true;
	config.readOnly = true;
	config.basicEntities = false;
	config.allowedContent = true;

	config.disableNativeSpellChecker = false;
	config.scayt_autoStartup = false;

	var url = document.URL;
	var pos = -1;
	pos = url.indexOf("/service/");
	if (pos > -1) {
		url = url.substring(0, pos);
	} else {
		pos = url.indexOf("/link/");
		if (pos > -1) {
			url = url.substring(0, pos);
		} else {
			url = "";
		}
	}

	var date = new Date()
	config.contentsCss = url + "/ckeditor-conf/print.css?a=" + date.getTime();

};

//https://ckeditor.com/latest/samples/toolbarconfigurator/index.html
