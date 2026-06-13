<template>
  <section class="section danger-section">
    <h3 class="section-title danger-title">危險區域</h3>
    <p class="section-desc">刪除帳號後，所有資料將永久移除且無法復原。</p>
    <el-button type="danger" plain @click="handleDeleteAccount">刪除帳號</el-button>
  </section>
</template>

<script setup>
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

async function handleDeleteAccount() {
  try {
    await ElMessageBox.confirm('刪除後所有資料將永久移除，此操作無法復原。', '確認刪除帳號', {
      confirmButtonText: '確定刪除',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger',
    })
    await authStore.deleteAccount()
    ElMessage.success('帳號已刪除')
    router.push('/')
  } catch (err) {
    if (err === 'cancel' || err?.toString() === 'cancel') return
    ElMessage.error(err.message || '刪除失敗，請稍後再試')
  }
}
</script>

<style scoped>
.section {
  padding: 8px 0 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 6px;
}

.section-desc {
  font-size: 14px;
  color: #94a3b8;
  margin: 0 0 16px;
}

.danger-section {
  border: 1px solid #fee2e2;
  border-radius: 8px;
  padding: 20px;
  background: #fff9f9;
}

.danger-title {
  color: #dc2626;
}
</style>
