<template>
  <div class="center">

    <!-- Placeholder when no itinerary selected -->
    <div v-if="!store.activeItinerary" class="no-itin">
      <i class="fa-solid fa-map-location-dot" style="font-size:3rem;opacity:.25;"></i>
      <p>選擇左側旅程或建立新旅程以開始規劃</p>
    </div>

    <template v-else>
      <!-- ── Header ── -->
      <div class="center-hd">
        <el-input
          class="title-input"
          v-model="titleModel"
          placeholder="旅程名稱"
          maxlength="40"
        />
        <el-segmented
          v-model="store.centerView"
          :options="VIEW_OPTS"
          style="flex-shrink:0"
        >
          <template #default="{ item }">
            <i :class="item.icon"></i> {{ item.label }}
          </template>
        </el-segmented>
      </div>

      <!-- ── Date row ── -->
      <div class="date-row">
        <div class="date-field">
          <i class="fa-regular fa-calendar" style="color:var(--tx3);"></i>
          <span class="date-label">開始日期：</span>
          <el-date-picker
            class="dp"
            type="date"
            size="small"
            :model-value="store.activeItinerary.startDate"
            value-format="YYYY-MM-DD"
            :clearable="false"
            :disabled-date="disablePastDates"
            placeholder="選擇日期"
            @update:model-value="store.setStartDate($event)"
          />
        </div>
        <div class="date-field">
          <i class="fa-regular fa-calendar-check" style="color:var(--tx3);"></i>
          <span class="date-label">結束日期：</span>
          <span class="date-val">{{ fmtDate(store.activeEndDate) }}</span>
        </div>
      </div>

      <!-- ── Day tabs ── -->
      <div class="day-tabs-wrap">
        <el-button text size="small" :disabled="tabScroll <= 0" @click="tabScroll = Math.max(0, tabScroll - 1)">
          <i class="fa-solid fa-chevron-left"></i>
        </el-button>
        <div class="day-tabs" ref="tabsEl">
          <button
            v-for="(_, di) in store.activeItinerary.days"
            :key="di"
            :class="['day-tab', store.activeDay === di && 'day-tab--active']"
            @click="store.setActiveDay(di)"
          >
            Day {{ di + 1 }}
            <span
              v-if="store.activeItinerary.numDays > 1"
              class="day-del"
              @click.stop="store.removeDay(di)"
              title="移除此天"
            >
              <i class="fa-solid fa-xmark"></i>
            </span>
          </button>
        </div>
        <el-button text size="small" :disabled="tabScroll >= maxScroll" @click="tabScroll = Math.min(maxScroll, tabScroll + 1)">
          <i class="fa-solid fa-chevron-right"></i>
        </el-button>
        <el-button
          class="day-add"
          size="small"
          :disabled="store.activeItinerary.numDays >= 10"
          @click="store.addDay()"
          title="新增一天"
        >
          <i class="fa-solid fa-plus"></i>
        </el-button>
      </div>

      <!-- ── Main area: List or Map ── -->
      <div class="main-area">

        <!-- List mode -->
        <div
          v-if="store.centerView === 'timeline'"
          class="timeline"
          @dragover.prevent="store.overDrop = store.isDragAttr"
          @dragleave="store.overDrop = false"
          @drop.prevent="store.dropOnZone()"
        >
          <div
            v-if="!store.activeDayItems.length"
            :class="['dropzone', store.isDragAttr && store.overDrop && 'dz-over']"
          >
            <i class="fa-solid fa-arrow-up-to-line"></i>
            從右側拖曳景點到此處加入行程
          </div>

          <template v-else>
            <div
              v-for="item in store.activeDayItems"
              :key="item.uid"
              :class="[
                'tl-item',
                store.dragItemUid === item.uid && 'tl-item--src',
                store.overItemUid === item.uid && 'tl-item--over',
              ]"
              draggable="true"
              @dragstart="e => startItemDrag(e, item)"
              @dragend="endItemDrag"
              @dragover.prevent="store.overItemUid = item.uid"
              @dragleave="store.overItemUid = null"
              @drop.prevent="dropOnItem(item.uid)"
            >
              <!-- 主行 -->
              <div class="tl-row">
                <span class="drag-handle"><i class="fa-solid fa-grip-vertical"></i></span>
                <div class="tl-content">
                  <div class="tl-name">{{ item.name }}</div>
                  <div class="tl-note-preview" v-if="item.note">{{ item.note }}</div>
                </div>
                <div class="tl-time">
                  <el-time-picker
                    class="tp"
                    size="small"
                    :model-value="item.startTime"
                    value-format="HH:mm"
                    format="HH:mm"
                    :clearable="false"
                    :disabled-hours="() => startDisabledHours(item.endTime)"
                    :disabled-minutes="h => startDisabledMinutes(h, item.endTime)"
                    @update:model-value="v => v && store.setItemField(store.activeDay, item.uid, 'startTime', v)"
                  />
                  <span class="time-sep">-</span>
                  <el-time-picker
                    class="tp"
                    size="small"
                    :model-value="item.endTime"
                    value-format="HH:mm"
                    format="HH:mm"
                    :clearable="false"
                    :disabled-hours="() => endDisabledHours(item.startTime)"
                    :disabled-minutes="h => endDisabledMinutes(h, item.startTime)"
                    @update:model-value="v => v && store.setItemField(store.activeDay, item.uid, 'endTime', v)"
                  />
                </div>
                <el-button text title="備註" @click="openNote(item)">
                  <i class="fa-solid fa-file-lines"></i>
                </el-button>
                <el-button text type="danger" title="移除" @click="store.removeItem(store.activeDay, item.uid)">
                  <i class="fa-solid fa-xmark"></i>
                </el-button>
              </div>

              <!-- AI 排程額外資訊 -->
              <div v-if="item.imageUrl || item.openingHours || item.ticketInfo || item.category" class="tl-extra">
                <img v-if="item.imageUrl" :src="item.imageUrl" :alt="item.name" class="tl-thumb" />
                <div class="tl-meta">
                  <span v-if="item.location" class="tl-meta-row">
                    <i class="fa-solid fa-location-dot"></i> {{ item.location }}
                  </span>
                  <span v-if="item.category" class="tl-meta-row tl-category">
                    <span class="tl-category-pill">{{ item.category }}</span>
                  </span>
                  <span v-if="item.openingHours" class="tl-meta-row">
                    <i class="fa-regular fa-clock"></i> {{ item.openingHours }}
                  </span>
                  <span v-if="item.ticketInfo" class="tl-meta-row">
                    <i class="fa-solid fa-ticket"></i> {{ item.ticketInfo }}
                  </span>
                  <span v-if="item.rating != null" class="tl-meta-row">
                    <i class="fa-solid fa-star" style="color:#f59e0b"></i> {{ Number(item.rating).toFixed(1) }}
                  </span>
                </div>
              </div>
            </div>

            <div
              :class="['dropzone dropzone--sm', store.isDragAttr && store.overDrop && 'dz-over']"
            >
              <i class="fa-solid fa-arrow-up-to-line"></i> 繼續拖曳景點加入
            </div>
          </template>
        </div>

        <!-- Map mode -->
        <div v-else class="map-wrap">
          <div ref="mapEl" class="leaflet-map"></div>
        </div>
      </div>

      <!-- ── Footer ── -->
      <div class="center-ft">
        <div class="ft-stats">
          <span><i class="fa-solid fa-location-dot"></i> {{ store.activeDayStats.count }} 個景點</span>
          <span><i class="fa-regular fa-clock"></i> {{ store.activeDayStats.duration }}</span>
          <span>共 {{ store.activeItinerary.numDays }} 天</span>
        </div>
        <el-button
          class="save-btn"
          :disabled="!store.isDirty"
          :loading="store.isSaving"
          @click="store.saveToBackend()"
        >
          <i v-if="!store.isSaving" class="fa-solid fa-floppy-disk"></i>
          儲存行程
        </el-button>
      </div>
    </template>

    <!-- Note dialog -->
    <el-dialog
      v-model="noteDialog.open"
      title="備註"
      width="460px"
      align-center
    >
      <div class="note-area-wrap">
        <el-input
          v-model="noteDialog.text"
          type="textarea"
          :rows="6"
          :maxlength="1500"
          show-word-limit
          placeholder="請輸入備註內容…"
          resize="none"
        />
      </div>
      <template #footer>
        <el-button @click="noteDialog.open = false">取消</el-button>
        <el-button type="primary" @click="saveNote">儲存</el-button>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import { ref, watch, nextTick, computed, onUnmounted } from 'vue'
