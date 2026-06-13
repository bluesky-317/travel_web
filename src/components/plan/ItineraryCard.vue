<template>
  <div
    :class="['icard', !trash && isActive && 'icard--active', trash && 'icard--trash']"
    @click="!trash && $emit('select')"
  >
    <div class="icard-title">{{ itinerary.title }}</div>
    <div class="icard-dates">
      <i class="fa-regular fa-calendar"></i>
      {{ fmtDate(itinerary.startDate) }} - {{ fmtDate(endDate) }}
      <span class="icard-days">({{ itinerary.numDays }}天)</span>
    </div>
    <button v-if="!trash" class="icard-del" title="移至垃圾桶" @click.stop="$emit('delete')">
      <i class="fa-solid fa-trash"></i>
    </button>
    <div v-else class="icard-actions">
      <el-button class="btn-restore" size="small" title="還原" @click="$emit('restore')">
        <i class="fa-solid fa-rotate-left"></i>
      </el-button>
      <el-button class="btn-hard-del" size="small" title="永久刪除" @click="confirmHardDelete">
        <i class="fa-solid fa-trash"></i>
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { ElMessageBox } from 'element-plus'
import { addDays, fmtDate } from '@/stores/plan'

const props = defineProps({
  itinerary: { type: Object, required: true },
  isActive:  { type: Boolean, default: false },
  trash:     { type: Boolean, default: false },
})
const emit = defineEmits(['select', 'delete', 'restore', 'hardDelete'])

const endDate = computed(() => addDays(props.itinerary.startDate, props.itinerary.numDays - 1))

async function confirmHardDelete() {
  try {
    await ElMessageBox.confirm(
      `確定要永久刪除「${props.itinerary.title}」嗎？此操作無法復原。`,
      '永久刪除',
      { confirmButtonText: '刪除', cancelButtonText: '取消', type: 'warning' }
    )
    emit('hardDelete')
  } catch {}
}
</script>

<style scoped>
.icard {
  position: relative;
  background: var(--surf);
  border: 1.5px solid var(--bd);
  border-radius: 10px;
  padding: 10px 36px 10px 12px;
  cursor: pointer;
  user-select: none;
  transition: border-color .15s, background .15s, box-shadow .15s;
}
.icard:hover { border-color: var(--gn2); box-shadow: 0 2px 8px rgba(0,0,0,.06); }
.icard--active { border-color: var(--gn); background: var(--gn3); }
.icard--trash  { padding: 10px 12px; cursor: default; }

.icard-title {
  font-weight: 600;
  font-size: 1.0rem;
  color: var(--tx);
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.icard-dates {
  font-size: .88rem;
  color: var(--tx2);
  display: flex;
  align-items: center;
  gap: 5px;
  flex-wrap: wrap;
}

.icard-days { color: var(--gn2); font-weight: 500; }

.icard-del {
  position: absolute;
  top: 50%;
  right: 10px;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: var(--tx3);
  cursor: pointer;
  padding: 4px 6px;
  border-radius: 5px;
  font-size: .92rem;
  transition: color .15s, background .15s;
}
.icard-del:hover { color: var(--tc); background: var(--tc3); }

.icard-actions {
  display: flex;
  gap: 6px;
  margin-top: 6px;
  justify-content: flex-end;
}

.btn-restore {
  --el-button-bg-color: var(--gn3);
  --el-button-border-color: var(--gn2);
  --el-button-text-color: var(--gn2);
  --el-button-hover-bg-color: var(--gn4);
  --el-button-hover-border-color: var(--gn);
  --el-button-hover-text-color: var(--gn);
}

.btn-hard-del {
  --el-button-bg-color: var(--tc3);
  --el-button-border-color: var(--tc);
  --el-button-text-color: var(--tc);
  --el-button-hover-bg-color: var(--tc);
  --el-button-hover-border-color: var(--tc);
  --el-button-hover-text-color: #fff;
}
</style>
