import Licenses from '../models/licenses';

export default Ember.Controller.extend({
  queryParams: ['q'],

  actions: {

    toggleEnabled: function(license) {
      license.toggleProperty('enabled');
      Licenses.save(license, true);
    },

    newSearch: function(params){
    	window.location.href = "/admin/plugins/licenses/find?q=" + params;
    }
  }
});