import { usePlanStore, fmtDate } from '@/stores/plan'
import L from 'leaflet'

const store = usePlanStore()

const titleModel = computed({
  get: () => store.activeItinerary?.title ?? '',
  set: (v) => store.setTitle(v),
})

const VIEW_OPTS = [
  { label: '列表模式', value: 'timeline', icon: 'fa-solid fa-list' },
  { label: '地圖模式', value: 'map',      icon: 'fa-solid fa-map'  },
]

// ── date / time validation ────────────────────────────────────────────────────
function disablePastDates(d) {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return d.getTime() < today.getTime()
}

function startDisabledHours(endTime) {
  const [eh] = endTime.split(':').map(Number)
  return Array.from({ length: 24 - eh - 1 }, (_, i) => eh + 1 + i)
}
function startDisabledMinutes(hour, endTime) {
  const [eh, em] = endTime.split(':').map(Number)
  if (hour === eh) return Array.from({ length: 60 - em }, (_, i) => em + i)
  return []
}
function endDisabledHours(startTime) {
  const [sh] = startTime.split(':').map(Number)
  return Array.from({ length: sh }, (_, i) => i)
}
function endDisabledMinutes(hour, startTime) {
  const [sh, sm] = startTime.split(':').map(Number)
  if (hour === sh) return Array.from({ length: sm + 1 }, (_, i) => i)
  return []
}

