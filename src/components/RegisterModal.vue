<template>
  <BaseAuthModal
    :open="authStore.isRegisterModalOpen"
    title="加入會員"
    subtitle="建立您的帳號，開啟更多專屬功能！"
    :error="registerError"
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
        placeholder="設定密碼 (至少 6 位數)"
        required
        :disabled="isLoading"
      />

      <PasswordInput
        v-model="form.confirmPassword"
        placeholder="確認密碼"
        required
        :disabled="isLoading"
      />

      <Transition name="auth-fade">
        <p v-if="registerError" class="error-msg">{{ registerError }}</p>
      </Transition>

      <button
        type="submit"
        class="submit-btn register"
        :disabled="isLoading"
      >
        <span v-if="!isLoading">立即註冊</span>
        <span v-else class="loader"></span>
      </button>
    </form>

    <template #footer>
      <span>已經有帳號了？<a href="#" @click.prevent="goToLogin">登入帳號</a></span>
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
const registerError = ref('');

const form = reactive({
  email: '',
  password: '',
  confirmPassword: ''
});

const handleClose = () => {
  if (isLoading.value) return;
  authStore.closeRegisterModal();
};

const triggerShake = () => {
  const el = document.querySelector('.auth-modal-card');
  if (!el) return;
  el.classList.remove('shake');
  void el.offsetWidth; // reflow hack
  el.classList.add('shake');
};

const handleSubmit = async () => {
  if (isLoading.value) return;
  registerError.value = '';

  if (form.password !== form.confirmPassword) {
    registerError.value = '兩次輸入的密碼不一致';
    triggerShake();
    return;
  }

  if (form.password.length < 6) {
    registerError.value = '密碼長度至少需要 6 位';
    triggerShake();
    return;
  }

  isLoading.value = true;
  try {
    const success = await authStore.handleRegister({
      email: form.email,
      password: form.password
    });

    if (success) {
      handleClose();
    } else {
      registerError.value = '此信箱已被註冊，請更換其他信箱';
      triggerShake();
    }
  } catch (error) {
    registerError.value = '系統繁忙中，請稍後再試';
  } finally {
    isLoading.value = false;
  }
};

const goToLogin = () => {
  handleClose();
  authStore.openLoginModal();
};
</script>
