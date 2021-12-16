require('@rails/ujs').start()

var ready = (callback) => {
  if (document.readyState != 'loading') callback();
  else document.addEventListener('DOMContentLoaded', callback);
}

ready(() => {
  document.querySelector('#sidebarCollapse').addEventListener('click', (e) => {
    var sidebar = document.querySelector('#sidebar');
    sidebar.classList.toggle('active');
  });
})
