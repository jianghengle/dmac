// get options from local storage
var projectFilter = localStorage.getItem('projectFilter')
var channelFilter = localStorage.getItem('channelFilter')
var channelSort = localStorage.getItem('channelSort')

// initial state
export const state = {
  projectFilter: projectFilter ? projectFilter : 'Active',
  channelFilter: channelFilter ? channelFilter : 'Open',
  channelSort: channelSort ? channelSort : 'Sort by Folder'
}

// mutations
export const mutations = {
  setProjectFilter (state, val) {
    state.projectFilter = val
    localStorage.setItem('projectFilter', val)
  },

  setChannelFilter (state, val) {
    state.channelFilter = val
    localStorage.setItem('channelFilter', val)
  },

  setChannelSort (state, val) {
    state.channelSort = val
    localStorage.setItem('channelSort', val)
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
