<template>
  <section class="section">
    <h3 class="section-title">景點介紹</h3>

    <div class="content">
      <p class="paragraph paragraph--first">{{ description }}</p>
    </div>
  </section>
</template>

<script setup>
defineProps({
  description: {
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

.content {
  background: rgba(249, 250, 251, 0.6);
  border: 1px solid rgba(229, 231, 235, 0.5);
  border-radius: 0.75rem;
  padding: 1.25rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
@media (min-width: 768px) {
  .content { padding: 1.5rem; }
}

.paragraph {
  line-height: 1.625;
  font-size: 1rem;
  color: #4b5563;
  margin: 0;
}
.paragraph--first { color: #374151; }
</style>
