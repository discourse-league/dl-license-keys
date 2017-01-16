import LicensesProduct from '../models/licenses-product';
import Group from 'discourse/models/group';

export default Ember.Controller.extend({

  baseProduct: function() {
    var a = [];
    a.set('product_name', I18n.t('admin.license_keys.products.new_name'));
    a.set('enabled', false);
    return a;
  }.property('model.@each.id'),

  removeSelected: function() {
    this.get('model').removeObject(this.get('selectedItem'));
    this.set('selectedItem', null);
  },

  changed: function(){
    if (!this.get('originals') || !this.get('selectedItem')) {this.set('disableSave', true); return;}
    if (((this.get('originals').product_name == this.get('selectedItem').product_name) &&
      (this.get('originals').group_id == this.get('selectedItem').group_id)) ||
      (!this.get('selectedItem').group_id) ||
      (!this.get('selectedItem').product_name)
      ) {
        this.set('disableSave', true); 
        return;
      }
      else{
        this.set('disableSave', false);
      }
  }.observes('selectedItem.product_name', 'selectedItem.group_id'),

  actions: {
    selectProduct: function(licensesProduct) {
      LicensesProduct.customGroups().then(g => {
        this.set('customGroups', g);
        if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); };
        this.set('originals', {
          product_name: licensesProduct.product_name,
          enabled: licensesProduct.enabled,
          group_id: licensesProduct.group_id
        });
        this.set('disableSave', true);
        this.set('selectedItem', licensesProduct);
        licensesProduct.set('savingStatus', null);
        licensesProduct.set('selected', true);
      });
    },

    newProduct: function() {
      const newProduct = Em.copy(this.get('baseProduct'), true);
      newProduct.set('product_name', I18n.t('admin.license_keys.products.new_name'));
      newProduct.set('newRecord', true);
      this.get('model').pushObject(newProduct);
      this.send('selectProduct', newProduct);
    },

    toggleEnabled: function() {
      var selectedItem = this.get('selectedItem');
      selectedItem.toggleProperty('enabled');
      LicensesProduct.save(this.get('selectedItem'), true);
    },

    disableEnable: function() {
      return !this.get('id') || this.get('saving');
    }.property('id', 'saving'),

    newRecord: function() {
      return (!this.get('id'));
    }.property('id'),

    save: function() {
      LicensesProduct.save(this.get('selectedItem'));
      this.send('selectProduct', this.get('selectedItem'));
    },

    copy: function(licensesProduct) {
      var newProduct = LicensesProduct.copy(licensesProduct);
      newProduct.set('product_name', I18n.t('admin.customize.colors.copy_name_prefix') + ' ' + licensesProduct.get('product_name'));
      this.get('model').pushObject(newProduct);
      this.send('selectProduct', newProduct);
    },

    destroy: function() {
      var self = this,
          item = self.get('selectedItem');

      return bootbox.confirm(I18n.t("admin.license_keys.products.delete_confirm"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          if (item.get('newRecord')) {
            self.removeSelected();
          } else {
            LicensesProduct.destroy(self.get('selectedItem')).then(function(){ self.removeSelected(); });
          }
        }
      });
    }
  }
});