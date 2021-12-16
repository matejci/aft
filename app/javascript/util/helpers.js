function csrfToken(document) {
  return document.querySelector('meta[name="csrf-token"]').content;
}

export function passAppTokens(document, axios) {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken(document);
  axios.defaults.headers.common['HTTP-X-APP-TOKEN'] = appToken
  axios.defaults.headers.common['APP-ID'] = appId
}
