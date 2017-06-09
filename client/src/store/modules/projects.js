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
      var oldArr = state.root.children
      var newArr = projects.map(function(p){
        p.type = 'project'
        p.path = '/' + p.id + '/-root-'
        p.createdDate = DateForm(p.created_at*1000, 'mediumDate')
        p.udpatedDate = DateForm(p.updated_at*1000, 'mediumDate')
        return p
      })
      updateArray(oldArr, newArr, state.nodeMap)
    }else{
      var root = {
        type: 'projects',
        path: '/'
      }
      Vue.set(state.nodeMap, '/', root)
      var children = projects.map(function(p){
        p.type = 'project'
        p.path = '/' + p.id + '/-root-'
        Vue.set(state.nodeMap, p.path, p)
        p.createdDate = DateForm(p.created_at*1000, 'mediumDate')
        p.udpatedDate = DateForm(p.updated_at*1000, 'mediumDate')
        return p
      })
      node.children = children
      state.root = node
    }
  },


  setProject (state, project) {
    var projectNode = state.nodeMap['/' + project[0].id + '/-root-']
    if(projectNode){
      updateNode(projectNode, project[0])
      if(!projectNode.children){
        projectNode.children = []
      }
      var oldArr = projectNode.children
      var newArr = project.slice(2).map(function(f){
        f.modifiedAt = DateForm(f.modified_at*1000, 'mmm dd yyyy HH:MM')
        return f
      })
      var usersNode = {type: 'users', path: '/'+ project[0].id + '/-users-'}
      newArr.unshift(usersNode)
      updateArray(oldArr, newArr, state.nodeMap)
    }else{
      var root = {
        type: 'projects',
        path: '/'
      }
      Vue.set(state.nodeMap, '/', root)
      var p = project[0]
      p.type = 'project'
      p.path = '/' + p.id + '/-root-'
      Vue.set(state.nodeMap, p.path, p)
      p.createdDate = DateForm(p.created_at*1000, 'mediumDate')
      p.udpateDate = DateForm(p.update_at*1000, 'mediumDate')
      root.children = [p]

      var children = []
      var usersNode = {type: 'users', path: '/'+ p.id + '/-users-'}
      var files = project.slice(2).map(function(f){
        Vue.set(state.nodeMap, f.path, f)
        f.modifiedAt = DateForm(f.modified_at*1000, 'mmm dd yyyy HH:MM')
        return f
      })
      p.children = files
      p.children.unshift(usersNode)
      state.root = root
    }
  },

  setFolder (state, folder) {
    console.log(folder)
    var folderNode = state.nodeMap[folder[0].path]
    if(folderNode){
      updateNode(folderNode, folder[0])
    }else{
      buildChain(state, folder[0])
      folderNode = state.nodeMap[folder[0].path]
    }

    if(!folderNode.children){
      folderNode.children = []
    }
    var oldArr = folderNode.children
    var newArr = folder.slice(1).map(function(f){
      f.modifiedAt = DateForm(f.modified_at*1000, 'mmm dd yyyy HH:MM')
      return f
    })
    updateArray(oldArr, newArr, state.nodeMap)

    console.log(folderNode)
  },

  reset (state) {
    state.projects = []
  }
}


function buildChain(state, folder){
  var root = {type: 'projects', path: '/'}
  Vue.set(state.nodeMap, '/', root)
  state.root = root

  var projectNode = {
    type: 'project',
    path: '/' + folder.project_id, 
    id: folder.project_id
  }
  Vue.set(state.nodeMap, projectNode.path, projectNode)
  state.root.children = [projectNode]
  
  var ss = folder.path.split('/')[2].split('--')
  var node = projectNode
  for(var i=0;i<ss.length;i++){
    var child
    if(i == 0){
      child = {path: node.path + '/' + ss[i], name: ss[i]}
    }else{
      child = {path: node.path + '--' + ss[i], name: ss[i]}
    }
    node.children = [child]
    Vue.set(state.nodeMap, child.path, child)
    node = child
  }

  updateNode(node, folder)
}


function updateNode(oldNode, newNode){
  Object.keys(newNode).forEach(function(k){
    if(oldNode[k] == undefined){
      Vue.set(oldNode, k, newNode[k])
    }else{
      oldNode[k] = newNode[k]
    }
  })
}


function updateArray(oldArr, newArr, nodeMap){
  var newMap = {}
  newArr.forEach(function(e){
    newMap[e.path] = e
  })
  var removed = []
  for(var i=0;i<oldArr.length;i++){
    var o = oldArr[i]
    var n = newMap[o.path]
    if(n){
      Object.keys(n).forEach(function(k){
        if(o[k] == undefined){
          Vue.set(o, k, n[k])
        }else{
          o[k] = n[k]
        }
      })
    }else{
      removed.push(i)
    }
  }
  for(var i=removed.length-1;i>=0;i--){
    var e = oldArr[i]
    delete nodeMap[e.path]
    oldArr.splice(removed[i], 1)
  }
  var oldMap = {}
  oldArr.forEach(function(e){
    oldMap[e.path] = e
  })
  newArr.forEach(function(e){
    if(!oldMap[e.path]){
      oldArr.push(e)
      Vue.set(nodeMap, e.path, e)
    }
  })
  return sortArray(oldArr)
}


function sortArray(arr){
  return arr
}


export default {
  namespaced: true,
  state,
  mutations
}
