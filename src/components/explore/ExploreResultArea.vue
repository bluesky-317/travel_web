<template>
  <main class="content-area">

    <!-- 結果列頭 -->
    <div class="result-header">
      <span class="result-count">
        找到 <strong>{{ exploreStore.total }}</strong> 個景點
      </span>
      <el-select
        :model-value="exploreStore.sortBy"
        size="small"
        style="width:140px;"
        @change="v => exploreStore.applyFilter('sortBy', v)"
      >
        <el-option label="預設排序" value="default" />
        <el-option label="由北到南"  value="ns" />
        <el-option label="由南到北"  value="sn" />
        <el-option label="最近更新"  value="updated" />
      </el-select>
    </div>

    <!-- 載入中 -->
    <div v-if="exploreStore.loading" class="state-msg">
      <i class="fa-solid fa-spinner fa-spin"></i> 載入中…
    </div>

    <!-- 錯誤 -->
    <div v-else-if="exploreStore.error" class="state-msg state-msg--error">
      <i class="fa-solid fa-circle-exclamation"></i> {{ exploreStore.error }}
      <button class="retry-btn" @click="exploreStore.fetch()">重新載入</button>
    </div>

    <!-- 無結果 -->
    <div v-else-if="exploreStore.attractions.length === 0" class="state-msg">
      <i class="fa-solid fa-magnifying-glass"></i>
      <span>沒有符合條件的景點</span>
    </div>

    <template v-else>
      <!-- 卡片列表 -->
      <div class="card-list">
        <TravelCard
          v-for="card in displayCards"
          :key="card.id"
          layout="list"
          :image="card.image"
          :category="card.category"
          :location="card.location"
          :title="card.title"
          :description="card.description"
          :link="card.link"
        />
      </div>

      <!-- 分頁 -->
      <div class="pagination-wrap">
        <el-pagination
          :current-page="exploreStore.currentPage"
          :page-size="exploreStore.pageSize"
          :total="exploreStore.total"
          layout="prev, pager, next"
          background
          @current-change="exploreStore.setPage"
        />
      </div>
    </template>

  </main>
</template>

<script setup>
import { computed } from 'vue'
import { useExploreStore } from '@/stores/explore'
import TravelCard from '@/components/TravelCard.vue'

const exploreStore = useExploreStore()

const displayCards = computed(() =>
  exploreStore.attractions.map(a => ({
    ...a,
    image:       a.imageUrl || '',
    category:    a.category || '',
    description: a.description || '',
    link:        `/attraction/${a.id}`,
  }))
)
</script>

<style scoped>
.content-area { min-width: 0; }

.result-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.result-count { font-size: 1rem; color: #6b7280; }
.result-count strong { color: #1e293b; }

.card-list { display: flex; flex-direction: column; gap: 16px; }

.pagination-wrap {
  display: flex;
  justify-content: center;
  margin-top: 28px;
}

.state-msg {
  text-align: center;
  padding: 60px 0;
  color: #9ca3af;
  font-size: 1.05rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}
.state-msg--error { color: #e11d48; }
.retry-btn {
  padding: 6px 18px;
  border: 1px solid #e11d48;
  border-radius: 6px;
  background: #fff1f2;
  color: #e11d48;
  font-size: 0.85rem;
  cursor: pointer;
}
.retry-btn:hover { background: #ffe4e6; }
</style>
