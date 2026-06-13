import request from '@/utils/request'

export function listItineraries() {
  return request({ url: '/itineraries', method: 'get' })
}

export function listItinerariesTrash() {
  return request({ url: '/itineraries/trash', method: 'get' })
}

export function createItineraryApi(data) {
  return request({ url: '/itineraries', method: 'post', data })
}

export function updateItineraryApi(id, data) {
  return request({ url: `/itineraries/${id}`, method: 'patch', data })
}

export function deleteItineraryApi(id) {
  return request({ url: `/itineraries/${id}`, method: 'delete' })
}

export function restoreItineraryApi(id) {
  return request({ url: `/itineraries/${id}/restore`, method: 'post' })
}

export function hardDeleteItineraryApi(id) {
  return request({ url: `/itineraries/${id}/permanent`, method: 'delete' })
}

export function putItineraryItemsApi(id, items) {
  return request({ url: `/itineraries/${id}/items`, method: 'put', data: { items } })
}

export function addItineraryItemApi(id, item) {
  return request({ url: `/itineraries/${id}/items`, method: 'post', data: item })
}

export function removeItineraryItemApi(id, itemId) {
  return request({ url: `/itineraries/${id}/items/${itemId}`, method: 'delete' })
}

export function updateItineraryItemApi(id, itemId, data) {
  return request({ url: `/itineraries/${id}/items/${itemId}`, method: 'patch', data })
}
