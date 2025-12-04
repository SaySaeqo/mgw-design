<template>
  <div class="section" v-if="isLoggedIn()">
    <CharacterPanel />
  </div>
  <div class="section">
    <ComponentMap :backgroundImage="mapImage" :points="mapPoints" />
  </div>
  <div class="section">
    <RouterLink to="/thread/1"><span>LOKACJA 1</span></RouterLink>
    <RouterLink to="/thread/1"><span>LOKACJA 2</span></RouterLink>
    <RouterLink to="/thread/1"><span>LOKACJA 3</span></RouterLink>
    <RouterLink to="/thread/1"><span>LOKACJA 4</span></RouterLink>
  </div>
</template>

<script setup>

import ComponentMap from '@/components/ComponentMap.vue';
import { RouterLink } from 'vue-router';
import CharacterPanel from '@/components/CharacterPanel.vue';
import { isLoggedIn } from '@/models/user';

const mapImage = require('@/assets/fantasy-map.jpg');
const mapPoints = [
  { x: 793, y: 412, title: "Latarnia", link: "/thread/1" },
  { x: 570, y: 334, title: "Miasto", link: "/thread/1" }
];



</script>

<style lang="scss" scoped>
</style>