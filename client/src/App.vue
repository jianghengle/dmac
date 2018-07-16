<template>
  <div id="app">
    <dmac-header @toggle-help-page="showHelp = !showHelp"></dmac-header>
    <div v-if="showHelp">
      <help-page @toggle-help-page="showHelp = !showHelp"></help-page>
    </div>
    <div v-else>
      <div v-if="showLogin">
        <dmac-login></dmac-login>
      </div>
      <div v-if="!showLogin" class="columns">
        <div class="column is-one-quarter" v-show="showNav">
          <dmac-nav></dmac-nav>
        </div>
        <div class="column" :class="{'is-three-quarter': showNav}" :style="{'max-width': mainWindowMaxWidth}">
          <router-view></router-view>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import DmacHeader from './components/DmacHeader'
import DmacNav from './components/DmacNav'
import DmacLogin from './components/DmacLogin'
import HelpPage from './components/HelpPage'

export default {
  name: 'app',
  components: {
    DmacHeader,
    DmacNav,
    DmacLogin,
    HelpPage
  },
  data () {
    return {
      windowWidth: 0,
      showHelp: false
    }
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
    },
    mainWindowMaxWidth () {
      if(this.showNav && this.windowWidth > 768){
        return '75%'
      }
      return '100%'
    }
  },
  methods: {
    handleResize () {
      this.windowWidth = window.innerWidth
    }
  },
  mounted () {
    this.windowWidth = window.innerWidth
    window.addEventListener('resize', this.handleResize)
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.handleResize)
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
  font-weight: normal;
}

.main-btn:hover {
  color: #e6e6e6!important;
}

.default-btn {
  color: #2e1052!important;
  font-weight: normal;
}

.main-link {
  color: #2e1052;
  cursor: pointer;
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
