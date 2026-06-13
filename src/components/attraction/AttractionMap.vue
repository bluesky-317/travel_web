<template>
  <div class="card">
    <h4 class="card-title">
      <i class="fa-solid fa-map-location-dot title-icon"></i> 地圖位置
    </h4>

    <div v-if="hasCoords" ref="mapEl" class="map-container"></div>
    <div v-else class="map-placeholder">
      <i class="fa-solid fa-map-location-dot placeholder-icon"></i>
      <span class="placeholder-text">座標資訊未提供</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: new URL('leaflet/dist/images/marker-icon-2x.png', import.meta.url).href,
  iconUrl: new URL('leaflet/dist/images/marker-icon.png', import.meta.url).href,
  shadowUrl: new URL('leaflet/dist/images/marker-shadow.png', import.meta.url).href,
})

const props = defineProps({
  lat: { type: [Number, String], default: null },
  lon: { type: [Number, String], default: null },
})

const mapEl = ref(null)
let mapInstance = null

const hasCoords = computed(() => {
  const lat = parseFloat(props.lat)
  const lon = parseFloat(props.lon)
  return !isNaN(lat) && !isNaN(lon)
})

onMounted(() => {
  if (!hasCoords.value || !mapEl.value) return
  const lat = parseFloat(props.lat)
  const lon = parseFloat(props.lon)

  mapInstance = L.map(mapEl.value, { scrollWheelZoom: false }).setView([lat, lon], 15)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19,
  }).addTo(mapInstance)
  L.marker([lat, lon]).addTo(mapInstance)
})

onUnmounted(() => {
  if (mapInstance) {
    mapInstance.remove()
    mapInstance = null
  }
})
</script>

<style scoped>
.card {
  background: rgba(249, 250, 251, 0.5);
  border: 1px solid rgba(229, 231, 235, 0.8);
  border-radius: 0.75rem;
  padding: 1rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}

.card-title {
  font-size: 0.75rem;
  font-weight: 700;
  color: #374151;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 0.625rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.title-icon {
  font-size: 0.875rem;
  color: #3b82f6;
}

.map-container {
  height: 220px;
  border-radius: 0.5rem;
  overflow: hidden;
  border: 1px solid rgba(229, 231, 235, 0.8);
}

.map-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 8rem;
  background: #fff;
  border: 1px dashed #d1d5db;
  border-radius: 0.5rem;
  color: #9ca3af;
}

.placeholder-icon {
  font-size: 1.5rem;
  margin-bottom: 0.25rem;
  color: #d1d5db;
}

.placeholder-text {
  font-size: 0.75rem;
  font-weight: 500;
}
</style>
