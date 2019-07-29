// initial state
export const state = {
  uploadChannelModal: {
    opened: false,
    channel: null,
    project: null
  },
}

// mutations
export const mutations = {

  openUploadChannelModal (state, obj) {
    state.uploadChannelModal.channel = obj.channel
    state.uploadChannelModal.project = obj.project
    state.uploadChannelModal.opened = true
  },

  closeUploadChannelModal (state) {
    state.uploadChannelModal.channel = null
    state.uploadChannelModal.channel = null
    state.uploadChannelModal.opened = false
  },
}

export default {
  namespaced: true,
  state,
  mutations
}
