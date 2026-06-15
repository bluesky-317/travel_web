<template>
  <section class="section">
    <h3 class="section-title">密碼</h3>
    <p class="section-desc">定期更換密碼以保護帳號安全。</p>
    <el-button @click="showPasswordDialog = true">修改密碼</el-button>
  </section>

  <el-dialog
    v-model="showPasswordDialog"
    title="修改密碼"
    width="480px"
    :close-on-click-modal="false"
    @close="resetPasswordForm"
    class="password-dialog"
  >
    <el-form
      ref="passwordFormRef"
      :model="passwordForm"
      :rules="passwordRules"
      label-position="top"
    >
      <el-form-item label="目前密碼" prop="currentPassword">
        <el-input
          v-model="passwordForm.currentPassword"
          type="password"
          size="large"
          show-password
          placeholder="請輸入目前密碼"
        />
      </el-form-item>
      <el-form-item label="新密碼" prop="newPassword">
        <el-input
          v-model="passwordForm.newPassword"
          type="password"
          size="large"
          show-password
          placeholder="請輸入新密碼（至少 6 位）"
        />
      </el-form-item>
      <el-form-item label="確認新密碼" prop="confirmPassword">
        <el-input
          v-model="passwordForm.confirmPassword"
          type="password"
          size="large"
          show-password
          placeholder="請再次輸入新密碼"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="showPasswordDialog = false">取消</el-button>
      <el-button type="primary" :loading="changingPw" @click="submitChangePassword">
        確認修改
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const showPasswordDialog = ref(false)
const passwordFormRef = ref(null)
const changingPw = ref(false)
const passwordForm = ref({ currentPassword: '', newPassword: '', confirmPassword: '' })

const passwordRules = {
  currentPassword: [{ required: true, message: '請輸入目前密碼', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '請輸入新密碼', trigger: 'blur' },
    { min: 6, message: '密碼至少 6 個字元', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '請確認新密碼', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.value.newPassword) {
          callback(new Error('兩次密碼不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur',
    },
  ],
}

function resetPasswordForm() {
  passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' }
  passwordFormRef.value?.clearValidate()
}

async function submitChangePassword() {
  const valid = await passwordFormRef.value?.validate().catch(() => false)
  if (!valid) return

  changingPw.value = true
  try {
    await authStore.changePassword({
      oldPassword: passwordForm.value.currentPassword,
      newPassword: passwordForm.value.newPassword,
    })
    ElMessage.success('密碼已成功更新')
    showPasswordDialog.value = false
  } catch (err) {
    ElMessage.error(err.message || '密碼更新失敗，請確認目前密碼是否正確')
  } finally {
    changingPw.value = false
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

:deep(.password-dialog .el-dialog__title) {
  font-size: 18px;
  font-weight: 600;
}

:deep(.password-dialog .el-form-item__label) {
  font-size: 15px;
  font-weight: 500;
  color: #374151;
}

:deep(.password-dialog .el-form-item__error) {
  font-size: 13px;
}
</style>
