<template>
  <div class="page">

    <!-- 返回按鈕 -->
    <div class="back-wrap">
      <button @click="router.back()" class="back-btn">
        <i class="fa-solid fa-arrow-left back-btn-icon"></i>
        <span>返回</span>
      </button>
    </div>

    <!-- Loading 狀態 -->
    <div v-if="store.loading" class="loading">
      <i class="fa-solid fa-spinner spin"></i>
    </div>

    <!-- 錯誤狀態 -->
    <div v-else-if="store.error" class="error">
      <i class="fa-solid fa-circle-exclamation error-icon"></i>
      <p class="error-text">{{ store.error }}</p>
      <button @click="store.fetchAttraction(attractionId)" class="retry-btn">
        重新載入
      </button>
    </div>

    <!-- 主卡片 -->
    <div v-else-if="attraction" class="card">

      <!-- 圖片展示區塊 -->
      <div class="image-box">
        <img
          v-if="attraction.imageUrl"
          :src="attraction.imageUrl"
          :alt="attraction.name"
          class="image"
        />
        <div v-else class="image-placeholder">
          <i class="fa-solid fa-mountain-sun placeholder-icon"></i>
          <span class="placeholder-text">圖片展示區塊</span>
        </div>
      </div>

      <!-- 主體網格 -->
      <div class="grid">

        <!-- 左側主要欄 -->
        <div class="main-col">
          <h1 class="title">{{ attraction.name }}</h1>

          <div v-if="attraction.rating != null" class="rating-row">
            <span v-for="i in 5" :key="i" class="star">
              <i :class="starClass(i, attraction.rating)"></i>
            </span>
            <span class="rating-value">{{ Number(attraction.rating).toFixed(1) }}</span>
          </div>

          <AttractionBasicInfo
            :attraction="attraction"
            :category="store.category"
            :formatted-date="formattedDate"
          />

          <AttractionDescription :description="attraction.description" />
        </div>

        <!-- 右側側邊欄 -->
        <div class="side-col">
          <AttractionMap :lat="attraction.lat" :lon="attraction.lon" />

          <AttractionOpeningHours
            v-if="attraction.openingHours"
            :hours="attraction.openingHours"
          />

          <AttractionTicketInfo
            v-if="attraction.ticketInfo"
            :info="attraction.ticketInfo"
          />

          <!-- 加入行程 -->
          <div class="side-card">
            <button
              @click="handleAddToItinerary"
              :title="!isLoggedIn ? '請先登入' : ''"
              :class="['itinerary-btn', { 'itinerary-btn--added': store.isInItinerary }]"
            >
              <i
                :class="[
                  'fa-solid itinerary-icon',
                  store.isInItinerary ? 'fa-circle-minus' : 'fa-plus'
                ]"
              ></i>
              {{ store.isInItinerary ? '取消加入行程' : '加入行程' }}
              <i v-if="!isLoggedIn" class="fa-solid fa-lock lock-icon"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>

  <LoginModal v-if="authStore.isLoginModalOpen" />
  <RegisterModal v-if="authStore.isRegisterModalOpen" />
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAttractionStore } from '@/stores/Attraction'
import { useAuthStore } from '@/stores/auth'

import AttractionBasicInfo from '@/components/attraction/AttractionBasicInfo.vue'
import AttractionDescription from '@/components/attraction/AttractionDescription.vue'
import AttractionMap from '@/components/attraction/AttractionMap.vue'
import AttractionOpeningHours from '@/components/attraction/AttractionOpeningHours.vue'
import AttractionTicketInfo from '@/components/attraction/AttractionTicketInfo.vue'
import LoginModal from '@/components/LoginModal.vue'
import RegisterModal from '@/components/RegisterModal.vue'

const router = useRouter()
const route = useRoute()
const store = useAttractionStore()
const authStore = useAuthStore()

const attractionId = computed(() => route.params.id)
const attraction = computed(() => store.attraction)
const isLoggedIn = computed(() => !!authStore.token)

const formattedDate = computed(() => {
  if (!attraction.value?.updatedAt) return ''
  return new Date(attraction.value.updatedAt).toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
})

function starClass(index, rating) {
  if (rating >= index) return 'fa-solid fa-star'
  if (rating >= index - 0.5) return 'fa-solid fa-star-half-stroke'
  return 'fa-regular fa-star'
}

const handleAddToItinerary = () => {
  if (!isLoggedIn.value) {
    authStore.openLoginModal()
    return
  }
  store.toggleItinerary()
}

