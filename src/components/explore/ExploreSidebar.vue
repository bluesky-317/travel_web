<template>
  <aside class="sidebar">
    <div class="sidebar-title">篩選條件</div>

    <!-- 區域 -->
    <div class="filter-group">
      <div class="filter-label">區域</div>
      <RegionDropdown
        :model-value="exploreStore.selectedCities"
        @update:model-value="v => exploreStore.applyFilter('selectedCities', v)"
      />
    </div>

    <!-- 分類（固定四大類） -->
    <div class="filter-group">
      <div class="filter-label">分類</div>
      <el-select
        :model-value="exploreStore.selectedCategory"
        placeholder="選擇類型"
        clearable
        style="width: 100%;"
        @change="v => exploreStore.applyFilter('selectedCategory', v ?? '')"
        @clear="() => exploreStore.applyFilter('selectedCategory', '')"
      >
        <el-option label="自然景觀"       value="自然景觀" />
        <el-option label="生態觀察與動植物" value="生態觀察與動植物" />
        <el-option label="林業歷史與人文"  value="林業歷史與人文" />
        <el-option label="戶外體驗"       value="戶外體驗" />
      </el-select>
    </div>

    <!-- 清除所有篩選 -->
    <button v-if="hasActiveFilters" class="clear-all-btn" @click="exploreStore.clearAll()">
      × 清除所有篩選
    </button>
  </aside>
</template>

<script setup>
import { computed } from 'vue'
import { useExploreStore } from '@/stores/explore'
import RegionDropdown from './RegionDropdown.vue'

const exploreStore = useExploreStore()

const hasActiveFilters = computed(() =>
  exploreStore.searchText || exploreStore.selectedCities.length ||
  exploreStore.selectedCategory
)
</script>

<style scoped>
.sidebar {
  flex: 0 0 230px;
  background: #fff;
  border-radius: 12px;
  padding: 20px 18px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.07);
  position: sticky;
  top: 100px;
}
.sidebar-title {
  font-size: 0.88rem;
  font-weight: 700;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 16px;
}
.filter-group { margin-bottom: 20px; }
.filter-label {
  font-size: 0.95rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}
.clear-all-btn {
  width: 100%;
  padding: 7px;
  border: 1px dashed #d1d5db;
  border-radius: 8px;
  background: none;
  color: #6b7280;
  font-size: 0.92rem;
  cursor: pointer;
  transition: all 0.2s;
}
.clear-all-btn:hover { border-color: #ef4444; color: #ef4444; }
</style>
