// get options from local storage
var projectFilter = localStorage.getItem('projectFilter')
var channelFilter = localStorage.getItem('channelFilter')
var channelSort = localStorage.getItem('channelSort')
var projectTab = localStorage.getItem('projectTab')

// initial state
export const state = {
  projectFilter: projectFilter ? projectFilter : 'Active',
  channelFilter: channelFilter ? channelFilter : 'Open',
  channelSort: channelSort ? channelSort : 'Sort by Folder',
  projectTab: projectTab ? projectTab : 'Basic'
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
  },

  setProjectTab (state, val) {
    state.projectTab = val
    localStorage.setItem('projectTab', val)
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
