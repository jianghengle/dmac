<template>
  <div class="folder-file-page">
    <address-bar></address-bar>

    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    
    <folder v-if="folderFile && folderFile.type == 'folder'"
      :folder="folderFile"
      :waiting="waiting"
      @content-changed="contentChanged"
      @open-edit-folder-modal="openEditFolderModal">
    </folder>

    <div v-if="folderFile && folderFile.type == 'file'">
      <normal-file
        v-if="folderFile.fileType == 'unknown'"
        :file="folderFile"
        @open-edit-file-modal="openEditFileModal">
      </normal-file>
      <image-file
        v-if="folderFile.fileType == 'image'"
        :file="folderFile"
        @open-edit-file-modal="openEditFileModal">
      </image-file>
      <pdf-file
        v-if="folderFile.fileType == 'pdf'"
        :file="folderFile"
        @open-edit-file-modal="openEditFileModal">
      </pdf-file>
      <text-file
        v-if="folderFile.fileType == 'text' || folderFile.fileType == 'code'"
        :file="folderFile"
        @content-changed="contentChanged"
        @open-edit-file-modal="openEditFileModal">
      </text-file>
      <csv-file
        v-if="folderFile.fileType == 'csv'"
        :file="folderFile"
        @open-edit-file-modal="openEditFileModal">
      </csv-file>
      <zip-file
        v-if="folderFile.fileType == 'zip'"
        :file="folderFile"
        @open-edit-file-modal="openEditFileModal">
      </zip-file>
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <edit-file-modal
      :opened="editFileModal.opened"
      :role="projectRole"
      :file="editFileModal.file"
      @close-edit-file-modal="closeEditFileModal">
    </edit-file-modal>

    <edit-folder-modal
      :opened="editFolderModal.opened"
      :role="projectRole"
      :file="editFolderModal.file"
      @close-edit-folder-modal="closeEditFolderModal">
    </edit-folder-modal>

  </div>
</template>

<script>
import AddressBar from './AddressBar'
import Folder from './folder-parts/Folder'
import NormalFile from './file-parts/NormalFile'
import ImageFile from './file-parts/ImageFile'
import PdfFile from './file-parts/PdfFile'
import TextFile from './file-parts/TextFile'
import CsvFile from './file-parts/CsvFile'
import ZipFile from './file-parts/ZipFile'
import EditFileModal from './modals/EditFileModal'
import EditFolderModal from './modals/EditFolderModal'

export default {
  name: 'folder-file-page',
  components: {
  	AddressBar,
    Folder,
    NormalFile,
    ImageFile,
    PdfFile,
    TextFile,
    CsvFile,
    ZipFile,
    EditFileModal,
    EditFolderModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      editFileModal: {
        opened: false,
        file: null
      },
      editFolderModal: {
        opened: false,
        file: null
      },
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
    folderFile () {
      return this.nodeMap[this.path]
    }
  },
  watch: {
    path: function (val) {
      this.requestFile(this.$route.params.dataPath)
    },
  },
  methods: {
    requestFile (dp) {
      var dataPath = encodeURIComponent(dp)
      dataPath = encodeURIComponent(dataPath)
      this.waiting = true
      if(!this.publicKey){
        this.$http.get(xHTTPx + '/get_file/' + this.projectId + "/" + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setFile', resp)
          this.waiting = false

        }, response => {
          this.error = 'Failed to get file!'
          this.waiting = false
        })
      }else{
        this.$http.get(xHTTPx + '/get_public_file/' + this.publicKey + "/" + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setPublicFile', resp)
          this.waiting = false
        }, response => {
          this.error = 'Failed to get file!'
          this.waiting = false
        })
      }
    },
    contentChanged(){
      this.requestFile(this.$route.params.dataPath)
    },
    openEditFileModal(){
      this.editFileModal.file = this.folderFile
      this.editFileModal.opened = true
    },
    closeEditFileModal(result){
      this.editFileModal.opened = false
      this.refreshAfterEdit(result)
    },
    openEditFolderModal(){
      this.editFolderModal.file = this.folderFile
      this.editFolderModal.opened = true
    },
    closeEditFolderModal(result){
      this.editFolderModal.opened = false
      this.refreshAfterEdit(result)
    },
    refreshAfterEdit(result){
      if(result){
        if(result == '.deleted.'){
          var dataPath = this.$route.params.dataPath
          var ss = dataPath.split('/')
          ss.pop()
        }else{
          var dataPath = this.$route.params.dataPath
          var ss = dataPath.split('/')
          ss.pop()
          this.requestFile(ss.join('/'))
          ss.push(result)
          this.requestFile(ss.join('/'))
        }
        var newDataPath = ss.join('/')
        var newPath = '/projects/' + this.projectId + '/data/' + encodeURIComponent(newDataPath)
        this.$nextTick(function(){
          this.$router.push(newPath)
        })
      }
    }
  },
  mounted () {
    this.$nextTick(function(){
      this.requestFile(this.$route.params.dataPath)
    })
  }
}
</script>

<style lang="scss" scoped>

.folder-file-page {
  padding: 10px;
}

.empty-label {
  text-align: center;
}

.buttons {
  text-align: right;
}
</style>
