'use strict';

$(document).ready(function() {
  $('body').on('click', '#submit-arrow', submitFormHandler);
  $('body').on('keypress', '#email', handleEnterKey);
});

function handleEnterKey(e) {
   if (e.which == 13) {
    submitFormHandler();
   }
}


function submitFormHandler(e) {
  fbq('trackCustom', 'USER_SUBSCRIBED', { email: $("#email").val(), campaign_name: $("#campaign_name").val() });
  let form = $('form')[0];

  if (form.requestSubmit) {
    form.requestSubmit();
  } else {
    form.dispatchEvent(new Event('submit', { bubbles: true }));
  }
}
