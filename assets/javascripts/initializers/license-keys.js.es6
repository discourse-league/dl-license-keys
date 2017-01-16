import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeLicenseKeys(api) {
}

export default {
  name: "apply-license-keys",

  initialize() {
    withPluginApi('0.5', initializeLicenseKeys);
  }
};