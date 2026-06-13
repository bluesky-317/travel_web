import { defineStore } from 'pinia'
import { searchAttractions } from '@/api/Attraction'

export const useExploreStore = defineStore('explore', {
  state: () => ({
    // 篩選狀態
    searchText:        '',
    selectedCities:    [],
    selectedCategory:  '',
    sortBy:            'default',
    currentPage:       1,
    pageSize:          10,

    // 結果
    attractions: [],
    total:       0,
    loading:     false,
    error:       null,
  }),

  actions: {
    async fetch() {
      this.loading = true
      this.error   = null
      try {
        const params = { page: this.currentPage, page_size: this.pageSize }

        if (this.searchText)             params.q        = this.searchText
        if (this.selectedCities.length)  params.cities   = this.selectedCities.join(',')
        if (this.selectedCategory)       params.category = this.selectedCategory
        if (this.sortBy !== 'default')   params.sort     = this.sortBy

        const res = await searchAttractions(params)
        this.attractions = res.data.items
        this.total       = res.data.total
      } catch (err) {
        this.error = err.message || '載入失敗'
      } finally {
        this.loading = false
      }
    },

    // 更新單一 filter 並重置到第 1 頁後重新 fetch
    applyFilter(key, value) {
      this[key]         = value
      this.currentPage  = 1
      this.fetch()
    },

    setPage(page) {
      this.currentPage = page
      this.fetch()
    },

    clearAll() {
      this.searchText        = ''
      this.selectedCities    = []
      this.selectedCategory  = ''
      this.sortBy            = 'default'
      this.currentPage       = 1
      this.fetch()
    },
  },
})
