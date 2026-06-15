<template>
  <div class="plan-page">
    <Navbar />
    <div class="plan-layout">
      <PlanLeftPanel />
      <PlanCenter />
      <PlanRightPanel />
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount } from 'vue'
import { onBeforeRouteLeave } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { usePlanStore } from '@/stores/plan'
import Navbar from '@/components/Navbar.vue'
import Footer from '@/components/Footer.vue'
import PlanLeftPanel from '@/components/plan/PlanLeftPanel.vue'
import PlanCenter from '@/components/plan/PlanCenter.vue'
import PlanRightPanel from '@/components/plan/PlanRightPanel.vue'

const store = usePlanStore()

function beforeUnloadHandler(e) {
  if (store.isDirty) {
    e.preventDefault()
    e.returnValue = ''
  }
}

onMounted(() => {
  store.init()
  window.addEventListener('beforeunload', beforeUnloadHandler)
})

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', beforeUnloadHandler)
})

onBeforeRouteLeave(async () => {
  if (!store.isDirty) return true
  let choice
  try {
    await ElMessageBox.confirm(
      '行程有未儲存的變更，要先儲存嗎？',
      '尚未儲存',
      {
        confirmButtonText: '儲存並離開',
        cancelButtonText: '放棄變更',
        distinguishCancelAndClose: true,
        type: 'warning',
        closeOnClickModal: false,
      }
    )
    choice = 'save'
  } catch (action) {
    choice = action === 'cancel' ? 'discard' : 'stay'
  }

  if (choice === 'save') {
    await store.saveToBackend()
    return !store.isDirty  // 存檔失敗仍 dirty → 留下；成功 → 離開
  }
  if (choice === 'discard') {
    await store.discardChanges()
    return true
  }
  return false  // stay
})
</script>

<style>
/* CSS variables cascade to all child components */
.plan-page {
  --bg: #f0f4f8; --surf: #fff; --surf2: #f5f8fc;
  --bd: #d0dcea; --bd2: #b0c4d8;
  --tx: #1a2637; --tx2: #4a5f78; --tx3: #8099b4;
  --gn: #1a5c96; --gn2: #2174c0; --gn3: #e6f2fb; --gn4: #a8d0f0;
  --tc: #c05520; --tc2: #d96a32; --tc3: #fdf0e6;
}
.plan-page ::-webkit-scrollbar { width: 5px; height: 5px; }
.plan-page ::-webkit-scrollbar-track { background: transparent; }
.plan-page ::-webkit-scrollbar-thumb { background: var(--bd2); border-radius: 3px; }
</style>

<style scoped>
.plan-page {
  font-family: 'DM Sans', sans-serif;
  font-size: 16px;
  color: var(--tx);
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: var(--bg);
}

.plan-layout {
  flex: 1;
  min-height: 620px;
  display: flex;
  overflow: hidden;
  border-top: 3px solid var(--bd);
}
</style>
