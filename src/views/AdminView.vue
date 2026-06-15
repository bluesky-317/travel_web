<template>
  <div class="admin-wrap">
    <el-container class="admin-container">
      <el-aside :width="collapsed ? '64px' : '200px'" class="admin-aside">
        <el-menu
          :default-active="activeMenu"
          :collapse="collapsed"
          class="side-menu"
          @select="handleMenuSelect"
        >
          <el-menu-item index="user">
            <i class="fa-solid fa-users"></i>
            <template #title>使用者管理</template>
          </el-menu-item>
          <el-menu-item index="attraction">
            <i class="fa-solid fa-map-location-dot"></i>
            <template #title>景點管理</template>
          </el-menu-item>
          <el-menu-item index="stats">
            <i class="fa-solid fa-chart-bar"></i>
            <template #title>統計</template>
          </el-menu-item>
        </el-menu>
        <div class="collapse-toggle" @click="collapsed = !collapsed">
          <i :class="collapsed ? 'fa-solid fa-chevron-right' : 'fa-solid fa-chevron-left'"></i>
        </div>
      </el-aside>

      <el-container class="main-container">
        <el-main class="admin-main">
          <div class="main-top">
            <el-button plain round @click="router.back()">
              <i class="fa-solid fa-arrow-left" style="margin-right:6px"></i>返回
            </el-button>
          </div>
          <component :is="currentComponent" />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, shallowRef, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import UserManage from '@/components/admin/UserManage.vue'
import AttractionsManage from '@/components/admin/AttractionsManage.vue'
import StatisticsManage from '@/components/admin/StatisticsManage.vue'

const router = useRouter()
const collapsed = ref(false)
const activeMenu = ref('user')
const currentComponent = shallowRef(markRaw(UserManage))

const menuMap = {
  user: markRaw(UserManage),
  attraction: markRaw(AttractionsManage),
  stats: markRaw(StatisticsManage),
}

function handleMenuSelect(key) {
  activeMenu.value = key
  currentComponent.value = menuMap[key]
}
</script>

<style scoped>
.admin-wrap {
  height: 100vh;
  overflow: hidden;
  background: #f1f5f9;
}

.admin-container {
  height: 100%;
}

.admin-aside {
  height: 100%;
  background: #1e293b;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: width 0.25s ease;
  flex-shrink: 0;
}

.side-menu {
  flex: 1;
  border-right: none !important;
  --el-menu-bg-color: #1e293b;
  --el-menu-text-color: #94a3b8;
  --el-menu-hover-bg-color: #334155;
  --el-menu-active-color: #60a5fa;
  --el-menu-hover-text-color: #e2e8f0;
}

.side-menu :deep(.el-menu-item) {
  height: 52px;
  line-height: 52px;
  font-size: 15px;
}

.side-menu :deep(.el-menu-item i) {
  font-size: 17px;
  width: 20px;
  text-align: center;
  margin-right: 10px;
  flex-shrink: 0;
}

.side-menu :deep(.el-menu-item.is-active) {
  background-color: #334155 !important;
}

.collapse-toggle {
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #64748b;
  border-top: 1px solid #2d3f55;
  flex-shrink: 0;
  transition: color 0.2s;
}

.collapse-toggle:hover {
  color: #cbd5e1;
}

.main-container {
  flex: 1;
  overflow: hidden;
}

.admin-main {
  height: 100%;
  overflow-y: auto;
  background: #f8fafc;
  padding: 24px 32px;
  box-sizing: border-box;
  font-size: 15px;
}

.admin-main :deep(.el-table) {
  font-size: 15px;
}

.admin-main :deep(.el-table th) {
  font-size: 15px;
}

.admin-main :deep(.el-form-item__label) {
  font-size: 15px;
}

.admin-main :deep(.el-input__inner),
.admin-main :deep(.el-textarea__inner) {
  font-size: 15px;
}

.admin-main :deep(.el-button) {
  font-size: 15px;
}

.admin-main :deep(.el-tag) {
  font-size: 14px;
}

.admin-main :deep(.el-select .el-input__inner) {
  font-size: 15px;
}

.main-top {
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  /* 手機強制 sidebar 縮成 icon-only，內容才有空間 */
  .admin-aside {
    width: 56px !important;
    --el-aside-width: 56px !important;
  }
  .side-menu :deep(.el-menu-item) {
    font-size: 0;
    padding: 0 18px !important;
    justify-content: center;
  }
  .side-menu :deep(.el-menu-item i) {
    font-size: 16px;
    margin-right: 0;
  }
  .collapse-toggle { display: none; }

  .admin-main {
    padding: 16px 14px;
    font-size: 14px;
  }
  .admin-main :deep(.el-table),
  .admin-main :deep(.el-table th),
  .admin-main :deep(.el-input__inner),
  .admin-main :deep(.el-textarea__inner),
  .admin-main :deep(.el-button),
  .admin-main :deep(.el-form-item__label) {
    font-size: 14px;
  }
}
</style>
