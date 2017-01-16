import LicensesProduct from '../models/licenses-product';

export default Discourse.Route.extend({
  model() {
    return LicensesProduct.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});