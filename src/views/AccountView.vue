<template>
  <div class="account-page">
    <div class="back-wrap">
      <button class="back-btn" @click="router.back()">
        <i class="fa-solid fa-arrow-left back-btn-icon"></i>
        <span>返回</span>
      </button>
    </div>

    <div class="account-container">
      <h2><i class="fa-solid fa-user-gear"></i> 帳戶設定</h2>
      <el-divider />

      <ProfileSection />
      <el-divider />

      <ChangePasswordSection />
      <el-divider />

      <DeleteAccountSection />
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import ProfileSection from '@/components/account/ProfileSection.vue'
import ChangePasswordSection from '@/components/account/ChangePasswordSection.vue'
import DeleteAccountSection from '@/components/account/DeleteAccountSection.vue'

const router = useRouter()
</script>

<style scoped>
.account-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 20px 60px;
  background-color: #f5f7fa;
}

.back-wrap {
  width: 100%;
  max-width: 640px;
  margin-bottom: 16px;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.8);
  color: #4b5563;
  padding: 6px 14px;
  border-radius: 10px;
  font-size: 0.875rem;
  font-weight: 500;
  border: 1px solid rgba(229, 231, 235, 0.8);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: background 0.2s, color 0.2s, box-shadow 0.2s;
}

.back-btn:hover {
  background: #fff;
  color: #111827;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.back-btn-icon {
  transition: transform 0.2s;
}

.back-btn:hover .back-btn-icon {
  transform: translateX(-2px);
}

.account-container {
  width: 100%;
  max-width: 640px;
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.account-container h2 {
  font-size: 24px;
  font-weight: bold;
  color: #1e293b;
  margin: 0 0 8px;
}

@media (max-width: 768px) {
  .account-page { padding: 24px 12px 40px; }
  .account-container { padding: 24px 18px; }
  .account-container h2 { font-size: 20px; }
}
</style>
