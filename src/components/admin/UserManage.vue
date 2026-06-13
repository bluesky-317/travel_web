<template>
  <div class="user-manage">
    <h2 class="section-title">
      <i class="fa-solid fa-users"></i> 使用者管理
    </h2>

    <el-table
      :data="users"
      v-loading="loading"
      border
      stripe
      style="width: 100%"
    >
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="role" label="角色" width="100">
        <template #default="{ row }">
          <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'" size="small">
            {{ row.role === 'admin' ? '管理員' : '一般用戶' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="name" label="名稱" width="120" show-overflow-tooltip />
      <el-table-column prop="email" label="Email" show-overflow-tooltip />
      <el-table-column prop="create_time" label="建立時間" width="175" show-overflow-tooltip />
      <el-table-column prop="login_time" label="最後登入" width="175" show-overflow-tooltip>
        <template #default="{ row }">
          {{ row.login_time || '—' }}
        </template>
      </el-table-column>
      <el-table-column label="管理" width="80" align="center">
        <template #default="{ row }">
          <el-tooltip
            :content="row.role === 'admin' ? '無法刪除管理員' : '刪除用戶'"
            placement="top"
          >
            <el-button
              :disabled="row.role === 'admin'"
              type="danger"
              link
              @click="handleDelete(row)"
            >
              <i class="fa-solid fa-trash"></i>
            </el-button>
          </el-tooltip>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserList, deleteUser } from '@/api/admin'

const users = ref([])
const loading = ref(false)

async function loadUsers() {
  loading.value = true
  try {
    const res = await getUserList()
    users.value = res.data
  } catch (err) {
    ElMessage.error('載入用戶列表失敗')
  } finally {
    loading.value = false
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(
      `確定要刪除用戶 ${row.email} 嗎？此操作無法復原。`,
      '確認刪除',
      { confirmButtonText: '刪除', cancelButtonText: '取消', type: 'warning' }
    )
    await deleteUser(row.id)
    ElMessage.success('用戶已刪除')
    users.value = users.value.filter(u => u.id !== row.id)
  } catch (err) {
    if (err !== 'cancel') ElMessage.error('刪除失敗，請稍後再試')
  }
}

onMounted(loadUsers)
</script>

<style scoped>
.user-manage {
  max-width: 1100px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 20px;
}

.section-title i {
  color: #3b82f6;
  margin-right: 8px;
}
</style>
