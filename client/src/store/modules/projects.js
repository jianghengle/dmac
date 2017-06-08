import Vue from 'vue'
import DateForm from 'dateformat'

// initial state
export const state = {
  root: null,
  nodeMap: {}
}

// mutations
export const mutations = {

  setProjects (state, projects) {
    if(state.root){
      var children = state.root.children
      var projectMap = {}
      projects.forEach(function(p){
        projectMap[p.id] = p
      })
      var indexes = []
      for(var i=0;i<children.length;i++){
        var child = children[i]
        if(projectMap[child.id]){
          child.updated_at = projectMap[child.id].updated_at
          child.udpateDate = DateForm(child.update_at*1000, 'mediumDate')
        }else{
          indexes.push(i)
        }
      }
      for(var i=indexes.length-1;i>=0;i--){
        children.splice(indexes[i], 1)
      }
    }else{
      var node = {
        type: 'projects',
        address: '/',
        path: '/'
      }
      state.nodeMap['/'] = node
      var children = projects.map(function(p){
        p.type = 'project'
        p.address = '/' + p.key
        state.nodeMap[p.address] = p
        p.path = '/' + p.id + '/-root-'
        p.createdDate = DateForm(p.created_at*1000, 'mediumDate')
        p.udpateDate = DateForm(p.update_at*1000, 'mediumDate')
        return p
      })
      node.children = children
      state.root = node
    }

  },

  reset (state) {
    state.projects = []
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
