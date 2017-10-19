
// initial state
export const state = {
  email: localStorage.getItem('email'),
  token: localStorage.getItem('token'),
  username: localStorage.getItem('username')
}

// mutations
export const mutations = {

  setEmail (state, email) {
    state.email = email
  },

  setToken (state, token) {
    state.token = token
  },

  setUsername (state, username) {
    state.username = username
  },

  reset (state) {
    state.email = null
    state.token = null
    state.username = null
    localStorage.removeItem('email')
    localStorage.removeItem('token')
    localStorage.removeItem('username')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
