<template>
  <div class="card">
    <h4 class="card-title">
      <i class="fa-solid fa-ticket title-icon"></i> 票價資訊
    </h4>
    <p class="content">{{ info }}</p>
  </div>
</template>

<script setup>
defineProps({
  info: {
    type: String,
    required: true,
  },
})
</script>

<style scoped>
.card {
  background: rgba(236, 253, 245, 0.4);
  border: 1px solid rgba(167, 243, 208, 0.6);
  border-radius: 0.75rem;
  padding: 1rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}

.card-title {
  font-size: 0.75rem;
  font-weight: 700;
  color: #022c22;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 0.625rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.title-icon {
  font-size: 0.875rem;
  color: #047857;
}

.content {
  color: #4b5563;
  line-height: 1.625;
  font-size: 0.875rem;
  margin: 0;
}
</style>
