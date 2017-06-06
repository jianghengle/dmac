<template>
  <div id="app">
    <dmac-header></dmac-header>
    <div v-if="!token">
      <dmac-login></dmac-login>
    </div>
    <div v-if="token" class="columns">
      <div class="column is-one-quarter">
        <dmac-nav></dmac-nav>
      </div>
      <div class="column is-three-quarter">
        <router-view></router-view>
      </div>
    </div>
  </div>
</template>

<script>
import DmacHeader from './components/DmacHeader'
import DmacNav from './components/DmacNav'
import DmacLogin from './components/DmacLogin'

export default {
  name: 'app',
  components: {
    DmacHeader,
    DmacNav,
    DmacLogin
  },
  computed: {
    token () {
      return this.$store.state.user.token
    }
  }
}
</script>

<style>
@import "../node_modules/bulma/css/bulma.css";

</style>
