import LicenseUsers from '../models/license-users';

export default Discourse.Route.extend({
  model() {
    return LicenseUsers.findAll(this.modelFor("user").id);
  },

  setupController(controller, model) {
  	if (this.currentUser.id !== this.modelFor("user").id){
  		this.replaceWith('userActivity');
  	}
  	else{
	    controller.setProperties({ model });
	};
  }
});