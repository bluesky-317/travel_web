import request from '@/utils/request';

export function loginApi(data) {
  return request({ url: '/login', method: 'post', data });
}

export function getUserInfoApi() {
  return request({ url: '/me', method: 'get' });
}

export function registerApi(data) {
  return request({ url: '/register', method: 'post', data });
}

export function updateProfileApi(data) {
  return request({ url: '/me', method: 'patch', data });
}

export function changePasswordApi(data) {
  return request({ url: '/me/password', method: 'put', data });
}

export function deleteAccountApi() {
  return request({ url: '/me', method: 'delete' });
}