onMounted(() => {
  store.fetchAttraction(attractionId.value)
})
</script>

<style scoped>
.page {
  min-height: 100vh;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #374151;
  font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  background-color: #f7f6f2;
  background-image:
    linear-gradient(to right, rgba(0, 0, 0, 0.03) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(0, 0, 0, 0.03) 1px, transparent 1px);
  background-size: 24px 24px;
}
@media (min-width: 768px) {
  .page { padding: 2rem; }
}

/* 返回按鈕 */
.back-wrap {
  max-width: 72rem;
  width: 100%;
  margin-bottom: 1rem;
  display: flex;
  justify-content: flex-start;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.8);
  color: #4b5563;
  padding: 0.5rem 1rem;
  border-radius: 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  border: 1px solid rgba(229, 231, 235, 0.8);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  backdrop-filter: blur(4px);
  cursor: pointer;
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}
.back-btn:hover {
  background: #fff;
  color: #111827;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}
.back-btn-icon {
  font-size: 1rem;
  transition: transform 0.2s;
}
.back-btn:hover .back-btn-icon {
  transform: translateX(-2px);
}

/* Loading */
.loading {
  max-width: 72rem;
  width: 100%;
  display: flex;
  justify-content: center;
  padding: 6rem 0;
  color: #9ca3af;
}
.spin {
  font-size: 1.875rem;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

/* Error */
.error {
  max-width: 72rem;
  width: 100%;
  background: #fff1f2;
  border: 1px solid #fecdd3;
  color: #e11d48;
  border-radius: 1rem;
  padding: 2rem;
  text-align: center;
}
.error-icon {
  font-size: 1.875rem;
  margin-bottom: 0.5rem;
  display: block;
}
.error-text { font-weight: 500; }
.retry-btn {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background: #ffe4e6;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  border: none;
  cursor: pointer;
  transition: background 0.2s;
  color: inherit;
}
.retry-btn:hover { background: #fecdd3; }

/* 主卡片 */
.card {
  max-width: 72rem;
  width: 100%;
  background: #fff;
  border-radius: 1rem;
  box-shadow:
    0 15px 35px rgba(0, 0, 0, 0.06),
    0 5px 15px rgba(0, 0, 0, 0.02);
  border: 1px solid rgba(229, 231, 235, 0.5);
  overflow: hidden;
}

/* 圖片區 */
.image-box {
  background: linear-gradient(to bottom right, #eceae1, #dfdbcf);
  height: 16rem;
  width: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(229, 231, 235, 0.6);
}
@media (min-width: 768px) {
  .image-box { height: 20rem; }
}
.image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.image-placeholder { text-align: center; }
.placeholder-icon {
  color: #9ca3af;
  font-size: 2.25rem;
  display: block;
  margin-bottom: 0.5rem;
}
.placeholder-text {
  color: #9ca3af;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
}

/* 內容網格 */
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  padding: 1.5rem;
}
@media (min-width: 768px) {
  .grid { padding: 2rem; }
}
@media (min-width: 1024px) {
  .grid { grid-template-columns: 2fr 1fr; }
}
.main-col {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}
.side-col {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* 評價 */
.rating-row {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  margin-top: -0.75rem;
}
.star {
  font-size: 1rem;
  color: #f59e0b;
}
.rating-value {
  font-size: 0.9rem;
  font-weight: 600;
  color: #92400e;
  margin-left: 0.25rem;
}

/* 標題 */
.title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
  letter-spacing: 0.025em;
  margin: 0;
}
@media (min-width: 768px) {
  .title { font-size: 1.875rem; }
}

/* 加入行程卡片 */
.side-card {
  background: rgba(249, 250, 251, 0.5);
  border: 1px solid rgba(229, 231, 235, 0.8);
  border-radius: 0.75rem;
  padding: 1rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}
.itinerary-btn {
  width: 100%;
  font-weight: 500;
  padding: 0.625rem 0;
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;
  font-size: 0.75rem;
  background: #2563eb;
  color: #fff;
  border: none;
  cursor: pointer;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  transition: background 0.2s;
}
.itinerary-btn:hover { background: #1d4ed8; }
.itinerary-btn--added {
  background: #e5e7eb;
  color: #4b5563;
  border: 1px solid #d1d5db;
}
.itinerary-btn--added:hover { background: #d1d5db; }
.itinerary-icon { font-size: 0.875rem; }
.lock-icon {
  font-size: 0.75rem;
  opacity: 0.6;
}
</style>
