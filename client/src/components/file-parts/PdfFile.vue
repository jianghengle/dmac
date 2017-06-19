<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}&nbsp;
        <a :href="dataUrl" :download="file && file.name" target="_blank" class="action-icon"><icon name="download"></icon></a>
      </div>
      <div class="column buttons">
        
      </div>
    </div>

    <div class="file-content">
      <div class="pdf-container">
        <div class="spinner-container" v-if="waiting">
          <icon name="spinner" class="icon is-medium fa-spin"></icon>
        </div>
        <embed :src="dataUrl" :width="pdfWidth + 'px'" height="1000px" class="pdf-body" type="application/pdf" />
      </div>
    </div>
  </div>
</template>

<script>
import PDFObject from 'pdfobject'

export default {
  name: 'pdf-file',
  props: ['file'],
  data () {
    return {
      url: null,
      data: null,
      dataUrl: null,
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
      return this.nodeMap['/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    path () {
      return this.$route.path
    },
  },
  watch: {
    path: function (val) {
      this.getDownloadUrl()
    },
  },
  methods: {
    getDownloadUrl() {
      this.$http.get(xHTTPx + '/get_download_url/' + this.projectId + "/" + this.file.dataPath).then(response => {
        this.url = xHTTPx + response.body
        this.waiting = true
        this.$http.get(this.url, {responseType: 'blob'}).then(response => {
          return response.blob()
        }).then(blob => {
          this.dataUrl = URL.createObjectURL(blob)
          this.waiting = false
        })
      }, response => {
        console.log('failed to get url')
      })
    }
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
  color: #3273dc;
  position: relative;
  top: 3px;
}

</style>
