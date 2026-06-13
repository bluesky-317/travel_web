<template>
  <section class="section">
    <h3 class="section-title">個人資料</h3>
    <el-form label-position="top" class="profile-form">
      <el-form-item label="名稱">
        <el-input v-model="form.name" placeholder="請輸入名稱" />
      </el-form-item>
      <el-form-item label="Email">
        <el-input v-model="form.email" placeholder="請輸入 Email" />
      </el-form-item>
    </el-form>
    <el-button type="primary" :disabled="!isDirty" :loading="saving" @click="saveProfile">
      儲存
    </el-button>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const original = ref({ name: '', email: '' })
const form     = ref({ name: '', email: '' })
const saving   = ref(false)

const isDirty = computed(
  () => form.value.name !== original.value.name || form.value.email !== original.value.email
)

onMounted(() => {
  if (authStore.user) {
    original.value = { name: authStore.user.name ?? '', email: authStore.user.email ?? '' }
    form.value = { ...original.value }
  }
})

async function saveProfile() {
  saving.value = true
  try {
    const payload = {}
    if (form.value.name  !== original.value.name)  payload.name  = form.value.name
    if (form.value.email !== original.value.email) payload.email = form.value.email
    await authStore.updateProfile(payload)
    original.value = { ...form.value }
    ElMessage.success('個人資料已儲存')
  } catch (err) {
    ElMessage.error(err.message || '儲存失敗，請稍後再試')
  } finally {
    saving.value = false
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

.profile-form {
  margin-bottom: 16px;
}
</style>
