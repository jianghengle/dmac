<template>
  <div>
    <nav class="navbar header">
      <div class="navbar-brand">
        <router-link class="nav-item app-name" :to="'/'">
          Data Management and Analysis Core
        </router-link>

        <div class="navbar-burger burger app-burger" :class="{'is-active': menuActive}"
          @click="menuActive = !menuActive">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>

      <div class="navbar-menu app-menu" :class="{'is-active': menuActive}">
        <div class="navbar-end">

          <div v-if="token" class="navbar-item">
            <span class="app-item" @mouseover="showEmail=true" @mouseout="showEmail=false">Hi,&nbsp;
              <span>{{name}}</span>
            </span>
          </div>

          <div v-if="token" class="navbar-item">
            <a class="app-item" href="https://sway.office.com/YzEjQGZyPF9FHATh" target="_blank">
              <span class="nav-icon"><icon name="tasks"></icon></span>Status
            </a>
          </div>

          <div class="navbar-item has-dropdown is-hoverable my-dropdown">
            <router-link class="navbar-link" :to="'/get_started'">
              <span class="nav-icon"><icon name="book"></icon></span>Docs
            </router-link>

            <div class="navbar-dropdown is-right">
              <router-link class="navbar-item" :to="'/get_started'">
                Get Started
              </router-link>
              <router-link class="navbar-item" :to="'/help'">
                Help
              </router-link>
            </div>
          </div>

          <div v-if="token" class="navbar-item">
            <a class="app-item" @click="logout">
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
      showEmail: false,
      menuActive: false
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
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
      this.menuActive = false
      if(loginFrom == 'Globus'){
        window.location.href = 'https://auth.globus.org/v2/web/logout?redirect_uri=' + xHTTPx + '&redirect_name=DMAC' 
      }else{
        this.$router.push('/login')
      }
    },
  },
}
</script>

<style lang="scss" scoped>
.header {
  background-color: #2e1052;
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
  margin: auto;
  padding-left: 20px;
}

.app-burger {
  color: white;
  margin: unset;
}

.app-menu {
  background-color: #2e1052;
}

.my-dropdown {

  .navbar-link {
    color: #FFFFFF;
  }

  .navbar-link::after {
    border-color: #FFFFFF;
  }

  .navbar-dropdown {

    .navbar-item {
      color: #FFFFFF;
    }

    .navbar-item:hover {
      color: #CCCCCC;
      background-color: #2e1052;
    }
  }
}

.my-dropdown:hover .navbar-link{
  color: #CCCCCC;
  background-color: #2e1052;
}

.my-dropdown:hover .navbar-link::after{
  border-color: #CCCCCC;
}

.my-dropdown:hover .navbar-dropdown{
  background-color: #2e1052;
}

.nav-icon {
  position: relative;
  top: 3px;
  right: 5px;
}

.app-item {
  color: #FFFFFF;
}

a:hover {
  color: #CCCCCC;
}


</style>
