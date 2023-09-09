<template>
  <div class="section">
    <div class="player_main">
      <div class="player_model">
        <table>
          <tr><td></td><td></td></tr>
          <tr><td></td><td></td></tr>
          <tr><td></td><td></td></tr>
        </table>
      </div>
      <div class="player_info">
        <img src="@/assets/user_icon.svg">
        <span><b>Nazwa:</b> Mahiro Suda</span>
        <span><b>Zdrowie:</b> 100%</span>
        <span><b>Mana:</b> 35 000 / 50 000</span>
        <span style="flex: 3; align-items: flex-start; padding-top: 1.5em; box-sizing: border-box; flex-direction: column;">
          <b>Przedmioty:</b>
          <table style="margin: 0.5em;">
            <tr><td></td><td></td><td></td><td></td><td></td></tr>
            <tr><td></td><td></td><td></td><td></td><td></td></tr>
            <tr><td></td><td></td><td></td><td></td><td></td></tr>
          </table>
        </span>
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

  .player_model{
    border: 0.2em solid $color_darker;
    box-sizing: border-box;
    width: 50%;
    background-image: url("../assets/standing_human.svg");
    background-size: contain;
    background-repeat: no-repeat;
    background-position: center center;
    background-origin: content-box;
    display: flex;

    table {
      display: flex;
      justify-content: start;
      align-items: center;
      flex-direction: column;
      flex: 1;
    }
    tr {
      display: flex;
      justify-content: space-between;
      margin-top: 4.5em;
    }
    td {
      margin: 0 3.5em 0 3.5em;
      opacity: 0.9;
      padding: 2em;
    }
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
    width: 50%;
    box-sizing: border-box;
    align-self: center;
  }

  span {
    height: auto;
    flex: 1;
    align-self: stretch;
    justify-content: flex-start;
    text-align: start;
    text-indent: 1em;
    margin: 0 1em 0 1;
  }
}

td {
    border: 0.2em solid $color_lighter;
    padding: 1.8em;
    box-sizing: border-box;
    background-color: $color_darker;
  }

</style>