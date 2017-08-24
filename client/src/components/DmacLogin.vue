<template>
  <div class="login-page">
    <div class="welcome">Welcome to DMAC system!</div>
    <div v-if="showLogin">
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
          <button class="button main-btn" :class="{'is-loading': sent}" @click="login">Login</button>
        </p>
      </div>

      <div>
        <a :href="adminPage" class="main-link">Forgot your password?</a>
      </div>
      <div>
        <a @click="showLogin = false" class="main-link">Register new account</a>
      </div>
    </div>

    <div v-else>
      <div class="welcome">You will register a new "Subscriber" user, who can only join projects but cannot create a new project. If you want to create a new project, first register here, and then contact jianghengle@gmail.com with your name, department and/or your referer so that he can grant you the permission.</div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="text" placeholder="Email" v-model="newEmail">
          <span class="icon is-small is-left">
            <icon name="envelope"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="password" placeholder="Password (minimum length 6)" v-model="newPassword">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="password" placeholder="Password again" v-model="newPasswordAgain">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="text" placeholder="First Name" v-model="newFirstName">
          <span class="icon is-small is-left">
            <icon name="user"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="text" placeholder="Last Name" v-model="newLastName">
          <span class="icon is-small is-left">
            <icon name="user"></icon>
          </span>
        </p>
      </div>

      <div v-if="registerError" class="notification is-danger login-text">
        <button class="delete" @click="registerError=''"></button>
        {{registerError}}
      </div>

      <div v-if="registerInfo" class="notification is-success login-text">
        <button class="delete" @click="registerInfo=''"></button>
        {{registerInfo}}
      </div>

      <div class="field is-grouped">
        <p class="control">
          <button class="button main-btn" :class="{'is-loading': sent}" @click="register">Register</button>
        </p>
      </div>

      <div>
        <a @click="showLogin = true" class="main-link">Login Page</a>
      </div>
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
      sent: false,
      showLogin: true,
      adminPage: xHTTPx.replace('3000', '3001'),
      newEmail: '',
      newPassword: '',
      newPasswordAgain: '',
      newFirstName: '',
      newLastName: '',
      registerError: '',
      registerSuccess: ''
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
    newEmail: function (val) {
      if (val) {
        this.registerError = ''
        this.registerInfo = ''
      }
    },
    newPassword: function (val) {
      if (val) {
        this.registerError = ''
        this.registerInfo = ''
      }
    },
    newPasswordAgain: function (val) {
      if (val) {
        this.registerError = ''
        this.registerInfo = ''
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
        this.$router.push("/projects")
      }, response => {
        vm.error = 'Failed to authorize user!'
        this.$store.commit('user/reset')
        this.sent = false
      })
    },
    register () {
      this.newEmail = this.newEmail.trim().toLowerCase()
      if(!emailRegex.test(this.newEmail)){
        this.registerError = 'Invalid email address!'
        return
      }
      this.newPassword = this.newPassword.trim()
      this.newPasswordAgain = this.newPasswordAgain.trim()
      if(this.newPassword.length < 6){
        this.registerError = 'Minmum password length is 6!'
        return
      }
      if(this.newPassword != this.newPasswordAgain){
        this.registerError = 'Two passwords do not match!'
        return
      }

      this.sent = true
      var vm = this
      var message = {email: this.newEmail, password: this.newPassword, firstName: this.newFirstName, lastName: this.newLastName}
      vm.$http.post(xHTTPx + '/create_user', message).then(response => {
        vm.registerInfo = 'Succeed. Go to login page.'
        this.sent = false
      }, response => {
        vm.registerError = 'Failed to create new account!'
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
