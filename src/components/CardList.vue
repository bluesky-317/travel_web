<script setup>
import TravelCard from '../components/TravelCard.vue'
import { ref, onMounted, computed, onUnmounted } from 'vue'
import { useAttractionStore } from '@/stores/Attraction'

const store = useAttractionStore()

const travelSpots = computed(() =>
  store.list.map((a) => ({
    id: a.id,
    image: a.imageUrl || '',
    category: a.category || '',
    location: a.location || '',
    title: a.name,
    description: a.description || '',
    link: `/attraction/${a.id}`,
  }))
)

const slider = ref(null)
const currentIndex = ref(0)
const cardsPerPage = ref(5)

const totalDots = computed(() => {
  if (travelSpots.value.length === 0) return 0
  const dotsCount = travelSpots.value.length - cardsPerPage.value + 1
  return Math.max(1, dotsCount)
})

const updateCardsPerPage = () => {
  const width = window.innerWidth
  if (width <= 640) {
    cardsPerPage.value = 1
  } else if (width <= 1024) {
    cardsPerPage.value = 2
  } else {
    cardsPerPage.value = 5
  }
}

const handleScroll = () => {
  if (!slider.value) return
  const container = slider.value
  const children = container.children
  if (children.length === 0) return
  const cardWidth = children[0].offsetWidth + 20
  const scrollLeft = container.scrollLeft
  const index = Math.round(scrollLeft / cardWidth)
  currentIndex.value = Math.max(0, Math.min(index, totalDots.value - 1))
}

const scrollToIndex = (index) => {
  if (!slider.value) return
  const container = slider.value
  const children = container.children
  if (children.length === 0) return
  const cardWidth = children[0].offsetWidth + 20
  container.scrollTo({ left: index * cardWidth, behavior: 'smooth' })
}

const scrollPrev = () => {
  if (currentIndex.value > 0) scrollToIndex(currentIndex.value - 1)
}

const scrollNext = () => {
  if (currentIndex.value < totalDots.value - 1) scrollToIndex(currentIndex.value + 1)
}


onMounted(() => {
  store.fetchList()
  updateCardsPerPage()
  window.addEventListener('resize', updateCardsPerPage)
})

onUnmounted(() => {
  window.removeEventListener('resize', updateCardsPerPage)
})
</script>

<template>
  <div class="container">
    <slot name="title">
      <h3 class="section-title">熱門推薦</h3>
    </slot>

    <div v-if="store.listLoading" class="state-msg">
      <i class="fa-solid fa-spinner fa-spin"></i> 載入中…
    </div>

    <div v-else-if="store.listError" class="state-msg state-msg--error">
      <i class="fa-solid fa-circle-exclamation"></i> {{ store.listError }}
      <button class="retry-btn" @click="store.fetchList(store.listPage)">重新載入</button>
    </div>

    <template v-else>
      <div class="carousel-container">
        <button
          class="nav-btn prev-btn"
          @click="scrollPrev"
          :class="{ 'btn-disabled': currentIndex === 0 }"
        >
          &#10094;
        </button>

        <div class="scroll-wrapper">
          <div class="card-grid" ref="slider" @scroll="handleScroll">
            <TravelCard
              v-for="spot in travelSpots"
              :key="spot.id"
              :image="spot.image"
              :category="spot.category"
              :location="spot.location"
              :title="spot.title"
              :description="spot.description"
              :link="spot.link"
            />
          </div>
        </div>

        <button
          class="nav-btn next-btn"
          @click="scrollNext"
          :class="{ 'btn-disabled': currentIndex === totalDots - 1 }"
        >
          &#10095;
        </button>
      </div>
    </template>

    <div v-if="!store.listLoading && !store.listError" class="dots-container">
      <span
        v-for="index in totalDots"
        :key="'dot-' + index"
        class="dot"
        :class="{ 'active': currentIndex === (index - 1) }"
        @click="scrollToIndex(index - 1)"
      ></span>
    </div>

  </div>
</template>

<style scoped>
.container {
  max-width: 1400px;
  margin: 2rem auto;
  padding: 0 20px;
}

:deep(.section-title) {
  text-align: center;
  margin-bottom: 2rem;
  font-size: 2rem;
  color: #2c3e50;
}

.carousel-container {
  display: flex;
  align-items: center;
  position: relative;
  width: 100%;
}

.scroll-wrapper {
  flex: 1;
  overflow: hidden;
  position: relative;
  -webkit-mask-image: linear-gradient(to right, transparent, black 5%, black 95%, transparent);
  mask-image: linear-gradient(to right, transparent, black 5%, black 95%, transparent);
}

.card-grid {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  padding: 20px 0;
  scrollbar-width: none;
  scroll-snap-type: x proximity;
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
}

.card-grid::-webkit-scrollbar { display: none; }

.card-grid > * {
  flex: 0 0 calc((100% - 80px) / 5);
  scroll-snap-align: start;
}

@media (max-width: 1024px) {
  .card-grid > * { flex: 0 0 calc((100% - 20px) / 2); }
}

@media (max-width: 640px) {
  .card-grid > * { flex: 0 0 100%; }
}

.nav-btn {
  background: none;
  border: none;
  font-size: 2rem;
  color: #3b82f6;
  cursor: pointer;
  padding: 10px;
  user-select: none;
  transition: opacity 0.3s, transform 0.2s;
  z-index: 10;
}

.nav-btn:hover { transform: scale(1.2); }

.btn-disabled {
  opacity: 0.2;
  cursor: not-allowed;
  pointer-events: none;
}

.dots-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  margin-top: 1.5rem;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #cbd5e1;
  cursor: pointer;
  transition: background-color 0.3s, transform 0.2s, width 0.3s;
}

.dot:hover { transform: scale(1.2); }

.dot.active {
  background-color: #3b82f6;
  width: 12px;
  height: 12px;
}


.state-msg {
  text-align: center;
  padding: 3rem 0;
  color: #9ca3af;
  font-size: 0.95rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
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
  transition: background 0.2s;
}

.retry-btn:hover { background: #ffe4e6; }
</style>
