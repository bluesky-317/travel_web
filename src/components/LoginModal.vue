<template>
  <!-- 使用 Teleport 將彈窗渲染到 body 層級 -->
  <Teleport to="body">
    <div 
      class="modal-overlay" 
      :class="{ 'active': authStore.isLoginModalOpen }"
    >
      <div 
        class="solid-card" 
        role="dialog" 
        aria-modal="true"
        :class="{ 'shake': loginError }"
      >
        <!-- 關閉按鈕 -->
        <button 
          class="close-btn" 
          @click="handleClose" 
          aria-label="關閉視窗"
        >
          &times;
        </button>
        
        <h2>會員登入</h2>
        <p class="subtitle">歡迎回來！請輸入您的帳號密碼進行登入。</p>
        
        <!-- 登入表單 -->
        <form class="login-form" @submit.prevent="handleSubmit">
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

          <!-- 密碼輸入組 (新增可見性切換) -->
          <div class="input-group password-wrapper">
            <input 
              v-model="form.password" 
              :type="isPasswordVisible ? 'text' : 'password'" 
              placeholder="密碼" 
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
              <!-- 顯示密碼圖示 -->
              <svg v-if="!isPasswordVisible" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
              <!-- 隱藏密碼圖示 -->
              <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
            </button>
          </div>

          <!-- 錯誤訊息提示 -->
          <Transition name="fade">
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
        
        <div class="card-footer">
          <span>還沒有帳號？<a href="#" @click.prevent="goToRegister">立即註冊</a></span>
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
const loginError = ref('');

// --- 新增狀態：控制密碼顯示 ---
const isPasswordVisible = ref(false);

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