// ── day tab scroll ────────────────────────────────────────────────────────────
const tabsEl = ref(null)
const tabScroll = ref(0)
const TAB_W = 88 // approx px per tab
const maxScroll = computed(() => Math.max(0, (store.activeItinerary?.numDays ?? 0) - 1))

watch(tabScroll, v => {
  if (tabsEl.value) tabsEl.value.scrollLeft = v * TAB_W
})

// ── note dialog ───────────────────────────────────────────────────────────────
const noteDialog = ref({ open: false, item: null, text: '' })

function openNote(item) {
  noteDialog.value = { open: true, item, text: item.note || '' }
}
function saveNote() {
  const { item, text } = noteDialog.value
  if (item) store.setItemField(store.activeDay, item.uid, 'note', text)
  noteDialog.value.open = false
}

// ── item drag (reorder within day) ───────────────────────────────────────────
function startItemDrag(e, item) {
  e.dataTransfer.effectAllowed = 'move'
  store.dragItemUid = item.uid
}
function endItemDrag() {
  store.dragItemUid = null
  store.overItemUid = null
}
function dropOnItem(toUid) {
  if (store.dragItemUid) {
    store.moveItem(store.activeDay, store.dragItemUid, toUid)
  } else if (store.isDragAttr && store.dragAttr) {
    store.dropOnZone()
  }
  store.dragItemUid = null
  store.overItemUid = null
}

// ── Leaflet map ───────────────────────────────────────────────────────────────
const mapEl = ref(null)
let leafletMap = null
let markers = []

function initMap() {
  if (!mapEl.value || !window.L) return
  if (leafletMap) { leafletMap.remove(); leafletMap = null }
  leafletMap = window.L.map(mapEl.value).setView([23.8, 121.0], 8)
  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
  }).addTo(leafletMap)
  updateMarkers()
}

function updateMarkers() {
  if (!leafletMap) return
  markers.forEach(m => m.remove())
  markers = []
  const items = store.activeDayItems
  const itin = store.activeItinerary
  if (!items.length || !itin) return

  const dayDate = (() => {
    const d = new Date(itin.startDate + 'T00:00:00')
    d.setDate(d.getDate() + store.activeDay)
    return `${d.getFullYear()}/${String(d.getMonth()+1).padStart(2,'0')}/${String(d.getDate()).padStart(2,'0')}`
  })()

  const bounds = []
  items.forEach(item => {
    const attr = store.attractions.find(a => String(a.id) === String(item.attractionId))
    if (!attr?.lat || !attr?.lon) return
    const coords = [attr.lat, attr.lon]
    bounds.push(coords)
    const marker = window.L.marker(coords).addTo(leafletMap)
    marker.bindTooltip(
      `<b>${item.name}</b><br>📅 ${dayDate}<br>🕐 ${item.startTime} - ${item.endTime}` +
      (item.note ? `<br>📝 ${item.note}` : ''),
      { permanent: false, direction: 'top', className: 'lf-tooltip' }
    )
    markers.push(marker)
  })
  if (bounds.length) leafletMap.fitBounds(bounds, { padding: [40, 40] })
}

