<template>
  <div id="app">
    <dmac-header></dmac-header>
    <div v-if="showLogin">
      <dmac-login></dmac-login>
    </div>
    <div v-if="!showLogin" class="columns">
      <div class="column is-one-quarter" v-show="showNav">
        <dmac-nav></dmac-nav>
      </div>
      <div class="column main-window" :class="{'is-three-quarter': showNav, 'show-nav': showNav}">
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
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    showLogin () {
      if(this.publicKey) return false
      return !this.token
    },
    showNav () {
      return this.$store.state.projects.showNav
    }
  }
}
</script>

<style lang="scss">
@import "~bulma/sass/utilities/initial-variables";
$primary: #2e1052;
$blue: #866ba6;
@import "~bulma";
@import "~c3/c3.css";
@import "~parcoord-es/dist/parcoords.css";


body {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: black;
}

.main-btn {
  color: white!important;
  background-color: #2e1052!important;
  border-color: #2e1052!important;
}

.main-btn:hover {
  color: #e6e6e6!important;
}

.default-btn {
  color: #2e1052!important;
}

.main-link {
  color: #2e1052;
}

.main-link:hover {
  color: #866ba6;
  text-decoration: underline;
}

.search-button {
  cursor: pointer;
}

.view-title {
  font-size: 24px;
  font-weight: bold;
  color: #2e1052;
}

.spinner-container {
  text-align: center;
}

.main-window {
  max-width: 100%;
}

.show-nav {
  max-width: 75%;
}

.dygraph-title {
  text-align: center;
  font-weight: bold;
}

.dygraph-legend {
  position: absolute;
  right: 0px;
  left: unset!important;
}

.table {
  color: unset!important;
}

.table thead th{
  color: unset!important;
}


</style>
