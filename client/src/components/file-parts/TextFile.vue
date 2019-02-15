<template>
  <div>
    <div class="view-title">
      <span class="main-link" @click="$router.go(-1)">
        <icon name="arrow-left"></icon>
      </span>&nbsp;
      {{file && file.name}}
      <span class="tag is-success file-tag" v-if="file && file.access==0">Normal</span>
      <span class="tag is-warning file-tag" v-if="file && file.access==1">Readonly</span>
      <span class="tag is-danger file-tag" v-if="file && file.access==2">Hidden</span>
      <a v-if="projectRole && projectRole!='Viewer' && ( projectRole=='Editor' ? (project.status=='Active' && file.access==0) : true )"
        @click="openEditFileModal"
        class="main-link">
        <icon name="edit"></icon>
      </a>
      <span class="main-link search-button" @click="openSearch">
        <icon name="search"></icon>
      </span>

      <div class="is-pulled-right default-btn">
        <div class="tabs is-toggle text-tabs">
        <ul>
          <li :class="{'is-active': activeTab=='text'}">
            <a class="tab-button text-tab-btn" :class="{'active-btn': activeTab=='text'}" @click="activeTab = 'text'">Text</a>
          </li>
          <li :class="{'is-active': activeTab=='table'}">
            <a class="tab-button text-tab-btn" :class="{'active-btn': activeTab=='table'}" @click="activeTab = 'table'">Table</a>
          </li>
        </ul>
      </div>
        <a class="button" :disabled="!textChanged" :class="{'is-danger': textChanged}" v-if="canEdit" @click="saveTextFile">
          <icon name="save"></icon>&nbsp;
          Save
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="field" v-show="activeTab=='text'">
      <p class="control">
        <textarea class="textarea"
          :readonly="!canEdit"
          :class="{'is-danger': textChanged}"
          :style="{height: textAreaHeight}"
          :spellcheck="file.fileType=='text'"
          v-model="textInput"
          @keydown="textAreaKeyDown">
        </textarea>
      </p>
    </div>

    <div v-show="activeTab=='table'" class="text-table">
      <table class="table is-narrow">
        <thead>
          <tr>
            <th>#</th>
            <th v-for="(h, i) in tableHeader">
              <span class="text-table-header">{{h}}</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in tableData">
            <td>{{i+1}}</td>
            <td v-for="cell in row">
              <span class="text-table-cell">{{cell}}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>

export default {
  name: 'text-file',
  props: ['file'],
  data () {
    return {
      textInput: '',
      waiting: false,
      error: '',
      activeTab: 'text',
      tableHeader: [],
      tableData: []
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    project () {
      return this.nodeMap['/projects/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    path () {
      return this.$route.path
    },
    textAreaHeight () {
      var re=/\r\n|\n\r|\n|\r/g
      var lines = this.textInput.replace(re,'\n').split('\n').length
      return 25*lines + 'px'
    },
    textChanged () {
      return this.textInput != this.file.text
    },
    canEdit () {
      if(!this.file) return false
      if(!this.projectRole) return false
      if(this.projectRole == 'Viewer') return false
      if(this.projectRole == 'Owner' || this.projectRole == 'Admin') return true
      if(this.project.status != 'Active') return false
      return this.file.access == 0
    }
  },
  watch: {
    path: function (val) {
      this.updateText()
      this.activeTab = 'text'
    },
    file: function (val) {
      this.updateText()
    },
    activeTab: function (val) {
      if(val == 'table') {
        this.buildTable()
      }
    }
  },
  methods: {
    updateText() {
      this.textInput = this.file.text
    },
    saveTextFile(){
      this.waiting = true
      var message = {projectId: this.projectId, dataPath: this.file.dataPath, text: this.textInput}
      this.$http.post(xHTTPx + '/save_text_file', message).then(response => {
        this.waiting = false
        this.$emit('content-changed', true)
      }, response => {
        this.error = 'Failed to save file!'
        this.waiting = false
      })
    },
    textAreaKeyDown(e){
      var keyCode = e.keyCode || e.which

      if (keyCode == 9) {
        e.preventDefault()
        var textarea = e.srcElement

        var start = textarea.selectionStart
        var end = textarea.selectionEnd

        // set textarea value to: text before caret + tab + text after caret
        var text = textarea.value
        textarea.value = text.substring(0, start) + "\t" + text.substring(end)
        // put caret at right position again
        textarea.selectionStart = start + 1
        textarea.selectionEnd = start + 1
      }
    },
    buildTable(){
      this.tableHeader = [],
      this.tableData = []
      var re=/\r\n|\n\r|\n|\r/g
      var lines = this.textInput.replace(re,'\n').split('\n')
      if(!lines.length) return
      this.tableHeader = lines[0].split('\t').map(function(s){
        var optionsStart = s.indexOf('{')
        var optionsEnd = s.indexOf('}')
        if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
          return s.trim()
        }
        return s.slice(0, optionsStart).trim()
      })
      var width = this.tableHeader.length
      var tableData = []
      for(var i=1;i<lines.length;i++){
        var row = lines[i].split('\t')
        tableData.push(row)
        width = Math.max(row.length, width)
      }
      for(var i=0;i<tableData.length;i++){
        var row = tableData[i]
        while(row.length < width){
          row.push('')
        }
      }
      this.tableData = tableData
    },
    openSearch(){
      var searchPath = this.$route.path.replace('/data/', '/search/')
      this.$router.push(searchPath)
    },
    openEditFileModal(){
      this.$emit('open-edit-file-modal')
    },
  },
  mounted () {
    this.updateText()
  }
}
</script>

<style lang="scss" scoped>

.buttons {
  text-align: right;
}

.text-tabs {
  display: inline-block;
  margin-bottom: 0px;
  padding-top: 0px;
  padding-bottom: 0px;
}

.text-tab-btn {
  padding-top: 5px;
  padding-bottom: 5px;
  padding-left: 15px;
  padding-right: 15px;
}

.action-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}

.text-area-container {
  margin-top: 5px;
  height: 100%;
}

.text-table {
  max-width: 100%;
  overflow-x: auto;
}

.file-tag {
  position: relative;
  top: -3px;
}

</style>
