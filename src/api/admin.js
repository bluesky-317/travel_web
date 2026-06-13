import request from '@/utils/request'

export function getUserList() {
  return request({ url: '/admin/users', method: 'get' })
}

export function deleteUser(id) {
  return request({ url: `/admin/users/${id}`, method: 'delete' })
}

export function createAttraction(data) {
  return request({ url: '/attractions', method: 'post', data })
}

export function updateAttraction(id, data) {
  return request({ url: `/attractions/${id}`, method: 'put', data })
}

export function deleteAttraction(id) {
  return request({ url: `/attractions/${id}`, method: 'delete' })
}
