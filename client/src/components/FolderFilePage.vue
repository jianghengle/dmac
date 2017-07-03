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
      @content-changed="contentChanged">
    </folder>

    <div v-if="folderFile && folderFile.type == 'file'">
      <normal-file
        v-if="folderFile.fileType == 'unknown'"
        :file="folderFile">
      </normal-file>
      <image-file
        v-if="folderFile.fileType == 'image'"
        :file="folderFile">
      </image-file>
      <pdf-file
        v-if="folderFile.fileType == 'pdf'"
        :file="folderFile">
      </pdf-file>
      <text-file
        v-if="folderFile.fileType == 'text' || folderFile.fileType == 'code'"
        :file="folderFile"
        @content-changed="contentChanged">
      </text-file>
      <csv-file
        v-if="folderFile.fileType == 'csv'"
        :file="folderFile">
      </csv-file>
      <zip-file
        v-if="folderFile.fileType == 'zip'"
        :file="folderFile">
      </zip-file>
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

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
    ZipFile
  },
  data () {
    return {
      error: '',
      waiting: false
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
    path () {
      return this.$route.path
    },
    folderFile () {
      return this.nodeMap[this.path]
    }
  },
  watch: {
    path: function (val) {
      this.requestFile()
    },
  },
  methods: {
    requestFile () {
      var dataPath = this.$route.params.dataPath
      this.waiting = true
      if(this.projectId){
        this.$http.get(xHTTPx + '/get_file/' + this.projectId + "/" + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setFile', resp)
          this.waiting = false

        }, response => {
          this.error = 'Failed to get file!'
          this.waiting = false
        })
      }else if(this.publicKey){
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
      this.requestFile()
    },
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
