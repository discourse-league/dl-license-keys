import Licenses from '../models/licenses';

export default Discourse.Route.extend({
  model(params) {
    return Licenses.findAll(params);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});