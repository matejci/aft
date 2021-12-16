document.addEventListener('DOMContentLoaded', function() {
  var checkbox = document.querySelector('[type="checkbox"][data-role="toggle-password"]')

  checkbox.addEventListener('click', (e) => {
    var inputFields = document.querySelectorAll('[data-role="toggle-password"]:not([type="checkbox"])');

    inputFields.forEach(field => {
      if (field.type == 'password') {
        field.type = 'text';
      } else {
        field.type = 'password';
      }
    })
  });
});
