import { defineStore } from 'pinia'
import { ElMessage } from 'element-plus'
import { getAttractionList, searchAttractions } from '@/api/Attraction'
import {
  listItineraries, listItinerariesTrash, createItineraryApi,
  updateItineraryApi, deleteItineraryApi, restoreItineraryApi,
  hardDeleteItineraryApi, putItineraryItemsApi,
} from '@/api/Itinerary'

// ── helpers ───────────────────────────────────────────────────────────────────

function uid() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2)
}

function pad(n) { return String(n).padStart(2, '0') }

function localDateStr(d) {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

function todayStr() {
  return localDateStr(new Date())
}

export function addDays(dateStr, n) {
  const d = new Date(dateStr + 'T00:00:00')
  d.setDate(d.getDate() + n)
  return localDateStr(d)
}

export function fmtDate(dateStr) {
  if (!dateStr) return ''
  return dateStr.replace(/-/g, '/')
}

// ── itineraryAttrIds stays in localStorage (UI state, not itinerary data) ────
const ITINERARY_IDS_KEY = 'travel_itinerary_attr_ids'

function loadStoredItineraryIds() {
  try { return JSON.parse(localStorage.getItem(ITINERARY_IDS_KEY) || '[]') } catch { return [] }
}

function persistItineraryIds(ids) {
  try { localStorage.setItem(ITINERARY_IDS_KEY, JSON.stringify(ids)) } catch {}
}

// ── module-level timers (not reactive) ───────────────────────────────────────
let _searchTimer = null
let _searchSeq = 0

// ── store ─────────────────────────────────────────────────────────────────────
export const usePlanStore = defineStore('plan', {
  state: () => ({
    itineraries: [],
    activeId: null,
    activeDay: 0,

    isLoading: false,

    attractions: [],
    attractionsLoading: false,
    attractionsError: null,

    itineraryAttrIds: loadStoredItineraryIds(),

    // right panel filter
    filterText: '',
    selCategory: '',

    // ui tabs
    rightTab: 'unscheduled',
    leftTab: 'list',
    centerView: 'timeline',

    isSaving: false,
    isDirty: false,
    trashLoaded: false,

    // drag: attraction → day
    dragAttr: null,
    dragAttrId: null,
    isDragAttr: false,
    overDrop: false,

    // drag: item reorder
    dragItemUid: null,
    overItemUid: null,

    // right panel paginated search
    searchResults: [],
    searchTotal: 0,
    searchPage: 1,
    searchPageSize: 10,
    searchLoading: false,
  }),

  getters: {
    activeItinerary(state) {
      if (!state.activeId) return null
      return state.itineraries.find(i => i.id === state.activeId) ?? null
    },

    activeDayData() {
      const itin = this.activeItinerary
      if (!itin) return null
      return itin.days[this.activeDay] ?? null
    },

    activeDayItems() {
      return this.activeDayData?.items ?? []
    },

    activeEndDate() {
      const itin = this.activeItinerary
      if (!itin) return null
      return addDays(itin.startDate, itin.numDays - 1)
    },

    normalItineraries: s => s.itineraries.filter(i => !i.isDeleted),
    deletedItineraries: s => s.itineraries.filter(i => i.isDeleted),

    allTags(state) {
      const s = new Set()
      state.attractions.forEach(a => a.category && s.add(a.category))
      return [...s].sort()
    },

    filteredAttractions(state) {
      const q = state.filterText.toLowerCase()
      return state.attractions.filter(a => {
        const txt = !q || a.name.toLowerCase().includes(q) || a.location.toLowerCase().includes(q)
        const category = !state.selCategory || a.category === state.selCategory
        return txt && category
      })
    },

    unscheduledAttractions(state) {
      const itin = this.activeItinerary
      const scheduledIds = itin
        ? new Set(itin.days.flatMap(d => d.items.map(it => String(it.attractionId))))
        : new Set()
      return state.attractions.filter(a =>
        state.itineraryAttrIds.includes(String(a.id)) && !scheduledIds.has(String(a.id))
      )
    },

    activeDayStats() {
      let mins = 0
      this.activeDayItems.forEach(it => {
        const [sh, sm] = it.startTime.split(':').map(Number)
        const [eh, em] = it.endTime.split(':').map(Number)
        mins += Math.max(0, (eh * 60 + em) - (sh * 60 + sm))
      })
      const h = Math.floor(mins / 60), m = mins % 60
      return {
        count: this.activeDayItems.length,
        duration: mins === 0 ? '0h' : (m > 0 ? `${h}h${m}m` : `${h}h`),
      }
    },
  },

  actions: {
    // ── itineraryAttrIds (localStorage) ──────────────────────────────────────

    addItineraryAttrId(id) {
      const sid = String(id)
      if (!this.itineraryAttrIds.includes(sid)) {
        this.itineraryAttrIds.push(sid)
        persistItineraryIds(this.itineraryAttrIds)
      }
    },

    removeItineraryAttrId(id) {
      const sid = String(id)
      const idx = this.itineraryAttrIds.indexOf(sid)
      if (idx >= 0) {
        this.itineraryAttrIds.splice(idx, 1)
        persistItineraryIds(this.itineraryAttrIds)
      }
    },

    // ── internal helpers ──────────────────────────────────────────────────────

    _collectItems(itin) {
      const items = []
      itin.days.forEach((day, di) => {
        day.items.forEach(item => {
          items.push({
            uid:          item.uid,
            attractionId: item.attractionId,
            dayIndex:     di,
            startTime:    item.startTime,
            endTime:      item.endTime,
            note:         item.note || '',
          })
        })
      })
      return items
    },

    async _syncItems(itin) {
      const target = itin ?? this.activeItinerary
      if (!target) return
      await putItineraryItemsApi(target.id, this._collectItems(target))
    },

    // ── itinerary management ──────────────────────────────────────────────────

    async createItinerary() {
      try {
        const res = await createItineraryApi({ title: '我的旅程', startDate: todayStr(), numDays: 1 })
        const itin = res.data
        this.itineraries.unshift(itin)
        this.activeId  = itin.id
        this.activeDay = 0
        this.isDirty   = false
      } catch {
        ElMessage.error('建立旅程失敗')
      }
    },

    async setActive(id) {
      if (this.activeId === id) return
      if (this.isDirty) {
        await this.saveToBackend()
        if (this.isDirty) return  // 存檔失敗則放棄切換，停在原本的行程
      }
      this.activeId  = id
      this.activeDay = 0
      this.isDirty   = false
    },

    async softDelete(id) {
      const itin = this.itineraries.find(i => i.id === id)
      if (!itin) return
      const wasActive = this.activeId === id
      itin.isDeleted = true
      if (wasActive) {
        // 直接放棄被刪除行程的 dirty 變更
        this.activeId  = this.itineraries.find(i => !i.isDeleted)?.id ?? null
        this.activeDay = 0
        this.isDirty   = false
      }
      try {
        await deleteItineraryApi(id)
      } catch {
        itin.isDeleted = false
        ElMessage.error('刪除失敗')
      }
    },

    async restore(id) {
      const itin = this.itineraries.find(i => i.id === id)
      if (!itin) return
      itin.isDeleted = false
      try {
        await restoreItineraryApi(id)
        // reload items for restored itinerary
        const res = await listItineraries()
        const fresh = res.data.find(i => i.id === id)
        if (fresh) itin.days = fresh.days
      } catch {
        itin.isDeleted = true
        ElMessage.error('還原失敗')
      }
    },

    async hardDelete(id) {
      const idx = this.itineraries.findIndex(i => i.id === id)
      if (idx < 0) return
      const [removed] = this.itineraries.splice(idx, 1)
      try {
        await hardDeleteItineraryApi(id)
      } catch {
        this.itineraries.splice(idx, 0, removed)
        ElMessage.error('刪除失敗')
      }
    },

    setTitle(title) {
      const itin = this.activeItinerary
      if (!itin) return
      itin.title   = title
      this.isDirty = true
    },

    setStartDate(newDate) {
      const itin = this.activeItinerary
      if (!itin) return
      itin.startDate = newDate
      this.isDirty   = true
    },

    // ── day management ────────────────────────────────────────────────────────

    setActiveDay(idx) {
      this.activeDay = idx
    },

    addDay() {
      const itin = this.activeItinerary
      if (!itin || itin.numDays >= 10) return
      itin.numDays++
      itin.days.push({ items: [] })
      this.activeDay = itin.numDays - 1
      this.isDirty   = true
    },

    removeDay(dayIdx) {
      const itin = this.activeItinerary
      if (!itin || itin.numDays <= 1) return
      itin.days.splice(dayIdx, 1)
      itin.numDays--
      if (this.activeDay >= itin.numDays) this.activeDay = itin.numDays - 1
      this.isDirty = true
    },

    // ── item management ───────────────────────────────────────────────────────

    addAttrToDay(attr) {
      const itin = this.activeItinerary
      if (!itin || !itin.days[this.activeDay]) return
      const items = itin.days[this.activeDay].items
      let startTime = '09:00', endTime = '10:30'
      if (items.length) {
        const last  = items[items.length - 1]
        startTime   = last.endTime
        const [h, m] = last.endTime.split(':').map(Number)
        const endMin = h * 60 + m + 90
        const eh     = Math.min(23, Math.floor(endMin / 60))
        const em     = endMin % 60
        endTime = `${pad(eh)}:${pad(em)}`
        if (eh === 23 && em + 90 > 59) endTime = '23:00'
      }
      items.push({
        uid:          uid(),
        attractionId: attr.id,
        name:         attr.name,
        location:     attr.location,
        category:     attr.category || '',
        imageUrl:     attr.imageUrl,
        openingHours: attr.openingHours,
        ticketInfo:   attr.ticketInfo,
        rating:       attr.rating,
        startTime,
        endTime,
        note: '',
      })
      this.isDirty = true
    },

    removeItem(dayIdx, itemUid) {
      const itin = this.activeItinerary
      if (!itin?.days[dayIdx]) return
      const items = itin.days[dayIdx].items
      const idx   = items.findIndex(i => i.uid === itemUid)
      if (idx < 0) return
      items.splice(idx, 1)
      this.isDirty = true
    },

    setItemField(dayIdx, itemUid, field, value) {
      const itin = this.activeItinerary
      if (!itin?.days[dayIdx]) return
      const item = itin.days[dayIdx].items.find(i => i.uid === itemUid)
      if (!item) return
      item[field]  = value
      this.isDirty = true
      if (field === 'startTime' || field === 'endTime') {
        const [sh, sm] = item.startTime.split(':').map(Number)
        const [eh, em] = item.endTime.split(':').map(Number)
        if (sh * 60 + sm >= eh * 60 + em) {
          const endMin = sh * 60 + sm + 90
          item.endTime = `${pad(Math.min(23, Math.floor(endMin / 60)))}:${pad(endMin % 60)}`
        }
      }
    },

    moveItem(dayIdx, fromUid, toUid) {
      const itin = this.activeItinerary
      if (!itin?.days[dayIdx]) return
      const items = itin.days[dayIdx].items
      const fi    = items.findIndex(i => i.uid === fromUid)
      const ti    = items.findIndex(i => i.uid === toUid)
      if (fi < 0 || ti < 0 || fi === ti) return
      const [item] = items.splice(fi, 1)
      items.splice(ti, 0, item)
      this.isDirty = true
    },

    // ── drag: attraction → day ────────────────────────────────────────────────

    startAttrDrag(attr) {
      this.dragAttr   = attr
      this.dragAttrId = attr.id
      this.isDragAttr = true
    },

    endDrag() {
      this.dragAttr    = null
      this.dragAttrId  = null
      this.isDragAttr  = false
      this.overDrop    = false
      this.dragItemUid = null
      this.overItemUid = null
    },

    dropOnZone() {
      if (!this.isDragAttr || !this.dragAttr) return
      this.addAttrToDay(this.dragAttr)
      this.endDrag()
    },

    // ── fetch attractions ─────────────────────────────────────────────────────

    async fetchAttractions() {
      this.attractionsLoading = true
      this.attractionsError   = null
      try {
        const res = await getAttractionList()
        this.attractions = res?.data ?? []
      } catch (err) {
        this.attractionsError = err.message
      } finally {
        this.attractionsLoading = false
      }
    },

    // ── save (force-sync all) ─────────────────────────────────────────────────

    async saveToBackend() {
      if (this.isSaving) return
      const itin = this.activeItinerary
      if (!itin) return
      this.isSaving = true
      try {
        await updateItineraryApi(itin.id, {
          title:     itin.title,
          startDate: itin.startDate,
          numDays:   itin.numDays,
        })
        await this._syncItems(itin)
        this.isDirty = false
        ElMessage.success('行程已儲存！')
      } catch (err) {
        ElMessage.error(err?.message || '儲存失敗，請稍後再試')
      } finally {
        this.isSaving = false
      }
    },

    // 放棄本地未儲存的編輯，從 server 重新拉一份覆蓋當前行程
    async discardChanges() {
      const activeId = this.activeId
      if (!activeId) return
      try {
        const res = await listItineraries()
        const fresh = (res.data ?? []).find(i => i.id === activeId)
        const itin = this.itineraries.find(i => i.id === activeId)
        if (fresh && itin) {
          itin.title     = fresh.title
          itin.startDate = fresh.startDate
          itin.numDays   = fresh.numDays
          itin.days      = fresh.days
        }
        this.isDirty = false
      } catch {
        ElMessage.error('還原失敗')
      }
    },

    markSaved() {
      this.isDirty = false
    },

    // ── init ──────────────────────────────────────────────────────────────────

    async init() {
      await this.fetchAttractions()
      // load itineraries from DB (requires auth; request.js will reject if 401)
      this.isLoading = true
      this.trashLoaded = false
      try {
        const activeRes = await listItineraries()
        this.itineraries = activeRes.data ?? []
        this.activeId    = this.itineraries[0]?.id ?? null
        this.activeDay   = 0
        this.isDirty     = false
      } catch {
        // 未登入或網路錯誤：保持空行程列表
        this.itineraries = []
        this.activeId    = null
      } finally {
        this.isLoading = false
      }
    },

    async fetchTrash() {
      if (this.trashLoaded) return
      try {
        const res = await listItinerariesTrash()
        const trash = res.data ?? []
        // 合併：保留 active，移除舊 trash，加入新 trash
        this.itineraries = [
          ...this.itineraries.filter(i => !i.isDeleted),
          ...trash,
        ]
        this.trashLoaded = true
      } catch {
        // 靜默失敗，下次切 tab 仍會再試
      }
    },

    // ── right panel paginated search ─────────────────────────────────────────

    async fetchSearchAttractions() {
      const seq = ++_searchSeq
      this.searchLoading = true
      try {
        const params = {
          page:      this.searchPage,
          page_size: this.searchPageSize,
        }
        if (this.filterText)     params.q               = this.filterText
        if (this.selCategory)    params.category        = this.selCategory
        const res = await searchAttractions(params)
        if (seq !== _searchSeq) return  // 已被更新的搜尋取代，丟棄此回應
        this.searchResults = res.data.items ?? []
        this.searchTotal   = res.data.total  ?? 0
      } catch {
        if (seq !== _searchSeq) return
        this.searchResults = []
        this.searchTotal   = 0
      } finally {
        if (seq === _searchSeq) this.searchLoading = false
      }
    },

    setSearchPage(page) {
      this.searchPage = page
      this.fetchSearchAttractions()
    },

    resetAndSearch() {
      clearTimeout(_searchTimer)
      this.searchPage = 1
      this.fetchSearchAttractions()
    },

    debouncedResetAndSearch() {
      clearTimeout(_searchTimer)
      _searchTimer = setTimeout(() => this.resetAndSearch(), 300)
    },
  },
})
