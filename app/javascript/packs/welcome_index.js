'use strict';

$(document).ready(function() {
  $('body').on('click', '.aft_join_waiting_list', joinListBtnHandler);
  $('body').on('keypress', '#subscriber_email', handleEnterKey);
  $('body').on('click', '.subscription_arrow', submitFormHandler);
  $('body').on('click', '.next_btn', submitFormHandler);
  $('body').on('click', '.next_btn_2', submitFormHandler);
  $('body').on('keypress', '#subscriber_last_name', handleEnterKey);
  $('body').on('click', '.copy_icon', copyToClipboard);
});

function copyToClipboard(e) {
   navigator.clipboard.writeText($('#share').val());
}

function handleEnterKey(e) {
   if (e.which == 13) {
    submitFormHandler();
   }
}

function joinListBtnHandler(e) {
  e.preventDefault();
  $('#subscriber_email').fadeTo(100, 0.1).fadeTo(200, 1.0).focus();
}

function submitFormHandler(e) {
  // e.currentTarget.classList[0]

  var form = $('form')[0];

  if (form.requestSubmit) {
    form.requestSubmit();
  } else {
    form.submit();
  }
}

