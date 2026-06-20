<template>
  <Teleport to="body">
    <div class="auth-modal-overlay" :class="{ active: open }">
      <div
        class="auth-modal-card"
        role="dialog"
        aria-modal="true"
        :class="{ shake: error }"
      >
        <button class="close-btn" aria-label="關閉視窗" @click="$emit('close')">&times;</button>
        <h2>{{ title }}</h2>
        <p class="subtitle">{{ subtitle }}</p>

        <slot />

        <div v-if="$slots.footer" class="card-footer">
          <slot name="footer" />
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  error: { type: [String, Boolean], default: '' },
})
defineEmits(['close'])

onMounted(() => document.documentElement.style.setProperty('overflow', 'hidden', 'important'))
onUnmounted(() => document.documentElement.style.removeProperty('overflow'))
</script>
