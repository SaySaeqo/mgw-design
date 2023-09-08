<template>
  <div class="section">
    <div class="player_main">
      <img src="@/assets/standing_human.svg">
      <div class="player_info">
        <img src="@/assets/user_icon.svg">
        <span>Nazwa:</span>
        <span>Życie/mana:</span>
        <span>Przedmioty:</span>
      </div>
    </div>
    <span>Aktualna lokacja</span>
    <span>Statystyki</span>
    <span>Dodatkowe informacje</span>
  </div>
  <div class="section">
    <span>MAPA</span>
  </div>
  <div class="section">
    <span>LOKACJA 1</span>
    <span>LOKACJA 2</span>
    <span>LOKACJA 3</span>
    <span>LOKACJA 4</span>
  </div>
</template>

<script>
export default {
  name: 'ViewPlay',
}
</script>

<style lang="scss" scoped>
@import '../styles/colors';

.player_main {
  display: flex;
  justify-content: center;
  gap: 1em;

  > img{
  height: 20em;
  border: 0.2em solid $color_darker;
  padding: 1em;
}
}



.player_info{
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  flex: 1;
  gap: 1em;

  img {
    border: 0.2em solid $color_darker;
    border-radius: 100em;
    height: 6.5em;
  }

  span {
    height: auto;
    flex: 1;
    align-self: stretch;
    text-align: start;
    text-indent: 1em;
  }
}

</style>