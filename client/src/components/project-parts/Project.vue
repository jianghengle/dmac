<template>
  <div>
    <address-bar></address-bar>

    <div class="columns">
      <div class="view-title column">
        <icon name="folder-open"></icon>&nbsp;
        {{project && project.name}}
      </div>
      <div class="column buttons">
        <a class="button" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewFolderModal">
          <icon name="plus"></icon>&nbsp;
          Folder
        </a>
        <a class="button" v-if="projectRole && projectRole!='Viewer'" @click="openFileUploadModal">
          <icon name="cloud-upload"></icon>&nbsp;
          File
        </a>
        <a class="button is-info" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewUsers">
          <icon name="user"></icon>&nbsp;
          Users
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
      :data-path="''"
      @close-new-folder-modal="closeNewFolderModal">
    </new-folder-modal>

    <file-upload-modal
      :opened="fileUploadModal.opened"
      :project-id="projectId"
      :data-path="'-root-'"
      @close-file-upload-modal="closeFileUploadModal">
    </file-upload-modal>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FileContent from './FileContent'
import NewFolderModal from '../modals/NewFolderModal'
import FileUploadModal from '../modals/FileUploadModal'

export default {
  name: 'project',
  components: {
    AddressBar,
    FileContent,
    NewFolderModal,
    FileUploadModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      newFolderModal: {
        opened: false
      },
      fileUploadModal: {
        opened: false
      },
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
    fileContent () {
      if(this.project && this.project.children){
        var vm = this
        return this.project.children.slice(1).map(function(c){
          return vm.nodeMap[c]
        })
      }
      return []
    },
    projectRole () {
      return this.project && this.project.projectRole
    }
  },
  watch: {
    projectId: function (val) {
      this.requestProject()  
    },
  },
  methods: {
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project!'
        vm.waiting = false
      })
    },
    viewUsers () {
      this.$router.push('/' + this.projectId + '/-users-')
    },
    openNewFolderModal(){
      this.newFolderModal.opened = true
    },
    closeNewFolderModal(result){
      this.newFolderModal.opened = false
      if(result){
        this.requestProject()
      }
    },
    onFileChanged(){
      this.requestProject()
    },
    openFileUploadModal(){
      this.fileUploadModal.opened = true
    },
    closeFileUploadModal(result){
      this.fileUploadModal.opened = false
      if(result){
        this.requestProject()
      }
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestProject()
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
