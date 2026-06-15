<template>
  <aside class="right-panel">
    <div class="panel-header">
      <el-segmented v-model="store.rightTab" :options="TABS" style="width:100%" />
    </div>

    <!-- ── 搜尋景點 tab ── -->
    <template v-if="store.rightTab === 'search'">
      <div class="filters">
        <el-input
          v-model="store.filterText"
          placeholder="搜尋景點名稱或地區…"
          clearable
          @input="store.debouncedResetAndSearch"
          @clear="store.resetAndSearch"
        >
          <template #prefix><i class="fa-solid fa-magnifying-glass"></i></template>
        </el-input>
        <el-select
          v-model="store.selCategory"
          placeholder="篩選類別"
          clearable
          style="width:100%"
          @change="store.resetAndSearch"
          @clear="store.resetAndSearch"
        >
          <el-option label="自然景觀"        value="自然景觀" />
          <el-option label="生態觀察與動植物" value="生態觀察與動植物" />
          <el-option label="林業歷史與人文"  value="林業歷史與人文" />
          <el-option label="戶外體驗"        value="戶外體驗" />
        </el-select>
      </div>

      <div class="list-body" v-loading="store.searchLoading">
        <el-empty
          v-if="!store.searchLoading && !store.searchResults.length"
          description="找不到符合的景點"
          :image-size="55"
        />
        <template v-else>
          <AttractionCard v-for="a in store.searchResults" :key="a.id" :attr="a" />
        </template>
      </div>

      <!-- 分頁 (超過 10 筆才顯示) -->
      <div v-if="store.searchTotal > store.searchPageSize" class="pager">
        <el-pagination
          :current-page="store.searchPage"
          :page-size="store.searchPageSize"
          :total="store.searchTotal"
          layout="prev, pager, next"
          small
          background
          @current-change="store.setSearchPage"
        />
      </div>
    </template>

    <!-- ── 尚未安排 tab ── -->
    <template v-else>
      <div class="list-body" v-loading="store.attractionsLoading">
        <el-empty
          v-if="!store.attractionsLoading && !store.unscheduledAttractions.length"
          description="所有景點已加入行程！"
          :image-size="55"
        />
        <template v-else>
          <AttractionCard v-for="a in store.unscheduledAttractions" :key="a.id" :attr="a" />
        </template>
      </div>
    </template>
  </aside>
</template>

<script setup>
import { watch } from 'vue'
import { usePlanStore } from '@/stores/plan'
import AttractionCard from './AttractionCard.vue'

const store = usePlanStore()
const TABS = [
  { label: '尚未安排', value: 'unscheduled' },
  { label: '搜尋景點', value: 'search' },
]

// 切換到搜尋 tab 時才載入第一頁（不再 onMounted 預載）
watch(() => store.rightTab, (tab) => {
  if (tab === 'search' && store.searchResults.length === 0) {
    store.resetAndSearch()
  }
})
</script>

<style scoped>
.right-panel {
  width: 240px;
  min-width: 240px;
  border-left: 1px solid var(--bd);
  display: flex;
  flex-direction: column;
  background: var(--surf2);
  overflow: hidden;
}

.panel-header {
  padding: 8px 10px;
  border-bottom: 1px solid var(--bd);
  flex-shrink: 0;
}

.filters {
  padding: 8px 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  border-bottom: 1px solid var(--bd);
  flex-shrink: 0;
}

.list-body {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 7px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.pager {
  padding: 6px 4px;
  border-top: 1px solid var(--bd);
  flex-shrink: 0;
  display: flex;
  justify-content: center;
}

.pager :deep(.el-pagination) {
  --el-pagination-font-size: 11px;
}

@media (max-width: 768px) {
  .right-panel {
    width: 100%;
    min-width: 0;
    max-height: 280px;
    border-left: none;
    border-top: 1px solid var(--bd);
  }
}
</style>
