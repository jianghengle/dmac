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
          <li :class="{'is-active': activeTab=='table'}">
            <a class="tab-button text-tab-btn" :class="{'active-btn': activeTab=='table'}" @click="activeTab = 'table'">Meta</a>
          </li>
          <li :class="{'is-active': activeTab=='text'}">
            <a class="tab-button text-tab-btn" :class="{'active-btn': activeTab=='text'}" @click="activeTab = 'text'">Raw</a>
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

    <div v-show="activeTab=='table'" class="meta-table">
      <table class="table is-narrow is-hoverable is-fullwidth">
        <thead>
          <tr @dblclick="projectRole && (projectRole=='Owner'||projectRole=='Admin')&&openEditHeaderModal()">
            <th>#</th>
            <th v-for="(h, i) in metaHeader">
              {{h.name}}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in metaRows" @dblclick="projectRole && (projectRole=='Owner'||projectRole=='Admin')&&openEditRowModal(i)">
            <td>{{i+1}}</td>
            <td v-for="cell in row">
              <div v-if="Array.isArray(cell)">
                <div v-for="f in cell">
                  <a class="main-link" v-if="fileMap[f]" @click="openDataPath(fileMap[f])">{{f}}</a>
                  <span v-if="!fileMap[f]">{{f}}</span>
                </div>
              </div>
              <div v-else>
                {{cell}}
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <edit-meta-header-modal
      :opened="editHeaderModal.opened"
      :file="file"
      :metaHeader="metaHeader"
      :metaRows="metaRows"
      @close-edit-meta-header-modal="closeEditModal">
    </edit-meta-header-modal>
    <edit-meta-row-modal
      :opened="editRowModal.opened"
      :rowIndex="editRowModal.rowIndex"
      :file="file"
      :metaHeader="metaHeader"
      :metaRows="metaRows"
      @close-edit-meta-row-modal="closeEditModal">
    </edit-meta-row-modal>
  </div>
</template>

<script>
import EditMetaHeaderModal from '../modals/EditMetaHeaderModal'
import EditMetaRowModal from '../modals/EditMetaRowModal'

export default {
  name: 'meta-file',
  components: {
    EditMetaHeaderModal,
    EditMetaRowModal
  },
  props: ['file'],
  data () {
    return {
      textInput: '',
      waiting: false,
      error: '',
      activeTab: 'table',
      fileMap: {},
      editHeaderModal: {
        opened: false,
      },
      editRowModal: {
        opened: false,
        rowIndex: null
      }
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    publicKey () {
      return this.$route.params.publicKey
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
    },
    metaHeader () {
      var re=/\r\n|\n\r|\n|\r/g
      var lines = this.textInput.replace(re,'\n').split('\n')
      if(!lines.length) return []
      return lines[0].split('\t').map(function(s){
        var name = ''
        var option = ''
        var optionsStart = s.indexOf('{')
        var optionsEnd = s.indexOf('}')
        if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
          name = s.trim()
        }else{
          name = s.slice(0, optionsStart).trim()
          option = s.slice(optionsStart+1, optionsEnd)
        }
        return {name: name, option: option}
      })
    },
    metaRows () {
      var re=/\r\n|\n\r|\n|\r/g
      var lines = this.textInput.replace(re,'\n').split('\n')
      if(!lines.length) return []
      var rows = []
      var vm = this
      lines.slice(1).forEach(function(line){
        if(!line.trim()) return
        var row = line.trim().split('\t').map(function(c){
          var files = []
          var found = false
          var ss = c.split(',')
          for(var i=0;i<ss.length;i++){
            var s = ss[i].trim()
            files.push(s)
            if(vm.fileMap[s]){
              found = true
            }
          }
          if(found){
            return files
          }
          return c.trim()
        })
        rows.push(row)
      })
      return rows
    },
  },
  watch: {
    path: function (val) {
      this.updateText()
      this.activeTab = 'table'
    },
    file: function (val) {
      this.updateText()
    },
  },
  methods: {
    updateText() {
      this.textInput = this.file.text
      var fdp = decodeURIComponent(this.file.dataPath)
      var ss = fdp.split('/')
      ss.pop()
      var dp = ss.join('/')
      if(!dp) dp = '/'
      this.requestFolderFiles(dp)
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
    openSearch(){
      var searchPath = this.$route.path.replace('/data/', '/search/')
      this.$router.push(searchPath)
    },
    openEditFileModal(){
      this.$emit('open-edit-file-modal')
    },
    requestFolderFiles (dp) {
      var dataPath = encodeURIComponent(dp)
      dataPath = encodeURIComponent(dataPath)
      if(!this.publicKey){
        this.$http.get(xHTTPx + '/get_file/' + this.projectId + "/" + dataPath).then(response => {
          var resp = response.body
          this.getFolderFiles(resp)
        })
      }else{
        this.$http.get(xHTTPx + '/get_public_file/' + this.publicKey + "/" + dataPath).then(response => {
          var resp = response.body

        })
      }
    },
    getFolderFiles (files) {
      var fileMap = {}
      for(var i=2;i<files.length;i++){
        var file = files[i]
        if(file.type == 'file'){
          fileMap[file.name] = file.dataPath
        }
      }
      this.fileMap = fileMap
    },
    openDataPath (dp) {
      var prefix = this.projectId ? ('/projects/' + this.projectId) : ('/public/' + this.publicKey)
      var path = prefix + '/data/' + encodeURIComponent(dp)
      this.$router.push(path)
    },
    openEditHeaderModal () {
      this.editHeaderModal.opened = true
    },
    closeEditModal(result){
      this.editHeaderModal.opened = false
      this.editRowModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    openEditRowModal (i) {
      this.editRowModal.rowIndex = i
      this.editRowModal.opened = true
    },
  },
  mounted () {
    this.updateText()
  }
}
</script>

<style lang="scss" scoped>

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

.meta-table {
  max-width: 100%;
  margin-top: 10px;
}

.file-tag {
  position: relative;
  top: -3px;
}

</style>
