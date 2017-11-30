import DateForm from 'dateformat'

// initial state
export const state = {
  sourceId: null,
  sourceType: null,
  input: '',
  pattern: '',
  dataPath: null,
  result: null,
  resultType: 'files'
}

// mutations
export const mutations = {
  setSourceId (state, id) {
    state.sourceId = id
    state.pattern = ''
    state.dataPath = null
    state.result = null
  },

  setSourceType (state, type) {
    state.sourceType = type
  },

  setInput (state, input) {
    state.input = input
  },

  setPattern (state, pattern) {
    state.pattern = pattern
  },

  setDataPath (state, dataPath) {
    state.dataPath = dataPath
  },

  setResult (state, result) {
    if(!result){
      state.result = result
      return
    }

    if(state.resultType == 'files'){
      state.result = result.map(function(f){
        f.path = '/projects/' + f.projectId + '/data/' + encodeURIComponent(f.dataPath)
        if(state.sourceType == 'public'){
          f.path = '/public/' + state.sourceId + '/data/' + encodeURIComponent(f.dataPath)
        }
        f.name = f.dataPath.slice(state.dataPath.length)
        if(f.name.startsWith('/')){
          f.name = f.name.slice(1)
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
        return f
      })
    }else{
      state.result = result.map(function(l){
        var splitIndex = l.indexOf(':')
        var num = ''
        var line = l
        if(splitIndex > -1){
          num = l.slice(0, splitIndex)
          line = l.slice(splitIndex + 1)
        }
        return [num, line]
      })
    }
  },

  setResultType (state, type) {
    state.resultType = type
  },

  sortResult(state, sortOption) {    
    if(!state.result)
      return
    state.result.sort(function(a, b){
      return compareNodes(a, b, sortOption)
    })
  },
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

export default {
  namespaced: true,
  state,
  mutations
}
