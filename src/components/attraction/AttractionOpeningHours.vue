<template>
  <div class="card">
    <h4 class="card-title">
      <i class="fa-solid fa-clock title-icon"></i> 開放時間
    </h4>
    <p class="content">{{ hours }}</p>
  </div>
</template>

<script setup>
defineProps({
  hours: {
    type: String,
    required: true,
  },
})
</script>

<style scoped>
.card {
  background: rgba(255, 251, 235, 0.4);
  border: 1px solid rgba(253, 230, 138, 0.6);
  border-radius: 0.75rem;
  padding: 1rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}

.card-title {
  font-size: 0.75rem;
  font-weight: 700;
  color: #78350f;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 0.625rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.title-icon {
  font-size: 0.875rem;
  color: #b45309;
}

.content {
  color: #4b5563;
  line-height: 1.625;
  font-size: 0.875rem;
  margin: 0;
}
</style>
