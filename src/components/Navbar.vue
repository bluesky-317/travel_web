<template>
  <!-- 外層 fixed 包裹：避免被 el-menu 的 position:relative 或祖先的 overflow 蓋掉黏頂效果 -->
  <header class="navbar-wrap">
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

      <!-- 右側：登入按鈕 / 已登入則顯示頭像下拉 -->
      <el-menu-item
        index="auth-trigger"
        disabled
        style="cursor: default; opacity: 1;"
        class="auth-menu-item"
      >
        <el-button
          v-if="!authStore.token"
          class="login-btn"
          @click.stop="authStore.openLoginModal"
        >登入</el-button>

        <el-dropdown
          v-else
          class="user-dropdown"
          trigger="click"
          placement="bottom-end"
          popper-class="navbar-user-menu-popper"
          @command="handleCommand"
        >
          <button class="avatar-btn" @click.stop aria-label="使用者選單">
            <span class="avatar-letter">{{ userInitial }}</span>
            <i class="fa-solid fa-chevron-down avatar-caret"></i>
          </button>
          <template #dropdown>
            <el-dropdown-menu class="user-menu">
              <div class="user-menu-head">
                <div class="user-menu-avatar">{{ userInitial }}</div>
                <div class="user-menu-info">
                  <div class="user-menu-name">{{ userDisplayName }}</div>
                  <div class="user-menu-role">
                    {{ authStore.isAdmin ? '系統管理員' : '一般會員' }}
                  </div>
                </div>
              </div>
              <el-dropdown-item command="account">
                <i class="fa-solid fa-user item-icon"></i>帳戶設定
              </el-dropdown-item>
              <el-dropdown-item v-if="authStore.isAdmin" command="admin">
                <i class="fa-solid fa-shield-halved item-icon"></i>系統管理
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided class="logout-item">
                <i class="fa-solid fa-right-from-bracket item-icon"></i>登出
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </el-menu-item>
    </el-menu>
  </header>
  <!-- 撐起被 fixed navbar 蓋掉的版面空間，等高即可不影響其他頁面排版 -->
  <div class="navbar-spacer" aria-hidden="true"></div>

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
import { usePlanStore } from '@/stores/plan';
import { useRouter } from 'vue-router';
const authStore = useAuthStore();
const planStore = usePlanStore();
const router = useRouter();

const userDisplayName = computed(() => {
  const u = authStore.user || {}
  return u.nickname || u.name || u.email || '會員'
})

const userInitial = computed(() => {
  const s = String(userDisplayName.value || '?').trim()
  return s ? s.charAt(0).toUpperCase() : '?'
})

function handleCommand(command) {
  if (command === 'account') {
    router.push('/account')
  } else if (command === 'admin') {
    router.push('/admin')
  } else if (command === 'logout') {
    confirmLogout()
  }
}

async function confirmLogout() {
  // 規劃頁有未存擋：合併成單一對話框，避免登出後 onBeforeRouteLeave 再次攔截（API 已 401）
  if (planStore.isDirty) {
    let choice
    try {
      await ElMessageBox.confirm(
        '行程有未儲存的變更，登出後將會遺失。要先儲存嗎？',
        '尚未儲存',
        {
          confirmButtonText: '儲存並登出',
          cancelButtonText: '放棄變更並登出',
          distinguishCancelAndClose: true,
          type: 'warning',
          closeOnClickModal: false,
        }
      )
      choice = 'save'
    } catch (action) {
      choice = action === 'cancel' ? 'discard' : 'stay'
    }

    if (choice === 'stay') return
    if (choice === 'save') {
      await planStore.saveToBackend()
      if (planStore.isDirty) return  // 存檔失敗（網路等）→ 中止登出，留在原處
    }
    // 放棄變更：要登出了，本地狀態反正會丟，直接清掉 dirty 讓 route guard 放行
    planStore.isDirty = false
  } else {
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
    } catch {
      return
    }
  }

  authStore.logout()
  router.replace('/')
}

</script>

<style scoped>
/* fixed 包裹層：把定位責任移出 el-menu，避免被 element-plus 預設 position:relative
   或祖先（如 html/body 的 overflow-x:hidden 形成的 scroll container）影響黏頂效果 */
.navbar-wrap {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  width: 100%;
  background-color: #333;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.4),
              0 12px 25px rgba(0, 0, 0, 0.5);
}

/* 撐起與 navbar 等高的版面占位：避免 fixed 導致內容被蓋掉，且不影響其他頁面排版 */
.navbar-spacer {
  height: 61px;
  flex-shrink: 0;
}

