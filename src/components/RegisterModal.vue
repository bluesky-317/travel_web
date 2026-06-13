<template>
  <!-- 使用 Teleport 將彈窗渲染到 body 層級 -->
  <Teleport to="body">
    <div 
      class="modal-overlay" 
      :class="{ 'active': authStore.isRegisterModalOpen }"
    >
      <div 
        class="solid-card" 
        role="dialog" 
        aria-modal="true"
        :class="{ 'shake': registerError }"
      >
        <!-- 關閉按鈕 -->
        <button 
          class="close-btn" 
          @click="handleClose" 
          aria-label="關閉視窗"
        >
          &times;
        </button>
        
        <h2>加入會員</h2>
        <p class="subtitle">建立您的帳號，開啟更多專屬功能！</p>
        
        <!-- 註冊表單 -->
        <form class="register-form" @submit.prevent="handleSubmit">
          <!-- 電子信箱 -->
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

          <!-- 設定密碼 -->
          <div class="input-group password-wrapper">
            <input 
              v-model="form.password" 
              :type="isPasswordVisible ? 'text' : 'password'" 
              placeholder="設定密碼 (至少 6 位數)" 
              required
              autocomplete="new-password"
              :disabled="isLoading"
            >
            <button 
              type="button" 
              class="eye-toggle" 
              @click="isPasswordVisible = !isPasswordVisible"
              tabindex="-1"
            >
              <!-- 顯示密碼 (Eye) -->
              <svg v-if="!isPasswordVisible" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
              <!-- 隱藏密碼 (Eye Off) -->
              <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
            </button>
          </div>

          <!-- 確認密碼 -->
          <div class="input-group password-wrapper">
            <input 
              v-model="form.confirmPassword" 
              :type="isConfirmVisible ? 'text' : 'password'" 
              placeholder="確認密碼" 
              required
              autocomplete="new-password"
              :disabled="isLoading"
            >
            <button 
              type="button" 
              class="eye-toggle" 
              @click="isConfirmVisible = !isConfirmVisible"
              tabindex="-1"
            >
              <svg v-if="!isConfirmVisible" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
              <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
            </button>
          </div>

          <!-- 錯誤訊息提示 -->
          <Transition name="fade">
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
        
        <div class="card-footer">
          <span>已經有帳號了？<a href="#" @click.prevent="goToLogin">登入帳號</a></span>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive, ref, onMounted, onUnmounted } from 'vue';
import { useAuthStore } from '@/stores/auth';

onMounted(() => document.documentElement.style.setProperty('overflow', 'hidden', 'important'))
onUnmounted(() => document.documentElement.style.removeProperty('overflow'))

const authStore = useAuthStore();
const isLoading = ref(false);
const registerError = ref('');

// 密碼可見性狀態
const isPasswordVisible = ref(false);
const isConfirmVisible = ref(false);


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
  const el = document.querySelector('.solid-card');
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

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0;
  width: 100vw; height: 100vh;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  opacity: 0;
  pointer-events: none;
  transition: all 0.3s ease;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.modal-overlay.active {
  opacity: 1;
  pointer-events: auto;
}

.solid-card {
  position: relative;
  width: 90%;
  max-width: 400px;
  padding: 40px 30px;
  background: #1e1e1e; 
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
  text-align: center;
  transform: translateY(20px);
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.modal-overlay.active .solid-card {
  transform: translateY(0);
}

.close-btn {
  position: absolute;
  top: 20px; right: 20px;
  background: none; border: none;
  font-size: 24px; color: rgba(255, 255, 255, 0.4);
  cursor: pointer;
}

h2 { color: #fff; font-size: 1.6rem; margin-bottom: 10px; }
.subtitle { color: rgba(255, 255, 255, 0.6); font-size: 0.9rem; margin-bottom: 30px; }

.register-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.input-group {
  width: 100%;
  position: relative;
  font-size: 13px;
}

.input-group input {
  width: 100%;
  padding: 14px 18px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  outline: none;
  box-sizing: border-box;
  font-size: 13px;
}

.input-group input:focus { border-color: #3b82f6; }

/* 眼睛圖示按鈕樣式 */
.password-wrapper input {
  padding-right: 50px; /* 預留右側按鈕位置 */
}

.eye-toggle {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.4);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  transition: color 0.2s;
}

.eye-toggle:hover {
  color: #fff;
}

.error-msg {
  color: #ff4d4d;
  font-size: 0.85rem;
  margin: -8px 0 8px;
  text-align: left;
}

.submit-btn {
  padding: 14px;
  border: none;
  border-radius: 12px;
  background: #3b82f6;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 16px;
}

.submit-btn:hover:not(:disabled) {
  background: #60a5fa;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
  transform: translateY(-1px);
}

.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }

.loader {
  width: 20px; height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: #fff;
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.shake {
  animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
}

@keyframes shake {
  10%, 90% { transform: translate3d(-1px, 0, 0); }
  20%, 80% { transform: translate3d(2px, 0, 0); }
  30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
  40%, 60% { transform: translate3d(4px, 0, 0); }
}

.card-footer { margin-top: 24px; color: rgba(255, 255, 255, 0.5); font-size: 0.9rem; }
.card-footer a { color: #ff4d4d; text-decoration: none; margin-left: 8px; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>