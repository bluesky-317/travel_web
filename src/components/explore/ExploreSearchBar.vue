<template>
  <div class="search-section">
    <el-input
      v-model="inputVal"
      placeholder="搜尋景點名稱或地點..."
      :prefix-icon="SearchIcon"
      clearable
      size="large"
      class="search-input"
      @input="handleInput"
      @clear="handleClear"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Search as SearchIcon } from '@element-plus/icons-vue'
import { useExploreStore } from '@/stores/explore'

const exploreStore = useExploreStore()
const inputVal = ref(exploreStore.searchText)

let timer = null
function handleInput() {
  clearTimeout(timer)
  timer = setTimeout(() => exploreStore.applyFilter('searchText', inputVal.value), 500)
}
function handleClear() {
  clearTimeout(timer)
  exploreStore.applyFilter('searchText', '')
}
</script>

<style scoped>
.search-section {
  background: #fff;
  border-radius: 12px;
  padding: 14px 18px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
}
.search-input { width: 100%; }
</style>
