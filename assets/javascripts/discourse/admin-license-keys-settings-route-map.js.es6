export default {
  resource: 'admin.adminPlugins.licenses',
  path: '/licenses',
  map() {
  	this.route('index', {path: '/'});
  	this.route('enabled');
  	this.route('disabled');
  	this.route('unused');
  }
};