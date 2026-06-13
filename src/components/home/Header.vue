<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import Navbar from '../Navbar.vue'
import Waves from '../Waves.vue'
import { useAttractionStore } from '@/stores/Attraction'

const store = useAttractionStore()

const slides = computed(() =>
  store.list.filter(a => a.imageUrl).slice(0, 8)
)

const currentIndex = ref(0)
let timer = null

function goTo(i) {
  currentIndex.value = i
  clearInterval(timer)
  startAuto()
}

function startAuto() {
  timer = setInterval(() => {
    if (!slides.value.length) return
    currentIndex.value = (currentIndex.value + 1) % slides.value.length
  }, 4500)
}

onMounted(() => {
  store.fetchList()
  startAuto()
})

onUnmounted(() => clearInterval(timer))
</script>

<template>
  <Navbar />
  <div class="hero-header">
    <!-- All slides stacked; opacity cross-fade -->
    <div
      v-for="(slide, i) in slides"
      :key="slide.id"
      class="slide"
      :class="{ 'slide--active': i === currentIndex }"
      :style="{ backgroundImage: `url(${slide.imageUrl})` }"
    />
    <div v-if="!slides.length" class="slide slide--active slide--placeholder" />

    <!-- Gradient to ensure text readability -->
    <div class="overlay" />

    <!-- Attraction caption -->
    <transition name="caption-fade" mode="out-in">
      <div v-if="slides.length" :key="currentIndex" class="caption">
        <p class="caption-name">{{ slides[currentIndex].name }}</p>
        <p class="caption-location">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          {{ slides[currentIndex].location }}
        </p>
      </div>
    </transition>

    <!-- Dots indicator -->
    <div v-if="slides.length > 1" class="dots">
      <span
        v-for="(_, i) in slides"
        :key="i"
        class="dot"
        :class="{ active: i === currentIndex }"
        @click="goTo(i)"
      />
    </div>

    <!-- Wave pinned to bottom -->
    <div class="wave-wrap">
      <Waves />
    </div>
  </div>
</template>

<style scoped>
.hero-header {
  position: relative;
  width: 100%;
  aspect-ratio: 4 / 1;
  min-height: 280px;
  overflow: hidden;
  background: #333;
}

/* ── Slides ─────────────────────────────── */
.slide {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center;
  opacity: 0;
  transition: opacity 1s ease;
}
.slide--active    { opacity: 1; }
.slide--placeholder { background: #555; }

/* ── Gradient overlay ───────────────────── */
.overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    to bottom,
    rgba(0, 0, 0, 0.15) 0%,
    rgba(0, 0, 0, 0.55) 100%
  );
  z-index: 1;
  pointer-events: none;
}

/* ── Caption ────────────────────────────── */
.caption {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -70%);
  text-align: center;
  color: #fff;
  z-index: 2;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.65);
  pointer-events: none;
  white-space: nowrap;
}
.caption-name {
  font-size: 1.6rem;
  font-weight: 700;
  margin: 0 0 6px;
  letter-spacing: 0.5px;
}
.caption-location {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  font-size: 0.95rem;
  margin: 0;
  opacity: 0.85;
}

.caption-fade-enter-active,
.caption-fade-leave-active { transition: opacity 0.45s ease; }
.caption-fade-enter-from,
.caption-fade-leave-to     { opacity: 0; }

/* ── Dots ───────────────────────────────── */
.dots {
  position: absolute;
  top: calc(50% + 48px);
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 7px;
  z-index: 5;
}
.dot {
  height: 7px;
  width: 7px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  cursor: pointer;
  transition: background 0.3s, width 0.3s, border-radius 0.3s;
}
.dot:hover { background: rgba(255, 255, 255, 0.85); }
.dot.active {
  width: 22px;
  border-radius: 4px;
  background: #fff;
}

/* ── Wave ───────────────────────────────── */
.wave-wrap {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 4;
  line-height: 0;
}

/* ── Mobile ─────────────────────────────── */
@media (max-width: 768px) {
  .caption        { transform: translate(-50%, -72%); }
  .caption-name   { font-size: 1.1rem; }
  .caption-location { font-size: 0.8rem; }
  .dots           { top: calc(50% + 38px); }
}
</style>
