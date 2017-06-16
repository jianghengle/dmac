// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'

import VueResource from 'vue-resource'
Vue.use(VueResource)

import 'vue-awesome/icons/sign-out'
import 'vue-awesome/icons/envelope'
import 'vue-awesome/icons/key'
import 'vue-awesome/icons/folder'
import 'vue-awesome/icons/folder-open'
import 'vue-awesome/icons/file-o'
import 'vue-awesome/icons/file-image-o'
import 'vue-awesome/icons/file-pdf-o'
import 'vue-awesome/icons/trash'
import 'vue-awesome/icons/navicon'
import 'vue-awesome/icons/spinner'
import 'vue-awesome/icons/user-o'
import 'vue-awesome/icons/user'
import 'vue-awesome/icons/database'
import 'vue-awesome/icons/folder-o'
import 'vue-awesome/icons/folder-open-o'
import 'vue-awesome/icons/plus'
import 'vue-awesome/icons/edit'
import 'vue-awesome/icons/upload'
import 'vue-awesome/icons/download'
import Icon from 'vue-awesome/components/Icon'
Vue.component('icon', Icon)

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: { App }
})
