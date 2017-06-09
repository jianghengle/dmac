<template>
  <div>
    <address-bar></address-bar>
    <div>project toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div></div>
    <folder-content :content="folderContent"></folder-content>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FolderContent from './FolderContent'

export default {
  name: 'project',
  components: {
  	AddressBar,
    FolderContent
  },
  data () {
    return {
      error: ''
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    project () {
      return this.$store.state.projects.nodeMap['/' + this.projectId + '/-root-']
    },
    folderContent () {
      if(this.project) return this.project.children.slice(1)
      return []
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
      }, response => {
        vm.error = 'Failed to get project!'
      })
    })
  }
}
</script>

<style lang="scss" scoped>

</style>
