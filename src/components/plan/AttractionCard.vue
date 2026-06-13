<template>
  <div
    :class="['acard', store.dragAttrId === attr.id && 'acard--dragging']"
    draggable="true"
    @dragstart="e => { e.dataTransfer.effectAllowed = 'copy'; store.startAttrDrag(attr) }"
    @dragend="store.endDrag()"
  >
    <div class="acard-name">{{ attr.name }}</div>
    <div class="acard-bottom">
      <span class="acard-loc"><i class="fa-solid fa-location-dot"></i> {{ attr.location }}</span>
      <router-link :to="`/attraction/${attr.id}`" class="acard-info" @click.stop>
        <i class="fa-solid fa-circle-info"></i> 詳情
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { usePlanStore } from '@/stores/plan'

defineProps({ attr: { type: Object, required: true } })
const store = usePlanStore()
</script>

<style scoped>
.acard {
  background: var(--surf);
  border: 1.5px solid var(--bd);
  border-radius: 9px;
  padding: 9px 11px;
  cursor: grab;
  user-select: none;
  transition: border-color .15s, box-shadow .15s, opacity .15s;
}
.acard:hover { border-color: var(--gn2); box-shadow: 0 2px 6px rgba(0,0,0,.07); }
.acard--dragging { opacity: .3; }

.acard-name {
  font-weight: 600;
  font-size: 1.0rem;
  color: var(--tx);
  margin-bottom: 5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.acard-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}

.acard-loc {
  font-size: .88rem;
  color: var(--tx3);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.acard-info {
  font-size: .86rem;
  color: var(--gn2);
  text-decoration: none;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 3px;
  flex-shrink: 0;
  transition: color .12s;
}
.acard-info:hover { color: var(--gn); }
</style>
