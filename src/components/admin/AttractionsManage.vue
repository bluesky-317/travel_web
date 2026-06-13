<template>
  <div class="attraction-manage">
    <div class="toolbar">
      <h2 class="section-title">
        <i class="fa-solid fa-map-location-dot"></i> 景點管理
      </h2>
      <el-button type="primary" @click="openAdd">
        <i class="fa-solid fa-plus" style="margin-right:6px"></i>新增景點
      </el-button>
    </div>

    <el-table :data="attractions" v-loading="loading" border stripe style="width:100%">
      <el-table-column prop="name" label="名稱" min-width="140" show-overflow-tooltip />
      <el-table-column prop="location" label="地點" min-width="160" show-overflow-tooltip />
      <el-table-column prop="category" label="分類" min-width="150" show-overflow-tooltip />
      <el-table-column prop="city" label="城市" width="110" show-overflow-tooltip />
      <el-table-column label="操作" width="110" align="center" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link @click="openEdit(row)">
            <i class="fa-solid fa-pen"></i>
          </el-button>
          <el-button type="danger" link @click="handleDelete(row)">
            <i class="fa-solid fa-trash"></i>
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Add / Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEditing ? '編輯景點' : '新增景點'"
      width="640px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        class="attraction-form"
      >
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="景點名稱" prop="name">
              <el-input v-model="form.name" placeholder="請輸入景點名稱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="地點" prop="location">
              <el-input v-model="form.location" placeholder="例：台北市士林區" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="城市">
              <el-input v-model="form.city" placeholder="例：台北市" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分類">
              <el-select v-model="form.category" placeholder="請選擇分類" clearable style="width:100%">
            <el-option label="自然景觀" value="自然景觀" />
            <el-option label="生態觀察與動植物" value="生態觀察與動植物" />
            <el-option label="林業歷史與人文" value="林業歷史與人文" />
            <el-option label="戶外體驗" value="戶外體驗" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="圖片網址">
          <el-input v-model="form.imageUrl" placeholder="https://..." />
        </el-form-item>

        <el-form-item label="景點描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="4"
            placeholder="請輸入景點介紹"
          />
        </el-form-item>

        <el-form-item label="開放時間">
          <el-input
            v-model="form.openingHoursText"
            type="textarea"
            :rows="3"
            placeholder="請輸入開放時間說明"
          />
        </el-form-item>

        <el-form-item label="票價資訊">
          <el-input
            v-model="form.ticketInfoText"
            type="textarea"
            :rows="3"
            placeholder="請輸入票價資訊說明"
          />
        </el-form-item>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="評價（0–5）">
              <el-input-number
                v-model="form.rating"
                :min="0"
                :max="5"
                :step="0.1"
                :precision="1"
                controls-position="right"
                style="width:100%"
                placeholder="例：4.5"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="電話">
              <el-input v-model="form.phone" placeholder="+886-..." />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="官方網站">
              <el-input v-model="form.website" placeholder="https://..." />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="緯度（Latitude）">
              <el-input v-model="form.lat" placeholder="例：25.0478" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="經度（Longitude）">
              <el-input v-model="form.lon" placeholder="例：121.5319" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">
          {{ isEditing ? '儲存' : '新增' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAttractionList } from '@/api/Attraction'
import { createAttraction, updateAttraction, deleteAttraction } from '@/api/admin'

const attractions = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const formRef = ref(null)
let editingId = null

const emptyForm = () => ({
  name: '',
  location: '',
  city: '',
  category: '',
  imageUrl: '',
  description: '',
  lat: '',
  lon: '',
  openingHoursText: '',
  ticketInfoText: '',
  rating: null,
  phone: '',
  website: '',
})

const form = ref(emptyForm())

const rules = {
  name: [{ required: true, message: '請輸入景點名稱', trigger: 'blur' }],
  location: [{ required: true, message: '請輸入地點', trigger: 'blur' }],
}

async function loadAttractions() {
  loading.value = true
  try {
    const res = await getAttractionList()
    attractions.value = res.data
  } catch {
    ElMessage.error('載入景點失敗')
  } finally {
    loading.value = false
  }
}

function openAdd() {
  isEditing.value = false
  editingId = null
  form.value = emptyForm()
  dialogVisible.value = true
}

function openEdit(row) {
  isEditing.value = true
  editingId = row.id
  const oh = row.openingHours || {}
  const ti = row.ticketInfo || {}
  form.value = {
    name: row.name || '',
    location: row.location || '',
    city: row.city || '',
    category: row.category || '',
    imageUrl: row.imageUrl || '',
    description: row.description || '',
    lat: row.lat != null ? String(row.lat) : '',
    lon: row.lon != null ? String(row.lon) : '',
    openingHoursText: typeof oh === 'string' ? oh
      : [oh.weekday && `平日：${oh.weekday}`, oh.weekend && `假日：${oh.weekend}`, oh.note].filter(Boolean).join('\n'),
    ticketInfoText: typeof ti === 'string' ? ti
      : [ti.adult && `成人：${ti.adult}`, ti.child && `兒童：${ti.child}`, ti.note].filter(Boolean).join('\n'),
    rating: row.rating != null ? row.rating : null,
    phone: row.phone || '',
    website: row.website || '',
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  const payload = {
    name: form.value.name,
    city: form.value.city || null,
    location: form.value.location,
    category: form.value.category || null,
    imageUrl: form.value.imageUrl || null,
    description: form.value.description || null,
    lat: form.value.lat !== '' ? parseFloat(form.value.lat) : null,
    lon: form.value.lon !== '' ? parseFloat(form.value.lon) : null,
    openingHours: form.value.openingHoursText || null,
    ticketInfo: form.value.ticketInfoText || null,
    rating: form.value.rating != null ? form.value.rating : null,
    phone: form.value.phone || null,
    website: form.value.website || null,
  }

  saving.value = true
  try {
    if (isEditing.value) {
      const res = await updateAttraction(editingId, payload)
      const idx = attractions.value.findIndex(a => a.id === editingId)
      if (idx !== -1) attractions.value[idx] = res.data
      ElMessage.success('景點已更新')
    } else {
      const res = await createAttraction(payload)
      attractions.value.push(res.data)
      ElMessage.success('景點已新增')
    }
    dialogVisible.value = false
  } catch {
    ElMessage.error('操作失敗，請稍後再試')
  } finally {
    saving.value = false
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(
      `確定要刪除景點「${row.name}」嗎？`,
      '確認刪除',
      { confirmButtonText: '刪除', cancelButtonText: '取消', type: 'warning' }
    )
    await deleteAttraction(row.id)
    attractions.value = attractions.value.filter(a => a.id !== row.id)
    ElMessage.success('景點已刪除')
  } catch (err) {
    if (err !== 'cancel') ElMessage.error('刪除失敗，請稍後再試')
  }
}

onMounted(loadAttractions)
</script>

<style scoped>
.attraction-manage {
  max-width: 960px;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.section-title i {
  color: #3b82f6;
  margin-right: 8px;
}

.attraction-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #374151;
}
</style>
