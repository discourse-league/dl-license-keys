import LicenseUsers from '../models/license-users';

export default Discourse.Route.extend({
  model() {
    return LicenseUsers.findAll(this.modelFor("user").id);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});