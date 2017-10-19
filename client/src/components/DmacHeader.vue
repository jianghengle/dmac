<template>
  <div>
    <nav class="nav header">
        <div class="nav-left">
          <router-link class="nav-item app-name" :to="'/'">
            Data Management and Analysis Core
          </router-link>
        </div>
        <div class="nav-right">
          <span class="nav-item app-item" v-if="token" @mouseover="showEmail=true" @mouseout="showEmail=false">Hi,&nbsp;
            <span>{{name}}</span>
          </span>
          <router-link class="nav-item app-item" v-if="token" :to="'/help'">
            <icon name="question"></icon>&nbsp;Help
          </router-link>
          <a class="nav-item app-item" v-if="token" @click="logout">
            <icon name="sign-out"></icon>&nbsp;Logout
          </a>
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
        return username + ' ( ' + email + ' )'
      return username
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

<style lang="scss" scoped>
.header {
  background-color: #2e1052;
  border-radius: 3px;
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
}

.app-item {
  color: #FFFFFF;
}

a:hover {
  color: #EEEEEE;
}


</style>
