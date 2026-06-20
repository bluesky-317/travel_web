<template>
  <!-- ── 水平 List 版型 ── -->
  <div v-if="layout === 'list'" class="card-list-item">
    <div class="list-img-wrap">
      <img v-if="image" :src="image" :alt="title" class="list-img" loading="lazy" decoding="async" />
      <div v-else class="list-img-placeholder">
        <i class="fa-solid fa-image"></i>
      </div>
    </div>

    <div class="list-body">
      <div class="list-meta">
        <div v-if="category" class="card-category-container">
          <span class="card-category">{{ category }}</span>
        </div>
        <div v-if="location" class="card-location">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
          </svg>
          <span>{{ location }}</span>
        </div>
      </div>

      <h4 class="list-title">{{ title }}</h4>
      <p class="list-desc">{{ description }}</p>

      <div class="list-actions">
        <router-link v-if="link" :to="link" class="btn list-detail-btn">查看詳情</router-link>
      </div>
    </div>
  </div>

  <!-- ── 原有卡片版型（首頁輪播用） ── -->
  <div v-else class="card">
    <img :src="image" :alt="title" class="card-img" loading="lazy" decoding="async" />

    <div class="card-content">
      <div v-if="category" class="card-category-container">
        <span class="card-category">{{ category }}</span>
      </div>

      <div v-if="location" class="card-location">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
          <circle cx="12" cy="10" r="3"></circle>
        </svg>
        <span>{{ location }}</span>
      </div>

      <h4 class="card-title">{{ title }}</h4>
      <p>{{ description }}</p>

      <router-link v-if="link" :to="link" class="btn">查看詳情</router-link>
    </div>
  </div>
</template>

<script setup>
defineProps({
  layout: { type: String, default: 'card' },   // 'card' | 'list'
  image: { type: String, default: '' },
  category: { type: String, default: '' },
  location: { type: String, default: '' },
  title: { type: String, required: true },
  description: { type: String, required: true },
  link: { type: String, default: '' },
})
</script>

<style scoped>
/* ── List 版型 ── */
.card-list-item {
  display: flex;
  gap: 20px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.08);
  overflow: hidden;
  transition: box-shadow 0.2s, transform 0.2s;
}
.card-list-item:hover {
  box-shadow: 0 6px 20px rgba(0,0,0,0.13);
  transform: translateY(-2px);
}
.list-img-wrap {
  flex: 0 0 200px;
  align-self: stretch;
}
.list-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.list-img-placeholder {
  width: 100%;
  height: 100%;
  background: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #cbd5e1;
  font-size: 2rem;
}
.list-body {
  flex: 1;
  padding: 16px 20px 16px 4px;
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.list-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 8px;
}
.list-title {
  font-size: 1.25rem;
  font-weight: bold;
  color: #1e293b;
  margin: 0 0 8px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.list-desc {
  color: #64748b;
  font-size: 1rem;
  line-height: 1.6;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}
.list-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 14px;
  flex-wrap: wrap;
}
.list-detail-btn {
  margin-left: auto;
}
/* ── 原有卡片版型 ── */
.card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  transition: transform 0.3s ease;
  display: flex;
  flex-direction: column;
  min-height: 475px;
}

.card:hover {
  transform: translateY(-10px);
}

.card-img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card-content {
  padding: 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 275px;
}

.card-category-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}

/* 簡約標籤 */
.card-category {
  display: inline-block;
  background: #e8f1f2;
  color: #4f6d7a;
  font-size: 13px;
  padding: 5px 10px;
  border-radius: 4px;
  font-weight: 500;
  line-height: 1.4;
}
.card-category::before {
  content: '#';
  margin-right: 1px;
}

.card-location {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #7f8c8d;
  font-size: 0.85rem;
  margin-bottom: 10px;
  min-width: 0;
}

.card-location span {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-title {
  font-size: 1.25rem;
  line-height: 1.35;
  margin: 0 0 10px;
  color: #2c3e50;
  font-weight: bold;
  min-height: 3.375rem;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-content p {
  color: #555;
  font-size: 0.95rem;
  line-height: 1.6;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 4.56rem;
}

.btn {
  display: inline-block;
  margin-top: auto;
  padding: 10px 20px;
  background-color: #3498db;
  color: white;
  text-decoration: none;
  border-radius: 5px;
  transition: background 0.3s;
  text-align: center;
}

.btn:hover {
  background-color: #2980b9;
}

/* ── 手機版（list 版型） ── */
@media (max-width: 640px) {
  .card-list-item { gap: 14px; }
  .list-img-wrap { flex: 0 0 130px; }
  .list-body { padding: 12px 14px 12px 4px; }
  .list-title { font-size: 1.05rem; }
  .list-desc { font-size: 0.88rem; }
}

@media (max-width: 480px) {
  .card-list-item { flex-direction: column; gap: 0; }
  .list-img-wrap {
    flex: 0 0 auto;
    width: 100%;
    height: 160px;
    align-self: auto;
  }
  .list-body { padding: 14px 16px 16px; }
  .list-detail-btn { margin-left: 0; }
}

/* ── 手機版（card 版型 / 首頁輪播） ── */
@media (max-width: 768px) {
  .card {
    min-height: auto;
    border-radius: 12px;
    width: 100%;
  }
  .card:hover { transform: none; }
  .card-img { height: 180px; }
  .card-content {
    padding: 1rem;
    min-height: auto;
  }
  .card-category-container { margin-bottom: 8px; }
  .card-location { font-size: 0.78rem; margin-bottom: 8px; }
  .card-title {
    font-size: 1.05rem;
    min-height: auto;
    margin-bottom: 6px;
    line-height: 1.3;
  }
  .card-content p {
    font-size: 0.85rem;
    line-height: 1.5;
    min-height: auto;
    -webkit-line-clamp: 2;
    margin-bottom: 12px;
  }
  .btn {
    padding: 8px 16px;
    font-size: 0.9rem;
  }
}

@media (max-width: 480px) {
  .card-img { height: 160px; }
  .card-content { padding: 0.85rem; }
  .card-title { font-size: 1rem; }
  .card-content p { font-size: 0.82rem; }
}
</style>
