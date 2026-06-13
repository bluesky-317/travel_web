<script setup>
import { useRouter } from 'vue-router'
import Kuuhenki from '@/assets/Kuuhenki.png'

const router = useRouter()
</script>

<template>
  <section class="not-found">
    <div class="not-found__content">
      <img
        class="not-found__image"
        :src="Kuuhenki"
        alt="找不到頁面"
        draggable="false"
        @dragstart.prevent
      />

      <div class="not-found__text">
        <p class="not-found__code">404</p>
        <h1>找不到這個頁面</h1>
        <p class="not-found__message">
          這個連結可能已經失效，或是網址輸入錯誤。
        </p>
        <button class="home-button" type="button" @click="router.push({ name: 'home' })">
          返回首頁
        </button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.not-found {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 48px 20px;
  background:
    linear-gradient(180deg, rgba(248, 250, 252, 0.94), rgba(239, 246, 255, 0.72)),
    #f8fafc;
}

.not-found__content {
  width: min(960px, 100%);
  display: grid;
  grid-template-columns: minmax(260px, 420px) minmax(260px, 1fr);
  align-items: center;
  gap: 52px;
}

.not-found__image {
  width: 100%;
  max-height: 430px;
  object-fit: contain;
  filter: drop-shadow(0 24px 38px rgba(15, 23, 42, 0.16));
  user-select: none;
  -webkit-user-drag: none;
  -webkit-user-select: none;
  pointer-events: none;
}

.not-found__text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.not-found__code {
  margin: 0 0 10px;
  color: #2563eb;
  font-size: 0.92rem;
  font-weight: 800;
  letter-spacing: 0.12em;
}

h1 {
  margin: 0;
  color: #0f172a;
  font-size: 2.6rem;
  line-height: 1.16;
  font-weight: 800;
}

.not-found__message {
  margin: 18px 0 28px;
  color: #475569;
  font-size: 1.05rem;
  line-height: 1.75;
}

.home-button {
  min-width: 132px;
  min-height: 44px;
  border: 0;
  border-radius: 8px;
  background: #2563eb;
  color: #fff;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 12px 24px rgba(37, 99, 235, 0.24);
  transition: transform 0.16s ease, background 0.16s ease, box-shadow 0.16s ease;
}

.home-button:hover {
  background: #1d4ed8;
  transform: translateY(-1px);
  box-shadow: 0 16px 28px rgba(37, 99, 235, 0.28);
}

.home-button:active {
  transform: translateY(0);
}

@media (max-width: 760px) {
  .not-found {
    min-height: 100vh;
    padding: 34px 18px;
  }

  .not-found__content {
    grid-template-columns: 1fr;
    gap: 26px;
    text-align: center;
  }

  .not-found__image {
    max-height: 300px;
  }

  .not-found__text {
    align-items: center;
  }

  h1 {
    font-size: 2rem;
  }

  .not-found__message {
    font-size: 1rem;
  }
}
</style>
