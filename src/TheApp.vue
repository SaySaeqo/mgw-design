<template>
  <header :class="{ open: isHeaderOpen }">
    <img src="@/assets/menu_icon.svg" @click="() => [isNavHidden, isNavOpen] = [false, !isNavOpen]">
    <div style="display: flex; gap: 1em;">
      <router-link to="/help"><img src="@/assets/mark_question_circle_icon.svg"></router-link>
      <router-link to="/settings"><img src="@/assets/cog_icon.svg"></router-link>
    </div>
  </header>
  <nav :class="{ hidden: isNavHidden, open: isNavOpen }" ref="nav">
    <ul>
      <li><img src="@/assets/menu_icon.svg" @click="() => [isNavHidden, isNavOpen] = [false, !isNavOpen]"></li>
      <li>
        <router-link to="/profile"><img src="@/assets/user_icon.svg"></router-link>
        <router-link to="/">
          <div class="box">Graj</div>
        </router-link>
      </li>
      <li><router-link to="/world">
          <div class="box">Świat</div>
        </router-link></li>
      <li><router-link to="/mechanics">
          <div class="box">Mechanika</div>
        </router-link></li>
      <li><router-link to="/managment">
          <div class="box">Zarządzanie</div>
        </router-link></li>
      <li>
        <router-link to="/login" v-if="!isLoggedIn()">
          <div class="box">Zaloguj</div>
        </router-link>
        <div class="box" style="cursor: pointer;" v-else @click="logout">Wyloguj</div>
      </li>
    </ul>
  </nav>
  <div class="logo"><img src="http://i.imgur.com/S9uIab8.png"></div>
  <div class="container"><router-view class="container" /></div>
  <footer><span>kontakt: <a href="mailto:saysaeqo@gmail.com">saysaeqo@gmail.com</a></span></footer>
</template>

<script setup>
import { isLoggedIn } from './models/user';
import { onMounted, onBeforeMount, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const isNavOpen = ref(false);
const isNavHidden = ref(true);
const isHeaderOpen = ref(true);
const scrollY = ref(0);

const nav = ref(null);


// Lifecycle hooks

onBeforeMount(() => {
  router.afterEach(() => {
    isNavOpen.value = false
    isNavHidden.value = true
    isHeaderOpen.value = true
  })

  window.addEventListener("scroll", () => {
    isHeaderOpen.value = window.scrollY <= scrollY.value
    scrollY.value = window.scrollY
  })
});

onMounted(() => {
  window.addEventListener("mouseup", function (event) {
    let element = event.target
    let maxCount = 5
    while (element && maxCount > 0) {
      if (element == nav.value) return
      element = element.parentNode
      maxCount--
    }
    isNavOpen.value = false
    isNavHidden.value = true
  });
});


// Methods

function logout() {
  sessionStorage.removeItem('jwt')
  localStorage.removeItem('jwt')
  window.location.reload()
}
</script>

<style lang="scss" scoped>
@import "styles/colors";

header {
  position: fixed;
  width: 100%;
  display: flex;
  justify-content: space-between;
  height: 0;
  background-color: $color-main;
  transition: height 0.2s linear;
  overflow: hidden;
  align-items: center;

  img {
    height: 3em;
  }
}

header.open {
  height: 3em;
}

img {
  height: 100%;
}

nav {
  position: fixed;
  display: flex;
  left: 0;
  background-color: $color-main;
  height: 100%;
  width: 0;
  overflow: hidden;
  transition: width 0.2s linear;

  ul {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    list-style: none;
    margin: 0;
    padding: 0;
    overflow: auto;
    scrollbar-width: none;
    -ms-overflow-style: none;
  }

  ul::-webkit-scrollbar {
    display: none;
  }

  li {
    min-height: 3em;
    margin: 0.3em;
    display: flex;
  }

  li:first-child {
    margin: 0;
  }

  a {
    text-decoration: none;
    display: flex;
    flex: 1;
  }

  li:nth-child(2) a:first-child {
    flex: 0;
  }

  .box {
    border: 0.2em solid $color-darker;
    flex: 1;
    display: flex;
    align-self: stretch;
    align-items: center;
    justify-content: center;
  }

  a img {
    border: 0.2em solid $color-darker;
    border-radius: 2em;
    height: 2.5em;
    width: 2.5em;
    padding: 0.25em;

  }


}

nav.open {
  width: 15em;
  max-width: 100%;
}

.hidden {
  visibility: hidden;
}

.container {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  align-self: stretch;
  flex: 1;
  gap: 1em;
  margin: 1em 1em 1em 1em;
}

.logo {
  display: flex;
  margin-top: 3.5em;

  img {
    max-width: 100%;
    flex: 1;
  }
}

footer {
  display: flex;
  justify-content: center;
  margin-bottom: 1em;
}

@media only screen and (min-width: 1000px) {
  .container {
    align-self: center;
    width: 60%;
  }

}
</style>
