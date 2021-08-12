import { helperContext, registerUnbound } from 'discourse-common/lib/helpers';

export default registerUnbound('license-viewing-self', function(model) {
  let currentUser = helperContext().currentUser;
  if (currentUser){
    return currentUser.username.toLowerCase() === model.username.toLowerCase();  
  }
  else {
    return false;
  }
});
