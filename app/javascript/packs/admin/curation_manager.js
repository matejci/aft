'use strict';

import { generate_req_headers } from '../utils.js';

$(document).ready(function() {
  $('body').on('click', '.remove_btn', removeBtnHandler);
  $('body').on('keypress', '#search_txt', searchHandler);
  $('body').on('change', '#options', optionsHandler);
  $('body').on('click', '.add_btn', addBtnHandler);
});


function removeBtnHandler(e) {
  e.preventDefault();

  $("#loader").show();

  $.ajax({
    url: e.currentTarget.dataset['url'],
    dataType: 'json',
    type: 'DELETE',
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      if ($("#options").val() == 'Curated List') {
        $("#" + data.id).remove();
      } else {
        $(e.currentTarget).addClass('add_btn').removeClass('remove_btn').html('Curate');
      }
      $(".loader").hide();
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      alert(errorMessage);
    }
  });
}

function addBtnHandler(e) {
  e.preventDefault();
  $(".loader").show();

  $.ajax({
    url: e.currentTarget.dataset['url'],
    dataType: 'json',
    type: 'PATCH',
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      $(".loader").hide();
      $(e.currentTarget).addClass('remove_btn').removeClass('add_btn').html('Remove');
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      alert(jqXhr.responseJSON['error']);
    }
  });
}

function searchHandler(e) {
  if (e.which == 13) {
    if ($("#options").val() != 'Search') {
      alert('Please switch to search mode');
      return false;
    }

    $(".loader").show();

    $.ajax({
      url: e.currentTarget.dataset['url'] + '?query=' + $('#search_txt').val(),
      dataType: 'script',
      type: 'GET',
      headers: generate_req_headers(),
      success: function(data, status, xhr) {
        $(".loader").hide();
      },
      error: function(jqXhr, textStatus, errorMessage) {
        $(".loader").hide();
        alert(errorMessage);
      }
    });
  }
}

function optionsHandler(e) {
  if (e.currentTarget.value == 'Curated List') { location.reload(); }
}
