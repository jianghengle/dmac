import DateForm from 'dateformat'

// initial state
export const state = {
  source: null,
  type: null,
  pattern: null,
  result: null,
  sortOption: null
}

// mutations
export const mutations = {
  startSearch (state, obj) {
    state.source = obj.source
    state.type = obj.type
    state.pattern = obj.pattern
    state.result = null
  },
  pushResult (state, result) {
    if(state.result == null)
      state.result = []

    if(state.type == 'Content'){
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
    }else{
      result.forEach(function(f){
        if(state.source.publicKey){
          f.path = '/public/' + state.source.publicKey + '/data/' + encodeURIComponent(f.dataPath)
        }else{
          f.path = '/projects/' + f.projectId + '/data/' + encodeURIComponent(f.dataPath)
        }
        f.modifiedAt = DateForm(f.modifiedTime*1000, 'mmm dd yy')
        f.sizeLabel = f.size
        if(f.size > 1000000000){
          f.sizeLabel = Math.floor(f.size / 1000000000) + 'G'
        }else if(f.size > 1000000){
          f.sizeLabel = Math.floor(f.size / 1000000) + 'M'
        }else if(f.size > 1000){
          f.sizeLabel = Math.floor(f.size / 1000) + 'K'
        }
        if(state.source.projectMap){
          f.project = state.source.projectMap[f.projectId].name
        }
        state.result.push(f)
      })
    }
  },

  sortResult(state, sortOption) {
    state.sortOption = sortOption
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
