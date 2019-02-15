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
        class="action-icon main-link">
        <icon name="edit"></icon>
      </a>
      <span class="main-link search-button" @click="openSearch">
        <icon name="search"></icon>
      </span>
      <a :href="url" :download="file && file.name" target="_blank" class="action-icon main-link"><icon name="download"></icon></a>
    </div>

    <div class="file-content">
      <div class="pdf-container">
        <div class="spinner-container" v-if="waiting">
          <icon name="spinner" class="icon is-medium fa-spin"></icon>
        </div>
        <!--<embed :src="dataUrl" :width="pdfWidth + 'px'" height="1000px" class="pdf-body" type="application/pdf" />-->
        <iframe class="doc" :src="iframeSource"></iframe>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'pdf-file',
  props: ['file'],
  data () {
    return {
      url: null,
      data: null,
      dataUrl: null,
      iframeSource: '',
      waiting: false,
      pdfWidth: 800
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
    publicKey () {
      return this.$route.params.publicKey
    },
  },
  watch: {
    path: function (val) {
      this.getDownloadUrl()
    },
  },
  methods: {
    getDownloadUrl() {
      var dataPath = encodeURIComponent(this.file.dataPath)
      dataPath = encodeURIComponent(dataPath)
      var url = xHTTPx + '/get_download_url/' + this.file.projectId + "/" + dataPath
      if(this.publicKey){
        url = xHTTPx + '/get_public_download_url/' + this.publicKey + "/" + this.file.projectId + "/" + dataPath
      }
      this.$http.get(url).then(response => {
        this.url = xHTTPx + response.body
        this.iframeSource = "https://docs.google.com/gview?url=" + this.url + "&embedded=true"
        this.waiting = false
        /*
        this.$http.get(this.url, {responseType: 'blob'}).then(response => {
          return response.blob()
        }).then(blob => {
          this.dataUrl = URL.createObjectURL(blob)
          this.waiting = false
        })
        */
      }, response => {
        console.log('failed to get url')
      })
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
    this.pdfWidth = this.$el.clientWidth
    this.getDownloadUrl()
  }
}
</script>

<style lang="scss" scoped>

.buttons {
  text-align: right;
}

.file-content {
  margin-top: 5px;
}

.pdf-container {
  width: 100%;
  height: 1000px;
}

.pdf-body {
  height: 100%
}

.action-icon {
  position: relative;
  top: 3px;
}

.doc {
  width: 100%;
  height: 1000px;
}

.file-tag {
  position: relative;
  top: -3px;
}

</style>
