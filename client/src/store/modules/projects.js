import Vue from 'vue'
import DateForm from 'dateformat'

// initial state
export const state = {
  showNav: true,
  nodeMap: {},
  clipboard: {projectId: null, dataPaths: []},
  publicDataPath: ''
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

    var urls = initPublicUrls(project)
    if(!state.nodeMap[urls.path]){
      Vue.set(state.nodeMap, urls.path, urls)
    }

    var history = initHistory(project)
    if(!state.nodeMap[history.path]){
      Vue.set(state.nodeMap, history.path, history)
    }

    var root = initFile({
      projectId: project.id,
      type: 'folder',
      name: 'Data',
      path: '/projects/' + project.id + '/data/%2F',
      dataPath: '/',
      size: 0,
      modifiedTime: 0
    })
    if(!state.nodeMap[root.path]){
      Vue.set(state.nodeMap, root.path, root)
    }

    var children = [history.path, urls.path, users.path, root.path]
    updateNode(state, project, children)
  },

  setFile (state, resp) {
    var project = initProject(resp[0])
    var file = initFile(resp[1])
    patchChain(state.nodeMap, project, file.path)
    if(file.type == 'folder'){
      var files = resp.slice(2).map(function(f){
        return initFile(f)
      })

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

  setPublicFile (state, resp) {
    var pub = resp[0]
    state.publicDataPath = pub.dataPath
    var file = initFile(resp[1], null, pub)
    patchPublicChain(state.nodeMap, pub, file.path)
    if(file.type == 'folder'){
      var files = resp.slice(2).map(function(f){
        return initFile(f, null, pub)
      })
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
  },

  sortNodeChildren(state, nodeSort) {
    var path = nodeSort.path
    var node = state.nodeMap[path]
    var sortOption = node.options.sortOption
    var field = nodeSort.field
    var order = nodeSort.order
    if(field == sortOption.field){
      sortOption.asc = !sortOption.asc
    }else{
      sortOption.field = field
      sortOption.order = order
    }
    sortChildren(node, state.nodeMap)
  },

  setShowOption(state, val) {
    state.showOption = val
    localStorage.setItem('showOption', val)
  },

  toggleSelected(state, path) {
    var node = state.nodeMap[path]
    if(node){
      node.options.selected = !node.options.selected
    }
  },

  copySelection(state, selection) {
    state.clipboard.projectId = selection.projectId
    state.clipboard.dataPaths = selection.dataPaths
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
    path: '/projects',
    name: 'Projects',
    options: options,
    children: []
  }
}


function initProject(project, options){
  var p = Object.assign({}, project)
  p.type = 'project'
  p.path = '/projects/' + p.id
  p.createdDate = DateForm(p.createdTime*1000, 'mediumDate')
  p.udpatedDate = DateForm(p.updatedTime*1000, 'mediumDate')
  var opts = {}
  opts.open = false
  if(options){
    Object.assign(opts, options)
  }
  p.options = opts
  p.children = ['/projects/'+ p.id + '/data/%2F']
  return p
}


function initUsers(project) {
  return {
    projectId: project.id,
    type: 'users',
    path: '/projects/'+ project.id + '/users',
    name: 'Users',
    options: {open: false}
  }
}

function initPublicUrls(project) {
  return {
    projectId: project.id,
    type: 'urls',
    path: '/projects/'+ project.id + '/urls',
    name: 'Urls',
    options: {open: false}
  }
}

function initHistory(project) {
  return {
    projectId: project.id,
    type: 'history',
    path: '/projects/'+ project.id + '/history',
    name: 'History',
    options: {open: false}
  }
}


function initFile(file, options, pub){
  var f = Object.assign({}, file)
  if(pub){
    f.path = '/public/' + pub.key + '/data/' + encodeURIComponent(f.dataPath)
  }else{
    f.path = '/projects/' + f.projectId + '/data/' + encodeURIComponent(f.dataPath)
    if(f.dataPath == '/'){
      f.name = 'Data'
    }
  }
  f.modifiedAt = DateForm(f.modifiedTime*1000, 'mmm dd yyyy HH:MM')
  if(f.type == 'file'){
    var iconMap = {
      unknown: 'file-o',
      image: 'file-image-o',
      pdf: 'file-pdf-o',
      text: 'file-text-o',
      code: 'file-code-o',
      csv: 'file-o',
      zip: 'file-zip-o'
    }
    f.icon = iconMap[f.fileType]
    f.sizeLabel = f.size
    if(f.size > 1000000000){
      f.sizeLabel = Math.floor(f.size / 1000000000) + 'G'
    }else if(f.size > 1000000){
      f.sizeLabel = Math.floor(f.size / 1000000) + 'M'
    }else if(f.size > 1000){
      f.sizeLabel = Math.floor(f.size / 1000) + 'K'
    }
  }

  var opts = {}
  opts.selected = false
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
    if(opt.field == 'type'){
      if(o1.name == 'meta.txt')
        return -1
      if(o2.name == 'meta.txt')
        return 1
      if(o1.name.includes('meta'))
        return -1
      if(o2.name.includes('meta'))
        return 1
    }
    return o1.name.localeCompare(o2.name)
  }
  if(opt.order == 'number'){
    if(opt.asc){
      return v1 - v2
    }
    return v2 - v1
  }else if(opt.order == 'string'){
    v1 = v1.toLowerCase()
    v2 = v2.toLowerCase()
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
  while(parent){
    if(!nodeMap[parent.path]){
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
    }else{
      var existingParent = nodeMap[parent.path]
      if(!existingParent.children){
        existingParent.children = [parent.childPath]
      }else if(existingParent.children.indexOf(parent.childPath) == -1){
        existingParent.children.push(parent.childPath)
      }
      existingParent.options.open = true
      break
    }
  }
}


function findParent(path){
  var ss = path.split('/')
  if(ss.length < 3) return null
  var parent = {childPath: path}
  if(ss.length == 3){
    parent.type = 'projects'
    parent.path = '/projects'
  }else if(ss.length == 4){
    if(ss[3] == 'users'){
      parent.type = 'project'
      parent.path = '/projects/' + ss[2]
    }
  }else if(ss.length == 5){
    if(ss[4] == ''){
      parent.type = 'project'
      parent.path = '/projects/' + ss[2]
    }else{
      var sss = decodeURIComponent(ss[4]).split('/')
      if(sss.length == 2){
        if(sss[1] == ''){
          parent.type = 'project'
          parent.path = '/projects/' + ss[2]
        }else{
          parent.type = 'folder'
          parent.dataPath = '/'
          parent.path = '/projects/' + ss[2] + '/data/%2F'
          parent.name = 'Data'
        }
      }else if(sss.length > 2){
        parent.type = 'folder'
        parent.dataPath = sss.slice(0, -1).join('/')
        parent.path = '/projects/' + ss[2] + '/data/' + encodeURIComponent(parent.dataPath)
        parent.name = sss[sss.length-2]
      }
    }
  }
  return parent
}


function patchPublicChain(nodeMap, pub, path){
  var parent = findPublicParent(pub.dataPath, path)
  while(parent && !nodeMap[parent.path]){
    var folder = {
      type: 'folder',
      name: parent.name,
      path: parent.path,
      dataPath: parent.dataPath,
      size: 0,
      modifiedTime: 0
    }
    var folder = initFile(folder, {open: true}, pub)
    folder.children = [parent.childPath]
    Vue.set(nodeMap, folder.path, folder)
    parent = findPublicParent(pub.dataPath, parent.path)
  }
}

function findPublicParent(pdp, path){
  var ss = path.split('/')
  if(ss.length != 5) return null
  pdp = encodeURIComponent(pdp)

  if(ss[4] == pdp) return null
  if(ss[4].indexOf(pdp) != 0) return null

  var sss = decodeURIComponent(ss[4]).split('/')
  var parent = {childPath: path}
  parent.type = 'folder'
  parent.dataPath = sss.slice(0, -1).join('/')
  parent.path = '/public/' + ss[2] + '/data/' + encodeURIComponent(parent.dataPath)
  parent.name = sss[sss.length-2]
  return parent
}

export default {
  namespaced: true,
  state,
  mutations
}
