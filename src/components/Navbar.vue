<template>
  <el-menu
    :default-active="activeIndex"
    class="navbar-menu"
    mode="horizontal"
    :router="true"
    :ellipsis="false"
    background-color="#333"
    text-color="#fff"
    active-text-color="#ffd04b"
  >
    <!-- 左側 Logo -->
    <router-link to="/" class="logo"><i class="fa-solid fa-compass"></i> 旅遊網站</router-link>

    <!-- 中間推開空間 -->
    <div class="flex-grow" />

    <!-- 選單項目 -->
    <el-menu-item index="/">首頁</el-menu-item>
    <el-menu-item index="/explore">探索</el-menu-item>

    <el-menu-item index="/plan">規劃</el-menu-item>

    <!-- 右側按鈕：登入 / 登出 -->
    <el-menu-item index="auth-trigger"
      disabled
      style="cursor: default; opacity: 1;"
      class="login-menu-item"
    >
      <el-button v-if="!authStore.token" class="login-btn" @click.stop="authStore.openLoginModal">登入</el-button>
      <template v-else>
        <el-button class="logout-btn" @click.stop="confirmLogout">登出</el-button>
        <el-dropdown class="settings-dropdown" trigger="click" @command="handleCommand">
          <button class="gear-btn" @click.stop>
            <i class="fa-solid fa-gear"></i>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="account">
                <i class="fa-solid fa-user" style="margin-right: 8px;"></i>帳戶設定
              </el-dropdown-item>
              <el-dropdown-item v-if="authStore.isAdmin" command="admin" divided>
                <i class="fa-solid fa-shield-halved" style="margin-right: 8px;"></i>系統管理
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </template>
    </el-menu-item>
  </el-menu>
  
  <LoginModal v-if="authStore.isLoginModalOpen"/>
  <RegisterModal v-if="authStore.isRegisterModalOpen" />

  
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import LoginModal from './LoginModal.vue'
import RegisterModal from './RegisterModal.vue'
import { ElMessageBox } from 'element-plus'

// 自動監聽路由變化，讓對應的選單項目高亮
const route = useRoute()
const activeIndex = computed(() => route.path)

// 登入鈕 modal event process
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';
const authStore = useAuthStore();
const router = useRouter();

function handleCommand(command) {
  if (command === 'account') {
    router.push('/account')
  } else if (command === 'admin') {
    router.push('/admin')
  }
}

async function confirmLogout() {
  try {
    await ElMessageBox.confirm(
      '確定要登出嗎？',
      '確認登出',
      {
        confirmButtonText: '登出',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    authStore.logout()
    router.replace('/')
  } catch {}
}

</script>

<style scoped>
/* 導覽列基礎設定 */
.navbar-menu {
  display: flex;
  align-items: center;
  padding: 0 30px;
  height: 61px;
  width: 100%;
  min-width: 0;
  border-bottom: none !important; /* 移除 Element Plus 預設底線 */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  position: sticky;
    top: 0;           /* 固定在距離頂部 0 的位置 */
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.4), 
                0 12px 25px rgba(0, 0, 0, 0.5);
  z-index: 1000;
}

.logo {
  font-size: 24px;
  font-weight: bold;
  color: white;
  margin-right: 20px;
  flex-shrink: 0;
  text-decoration: none;
  cursor: pointer;
}

.logo:hover {
  color: #2563eb !important;
}

/* 將選單項目推向右側 */
.flex-grow {
  flex-grow: 1;
}

/* 文字大小微調 */
:deep(.el-menu-item), 
:deep(.el-sub-menu__title) {
  font-size: 14px;
  min-width: 0;
}

/* 登入按鈕容器：移除選單原本的 hover 背景色 */
.login-menu-item {
  background-color: transparent !important;
  cursor: default;
  padding-right: 0; /* 讓按鈕靠最右 */
}

.login-menu-item:hover {
  background-color: transparent !important;
}

/* 登入按鈕本體樣式 */
.login-btn {
  background-color: #2563eb !important;
  border-color: #2563eb !important;
  color: white !important;
  font-weight: bold;
  padding: 8px 20px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.login-btn:hover {
  background-color: #3b82f6 !important;
  border-color: #3b82f6 !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.logout-btn {
  background-color: #dc2626 !important;
  border-color: #dc2626 !important;
  color: white !important;
  font-weight: bold;
  padding: 8px 20px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  background-color: #ef4444 !important;
  border-color: #ef4444 !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.4);
}

/* 修正下拉選單項目的最小寬度 */
:deep(.el-menu--horizontal .el-menu .el-menu-item) {
  min-width: 120px;
  justify-content: center;
}

/* 齒輪按鈕 */
.settings-dropdown {
  margin-left: 8px;
}

.gear-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 6px;
  border: 1.5px solid rgba(255, 255, 255, 0.3);
  background-color: transparent;
  color: #fff;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.gear-btn:hover {
  background-color: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.6);
  transform: rotate(30deg);
}

/* ── 手機版 ── */
@media (max-width: 768px) {
  .navbar-menu {
    padding: 0 8px;
    height: 54px;
    overflow: visible;
  }
  .logo {
    font-size: 17px;
    margin-right: 6px;
  }
  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    font-size: 13px;
    padding: 0 7px !important;
  }
  .login-menu-item { padding-right: 0 !important; }
  .login-btn,
  .logout-btn {
    padding: 6px 12px;
    font-size: 13px;
  }
  .gear-btn {
    width: 32px;
    height: 32px;
    font-size: 14px;
  }
  .settings-dropdown { margin-left: 4px; }
}

@media (max-width: 480px) {
  .navbar-menu { padding: 0 4px; }
  .logo {
    font-size: 0;          /* 隱藏文字 */
    margin-right: 2px;
  }
  .logo i {
    font-size: 22px;       /* icon 維持可見 */
  }
  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    font-size: 12px;
    padding: 0 5px !important;
  }
  .login-btn,
  .logout-btn {
    padding: 5px 8px;
    font-size: 12px;
  }
  .settings-dropdown { margin-left: 2px; }
}

@media (max-width: 360px) {
  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    padding: 0 4px !important;
  }
  .login-btn,
  .logout-btn {
    padding: 4px 7px;
  }
}
</style>
