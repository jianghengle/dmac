<template>
  <div>
    <address-bar></address-bar>
    <div>folder toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <folder-content :content="folderContent"></folder-content>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FolderContent from './FolderContent'

export default {
  name: 'folder',
  components: {
  	AddressBar,
    FolderContent
  },
  data () {
    return {
      error: '',
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    path () {
      return "/" + this.projectId + "/" + this.$route.params.path
    },
    folder () {
      return this.$store.state.projects.nodeMap[this.path]
    },
    folderContent () {
      if(this.folder)
        return this.folder.children
      return []
    }
  },
  watch: {
    path: function (val) {
      this.requestFolder()  
    },
  },
  methods: {
    requestFolder () {
      var vm = this
      var path = this.$route.params.path
      vm.$http.get(xHTTPx + '/get_folder/' + vm.projectId + "/" + path).then(response => {
        var resp = response.body
        this.$store.commit('projects/setFolder', resp)
      }, response => {
        vm.error = 'Failed to get project!'
      })
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestFolder()
    })
  }
}
</script>

<style lang="scss" scoped>

</style>
