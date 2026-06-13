import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('../views/ExploreView.vue'),
  },
  {
    path: '/attraction/:id',
    name: 'attraction',
    component: () => import('../views/AttractionDetailView.vue'),
  },
  {
    path: '/plan',
    name: 'plan',
    component: () => import('../views/PlanView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/account',
    name: 'account',
    component: () => import('../views/AccountView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/admin',
    name: 'admin',
    component: () => import('../views/AdminView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('../views/NotFoundView.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from) => {
  const authStore = useAuthStore()

  // 有 modal 開著時攔截所有導航（含返回鍵），關掉 modal 並留在原頁
  if (authStore.isLoginModalOpen || authStore.isRegisterModalOpen) {
    authStore.closeLoginModal()
    authStore.closeRegisterModal()
    return false
  }

  if (to.meta.requiresAuth) {
    if (!authStore.token) {
      authStore.openLoginModal()
      return from.name ? false : { name: 'home' }
    }
    if (to.meta.requiresAdmin && !authStore.isAdmin) {
      return from.name ? false : { name: 'home' }
    }
  }
})

export default router
