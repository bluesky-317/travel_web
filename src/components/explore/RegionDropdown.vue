<template>
  <el-popover trigger="click" placement="bottom-start" :width="380" popper-class="region-popper">
    <template #reference>
      <button class="region-btn">
        <i class="fa-solid fa-map-location-dot"></i>
        區域
        <span v-if="modelValue.length" class="count-tag">已選 {{ modelValue.length }}</span>
        <i class="fa-solid fa-chevron-down chevron-icon"></i>
      </button>
    </template>

    <div class="region-panel">
      <!-- 全選 / 清除 -->
      <div class="panel-header">
        <el-checkbox
          :model-value="isAllSelected"
          :indeterminate="isIndeterminate"
          @change="toggleAll"
        >全選</el-checkbox>
        <button v-if="modelValue.length" class="clear-btn" @click="$emit('update:modelValue', [])">清除全部</button>
      </div>

      <div class="divider" />

      <!-- 各地區 -->
      <div v-for="region in REGIONS" :key="region.label" class="region-group">
        <div class="group-header">
          <i
            :class="['fa-solid', expanded.has(region.label) ? 'fa-chevron-down' : 'fa-chevron-right', 'expand-icon']"
            @click="toggleExpand(region.label)"
          ></i>
          <el-checkbox
            :model-value="isGroupAllChecked(region)"
            :indeterminate="isGroupIndeterminate(region)"
            @change="(v) => toggleGroup(region, v)"
          >{{ region.label }}</el-checkbox>
        </div>

        <div v-if="expanded.has(region.label)" class="city-grid">
          <el-checkbox
            v-for="city in region.cities"
            :key="city"
            :model-value="modelValue.includes(city)"
            @change="(v) => toggleCity(city, v)"
          >{{ city }}</el-checkbox>
        </div>
      </div>
    </div>
  </el-popover>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
})
const emit = defineEmits(['update:modelValue'])

const REGIONS = [
  { label: '北部地區', cities: ['台北市', '新北市', '基隆市', '桃園市', '宜蘭縣', '新竹市', '新竹縣'] },
  { label: '中部地區', cities: ['台中市', '苗栗縣', '彰化縣', '南投縣', '雲林縣'] },
  { label: '南部地區', cities: ['台南市', '高雄市', '嘉義市', '嘉義縣', '屏東縣'] },
  { label: '東部與外島', cities: ['花蓮縣', '台東縣', '澎湖縣', '金門縣', '連江縣'] },
]
const ALL_CITIES = REGIONS.flatMap(r => r.cities)

// 預設展開第一個地區
const expanded = ref(new Set(['北部地區']))

const isAllSelected = computed(() => ALL_CITIES.every(c => props.modelValue.includes(c)))
const isIndeterminate = computed(() => !isAllSelected.value && props.modelValue.length > 0)

function isGroupAllChecked(region) {
  return region.cities.every(c => props.modelValue.includes(c))
}
function isGroupIndeterminate(region) {
  const count = region.cities.filter(c => props.modelValue.includes(c)).length
  return count > 0 && count < region.cities.length
}

function toggleAll(v) {
  emit('update:modelValue', v ? [...ALL_CITIES] : [])
}
function toggleGroup(region, v) {
  const current = new Set(props.modelValue)
  region.cities.forEach(c => v ? current.add(c) : current.delete(c))
  emit('update:modelValue', [...current])
}
function toggleCity(city, v) {
  const current = new Set(props.modelValue)
  v ? current.add(city) : current.delete(city)
  emit('update:modelValue', [...current])
}
function toggleExpand(label) {
  const s = new Set(expanded.value)
  s.has(label) ? s.delete(label) : s.add(label)
  expanded.value = s
}
</script>

<style scoped>
.region-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 7px 14px;
  border: 1.5px solid #d1d5db;
  border-radius: 8px;
  background: #fff;
  color: #374151;
  font-size: 0.88rem;
  cursor: pointer;
  transition: border-color 0.2s;
  width: 100%;
  justify-content: space-between;
}
.region-btn:hover {
  border-color: #6b7280;
}
.count-tag {
  background: #2563eb;
  color: #fff;
  border-radius: 10px;
  padding: 1px 8px;
  font-size: 0.75rem;
  margin-left: auto;
}
.chevron-icon {
  font-size: 0.75rem;
  color: #9ca3af;
}

.region-panel {
  padding: 4px 2px;
}
.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 4px 6px 8px;
}
.clear-btn {
  border: none;
  background: none;
  color: #ef4444;
  font-size: 0.8rem;
  cursor: pointer;
  padding: 2px 6px;
}
.clear-btn:hover { text-decoration: underline; }
.divider {
  border-top: 1px solid #f0f0f0;
  margin-bottom: 6px;
}

.region-group { margin-bottom: 4px; }
.group-header {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 6px;
  border-radius: 6px;
  cursor: pointer;
}
.group-header:hover { background: #f9fafb; }
.expand-icon {
  font-size: 0.72rem;
  color: #9ca3af;
  width: 14px;
  cursor: pointer;
  flex-shrink: 0;
}
.city-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2px 0;
  padding: 4px 6px 4px 24px;
}
</style>

<style>
.region-popper { padding: 8px !important; }
</style>
