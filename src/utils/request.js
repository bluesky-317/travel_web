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
  error => Promise.reject(new Error(error.response?.data?.message || '網路錯誤'))
);

export default request;
