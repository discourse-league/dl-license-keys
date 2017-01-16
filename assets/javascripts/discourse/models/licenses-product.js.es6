import { ajax } from 'discourse/lib/ajax';
import Group from 'discourse/models/group';

const LicensesProduct = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

function getOpts() {
  const siteSettings = Discourse.__container__.lookup('site-settings:main');

  return buildOptions({
    getURL: Discourse.getURLWithCDN,
    currentUser: Discourse.__container__.lookup('current-user:main'),
    siteSettings
  });
}


var LicensesProducts = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

LicensesProduct.reopenClass({

  customGroups: function(){
    return Group.findAll().then(groups => {
      return groups.filter(g => !g.get('automatic'));
    });
  },

  findAll: function() {
    var licensesProducts = LicensesProducts.create({ content: [], loading: true });
    ajax('/licenses/products').then(function(products) {
      if (products){
        _.each(products, function(licensesProduct){
            licensesProducts.pushObject(LicensesProduct.create({
            id: licensesProduct.id,
            product_name: licensesProduct.product_name,
            enabled: licensesProduct.enabled,
            group_id: licensesProduct.group_id
          }));
        });
      };
      licensesProducts.set('loading', false);
    });
    return licensesProducts;
  },

  save: function(object, enabledOnly=false) {
    if (object.get('disableSave')) return;
    
    object.set('savingStatus', I18n.t('saving'));
    object.set('saving',true);

    var data = { enabled: object.enabled };

    if (object.id){
      data.id = object.id;
    }

    if (!object || !enabledOnly) {
      data.product_name = object.product_name;
      data.group_id = object.group_id;
    };
    
    return ajax("/licenses/products.json", {
      data: JSON.stringify({"product": data}),
      type: object.id ? 'PUT' : 'POST',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result) {
      if(result.id) { object.set('id', result.id); }
      object.set('savingStatus', I18n.t('saved'));
      object.set('saving', false);
    });
  },

  copy: function(object){
    var copiedProduct = LicensesProduct.create(object);
    copiedProduct.id = null;
    return copiedProduct;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/licenses/products.json", { 
        data: JSON.stringify({"product": data }), 
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default LicensesProduct;