export default {
  resource: 'admin.adminPlugins.licenses',
  path: '/licenses',
  map() {
  	this.route('products', {path: '/'});
  	this.route('find');
  	this.route('enabled');
  	this.route('disabled');
  	this.route('unused');
  }
};