<style scoped>
/* 沿用 PlanView 的 CSS 變數系統（淺色） */
.modal-overlay {
  --bg: #f0f4f8; --surf: #fff; --surf2: #f5f8fc;
  --bd: #d0dcea; --bd2: #b0c4d8;
  --tx: #1a2637; --tx2: #4a5f78; --tx3: #8099b4;
  --gn: #1a5c96; --gn2: #2174c0; --gn3: #e6f2fb;

  position: fixed;
  top: 0; left: 0;
  width: 100vw; height: 100vh;
  background-color: rgba(15, 30, 50, 0.45);
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
  background: var(--surf);
  border-radius: 20px;
  border: 1px solid var(--bd);
  box-shadow: 0 24px 60px rgba(26, 92, 150, 0.18);
  text-align: center;
  transform: translateY(20px);
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.modal-overlay.active .solid-card {
  transform: translateY(0);
}

.close-btn {
  position: absolute;
  top: 16px; right: 16px;
  width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 10px;
  font-size: 22px;
  color: var(--tx3);
  cursor: pointer;
  line-height: 1;
  transition: background 0.2s, color 0.2s, border-color 0.2s, box-shadow 0.2s;
}

.close-btn:hover {
  background: rgba(33, 116, 192, 0.06);
  color: var(--tx);
  border-color: rgba(47, 127, 201, 0.35);
  box-shadow: 0 0 0 4px rgba(105, 180, 255, 0.10);
}

.close-btn:focus-visible {
  outline: none;
  color: var(--tx);
  border-color: #2f7fc9;
  box-shadow: 0 0 0 4px rgba(105, 180, 255, 0.18);
}

h2 {
  color: var(--tx);
  font-size: 1.6rem;
  margin-bottom: 10px;
  font-weight: 700;
}

.subtitle {
  color: var(--tx2);
  font-size: 0.9rem;
  margin-bottom: 28px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.input-group {
  position: relative;
  width: 100%;
}

.input-group input {
  width: 100%;
  padding: 13px 16px;
  border-radius: 10px;
  border: 1px solid var(--bd);
  background: var(--surf2);
  color: var(--tx);
  font-size: 1rem;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
  box-sizing: border-box;
}

.input-group input::placeholder {
  color: var(--tx3);
}

.password-wrapper input {
  padding-right: 48px;
}

.input-group input:hover:not(:disabled):not(:focus) {
  border-color: var(--bd2);
}

.input-group input:focus {
  border-color: var(--gn2);
  background: #fff;
  box-shadow: 0 0 0 3px rgba(33, 116, 192, 0.15);
}

.input-group input:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.eye-toggle {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: 1px solid transparent;
  color: var(--tx3);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  border-radius: 8px;
  transition: color 0.2s, background 0.2s, border-color 0.2s, box-shadow 0.2s;
}

.eye-toggle:hover {
  color: var(--gn2);
  background: rgba(33, 116, 192, 0.06);
  border-color: rgba(47, 127, 201, 0.30);
  box-shadow: 0 0 0 3px rgba(105, 180, 255, 0.10);
}

.eye-toggle:focus-visible {
  outline: none;
  color: var(--gn2);
  border-color: #2f7fc9;
  box-shadow: 0 0 0 3px rgba(105, 180, 255, 0.18);
}

.error-msg {
  color: #c0392b;
  font-size: 0.85rem;
  margin: -4px 0 0;
  text-align: left;
  padding-left: 4px;
}

.submit-btn {
  position: relative;
  margin-top: 6px;
  padding: 13px;
  border: 1.5px solid #2f7fc9;
  border-radius: 12px;
  background: #102a44;
  color: #cfe6ff;
  font-weight: 600;
  letter-spacing: 0.04em;
  cursor: pointer;
  transition:
    background 0.25s,
    border-color 0.25s,
    color 0.25s,
    box-shadow 0.25s,
    transform 0.15s;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 16px;
  overflow: hidden;
}

.submit-btn::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  background: radial-gradient(120% 100% at 50% 0%, rgba(105, 180, 255, 0.22), transparent 60%);
  opacity: 0;
  transition: opacity 0.25s;
}

.submit-btn:hover:not(:disabled) {
  background: #143656;
  border-color: #69b4ff;
  color: #fff;
  box-shadow:
    0 0 0 4px rgba(105, 180, 255, 0.18),
    0 0 18px rgba(105, 180, 255, 0.45);
  transform: translateY(-1px);
}

.submit-btn:hover:not(:disabled)::before { opacity: 1; }

.submit-btn:focus-visible {
  outline: none;
  border-color: #69b4ff;
  color: #fff;
  box-shadow:
    0 0 0 4px rgba(105, 180, 255, 0.28),
    0 0 18px rgba(105, 180, 255, 0.45);
}

.submit-btn:active:not(:disabled) {
  transform: translateY(0);
  box-shadow:
    0 0 0 3px rgba(105, 180, 255, 0.20),
    0 0 12px rgba(105, 180, 255, 0.35);
}

.submit-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  border-color: rgba(47, 127, 201, 0.45);
  color: rgba(207, 230, 255, 0.7);
}

.loader {
  width: 20px; height: 20px;
  border: 3px solid rgba(207, 230, 255, 0.35);
  border-radius: 50%;
  border-top-color: #cfe6ff;
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

.card-footer {
  margin-top: 22px;
  color: var(--tx2);
  font-size: 0.9rem;
}

.card-footer a {
  color: var(--gn2);
  text-decoration: none;
  margin-left: 6px;
  font-weight: 600;
}

.card-footer a:hover {
  color: var(--gn);
  text-decoration: underline;
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

/* ── 手機版 ── */
@media (max-width: 480px) {
  .solid-card {
    width: calc(100% - 24px);
    padding: 32px 22px 28px;
    border-radius: 18px;
  }
  h2 { font-size: 1.35rem; }
  .subtitle { font-size: 0.85rem; margin-bottom: 22px; }
  .input-group input {
    padding: 12px 14px;
    font-size: 0.95rem;
  }
  .password-wrapper input { padding-right: 44px; }
  .submit-btn { padding: 12px; font-size: 15px; }
  .close-btn {
    top: 10px;
    right: 10px;
    width: 36px;
    height: 36px;
    font-size: 24px;
  }
}
</style>