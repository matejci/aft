import axios from 'axios';

export default axios.create({
  headers: {
    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
    'HTTP-X-APP-TOKEN': appToken,
    'APP-ID': appId
  }
});
