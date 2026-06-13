<template>
  <section class="section">
    <h3 class="section-title">基本資訊</h3>

    <div class="info-list">
      <div v-if="attraction.location" class="info-row">
        <i class="fa-solid fa-location-dot icon icon-place"></i>
        <div class="text">{{ attraction.location }}</div>
      </div>

      <div v-if="attraction.phone" class="info-row info-row--center">
        <i class="fa-solid fa-phone icon"></i>
        <div class="text">{{ attraction.phone }}</div>
      </div>

      <div v-if="attraction.website" class="info-row info-row--center">
        <i class="fa-solid fa-globe icon"></i>
        <a :href="attraction.website" target="_blank" class="link">
          {{ attraction.website.replace(/^https?:\/\//, '') }}
        </a>
      </div>

      <div v-if="category" class="info-row info-row--center">
        <i class="fa-solid fa-tag icon"></i>
        <div class="category">{{ category }}</div>
      </div>

      <div v-if="attraction.updatedAt" class="info-row info-row--center info-row--muted">
        <i class="fa-solid fa-clock-rotate-left icon"></i>
        <div>資料更新時間：{{ formattedDate }}</div>
      </div>
    </div>
  </section>
</template>

<script setup>
defineProps({
  attraction: {
    type: Object,
    required: true,
  },
  category: {
    type: String,
    default: '',
  },
  formattedDate: {
    type: String,
    default: '',
  },
})
</script>

<style scoped>
.section-title {
  font-size: 0.875rem;
  font-weight: 700;
  color: #1f2937;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 1rem;
  padding-left: 0.625rem;
  border-left: 4px solid #374151;
}

.info-list {
  border-top: 1px solid #f3f4f6;
  border-bottom: 1px solid #f3f4f6;
  font-size: 0.875rem;
}

.info-row {
  padding: 0.875rem 0;
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}
.info-row + .info-row {
  border-top: 1px solid #f3f4f6;
}
.info-row--center { align-items: center; }
.info-row--muted {
  color: #9ca3af;
  font-size: 0.75rem;
}

.icon {
  font-size: 1rem;
  color: #9ca3af;
  margin-top: 2px;
}
.icon-place { color: #f43f5e; }

.text { color: #374151; }

.link {
  color: #2563eb;
  font-weight: 500;
  text-decoration: none;
}
.link:hover { text-decoration: underline; }

.category {
  color: #6b7280;
  font-size: 0.75rem;
  background: #f9fafb;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
}
</style>