watch(() => store.centerView, async v => {
  if (v === 'map') {
    await nextTick()
    initMap()
  }
})

watch(() => [store.activeDay, store.activeDayItems.length, store.centerView], () => {
  if (store.centerView === 'map' && leafletMap) updateMarkers()
}, { deep: true })

watch(() => store.activeId, async () => {
  tabScroll.value = 0
  if (store.centerView === 'map') {
    await nextTick()
    updateMarkers()
  }
})

onUnmounted(() => {
  if (leafletMap) { leafletMap.remove(); leafletMap = null }
})
</script>

<style scoped>
.center {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: var(--bg);
}

/* ── No itinerary placeholder ── */
.no-itin {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
  color: var(--tx3);
  font-size: .9rem;
  text-align: center;
}

/* ── Header ── */
.center-hd {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  background: var(--surf);
  border-bottom: 1px solid var(--bd);
  box-shadow: 0 2px 6px rgba(0,0,0,.04);
  flex-shrink: 0;
  z-index: 1;
}

.title-input {
  flex: 1;
  min-width: 0;
  font-size: 1.08rem !important;
  font-weight: 600 !important;
}

/* ── Date row ── */
.date-row {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 14px;
  background: var(--surf);
  border-bottom: 1px solid var(--bd);
  flex-shrink: 0;
}

.date-field {
  display: flex;
  align-items: center;
  gap: 6px;
}
.date-label { font-size: .92rem; color: var(--tx2); white-space: nowrap; }
.date-val { font-size: .96rem; font-weight: 500; color: var(--tx); }

.dp { width: 130px; }
.dp :deep(.el-input__wrapper) {
  background: var(--surf2);
  box-shadow: 0 0 0 1px var(--bd2) inset;
  border-radius: 7px;
  padding: 0 6px;
}
.dp :deep(.el-input__wrapper:hover),
.dp :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px var(--gn) inset;
}
.dp :deep(.el-input__inner) {
  font-family: 'DM Sans', sans-serif;
  font-size: .8rem;
  color: var(--tx);
}

/* ── Day tabs ── */
.day-tabs-wrap {
  display: flex;
  align-items: center;
  gap: 0;
  padding: 6px 10px;
  background: var(--surf);
  border-bottom: 1px solid var(--bd);
  flex-shrink: 0;
  overflow: hidden;
}


.day-tabs {
  display: flex;
  gap: 4px;
  flex: 1;
  overflow-x: hidden;
  scroll-behavior: smooth;
}

