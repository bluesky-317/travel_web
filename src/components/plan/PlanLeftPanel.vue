<template>
  <aside class="left-panel">
    <div class="panel-header">
      <el-segmented v-model="store.leftTab" :options="TABS" style="width:100%" />
    </div>

    <template v-if="store.leftTab === 'list'">
      <div class="create-row">
        <el-button class="create-btn" @click="store.createItinerary()">
          <i class="fa-solid fa-plus"></i>&nbsp;建立新旅程
        </el-button>
      </div>
      <el-scrollbar class="card-scroll">
        <div class="card-inner">
          <el-empty v-if="!store.normalItineraries.length" description="尚無旅程" :image-size="55" />
          <ItineraryCard
            v-for="itin in store.normalItineraries"
            :key="itin.id"
            :itinerary="itin"
            :isActive="itin.id === store.activeId"
            @select="store.setActive(itin.id)"
            @delete="store.softDelete(itin.id)"
          />
        </div>
      </el-scrollbar>
    </template>

    <template v-else>
      <el-scrollbar class="card-scroll">
        <div class="card-inner">
          <el-empty v-if="!store.deletedItineraries.length" description="垃圾桶是空的" :image-size="55" />
          <ItineraryCard
            v-for="itin in store.deletedItineraries"
            :key="itin.id"
            :itinerary="itin"
            trash
            @restore="store.restore(itin.id)"
            @hardDelete="store.hardDelete(itin.id)"
          />
        </div>
      </el-scrollbar>
    </template>
  </aside>
</template>

<script setup>
import { usePlanStore } from '@/stores/plan'
import ItineraryCard from './ItineraryCard.vue'

const store = usePlanStore()
const TABS = [
  { label: '安排旅遊', value: 'list' },
  { label: '垃圾桶',   value: 'trash' },
]
</script>

<style scoped>
.left-panel {
  width: 240px;
  min-width: 240px;
  border-right: 1px solid var(--bd);
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

.create-row {
  padding: 8px 10px;
  border-bottom: 1px solid var(--bd);
  flex-shrink: 0;
}

.create-btn {
  width: 100%;
  border-style: dashed !important;
  font-size: .96rem !important;
  font-weight: 600 !important;
  --el-button-bg-color: var(--gn3);
  --el-button-border-color: var(--gn2);
  --el-button-text-color: var(--gn);
  --el-button-hover-bg-color: var(--gn4);
  --el-button-hover-border-color: var(--gn);
  --el-button-hover-text-color: var(--gn);
}

.card-scroll { flex: 1; min-height: 0; }
.card-inner  { padding: 8px; display: flex; flex-direction: column; gap: 6px; }
</style>
