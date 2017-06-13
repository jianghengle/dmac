<template>
  <div class="login-page">
    <div class="welcome">Welcome to DMAC system!</div>
    <div class="field">
      <p class="control has-icons-left">
        <input class="input login-text" type="text" placeholder="Email" v-model="email">
        <span class="icon is-small is-left">
          <icon name="envelope"></icon>
        </span>
      </p>
    </div>

    <div class="field">
      <p class="control has-icons-left">
        <input class="input login-text" type="password" placeholder="Password" v-model="password">
        <span class="icon is-small is-left">
          <icon name="key"></icon>
        </span>
      </p>
    </div>

    <div class="field">
      <p class="control">
        <label class="checkbox">
          <input type="checkbox" v-model="rememberMe">
          Remember me
        </label>
      </p>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="field is-grouped">
      <p class="control">
        <button class="button is-info" :class="{'is-loading': sent}" @click="login">Login</button>
      </p>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

export default {
  name: 'dmac-login',
  data () {
    return {
      email: '',
      password: '',
      rememberMe: false,
      error: '',
      sent: false 
    }
  },
  watch: {
    email: function (val) {
      if (val) {
        this.error = ''
      }
    },
    password: function (val) {
      if (val) {
        this.error = ''
      }
    },
  },
  methods: {
    login () {
      this.email = this.email.trim().toLowerCase()
      if(!emailRegex.test(this.email)){
        this.error = 'Invalid email address!'
        return
      }
      this.sent = true
      var vm = this
      var message = {email: this.email, password: this.password}
      vm.$http.post(xHTTPx + '/get_auth_token', message).then(response => {
        var token = response.body.token
        Vue.http.headers.common['Authorization'] = token
        this.$store.commit('user/setToken', token)
        this.$store.commit('user/setEmail', this.email)
        if (vm.rememberMe) {
          localStorage.setItem('token', token)
          localStorage.setItem('email', this.email)
        }
        this.sent = false
        this.$router.push("/")
      }, response => {
        vm.error = 'Failed to authorize user!'
        this.$store.commit('user/reset')
        this.sent = false
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  .login-page {
    padding: 20px;
  }

  .welcome {
    padding-bottom: 10px;
  }

  .login-text {
    max-width: 500px;
  }
</style>
