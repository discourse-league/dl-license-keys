import { ajax } from 'discourse/lib/ajax';

const LicenseUsers = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

var LicensesUsers = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

function getOpts() {
  const siteSettings = Discourse.__container__.lookup('site-settings:main');

  return buildOptions({
    getURL: Discourse.getURLWithCDN,
    currentUser: Discourse.__container__.lookup('current-user:main'),
    siteSettings
  });
}

LicenseUsers.reopenClass({
  findAll: function(user_id) {
    var licenseUsers = LicensesUsers.create({ content: [], loading: true });
    ajax(`/licenses/license/users/${user_id}`).then(function(licenses) {
      if (licenses){
        _.each(licenses, function(license){
            licenseUsers.pushObject(LicenseUsers.create({
            id: license.id,
            enabled: license.enabled,
            license: license.license,
            sites: license.sites,
            key: license.key
          }));
        });
      };
      licenseUsers.set('loading', false);
    });
    console.log(licenseUsers);
    return licenseUsers;
  },
  findSites: function(user_id) {
    var userSites = LicensesUsers.create({ content: [], loading: true });
    ajax(`/licenses/sites/users/${user_id}`).then(function(sites) {
      if (sites){
        _.each(sites, function(site){
            userSites.pushObject(LicenseUsers.create({
            id: site.id,
            enabled: site.enabled,
            product_name: site.product_name,
            key: site.key
          }));
        });
      };
      userSites.set('loading', false);
    });
    return userSites;
  },
});

export default LicenseUsers;