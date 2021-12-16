'use strict';

import { generate_req_headers, messages_handler } from '../utils.js';

$(document).ready(function() {
  $('body').on('keypress', '#search_txt', searchHandler);
  $('body').on('click', '.report_details_btn', loadDetailsModal);
  $('body').on('click', '.cancel_btn, .close_btn', closeModal);
  $('body').on('click', '.details_allow_btn', allowBtnHandler);
  $('body').on('click', '.details_archive_btn', archiveBtnHandler);
  $('body').on('change', '#options', dropdownChangeHandler);
  $('body').on('change', '#allowed_chk, #archived_chk', chkHandler);
  $('body').on('click', '#notes-tab', notesClickHandler);
  $('body').on('click', '#history-tab', historyClickHandler);
  $('body').on('click', '.save_btn', saveNotesHandler);
});

function notesClickHandler(e) {
  $(e.currentTarget).addClass('active-tab').removeClass('inactive-tab');
  $("#history-tab").addClass('inactive-tab').removeClass('active-tab');
  $("#notes-content").show();
  $("#history-content").hide();
}

function historyClickHandler(e) {
  $(e.currentTarget).addClass('active-tab').removeClass('inactive-tab');
  $("#notes-tab").addClass('inactive-tab').removeClass('active-tab');
  $("#history-content").show();
  $("#notes-content").hide();
}

function loadDetailsModal(e) {
  $(".loader").show();

  $.ajax({
    url: e.currentTarget.dataset['url'],
    dataType: 'script',
    type: 'GET',
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      $(".loader").hide();
      $("#report_details_modal").modal('show');
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      messages_handler(false);
    }
  });
}

function closeModal(e) {
  $("#report_details_modal").modal('hide');
}

function allowBtnHandler(e) {
  updateReport(true);
}

function archiveBtnHandler(e) {
  updateReport(false);
}

function saveNotesHandler(e) {
  updateReport(undefined, $("#notes").val());
}

function updateReport(allowed, notes) {
  $(".loader").show();

  var req_data;

  if (allowed !== undefined) {
    req_data = { allowed: allowed };
  }

  if (notes !== undefined) {
    req_data = { notes: notes };
  }

  $.ajax({
    url: $("#admin_update_url").val(),
    type: 'PATCH',
    dataType: 'script',
    data: req_data,
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      $(".loader").hide();

      if (notes != undefined) { return false; }

      messages_handler(true);
      $("#report_details_modal").modal('hide');
      loadReports(true);
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      messages_handler(success);
    }
  });
}

function dropdownChangeHandler(e) {
  loadReports(true);
}

function chkHandler(e) {
  loadReports(true);
}

function loadReports(search_mode) {
  $(".loader").show();

  $.ajax({
    url: $("#index_url").val() + prepareQueryString(search_mode),
    dataType: 'script',
    type: 'GET',
    headers: generate_req_headers(),
    success: function(data, status, xhr) {
      $(".loader").hide();
    },
    error: function(jqXhr, textStatus, errorMessage) {
      $(".loader").hide();
      messages_handler(false);
    }
  });
}

function prepareQueryString(search_mode) {
  var qstring = "?option=" + $("#options").val();
  qstring += ("&archived=" + $("#archived_chk")[0].checked);
  qstring += ("&allowed=" + $("#allowed_chk")[0].checked);

  if (search_mode) {
    qstring += ("&search_term=" + $("#search_txt").val());
  }

  return qstring;
}

function searchHandler(e) {
  if (e.which == 13) {
    loadReports(true);
  }
}
