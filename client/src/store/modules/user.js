
// initial state
export const state = {
  email: localStorage.getItem('email'),
  token: localStorage.getItem('token')
}

// mutations
export const mutations = {

  setEmail (state, email) {
    state.email = email
  },

  setToken (state, token) {
    state.token = token
  },

  reset (state) {
    state.email = null
    state.token = null
    localStorage.removeItem('email')
    localStorage.removeItem('token')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
