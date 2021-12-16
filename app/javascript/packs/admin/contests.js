'use strict';

import { generate_req_headers, messages_handler } from '../utils.js';

$(document).ready(function() {
  $('body').on('click', '.remove_btn', cancelBtnHandler);
  $('body').on('click', '.close_btn', closeModal);
  $('body').on('click', '.save_btn', updateContestHandler);
  $('body').on('click', '.new_btn', newContestHandler);
  $('body').on('click', '.create_contest_btn', createContestHandler);
});


function cancelBtnHandler(e) {
  $('#contests-modal').modal('show');
}

function closeModal(e) {
  $('.modal').modal('hide');
}

function updateContestHandler(e) {

  $(".loader").show();

  $.ajax({
    url: $("#update_url").val(),
    type: 'PATCH',
    dataType: 'script',
    data: { username: $("#username").val() },
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      $(".loader").hide();
      closeModal();
      window.location.reload();
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      alert("Something went wrong: " + errorMessage);
    }
  });
}

function newContestHandler(e) {
  $('#newcontest-modal').modal('show');
}


function createContestHandler(e) {
  $('#contest-form').submit();
}
