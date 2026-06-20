<template>
  <div class="stats-manage">
    <h2 class="section-title">
      <i class="fa-solid fa-chart-bar"></i> 統計
    </h2>

    <div class="chart-card" v-loading="loading">
      <h3 class="chart-title">各縣市景點數量</h3>
      <div v-if="chartData.length" class="chart-area">
        <div class="y-axis">
          <span v-for="tick in yTicks" :key="tick" class="y-tick">{{ tick }}</span>
        </div>
        <div class="bars-wrap">
          <div
            v-for="item in chartData"
            :key="item.city"
            class="bar-col"
          >
            <span class="bar-count">{{ item.count }}</span>
            <div
              class="bar-body"
              :style="{ height: `${(item.count / maxCount) * BAR_MAX_HEIGHT}px` }"
            ></div>
            <span class="bar-label">{{ item.city }}</span>
          </div>
        </div>
      </div>
      <el-empty v-else description="暫無資料" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { searchAttractions } from '@/api/Attraction'
import { CITIES, extractCity } from '@/constants/cities'

const BAR_MAX_HEIGHT = 220

const loading = ref(false)
const rawData = ref([])

const chartData = computed(() => {
  const counts = {}
  for (const a of rawData.value) {
    const city = extractCity(a.location)
    counts[city] = (counts[city] || 0) + 1
  }
  return Object.entries(counts)
    .map(([city, count]) => ({ city, count }))
    .sort((a, b) => {
      const ia = CITIES.indexOf(a.city)
      const ib = CITIES.indexOf(b.city)
      if (ia === -1 && ib === -1) return 0
      if (ia === -1) return 1
      if (ib === -1) return -1
      return ia - ib
    })
})

const maxCount = computed(() => Math.max(...chartData.value.map(d => d.count), 1))

const yTicks = computed(() => {
  const max = maxCount.value
  return [max, Math.ceil(max / 2), 0].filter((v, i, arr) => arr.indexOf(v) === i)
})

async function loadData() {
  loading.value = true
  try {
    const res = await searchAttractions()
    rawData.value = res.data
  } catch {
    ElMessage.error('載入資料失敗')
  } finally {
    loading.value = false
  }
}

onMounted(loadData)
</script>

<style scoped>
.stats-manage {
  max-width: 900px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 20px;
}

.section-title i {
  color: #3b82f6;
  margin-right: 8px;
}

.chart-card {
  background: #fff;
  border-radius: 12px;
  padding: 28px 32px 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  min-height: 360px;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  color: #374151;
  margin: 0 0 24px 0;
}

.chart-area {
  display: flex;
  align-items: flex-end;
  gap: 0;
}

.y-axis {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: v-bind('BAR_MAX_HEIGHT + "px"');
  margin-right: 12px;
  padding-bottom: 32px;
}

.y-tick {
  font-size: 14px;
  color: #9ca3af;
  line-height: 1;
}

.bars-wrap {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  flex: 1;
  overflow-x: auto;
  padding-bottom: 4px;
}

.bar-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 52px;
  flex-shrink: 0;
}

.bar-count {
  font-size: 14px;
  font-weight: 600;
  color: #3b82f6;
  margin-bottom: 4px;
}

.bar-body {
  width: 40px;
  background: linear-gradient(180deg, #60a5fa, #3b82f6);
  border-radius: 4px 4px 0 0;
  transition: height 0.5s ease;
  min-height: 4px;
}

.bar-label {
  font-size: 13px;
  color: #6b7280;
  margin-top: 8px;
  text-align: center;
  white-space: nowrap;
}
</style>
