<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        
      </div>
    </div>

    <div class="file-content">
      No Preview Available.
    </div>
    <a v-if="!url"
      @click="getDownloadUrl"
      class="button is-info">
      <icon name="download"></icon> &nbsp;
      Download
    </a>
    <a v-if="url" :href="url">Download Link</a>
  </div>
</template>

<script>

export default {
  name: 'normal-file',
  props: ['file'],
  
  data () {
    return {
      url: null
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
      this.url = null
    },
  },
  methods: {
    getDownloadUrl() {
      this.$http.get(xHTTPx + '/get_download_url/' + this.projectId + "/" + this.file.dataPath).then(response => {
        this.url = xHTTPx + response.body
      }, response => {
        console.log('failed to get url')
      })
    }
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

.action-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}

</style>
