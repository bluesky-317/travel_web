// stores/attractionStore.js
import { defineStore } from 'pinia'
import { getAttractionById, searchAttractions } from '@/api/Attraction'
import { usePlanStore } from '@/stores/plan'

const MAX_SIZE = 20          // 最多快取幾筆景點
const TTL     = 3 * 60 * 1000  // 快取存活時間：3 分鐘

export const useAttractionStore = defineStore('attraction', {
  state: () => ({
    // 景點資料快取：{ [id]: AttractionObject }
    cache: {},
    // 快取元資料：{ [id]: { fetchedAt: number, lastUsed: number } }
    meta: {},

    // 當前正在瀏覽的景點 ID（View 透過 currentId 存取資料）
    currentId: null,

    loading: false,
    error: null,

    // 首頁景點列表（評分前 10）
    list: [],
    listLoading: false,
    listError: null,
  }),

  getters: {
    // 當前景點物件（View 直接讀這個，不需自己查 cache）
    attraction: (state) =>
      state.currentId ? state.cache[state.currentId] ?? null : null,

    category:      (state) => state.cache[state.currentId]?.category      ?? '',
    isInItinerary: (state) => state.cache[state.currentId]?.isInItinerary ?? false,
  },

  actions: {
    /**
     * 取得景點詳情
     * - 快取有效 → 直接讀取，更新 lastUsed
     * - 快取過期或不存在 → 打 API，必要時先 evict
     */
    async fetchAttraction(id) {
      this.currentId = id
      this.error     = null

      const now = Date.now()
      const m   = this.meta[id]
      const isExpired = !m || (now - m.fetchedAt > TTL)

      // 快取命中：只更新 lastUsed，不打 API
      if (!isExpired) {
        this.meta[id].lastUsed = now
        if (this.cache[id]) {
          const planStore = usePlanStore()
          this.cache[id].isInItinerary = planStore.itineraryAttrIds.includes(String(id))
        }
        return
      }

      // 快取未命中：evict → fetch
      this._evictIfNeeded()
      this.loading = true
      try {
        const result    = await getAttractionById(id)
        this.cache[id]  = result?.data ?? result
        this.meta[id]   = { fetchedAt: now, lastUsed: now }
        if (this.cache[id]) {
          const planStore = usePlanStore()
          this.cache[id].isInItinerary = planStore.itineraryAttrIds.includes(String(id))
        }
      } catch (err) {
        this.error = err.message || '無法載入景點資料'
      } finally {
        this.loading = false
      }
    },

    /**
     * LRU Eviction：超過 MAX_SIZE 時，移除最久未使用的那筆
     */
    _evictIfNeeded() {
      if (Object.keys(this.cache).length < MAX_SIZE) return

      const oldestId = Object.entries(this.meta)
        .sort((a, b) => a[1].lastUsed - b[1].lastUsed)[0][0]

      delete this.cache[oldestId]
      delete this.meta[oldestId]
    },

    toggleItinerary() {
      const item = this.cache[this.currentId]
      if (!item) return
      item.isInItinerary = !item.isInItinerary
      const planStore = usePlanStore()
      if (item.isInItinerary) {
        planStore.addItineraryAttrId(this.currentId)
      } else {
        planStore.removeItineraryAttrId(this.currentId)
      }
    },

    /**
     * 強制使某筆快取失效（例如：編輯後需要重新拉取）
     */
    invalidate(id) {
      delete this.cache[id]
      delete this.meta[id]
    },

    async fetchList() {
      if (this.listLoading) return
      this.listLoading = true
      this.listError   = null
      try {
        const res = await searchAttractions({ page: 1, page_size: 10, sort: 'rating' })
        this.list = res?.data?.items ?? []
      } catch (err) {
        this.listError = err.message
      } finally {
        this.listLoading = false
      }
    },
  },
})
