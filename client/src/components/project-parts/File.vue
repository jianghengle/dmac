<template>
  <div>
    <address-bar></address-bar>
    <div class="view-title">{{file && file.name}}</div>
    <div>file toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <file-content :content="fileContent"></file-content>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
    <div class="empty-label" v-if="!waiting && (!fileContent || !fileContent.length)">(Empty)</div>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FileContent from './FileContent'

export default {
  name: 'file',
  components: {
  	AddressBar,
    FileContent
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

</style>
