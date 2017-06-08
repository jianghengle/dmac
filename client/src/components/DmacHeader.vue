<template>
  <div>
    <nav class="nav">
        <div class="nav-left">
          <a class="nav-item app-name">
            Data Management and Analysis Core
          </a>
        </div>
        <div class="nav-right">
          <a class="nav-item" v-if="token" @click="logout">Log out</a>
        </div>
    </nav>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'dmac-header',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  computed: {
    token () {
      var token = this.$store.state.user.token
      if(token){
        Vue.http.headers.common['Authorization'] = token
      }
      return token
    }
  },
  methods: {
    logout () {
      delete Vue.http.headers.common['Authorization']
      return this.$store.commit('user/reset')
    }
  },
}
</script>

<style scoped>
.app-name {
    font-weight: bold;
    font-size: 18px;
}
</style>
