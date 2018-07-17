<template>
  <div class="search-page">
    <address-bar></address-bar>
    <project-tab></project-tab>

    <div>
      <div>
        <a class="button back-btn" @click="$router.go(-1)">
          <icon name="arrow-left"></icon>&nbsp;
          Back
        </a>
      </div>

      <div class="field has-addons">
        <div class="control is-expanded has-icons-left">
          <input class="input" type="text" :placeholder="tip" v-model="searchInput" @keyup.enter="search" v-focus>
          <span class="icon is-small is-left search-btn">
            <icon name="search"></icon>
          </span>
        </div>
        <div class="control">
          <a class="button is-primary" @click="search" :disabled="!canSearch">
            Search
          </a>
        </div>
      </div>
    </div>

    <div class="search-result" v-if="searchResult">
      <div v-if="searchResultType == 'files'">
        <div class="search-info">Searching <strong><em>{{searchPattern}}</em></strong> in the folder <strong><em>{{searchDataPath}}</em></strong> returns {{searchResult.length}} files:</div>
        <table class="table is-narrow is-fullwidth is-hoverable">
          <thead>
            <tr>
              <th class="number-cell is-clickable">{{searchResult.length}}</th>
              <th class="text-cell is-clickable" @click="sortSearchResult('type', typeOrder)">Type
                <span v-if="sortOption.field=='type'">
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
              <td class="text-cell">
                <icon class="type-icon" v-if="f.type=='folder'" name="folder-o"></icon>
                <span v-if="f.type=='file'">
                  <icon class="type-icon" :name="f.icon"></icon>
                </span>
              </td>
              <td>{{f.name}}</td>
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
        <div class="search-info">Searching <strong><em>{{searchPattern}}</em></strong> in the file <strong><em>{{folderFile.name}}</em></strong> returns {{searchResult.length}} lines:</div>
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
      searchInput: '',
      sortOption: {
        field: 'type',
        order: ['folder', 'file'],
        asc: true
      },
      typeOrder: ['folder', 'file']
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
    path () {
      return this.$route.path
    },
    folderFile () {
      return this.nodeMap[this.path.replace('/search/', '/data/')]
    },
    searchDataPath () {
      return this.$store.state.search.dataPath
    },
    searchPattern () {
      return this.$store.state.search.pattern
    },
    searchResult () {
      return this.$store.state.search.result
    },
    searchResultType () {
      return this.$store.state.search.resultType
    },
    canSearch () {
      return this.searchInput.trim()
    },
    tip () {
      if(!this.folderFile)
        return ''
      if(this.folderFile.type == 'folder') {
        return 'Search files: e.g. *.pdf matches all pdf files'
      }
      return 'Search a string in the file'
    }
  },
  watch: {
    searchInput: function (val) {
      this.$store.commit('search/setInput', val)
    },
  },
  methods: {
    requestFile () {
      var dataPath = encodeURIComponent(this.dataPath)
      dataPath = encodeURIComponent(dataPath)
      this.waiting = true
      if(!this.publicKey){
        this.$http.get(xHTTPx + '/get_file/' + this.projectId + '/' + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setFile', resp)
          this.waiting = false

        }, response => {
          this.error = 'Failed to get file!'
          this.waiting = false
        })
      }else{
        this.$http.get(xHTTPx + '/get_public_file/' + this.publicKey + '/' + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setPublicFile', resp)
          this.waiting = false
        }, response => {
          this.error = 'Failed to get file!'
          this.waiting = false
        })
      }
    },
    search () {
      if(!this.canSearch)
        return
      this.searchInput = this.searchInput.trim()
      this.waiting = true
      this.$store.commit('search/setPattern', this.searchInput)
      this.$store.commit('search/setDataPath', this.dataPath)
      this.$store.commit('search/setResult', null)
      if(this.folderFile.type == 'folder'){
        this.$store.commit('search/setResultType', 'files')
        var message = {projectId: this.projectId, dataPath: this.dataPath, pattern: this.searchInput}
        var resource = '/search_project_files'
        if(this.publicKey){
          message = {publicKey: this.publicKey, dataPath: this.dataPath, pattern: this.searchInput}
          resource = '/search_public_files'
        }
        this.$http.post(xHTTPx + resource, message).then(response => {
          this.$store.commit('search/setResult', response.body)
          this.$store.commit('search/sortResult', this.sortOption)
          this.error = ''
          this.waiting = false
        }, response => {
          this.error = 'Search failed!'
          this.waiting = false
        })
      }else{
        this.$store.commit('search/setResultType', 'lines')
        var message = {projectId: this.projectId, dataPath: this.dataPath, pattern: this.searchInput}
        var resource = '/search_in_project_file'
        if(this.publicKey){
          message = {publicKey: this.publicKey, dataPath: this.dataPath, pattern: this.searchInput}
          resource = '/search_in_public_file'
        }
        this.$http.post(xHTTPx + resource, message).then(response => {
          this.$store.commit('search/setResult', response.body)
          this.error = ''
          this.waiting = false
        }, response => {
          this.error = 'Search failed!'
          this.waiting = false
        })
      }
      
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
    this.searchInput = this.$store.state.search.input
    var sourceId = this.publicKey ? this.publicKey : this.projectId
    if(sourceId != this.$store.state.search.sourceId){
      if(this.publicKey){
        this.$store.commit('search/setSourceId', sourceId)
        this.$store.commit('search/setSourceType', 'public')
      }else{
        this.$store.commit('search/setSourceId', sourceId)
        this.$store.commit('search/setSourceType', 'project')
      }
    }
    this.$nextTick(function(){
      this.requestFile()
    })
  }
}
</script>

<style lang="scss" scoped>

.search-page {
  padding: 10px;
}

.back-btn {
  margin-bottom: 10px;
}

.search-btn {
  cursor: pointer;
}

.search-result {
  margin-top: 5px;
}

.search-info {
  margin-top: 30px;
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
