import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import projects from './modules/projects'
import search from './modules/search'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    user: user,
    projects: projects,
    search: search
  }
})
