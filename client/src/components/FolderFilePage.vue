<template>
  <div class="folder-file-page">
    <address-bar></address-bar>

    <div v-if="error" class="notification is-danger login-text">
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
        v-if="folderFile.fileType == 'text'"
        :file="folderFile"
        @content-changed="contentChanged">
      </text-file>
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

export default {
  name: 'folder-file-page',
  components: {
  	AddressBar,
    Folder,
    NormalFile,
    ImageFile,
    PdfFile,
    TextFile
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
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    path () {
      return "/projects/" + this.projectId + "/data/" + this.$route.params.dataPath
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
