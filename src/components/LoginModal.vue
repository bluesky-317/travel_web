<template>
  <BaseAuthModal
    :open="authStore.isLoginModalOpen"
    title="會員登入"
    subtitle="歡迎回來！請輸入您的帳號密碼進行登入。"
    :error="loginError"
    @close="handleClose"
  >
    <form class="auth-form" @submit.prevent="handleSubmit">
      <div class="input-group">
        <input
          v-model.trim="form.email"
          type="email"
          placeholder="電子信箱"
          required
          autocomplete="email"
          :disabled="isLoading"
        >
      </div>

      <PasswordInput
        v-model="form.password"
        placeholder="密碼"
        required
        :disabled="isLoading"
      />

      <Transition name="auth-fade">
        <p v-if="loginError" class="error-msg">{{ loginError }}</p>
      </Transition>

      <button
        type="submit"
        class="submit-btn"
        :disabled="isLoading"
      >
        <span v-if="!isLoading">登入</span>
        <span v-else class="loader"></span>
      </button>
    </form>

    <template #footer>
      <span>還沒有帳號？<a href="#" @click.prevent="goToRegister">立即註冊</a></span>
    </template>
  </BaseAuthModal>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { useAuthStore } from '@/stores/auth';
import BaseAuthModal from '@/components/base/BaseAuthModal.vue';
import PasswordInput from '@/components/base/PasswordInput.vue';

const authStore = useAuthStore();
const isLoading = ref(false);
const loginError = ref('');

const form = reactive({
  email: '',
  password: ''
});

const handleClose = () => {
  if (isLoading.value) return;
  authStore.closeLoginModal();
};

const handleSubmit = async () => {
  if (isLoading.value) return;
  isLoading.value = true;
  loginError.value = '';

  try {
    const success = await authStore.handleLogin(form);
    if (success) {
      handleClose();
    } else {
      loginError.value = '帳號或密碼錯誤，請再試一次';
    }
  } catch (error) {
    loginError.value = '連線伺服器失敗，請稍後再試';
  } finally {
    isLoading.value = false;
  }
};

const goToRegister = () => {
  handleClose();
  authStore.openRegisterModal();
};
</script>
