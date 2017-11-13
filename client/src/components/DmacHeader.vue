<template>
  <div>
    <nav class="navbar header">
      <div class="navbar-brand">
        <router-link class="nav-item app-name" :to="'/'">
          Data Management and Analysis Core
        </router-link>
      </div>

      <div class="navbar-menu">
        <div class="navbar-start">
        </div>

        <div class="navbar-end">
          <div class="navbar-item">
            <span class="app-item" v-if="token" @mouseover="showEmail=true" @mouseout="showEmail=false">Hi,&nbsp;
              <span>{{name}}</span>
            </span>
          </div>
          <div class="navbar-item">
            <router-link class="app-item" v-if="token" :to="'/help'">
              <span class="nav-icon"><icon name="question"></icon></span>Help
            </router-link>
          </div>
          <div class="navbar-item">
            <a class="app-item" v-if="token" @click="logout">
              <span class="nav-icon"><icon name="sign-out"></icon></span>Logout
            </a>
          </div>
        </div>
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
      showEmail: false
    }
  },
  computed: {
    token () {
      var token = this.$store.state.user.token
      if(token){
        Vue.http.headers.common['Authorization'] = token
      }
      return token
    },
    name () {
      var username = this.$store.state.user.username
      var email = this.$store.state.user.email
      if(this.showEmail)
        return username + ' <' + email + '>'
      return username
    }
  },
  methods: {
    logout () {
      delete Vue.http.headers.common['Authorization']
      var loginFrom = this.$store.state.user.loginFrom
      this.$store.commit('user/reset')
      if(loginFrom == 'Globus'){
        window.location.href = 'https://auth.globus.org/v2/web/logout?redirect_uri=' + xHTTPx + '&redirect_name=DMAC' 
      }
    }
  },
}
</script>

<style lang="scss" scoped>
.header {
  background-color: #2e1052;
  border-radius: 3px;
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
  margin: auto;
  padding-left: 20px;
}

.nav-icon {
  position: relative;
  top: 3px;
  right: 3px;
}

.app-item {
  color: #FFFFFF;
}

a:hover {
  color: #EEEEEE;
}


</style>
