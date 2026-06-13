<template>
  <div class="explore-page">
    <Navbar />
    <div class="main-layout">
      <ExploreSidebar />
      <div class="content-column">
        <ExploreSearchBar />
        <ExploreResultArea />
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import Navbar            from '@/components/Navbar.vue'
import Footer            from '@/components/Footer.vue'
import ExploreSearchBar  from '@/components/explore/ExploreSearchBar.vue'
import ExploreSidebar    from '@/components/explore/ExploreSidebar.vue'
import ExploreResultArea from '@/components/explore/ExploreResultArea.vue'
import { useExploreStore } from '@/stores/explore'

const exploreStore = useExploreStore()

onMounted(() => exploreStore.fetch())
</script>

<style scoped>
.explore-page {
  min-height: 100vh;
  background: #f8fafc;
}
.main-layout {
  display: flex;
  max-width: 1300px;
  margin: 0 auto;
  padding: 40px 24px 56px;
  align-items: flex-start;
  gap: 24px;
}
.content-column {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

@media (max-width: 768px) {
  .main-layout { flex-direction: column; padding: 16px; }
}
</style>
