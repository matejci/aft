'use strict';

import { generate_req_headers, messages_handler } from '../utils.js';

$(document).ready(function() {
  $('body').on('click', '.remove_btn', removeBtnHandler);
  $('body').on('keypress', '#search_txt', searchHandler);
  $('body').on('click', '.add_btn', addBtnHandler);
  $('body').on('change', '#boost_options', optionsHandler);
  $('body').on('change', '#post_boost_options', optionsHandler);
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
      $("#" + data.id).remove();
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
      e.currentTarget.dataset['url'] = data.remove_url;
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      alert(jqXhr.responseJSON['error']);
    }
  });
}

function searchHandler(e) {
  if (e.which == 13) {
    $(".loader").show();

    var search_val = $('#search_txt').val();

    if (search_val == '') {
      return window.location.reload();
    }

    $.ajax({
      url: e.currentTarget.dataset['url'] + '?query=' + search_val,
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
  var url = null;
  var boost_value = null;

  if (e.currentTarget.name === 'boost_options') {
    url = $('#boost_value_url').val();
    boost_value = $("#boost_options").val();
  } else {
    url = $('#post_boost_value_url').val();
    boost_value = $("#post_boost_options").val()
  }

  $.ajax({
      url: url,
      data: { boost_value: boost_value },
      dataType: 'json',
      type: 'PATCH',
      headers: generate_req_headers(),
      success: function(data, status, xhr) {
        messages_handler(true);

        if (e.currentTarget.name === 'post_boost_options' && boost_value === '1.0x') {
          $("#post_boost_validation_date").hide();
        } else {
          $("#post_boost_validation_date").html("Valid until: " + data['valid_until']);
          $("#post_boost_validation_date").show();
        }
      },
      error: function(jqXhr, textStatus, errorMessage) {
        messages_handler(false);
      }
    });
}
