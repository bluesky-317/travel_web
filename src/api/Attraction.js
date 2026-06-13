import request from '@/utils/request'

export function getAttractionList() {
  return request({ url: '/attractions', method: 'get' })
}

export function searchAttractions(params) {
  return request({ url: '/attractions', method: 'get', params })
}

/**
 * 根據景點 ID 取得詳細資料
 * @param {string|number} id
 * @returns {Promise<Object>}
 */
export function getAttractionById(id) {
  return request({
    url: `/attractions/${id}`,
    method: 'get'
  })
}
