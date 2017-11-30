<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <span class="main-link search-button" @click="openSearch">
          <icon name="search"></icon>
        </span>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        
      </div>
    </div>

    <div class="file-content">
      <figure class="image image-container">
        <img :src="url">
      </figure>
    </div>

  </div>
</template>

<script>

export default {
  name: 'image-file',
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
      if(this.publicKey){
        this.$http.get(xHTTPx + '/get_public_download_url/' + this.publicKey + "/" + this.file.projectId + "/" + dataPath).then(response => {
          this.url = xHTTPx + response.body
        }, response => {
          console.log('failed to get url')
        })
      }else{
        this.$http.get(xHTTPx + '/get_download_url/' + this.file.projectId + "/" + dataPath).then(response => {
          this.url = xHTTPx + response.body
        }, response => {
          console.log('failed to get url')
        })
      }
    },
    openSearch(){
      var searchPath = this.$route.path.replace('/data/', '/search/')
      this.$router.push(searchPath)
    }
  },
  mounted () {
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

.image-container {
  max-width: 1000px;
}


</style>
