<template>
  <div>
    <address-bar></address-bar>
    
    <div class="columns">
      <div class="view-title column">
        <icon name="folder-open"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        <a class="button" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewFolderModal">
          <icon name="plus"></icon>&nbsp;
          Folder
        </a>
        <a class="button" v-if="projectRole && projectRole!='Viewer'">
          <icon name="cloud-upload"></icon>&nbsp;
          File
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <file-content :content="fileContent" :project="project" @file-changed="onFileChanged"></file-content>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
    <div class="empty-label" v-if="!waiting && (!fileContent || !fileContent.length)">(Empty)</div>

    <new-folder-modal
      :opened="newFolderModal.opened"
      :role="projectRole"
      :files="fileContent"
      :project-id="projectId"
      :data-path="file && file.dataPath"
      @close-new-folder-modal="closeNewFolderModal">
    </new-folder-modal>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FileContent from './FileContent'
import NewFolderModal from '../modals/NewFolderModal'

export default {
  name: 'file',
  components: {
  	AddressBar,
    FileContent,
    NewFolderModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      newFolderModal: {
        opened: false
      }
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
      return this.nodeMap['/' + this.projectId + '/-root-']
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    path () {
      return "/" + this.projectId + "/" + this.$route.params.dataPath
    },
    file () {
      return this.nodeMap[this.path]
    },
    fileContent () {
      if(this.file){
        var vm = this
        return this.file.children.map(function(c){
          return vm.nodeMap[c]
        })
      }
      return []
    }
  },
  watch: {
    path: function (val) {
      this.requestFile()
    },
  },
  methods: {
    requestFile () {
      var vm = this
      var dataPath = this.$route.params.dataPath
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_file/' + vm.projectId + "/" + dataPath).then(response => {
        var resp = response.body
        this.$store.commit('projects/setFile', resp)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get file!'
        vm.waiting = false
      })
    },
    openNewFolderModal(){
      this.newFolderModal.opened = true
    },
    closeNewFolderModal(result){
      this.newFolderModal.opened = false
      if(result){
        this.requestFile()
      }
    },
    onFileChanged(){
      this.requestFile()
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestFile()
    })
  }
}
</script>

<style lang="scss" scoped>

.empty-label {
  text-align: center;
}

.buttons {
  text-align: right;
}
</style>
