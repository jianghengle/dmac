import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import projects from './modules/projects'
import search from './modules/search'
import options from './modules/options'
import irods from './modules/irods'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    user: user,
    projects: projects,
    search: search,
    options: options,
    irods: irods
  }
})
