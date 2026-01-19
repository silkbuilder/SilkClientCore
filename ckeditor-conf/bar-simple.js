CKEDITOR.editorConfig = function(config) {
	config.toolbar = [
		{ name: 'basicstyles', items: ['Bold', 'Italic'] },
		{ name: 'paragraph', items: ['NumberedList', 'BulletedList', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
		{ name: 'tools', items: ['Maximize'] }
	];
	config.removePlugins = 'elementspath';
	config.resize_enabled = false;
};

