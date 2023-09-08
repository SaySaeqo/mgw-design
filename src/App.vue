<template>
  <header>
    <img src="@/assets/menu_icon.svg" @click="() => isOpen = !isOpen">
    <router-link to="/settings"><img src="@/assets/cog_icon.svg"></router-link>
  </header>
  <nav :class="{open: isOpen}">
    <ul>
      <li>
        <router-link to="/profile"><img src="@/assets/user_icon.svg"></router-link>
        <router-link to="/"><div class="box">Graj</div></router-link>
      </li>
      <li><router-link to="/world"><div class="box">Świat</div></router-link></li>
      <li><router-link to="/mechanics"><div class="box">Mechanika</div></router-link></li>
      <li><router-link to="/managment"><div class="box">Zarządzanie</div></router-link></li>
      <li><router-link to="/login"><div class="box">Zaloguj</div></router-link></li>
    </ul>
  </nav>
  <router-view/>
</template>

<script>
export default {
  name: 'App',
  data: () => ({
     isOpen: true 
    })
}
</script>

<style lang="scss">
@import 'styles/colors';

header {
  display: flex;
  justify-content: space-between;
  height: 3em;
  background-color: $color-main;
}

img {
    height: 100%;
}

nav{
  position: fixed;
  display: flex;
  left: 0;
  background-color: $color-main;
  height: 100%;
  width: 0;
  overflow: hidden;
  margin-top: 3em;
  transition: width 0.2s linear;

  ul {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    list-style: none;
    margin: 0;
    padding: 0;
  }
  li{
    height: 3em;
    margin: 0.3em;
    display: flex;
  }

  a {
    text-decoration: none;
    display: flex;
    flex: 1;
  }

  li:first-child a:first-child {
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

  img {
    border: 0.2em solid $color-darker;
    border-radius: 2em;
  }

  
}
nav.open{
  width: 15em;
}
</style>
