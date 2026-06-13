import { defineStore } from 'pinia';
import { loginApi, getUserInfoApi, registerApi, updateProfileApi, changePasswordApi, deleteAccountApi } from '@/api/auth';
import Cookies from 'js-cookie';
import { ElMessage } from 'element-plus';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: Cookies.get('token') || '',
    isLoginModalOpen: false,
    isRegisterModalOpen: false
  }),

  getters: {
    isAdmin: (state) => state.user?.role === 'admin',
  },

  actions: {
    openLoginModal() {
      this.isLoginModalOpen = true;
    },
    closeLoginModal() {
      this.isLoginModalOpen = false;
    },
    openRegisterModal(){
      this.isRegisterModalOpen = true;
    },
    closeRegisterModal(){
      this.isRegisterModalOpen = false;
    },

    // 登入流程
    async handleLogin(credentials) {
      try {
        const res = await loginApi(credentials);
        const newToken = res.data.token;

        // 1. 更新 Pinia 狀態
        this.token = newToken;

        // 2. 儲存至 Cookie (不設定 expires，關閉瀏覽器即消失)
        // 這樣能達成「F5 不會登出，但關閉網頁會登出」
        Cookies.set('token', newToken, { SameSite: 'Lax' });
        
        // 3. 獲取並儲存使用者詳細資料
        const userRes = await getUserInfoApi();
        this.user = userRes.data;
        
        // 4. 關閉彈窗
        this.isLoginModalOpen = false;

        ElMessage.success('登入成功！');
        return true;
      } catch (error) {
        console.error('Login failed:', error);
        return false;
      }
    },
    
    async updateProfile(payload) {
      await updateProfileApi(payload)
      this.user = { ...this.user, ...payload }
    },

    async changePassword(payload) {
      await changePasswordApi(payload)
    },

    async deleteAccount() {
      await deleteAccountApi()
      this.user = null
      this.token = ''
      Cookies.remove('token')
    },

    // 頁面刷新後，token 從 cookie 恢復，但 user 需重新從 API 取得
    async restoreSession() {
      try {
        const userRes = await getUserInfoApi()
        this.user = userRes.data
      } catch {
        // token 失效，清除狀態
        this.user = null
        this.token = ''
        Cookies.remove('token')
      }
    },

    // 登出流程
    logout() {
      this.user = null;
      this.token = '';
      Cookies.remove('token');
      ElMessage.info('已登出');
    },

    // 註冊流程
    async handleRegister(payload) {
      try {
        // 1. 調用註冊 API
        const res = await registerApi(payload);
        const newToken = res.data.token;

        // 2. 更新 Pinia 狀態
        this.token = newToken;

        // 3. 儲存至 Cookie (比照登入：不設 expires，關網頁即消失)
        // 這樣註冊完直接登入，且具備一樣的持久化特性
        Cookies.set('token', newToken, { SameSite: 'Lax' });

        // 4. 獲取並儲存使用者詳細資料 (註冊後通常會直接獲取資料)
        const userRes = await getUserInfoApi();
        this.user = userRes.data;

        // 5. 關閉註冊彈窗
        this.isRegisterModalOpen = false;

        return true;
      } catch (error) {
        console.error('Registration failed:', error.message);
        return false;
      }
    }
  }
});