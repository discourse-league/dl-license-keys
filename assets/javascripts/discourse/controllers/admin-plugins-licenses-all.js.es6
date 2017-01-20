import Licenses from '../models/licenses';

export default Ember.Controller.extend({
  queryParams: ['order', 'desc'],

  actions: {

    toggleEnabled: function(license) {
      license.toggleProperty('enabled');
      Licenses.save(license, true);
    }
  }
});