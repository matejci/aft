'use strict';

export function generate_req_headers() {
  return {
    'Session-token': $('session_token').val(),
    'X-CSRF-Token': $("meta[name='csrf-token']").attr('content'),
    'HTTP-X-APP-TOKEN': appToken,
    'APP-ID': appId
  }
}

export function messages_handler(success) {
  if (success) {
    $("#messages").addClass('alert-success').removeClass('alert-danger').html('Operation successful').show().fadeOut(4000);
  } else {
    $("#messages").addClass('alert-danger').removeClass('alert-success').html('Something went wrong').show().fadeOut(4000);
  }
}
