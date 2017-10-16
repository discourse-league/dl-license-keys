export default {
  resource: 'admin.adminPlugins',
  path: '/plugins',
  map() {
    this.route('licenses', function(){
      this.route('products', {path: '/'});
      this.route('find');
      this.route('enabled');
      this.route('disabled');
      this.route('unused');
    });
  }
};