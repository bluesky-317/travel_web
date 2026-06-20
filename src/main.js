import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router';
import { createPinia } from 'pinia'
import { useAuthStore } from '@/stores/auth'

import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import 'leaflet/dist/leaflet.css'
import '@/styles/modal.css'

const app = createApp(App)
const pinia = createPinia()

app.use(ElementPlus)
app.use(router)
app.use(pinia)
app.mount('#app')

// 頁面刷新後 token 已從 cookie 恢復，補抓 user 資料（含 role）
const authStore = useAuthStore()
if (authStore.token) {
  authStore.restoreSession()
}
