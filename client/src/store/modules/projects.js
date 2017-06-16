import Vue from 'vue'
import DateForm from 'dateformat'

// initial state
export const state = {
  showNav: false,
  nodeMap: {}
}

// mutations
export const mutations = {

  toggleNav (state) {
    state.showNav = !state.showNav
  },

  setProjects (state, resp) {
    var ps = resp.map(initProject)
    var children = []
    ps.forEach(function(p){
      var np = updateNode(state, p)
      children.push(p.path)
    })
    var root = initRoot()
    updateNode(state, root, children)
  },


  setProject (state, resp) {
    var project = initProject(resp)
    patchChain(state.nodeMap, project, project.path)

    var users = initUsers(project)
    if(!state.nodeMap[users.path]){
      Vue.set(state.nodeMap, users.path, users)
    }

    var root = initFile({
      projectId: project.id,
      type: 'folder',
      name: '-root-',
      path: '/' + project.id + '/-root-',
      dataPath: '-root-',
      size: 0,
      modifiedTime: 0
    })
    if(!state.nodeMap[root.path]){
      Vue.set(state.nodeMap, root.path, root)
    }

    var children = [users.path, root.path]
    updateNode(state, project, children)
  },

  setFile (state, resp) {
    var project = initProject(resp[0])
    var file = initFile(resp[1])
    if(file.dataPath == '-root-'){
      file.name = '-root-'
    }
    patchChain(state.nodeMap, project, file.path)
    if(file.type == 'folder'){
      var files = resp.slice(2).map(initFile)
      var children = []
      files.forEach(function(f){
        var nf = updateNode(state, f)
        children.push(nf.path)
      })
      updateNode(state, file, children)
    }else{
      updateNode(state, file)
    }
  },

  openNode (state, path) {
    var node = state.nodeMap[path]
    if(node){
        node.options.open = true
    }
  },

  closeNode (state, path) {
    var node = state.nodeMap[path]
    if(node){
      node.options.open = false
    }
  }

}


function initRoot(){
  var options = {
    open: true,
    sortOption: {
      field: 'createdTime',
      order: 'number',
      asc: false
    }
  }
  return {
    type: 'projects',
    path: '/',
    name: 'Projects',
    options: options,
    children: []
  }
}


function initProject(project, options){
  var p = Object.assign({}, project)
  p.type = 'project'
  p.path = '/' + p.id
  p.createdDate = DateForm(p.createdTime*1000, 'mediumDate')
  p.udpatedDate = DateForm(p.updatedTime*1000, 'mediumDate')
  var opts = {}
  opts.open = false
  if(options){
    Object.assign(opts, options)
  }
  p.options = opts
  p.children = ['/'+ p.id + '/users']
  p.children = ['/'+ p.id + '/-root-']
  return p
}


function initUsers(project) {
  return {
    type: 'users',
    path: '/'+ project.id + '/users',
    name: 'Users',
    options: {open: false}
  }
}


function initFile(file, options){
  var f = Object.assign({}, file)
  f.path = '/' + f.projectId + '/data/' + f.dataPath
  f.modifiedAt = DateForm(f.modifiedTime*1000, 'mmm dd yyyy HH:MM')
  if(f.type == 'file'){
    var iconMap = {
      unknown: 'file-o',
      image: 'file-image-o',
      pdf: 'file-pdf-o'
    }
    f.icon = iconMap[f.fileType]
  }

  var opts = {}
  if(f.type == 'folder'){
    opts.open = false
  }
  opts.sortOption = {
    field: 'type',
    order: ['folder', 'file'],
    asc: true
  }
  if(options){
    Object.assign(opts, options)
  }
  f.options = opts
  if(f.type == 'folder'){
    f.children = []
  }
  return f
}


function updateNode(state, node, children){
  var old = state.nodeMap[node.path]
  if(old){
    node.options = old.options
    if(old.children){
      node.children = old.children
    }
  }
  if(children){
    node.children = children
    if(node.options.sortOption){
      sortChildren(node, state.nodeMap)
    }
  }
  if(old){
    state.nodeMap[node.path] = node
  }else{
    Vue.set(state.nodeMap, node.path, node)
  }
  return node
}


function sortChildren(node, nodeMap){
  var children = node.children.slice()
  var nodes = children.map(function(c){
    return nodeMap[c]
  })
  nodes.sort(function(a, b){
    return compareNodes(a, b, node.options.sortOption)
  })
  children = nodes.map(function(o){
    return o.path
  })
  node.children = children
}


function compareNodes(o1, o2, opt){
  var v1 = o1[opt.field]
  var v2 = o2[opt.field]
  if(v1 == v2){
    return o1.name.localeCompare(o2.name)
  }
  if(opt.order == 'number'){
    if(opt.asc){
      return v1 - v2
    }
    return v2 - v1
  }else if(opt.order == 'string'){
    if(opt.asc){
      return v1.localeCompare(v2)
    }
    return -v1.localeCompare(v2)
  }else if(Array.isArray(opt.order)){
    var i1 = opt.order.indexOf(v1)
    var i2 = opt.order.indexOf(v2)
    if(opt.asc){
      return i1 - i2
    }
    return i2 - i1
  }
  return 0
}


function patchChain(nodeMap, project, path){
  var parent = findParent(path)
  while(parent && !nodeMap[parent.path]){
    if(parent.type == 'projects'){
      var root = initRoot()
      root.children = [parent.childPath]
      Vue.set(nodeMap, root.path, root)
    }else if(parent.type == 'project'){
      var project = initProject(project, {open: true})
      project.children = [parent.childPath]
      Vue.set(nodeMap, project.path, project)
    }else if(parent.type == 'folder'){
      var folder = {
        projectId: project.id,
        type: 'folder',
        name: parent.name,
        dataPath: parent.dataPath,
        size: 0,
        modifiedTime: 0
      }
      var folder = initFile(folder, {open: true})
      folder.children = [parent.childPath]
      Vue.set(nodeMap, folder.path, folder)
    }
    parent = findParent(parent.path)
  }
}


function findParent(path){
  var ss = path.split('/')
  if(ss.length < 2) return null
  var parent = {childPath: path}
  if(ss.length == 2){
    parent.type = 'projects'
    parent.path = '/'
  }else if(ss.length == 3){
    if(ss[2] == 'users'){
      parent.type = 'project'
      parent.path = '/' + ss[1]
    }
  }else if(ss.length == 4){
    if(ss[3] == '-root-'){
      parent.type = 'project'
      parent.path = '/' + ss[1]
    }else{
      var sss = ss[3].split('--')
      if(sss.length == 1){
        parent.type = 'folder'
        parent.dataPath = '-root-'
        parent.path = '/' + ss[1] + '/data/-root-'
        parent.name = '-root-'
      }else{
        parent.type = 'folder'
        parent.dataPath = sss.slice(0, -1).join('--')
        parent.path = '/' + ss[1] + '/data/' + parent.dataPath
        parent.name = sss[sss.length-2]
      }
    }
  }
  return parent
}


export default {
  namespaced: true,
  state,
  mutations
}
