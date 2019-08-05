<template>
  <div class="search-page">
    <address-bar></address-bar>
    <project-tab v-if="dataPath"></project-tab>

    <div v-if="!dataPath" >
      <div class="projects-title">
        <icon name="database"></icon>
         Search in Projects
      </div>
      <div class="project-selection">
        <div class="field">
          <div class="control" v-for="p in searchProjects">
            <label class="checkbox">
              <input type="checkbox" v-model="p.selected">
              <span>{{p.name}}</span>
            </label>
          </div>
        </div>
      </div>
    </div>

    <div>
      <div class="field is-grouped">
        <div class="control" v-if="dataPath">
          <a class="button" @click="$router.go(-1)">
            <icon name="arrow-left"></icon>&nbsp;
            Back
          </a>
        </div>
        <div class="control is-expanded">
          <div class="field has-addons">
            <div class="control has-icons-left">
              <span class="select">
                <select v-model="searchSelect">
                  <option v-for="opt in options">{{opt}}</option>
                </select>
              </span>
              <span class="icon">
                <icon name="search"></icon>
              </span>
            </div>
            <div class="control is-expanded">
              <input class="input" type="text" :placeholder="tip" v-model="searchInput" @keyup.enter="search">
            </div>
            <div class="control">
              <a class="button is-primary" @click="search" :disabled="!canSearch">
                Search
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="search-result" v-if="searchResult">
      <div v-if="searchType != 'Content'">
        <div class="search-info">Searching <strong><em>{{searchPattern}}</em></strong>
        <span v-if="searchSource.project">in project <strong>{{searchSource.project.name}}</strong></span>
        <span v-if="searchSource.projectMap">in projects</span>
        <span v-if="searchSource.folderFile">in <strong><em>{{searchSource.folderFile.dataPath}}</em></strong></span>
        returns {{searchResult.length}} files:</div>
        <table class="table is-narrow is-fullwidth is-hoverable">
          <thead>
            <tr>
              <th class="number-cell is-clickable">{{searchResult.length}}</th>
              <th v-if="!dataPath" class="is-clickable" @click="sortSearchResult('project', 'string')">Project
                <span v-if="sortOption.field=='project'">
                  <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                  <icon name="sort-desc" v-if="!sortOption.asc"></icon>
                </span>
              </th>
              <th class="is-clickable" @click="sortSearchResult('name', 'string')">Name
                <span v-if="sortOption.field=='name'">
                  <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                  <icon name="sort-desc" v-if="!sortOption.asc"></icon>
                </span>
              </th>
              <th class="is-clickable" @click="sortSearchResult('owner', 'string')">Owner
                <span v-if="sortOption.field=='owner'">
                  <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                  <icon name="sort-desc" v-if="!sortOption.asc"></icon>
                </span>
              </th>
              <th class="number-cell is-clickable" @click="sortSearchResult('size', 'number')">Size
                <span v-if="sortOption.field=='size'">
                  <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                  <icon name="sort-desc" v-if="!sortOption.asc"></icon>
                </span>
              </th>
              <th class="text-cell is-clickable" @click="sortSearchResult('modifiedTime', 'number')">Modified At
                <span v-if="sortOption.field=='modifiedTime'">
                  <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                  <icon name="sort-desc" v-if="!sortOption.asc"></icon>
                </span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(f, i) in searchResult" class="entry" :class="{'folder': f.type=='folder'}" @click="viewFile(f)">
              <td class="number-cell" @click.stop="toggleSelected(f)">{{i+1}}</td>
              <td v-if="!dataPath">{{f.project}}</td>
              <td>{{f.name}}</td>
              <td>{{f.owner}}</td>
              <td class="number-cell">
                <span class="tooltip">
                  {{f.sizeLabel}}
                  <span class="tooltiptext">{{f.size}}</span>
                </span>
              </td>
              <td class="text-cell">{{f.modifiedAt}}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else>
        <div class="search-info">Searching <strong><em>{{searchPattern}}</em></strong> in the file <strong><em>{{searchSource.folderFile.name}}</em></strong> returns {{searchResult.length}} lines:</div>
        <table class="table is-fullwidth is-hoverable">
        <thead>
          <tr>
            <th>line #</th>
            <th>Content</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="l in searchResult">
            <td>{{l[0]}}</td>
            <td>{{l[1]}}</td>
          </tr>
        </tbody>
      </table>
      </div>
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

  </div>