/* 導覽列基礎設定 */
.navbar-menu {
  display: flex;
  align-items: center;
  padding: 0 30px;
  height: 61px;
  width: 100%;
  min-width: 0;
  border-bottom: none !important; /* 移除 Element Plus 預設底線 */
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

/* 登入/使用者按鈕容器：移除選單原本的 hover 背景色 */
.auth-menu-item {
  background-color: transparent !important;
  cursor: default;
  padding-right: 0; /* 讓按鈕靠最右 */
}

.auth-menu-item:hover {
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

/* 修正下拉選單項目的最小寬度 */
:deep(.el-menu--horizontal .el-menu .el-menu-item) {
  min-width: 120px;
  justify-content: center;
}

/* ── 使用者頭像下拉（取代原本的「登出鈕 + 齒輪」）── */
.user-dropdown {
  display: inline-flex;
}

.avatar-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  height: 40px;
  padding: 4px 12px 4px 4px;
  border-radius: 999px;
  border: 1.5px solid rgba(255, 255, 255, 0.18);
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
  cursor: pointer;
  transition: background 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.avatar-btn:hover,
.avatar-btn:focus-visible {
  background: rgba(255, 255, 255, 0.14);
  border-color: rgba(255, 255, 255, 0.45);
  outline: none;
}

.avatar-letter {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2174c0, #1a5c96);
  color: #fff;
  font-weight: 700;
  font-size: 14px;
  letter-spacing: 0;
  flex-shrink: 0;
}

.avatar-caret {
  font-size: 11px;
  opacity: 0.7;
  transition: transform 0.2s ease;
}

.avatar-btn:hover .avatar-caret {
  transform: translateY(1px);
  opacity: 1;
}

/* ── 手機版 ── */
@media (max-width: 768px) {
  .navbar-spacer { height: 54px; }
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
  .auth-menu-item { padding-right: 0 !important; }
  .login-btn {
    padding: 6px 12px;
    font-size: 13px;
  }
  .avatar-btn {
    height: 34px;
    padding: 3px 10px 3px 3px;
    gap: 6px;
  }
  .avatar-letter {
    width: 26px;
    height: 26px;
    font-size: 13px;
  }
  .avatar-caret { font-size: 10px; }
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
  .login-btn {
    padding: 5px 8px;
    font-size: 12px;
  }
  /* 極窄空間：只留圓形頭像、收起箭頭與右側 padding，避免擠壓選單 */
  .avatar-btn {
    padding: 2px;
    gap: 0;
    height: 32px;
    width: 32px;
    justify-content: center;
  }
  .avatar-letter {
    width: 26px;
    height: 26px;
    font-size: 13px;
  }
  .avatar-caret { display: none; }
}

@media (max-width: 360px) {
  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    padding: 0 4px !important;
  }
  .login-btn {
    padding: 4px 7px;
  }
}
</style>

<!-- 全域樣式：el-dropdown 會被 teleport 到 body，scoped 樣式接不到，所以用 popper-class 套全域 -->
<style>
.navbar-user-menu-popper.el-popper {
  --el-bg-color-overlay: #fff;
}

.navbar-user-menu-popper .el-dropdown-menu {
  min-width: 220px;
  padding: 6px;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 12px 32px rgba(26, 92, 150, 0.18);
}

.navbar-user-menu-popper .el-dropdown-menu__item {
  border-radius: 8px;
  padding: 8px 12px;
  color: #1a2637;
  font-size: 14px;
  display: flex;
  align-items: center;
}

.navbar-user-menu-popper .el-dropdown-menu__item:not(.is-disabled):hover,
.navbar-user-menu-popper .el-dropdown-menu__item:not(.is-disabled):focus {
  background: #f5f8fc;
  color: #1a5c96;
}

.navbar-user-menu-popper .el-dropdown-menu__item .item-icon {
  width: 18px;
  margin-right: 10px;
  text-align: center;
  color: #4a5f78;
}

.navbar-user-menu-popper .el-dropdown-menu__item:hover .item-icon,
.navbar-user-menu-popper .el-dropdown-menu__item:focus .item-icon {
  color: #2174c0;
}

.navbar-user-menu-popper .logout-item {
  color: #c0392b;
}

.navbar-user-menu-popper .logout-item .item-icon {
  color: #c0392b;
}

.navbar-user-menu-popper .logout-item:not(.is-disabled):hover,
.navbar-user-menu-popper .logout-item:not(.is-disabled):focus {
  background: #fdecea;
  color: #a93324;
}

.navbar-user-menu-popper .logout-item:hover .item-icon,
.navbar-user-menu-popper .logout-item:focus .item-icon {
  color: #a93324;
}

/* 下拉頂端的使用者資訊區塊 */
.navbar-user-menu-popper .user-menu-head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px 12px;
  margin-bottom: 4px;
  border-bottom: 1px solid #eef2f7;
}

.navbar-user-menu-popper .user-menu-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2174c0, #1a5c96);
  color: #fff;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.navbar-user-menu-popper .user-menu-info {
  min-width: 0;
}

.navbar-user-menu-popper .user-menu-name {
  font-size: 14px;
  font-weight: 600;
  color: #1a2637;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 160px;
}

.navbar-user-menu-popper .user-menu-role {
  font-size: 12px;
  color: #8099b4;
  margin-top: 2px;
}

@media (max-width: 480px) {
  .navbar-user-menu-popper .el-dropdown-menu { min-width: 200px; }
  .navbar-user-menu-popper .user-menu-name { max-width: 130px; }
}
</style>
