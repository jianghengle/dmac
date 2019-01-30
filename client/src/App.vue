<template>
  <div id="app">
    <dmac-header></dmac-header>

    <div class="columns">
      <div class="column is-one-quarter" v-show="showNav">
        <dmac-nav></dmac-nav>
      </div>
      <div class="column" :class="{'is-three-quarter': showNav}" :style="{'max-width': mainWindowMaxWidth}">
        <router-view></router-view>
      </div>
    </div>

  </div>
</template>

<script>
import DmacHeader from './components/DmacHeader'
import DmacNav from './components/DmacNav'
import Vue from 'vue'

export default {
  name: 'app',
  components: {
    DmacHeader,
    DmacNav
  },
  data () {
    return {
      windowWidth: 0,
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    routePath () {
      return this.$route.path
    },
    showNav () {
      if(this.routePath == '/help' || this.routePath == '/login' || this.routePath == '/get_started')
        return false
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

    if(this.token) {
      Vue.http.headers.common['Authorization'] = this.token
    }else{
      this.$router.push('/login')
    }
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.handleResize)
  }
}
</script>

<style lang="scss">
@import "~bulma/sass/utilities/initial-variables";
$primary: #2e1052;
$blue: #2e1052;
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
  font-size: 20px;
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
