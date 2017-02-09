import { ajax } from 'discourse/lib/ajax';

const Licenses = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

var LicenseItems = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

Licenses.reopenClass({
  findAll: function(params) {
    var licenseItems = LicenseItems.create({ content: [], loading: true, query: params.q });
    ajax("/licenses/license/users/all", {
      data: { q: params.q } ,
      type: 'GET',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(licenses) {
      if (licenses){
        _.each(licenses, function(license){
            licenseItems.pushObject(Licenses.create({
            id: license.id,
            user: license.user,
            enabled: license.enabled,
            license: license.license,
            sites: license.sites,
            key: license.key,
            created_at: license.created_at
          }));
        });
      };
      licenseItems.set('loading', false);
    });
    return licenseItems;
  },

  save: function(license){
    return ajax("/licenses/license/users/all", {
      data: JSON.stringify({"license_user": license}),
      type: 'PUT',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result) {
      if(result.id) { license.set('id', result.id); }
      license.set('enabled', result.enabled);
      license.set('savingStatus', I18n.t('saved'));
      license.set('saving', false);
    });
  }
});

export default Licenses;