</template>

<script>
import AddressBar from './AddressBar'
import ProjectTab from './ProjectTab'

export default {
  name: 'search-page',
  components: {
    AddressBar,
    ProjectTab
  },
  data () {
    return {
      error: '',
      waiting: false,
      searchSelect: 'Filename',
      searchInput: '',
      sortOption: {
        field: 'name',
        asc: true
      },
      searchProjects: []
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    dataPath () {
      return this.$route.params.dataPath
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    projects () {
      var node = this.nodeMap['/projects']
      if(!node) return []
      var vm = this
      return node.children.map(function(c){
        return vm.nodeMap[c]
      })
    },
    project () {
      return this.nodeMap['/projects/' + this.projectId]
    },
    path () {
      return this.$route.path
    },
    folderFile () {
      return this.nodeMap[this.path.replace('/search/', '/data/')]
    },
    searchSource () {
      return this.$store.state.search.source
    },
    searchType () {
      return this.$store.state.search.type
    },
    searchPattern () {
      return this.$store.state.search.pattern
    },
    searchResult () {
      return this.$store.state.search.result
    },
    canSearch () {
      if(!this.searchInput.trim())
        return false
      if(!this.dataPath){
        return this.searchProjects.filter(function(p){
          return p.selected
        }).length
      }
      return true
    },
    options () {
      if(!this.folderFile)
        return ['Metadata', 'Filename']
      if(this.folderFile.type == 'folder')
        return ['Metadata', 'Filename']
      return ['Content']
    },
    tip () {
      if(this.searchSelect == 'Filename')
        return 'Search by filename: e.g. *.pdf matches all pdf files'
      if(this.searchSelect == 'Metadata')
        return 'Search in metadata files for a string'
      if(this.searchSelect == 'Content')
        return 'Search a string in the file'
      return ''
    }
  },
  methods: {
    requestSource () {
      if(this.dataPath){
        var dataPath = encodeURIComponent(this.dataPath)
        dataPath = encodeURIComponent(dataPath)
        this.waiting = true
        if(!this.publicKey){
          this.$http.get(xHTTPx + '/get_file/' + this.projectId + '/' + dataPath).then(response => {
            var resp = response.body
            this.$store.commit('projects/setFile', resp)
            this.waiting = false
            this.$nextTick(function(){
              this.initSearch()
            })
          }, response => {
            this.error = 'Failed to get file!'
            this.waiting = false
          })
        }else{
          this.$http.get(xHTTPx + '/get_public_file/' + this.publicKey + '/' + dataPath).then(response => {
            var resp = response.body
            this.$store.commit('projects/setPublicFile', resp)
            this.waiting = false
            this.$nextTick(function(){
              this.initSearch()
            })
          }, response => {
            this.error = 'Failed to get file!'
            this.waiting = false
          })
        }
      }else{
        this.waiting = true
        this.$http.get(xHTTPx + '/get_projects').then(response => {
          var resp = response.body
          this.$store.commit('projects/setProjects', resp.slice(1))
          this.waiting = false
          this.$nextTick(function(){
            this.initSearch()
          })
        }, response => {
          this.waiting = false
          this.error = 'Failed to get projects!'
        })
      }
    },
    initSearch () {
      if(this.$store.state.search.sortOption)
        this.sortOption = this.$store.state.search.sortOption
      if(this.folderFile && this.folderFile.type == 'file'){
        this.searchSelect = 'Content'
      }else if(this.seachType && this.searchType != 'Content') {
        this.searchSelect = this.searchType
      }else{
        this.searchSelect = 'Metadata'
      }
      this.searchProjects = this.projects.map(function(p){
        return {
          id: p.id,
          name: p.name,
          selected: true
        }
      })
    },
    search () {
      if(!this.canSearch)
        return
      this.searchInput = this.searchInput.trim()
      this.waiting = true
      var searchSource = {}
      if(this.dataPath){
        searchSource.folderFile = this.folderFile
        if(this.publicKey){
          searchSource.publicKey = this.publicKey
        }else{
          searchSource.project = this.project
        }
        this.sortOption = {field: 'name', asc: true}
      }else{
        var projectMap = {}
        this.searchProjects.forEach(function(p){
          if(p.selected){
            projectMap[p.id] = p
          }
        })
        searchSource.projectMap = projectMap
        this.sortOption = {field: 'project', asc: true}
      }
      var searchObj = {
        source: searchSource,
        type: this.searchSelect,
        pattern: this.searchInput,
      }
      this.$store.commit('search/startSearch', searchObj)

      var vm = this
      var promises = vm.makeRequests().map(function(request){
        return vm.$http.post(xHTTPx + request.resource, request.message).then(response => {
          vm.$store.commit('search/pushResult', response.body)
          if(vm.searchType != 'Content'){
            vm.$store.commit('search/sortResult', vm.sortOption)
          }
        }, response => {
          this.error = 'Some search failed!'
        })
      })
      Promise.all(promises).then((response) => {
        vm.waiting = false
      }, (response) => {
        vm.waiting = false
        vm.error = 'Search failed...'
      })
    },
    makeRequests () {
      var requests = []
      if(this.searchSelect == 'Content'){
        if(this.publicKey){
          var resource = '/search_in_public_file'
          var message = {publicKey: this.publicKey, dataPath: this.dataPath, pattern: this.searchInput}
        }else{
          var resource = '/search_in_project_file'
          var message = {projectId: this.projectId, dataPath: this.dataPath, pattern: this.searchInput}
        }
        requests.push({resource: resource, message: message})
      }else if(this.dataPath){
        if(this.searchType == 'Filename'){
          if(this.publicKey){
            var resource = '/search_public_files'
            var message = {publicKey: this.publicKey, dataPath: this.dataPath, pattern: this.searchInput}
          }else{
            var resource = '/search_project_files'
            var message = {projectId: this.projectId, dataPath: this.dataPath, pattern: this.searchInput}
          }
        }else{
          if(this.publicKey){
            var resource = '/search_public_files_by_meta'
            var message = {publicKey: this.publicKey, dataPath: this.dataPath, pattern: this.searchInput}
          }else{
            var resource = '/search_project_files_by_meta'
            var message = {projectId: this.projectId, dataPath: this.dataPath, pattern: this.searchInput}
          }
        }
        requests.push({resource: resource, message: message})
      }else{
        for(var i=0;i<this.searchProjects.length;i++){
          var project = this.searchProjects[i]
          if(project.selected){
            var resource = this.searchSelect == 'Filename' ? '/search_project_files' : '/search_project_files_by_meta'
            var message = {projectId: project.id, dataPath: '/', pattern: this.searchInput}
            requests.push({resource: resource, message: message})
          }
        }
      }
      return requests
    },
    sortSearchResult(field, order){
      if(this.sortOption.field == field && this.sortOption.order == order){
        this.sortOption.asc = !this.sortOption.asc
      }else{
        this.sortOption.field = field
        this.sortOption.order = order
      }
      this.$store.commit('search/sortResult', this.sortOption)
    },
    viewFile (f) {
      this.$router.push(f.path)
    }
  },
  mounted () {
    this.$nextTick(function(){
      if(this.dataPath){
        if(this.folderFile){
          this.initSearch()
        }else{
          this.requestSource()
        }
      }else{
        if(this.projects.length){
          this.initSearch()
        }else{
          this.requestSource()
        }
      }
    })
  }
}
</script>

<style lang="scss" scoped>

.search-page {
  padding: 10px;
}

.projects-title {
  font-size: 24px;
  font-weight: bold;
  color: #2e1052;
}

.project-selection {
  margin-bottom: 10px;
}

.search-result {
  margin-top: 5px;
}

.search-info {
  margin-top: 15px;
  margin-bottom: 10px;
  color: #2e1052;
}

.entry {
  cursor: pointer;
}

.folder{
  background-color: #f2f2f2;
}

.folder:hover{
  background-color: #EEEEEE;
}

.text-cell {
  text-align: center;
}

.number-cell {
  text-align: right;
}

.action-icon {
  position: relative;
  top: 3px;
}

.type-icon {
  position: relative;
  top: 3px;
}

.asc-icon {
  position: relative;
  top: 5px;
}

.is-clickable {
  cursor: pointer;
}

.tooltip {
  position: relative;
  display: inline-block;
}
.tooltip .tooltiptext {
  visibility: hidden;
  background-color: #363636;
  color: white;
  font-size: 14px;
  text-align: center;
  border-radius: 5px;
  padding: 5px 5px;
  /* Position the tooltip */
  position: absolute;
  left: 0px;
  z-index: 10;
}
.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 0.9;
}

</style>
