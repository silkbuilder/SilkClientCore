CKEDITOR.editorConfig = function( config ) {
	config.toolbar = [
		{ name: 'document', items: [ 'Source', '-', 'Preview', 'Print', '-', 'Templates' ] },
		{ name: 'clipboard', items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
		{ name: 'editing', items: [ 'Find', 'Replace', '-', 'SelectAll' ] },
		'/',
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'CopyFormatting', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl', 'Language' ] },
		{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
		{ name: 'insert', items: [ 'Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak'] },
		'/',
		{ name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'tools', items: [ 'Maximize', 'ShowBlocks' ] }
	];

	config.removePlugins = 'elementspath';
	config.resize_enabled = false;
	config.basicEntities = false;
	config.allowedContent = true;
	
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

//https://ckeditor.com/latest/samples/toolbarconfigurator/index.html
