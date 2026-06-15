<script setup>
import CardList from '../components/CardList.vue';
import Footer from '../components/Footer.vue';
import Header from '../components/home/Header.vue';
</script>

<template>
  <div class="home-page">
    <Header />
    <CardList />
    <Footer />
  </div>
</template>

<style scoped>
.home-page {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}
</style>
