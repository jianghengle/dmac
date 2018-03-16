
// initial state
export const state = {
  username: null,
  password: null,
  irodsPath: null
}

// mutations
export const mutations = {

  setUsername (state, val) {
    state.username = val
  },

  setPassword (state, val) {
    state.password = val
  },

  setIrodsPath (state, val) {
    state.irodsPath = val
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
