'use strict';

import { generate_req_headers } from '../utils.js';
import Dropzone from "dropzone";
Dropzone.autoDiscover = false;

$(document).ready(function() {
  Array.prototype.slice.call(document.querySelectorAll('.dropzone'))
    .forEach(element => {
      var $form = $(element).parents('form');
      new Dropzone(element, {
        autoProcessQueue: false,
        url: $form.attr('action'),
        method: $form.find('input[name="_method"]').val() || 'post',
        headers: generate_req_headers(),
        dataType: 'json',
        paramName: 'banner[image]',
        maxFiles: 1,
        acceptedFiles: 'image/*',
        previewTemplate: $form.find('.dz-preview').html(),
        init: function() {
          var dz = this;

          $form.find("input[type='submit']").click(function(e){
            e.preventDefault();
            e.stopPropagation();

            if (dz.getQueuedFiles().length > 0) {
              dz.processQueue();
            } else if (dz.files.length > 0) {
              dz.uploadFiles(dz.files);
            } else {
              $.ajax({
                url: $form.attr('action'),
                dataType: 'json',
                method: $form.find('input[name="_method"]').val() || 'post',
                headers: generate_req_headers(),
                data: $form.serialize(),
                success: function() { location.reload(); },
                error: function(jqXhr, textStatus, errorMessage) {
                  showError(errorMessage, jqXhr.responseJSON);
                }
              });
            }
          })

          $form.find('[data-role-delete-banner]').click(function(e){
            e.preventDefault();
            e.stopPropagation();
            $.ajax({
              url: $form.attr('action'),
              dataType: 'json',
              method: 'delete',
              headers: generate_req_headers(),
              complete: function() { location.reload(); }
            });
          })

          dz.on('addedfile', function(file) {
            while ( this.files.length > this.options.maxFiles ) this.removeFile(this.files[0]);
            $form.find('.dz-message').hide();
          })
          dz.on('sending', function (file, xhr, formData) {
            $.each( $form.serializeArray()
            , function( key, value ) {
              if (value.name.match(/banner/)) { formData.append(value.name, value.value) }
            });
          });
          dz.on('success', function() {
            location.reload();
          });
          dz.on('error', function(file, error, xhr) {
            showError(xhr.statusText, error);
          });
        }
      });
  })
});


function showError(message, errors) {
  var errorsList = $('<ul>');
  $.each( errors
  , function( key, value ) {
    if ($.isArray(value)) { value = value.join(', ') };
    errorsList.append(`<li>${key}: ${value}</li>`);
  });
  $('#banners-modal').find('.modal-title').html(`Error: ${message}`);
  $('#banners-modal').find('.modal-body').html(errorsList);
  $('#banners-modal').modal('show');
}