.day-tab {
  border: 1.5px solid var(--bd2);
  background: var(--surf2);
  color: var(--tx2);
  border-radius: 7px;
  padding: 4px 10px;
  font-family: 'DM Sans', sans-serif;
  font-size: .92rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
  transition: all .13s;
  flex-shrink: 0;
}
.day-tab:hover { border-color: var(--gn2); color: var(--gn); }
.day-tab--active { background: var(--gn); border-color: var(--gn); color: #fff; }
.day-tab--active:hover { color: #fff; }

.day-del {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  font-size: .82rem;
  opacity: .7;
  transition: opacity .12s, background .12s;
}
.day-tab:hover .day-del { opacity: 1; }
.day-tab--active .day-del:hover { background: rgba(255,255,255,.25); }

.day-add {
  --el-button-bg-color: var(--gn3);
  --el-button-border-color: var(--gn2);
  --el-button-text-color: var(--gn);
  --el-button-hover-bg-color: var(--gn4);
  --el-button-hover-border-color: var(--gn);
  --el-button-hover-text-color: var(--gn);
  border-style: dashed !important;
  margin-left: 4px;
}

/* ── Main area ── */
.main-area {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* ── Timeline / list mode ── */
.timeline {
  flex: 1;
  overflow-y: auto;
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.dropzone {
  border: 2px dashed var(--bd2);
  border-radius: 10px;
  padding: 22px;
  text-align: center;
  color: var(--tx3);
  font-size: .98rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: border-color .15s, background .15s, color .15s;
  flex: 1;
  min-height: 80px;
}
.dropzone--sm { flex: none; min-height: unset; padding: 12px; }
.dropzone.dz-over { border-color: var(--gn); background: var(--gn3); color: var(--gn); }

.tl-item {
  display: flex;
  flex-direction: column;
  background: var(--surf);
  border: 1.5px solid var(--bd);
  border-left: 3px solid var(--bd2);
  border-radius: 10px;
  padding: 8px 10px;
  cursor: default;
  box-shadow: 0 1px 4px rgba(0,0,0,.05);
  transition: border-color .14s, background .14s, opacity .14s, box-shadow .14s;
}
.tl-item:hover { border-color: var(--gn2); border-left-color: var(--gn2); box-shadow: 0 2px 8px rgba(26,92,150,.1); }
.tl-item--src { opacity: .35; }
.tl-item--over { border-color: var(--gn); border-left-color: var(--gn); background: var(--gn3); }

/* 主行 (原本的行內佈局) */
.tl-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* AI 排程額外資訊 */
.tl-extra {
  display: flex;
  gap: 8px;
  margin-top: 7px;
  padding-top: 7px;
  border-top: 1px dashed var(--bd);
}

.tl-thumb {
  width: 64px;
  height: 52px;
  object-fit: cover;
  border-radius: 6px;
  flex-shrink: 0;
}

.tl-meta {
  display: flex;
  flex-direction: column;
  gap: 3px;
  font-size: .78rem;
  color: var(--tx2);
  min-width: 0;
}

.tl-meta-row {
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tl-category { flex-wrap: wrap; white-space: normal; }

.tl-category-pill {
  background: var(--gn3);
  color: var(--gn);
  border-radius: 4px;
  padding: 1px 5px;
  font-size: .72rem;
  font-weight: 500;
}

.drag-handle {
  color: var(--tx3);
  font-size: .78rem;
  cursor: grab;
  flex-shrink: 0;
  padding: 0 2px;
}

.tl-content {
  flex: 1;
  min-width: 0;
}
.tl-name {
  font-weight: 600;
  font-size: 1.0rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.tl-note-preview {
  font-size: .88rem;
  color: var(--tx3);
  margin-top: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tl-time {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}
.time-sep { font-size: .92rem; color: var(--tx3); }

.tp { width: 80px; }
.tp :deep(.el-input__wrapper) {
  background: var(--surf2);
  box-shadow: 0 0 0 1px var(--bd2) inset;
  border-radius: 6px;
  padding: 0 5px;
}
.tp :deep(.el-input__wrapper:hover),
.tp :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px var(--gn) inset;
}
.tp :deep(.el-input__inner) {
  font-family: 'DM Sans', sans-serif;
  font-size: .78rem;
  color: var(--tx);
}


/* ── Map mode ── */
.map-wrap {
  flex: 1;
  overflow: hidden;
  position: relative;
}
.leaflet-map {
  width: 100%;
  height: 100%;
}

/* ── Footer ── */
.center-ft {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
  background: var(--surf);
  border-top: 1px solid var(--bd);
  flex-shrink: 0;
}

.ft-stats {
  display: flex;
  gap: 14px;
  font-size: .9rem;
  color: var(--tx2);
}
.ft-stats span { display: flex; align-items: center; gap: 4px; }

.save-btn {
  --el-button-bg-color: var(--gn);
  --el-button-border-color: var(--gn);
  --el-button-text-color: #fff;
  --el-button-hover-bg-color: var(--gn2);
  --el-button-hover-border-color: var(--gn2);
  --el-button-hover-text-color: #fff;
  font-weight: 600 !important;
  letter-spacing: .02em;
  padding: 0 20px !important;
}
.save-btn :deep(span) {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ── Note dialog ── */
.note-area-wrap { padding: 4px 0; }
</style>

<style>
.lf-tooltip {
  background: #fff;
  border: 1px solid #e5ddd0;
  border-radius: 8px;
  box-shadow: 0 3px 12px rgba(0,0,0,.12);
  font-size: 13px;
  line-height: 1.5;
  padding: 8px 12px;
}
.lf-tooltip::before { display: none; }
</style>
