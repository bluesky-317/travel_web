import axios from 'axios';
import Cookies from 'js-cookie';

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 5000
});

request.interceptors.request.use(config => {
  const token = Cookies.get('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

request.interceptors.response.use(
  response => response.data,
  error => {
    const data = error.response?.data;
    let msg = data?.detail ?? data?.message;
    if (Array.isArray(msg)) {
      msg = msg.map(e => e?.msg).filter(Boolean).join('；');
    } else if (msg && typeof msg === 'object') {
      msg = msg.msg || JSON.stringify(msg);
    }
    return Promise.reject(new Error(msg || '網路錯誤'));
  }
);

export default request;
