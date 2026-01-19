CKEDITOR.editorConfig = function( config ) {
	config.toolbarGroups = [
		{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
		{ name: 'paragraph', groups: [ 'align', 'list', 'indent', 'blocks', 'bidi', 'paragraph' ] },
		{ name: 'forms', groups: [ 'forms' ] },
		{ name: 'links', groups: [ 'links' ] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'styles', groups: [ 'styles' ] },
		{ name: 'colors', groups: [ 'colors' ] },
		{ name: 'tools', groups: [ 'tools' ] },
		{ name: 'others', groups: [ 'others' ] },
		{ name: 'about', groups: [ 'about' ] },
		{ name: 'document', groups: [ 'mode', 'doctools', 'document' ] }
	];
	
	config.removeButtons = 'Cut,Copy,Paste,PasteText,PasteFromWord,SelectAll,Scayt,Preview,NewPage,Templates,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,Undo,Redo,Strike,CreateDiv,BidiLtr,BidiRtl,Language,Flash,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,FontSize,Font,About,Outdent,Indent,Subscript,Superscript,Blockquote,Anchor,BGColor';
	config.removePlugins = 'elementspath';
	config.resize_enabled = false;
	config.basicEntities = false;
	config.allowedContent = true;
	
	config.disableNativeSpellChecker = false;
	config.scayt_autoStartup = false;
	
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
	config.contentsCss = url+"/ckeditor-conf/print.css?a="+date.getTime();
	
};

