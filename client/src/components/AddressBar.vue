<template>
  <div>
    <span class="nav-icon" @click="toggleNav">
      <icon name="navicon"></icon>
    </span>
    &nbsp
    <span v-for="(node, i) in nodes">
      <span v-if="i != 0">/</span>
      <a @click="viewNode(node)" class="address-text main-link">
        {{node.name}}
        <span v-if="node.publicUrl">*</span>
      </a>
    </span>
  </div>
</template>

<script>
export default {
  name: 'address-bar',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    publicDataPath () {
      return this.$store.state.projects.publicDataPath
    },
    dataPath () {
      return this.$route.params.dataPath
    },
    routeName () {
      return this.$route.name
    },
    commitHash () {
      return this.$route.params.hash
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    nodes () {
      var nodes = []
      if(!this.publicKey){
        nodes.push(this.getNode('/projects'))

        if(!this.projectId) return nodes
        nodes.push(this.getNode('/projects/' + this.projectId))
        if(this.routeName == 'Project') return nodes

        if(this.routeName == 'ProjectUsers'){
          nodes.push(this.getNode('/projects/' + this.projectId + '/users'))
        }else if(this.routeName == 'PublicUrlsPage'){
          nodes.push(this.getNode('/projects/' + this.projectId + '/urls'))
        }else if(this.routeName == 'ChannelsPage'){
          nodes.push(this.getNode('/projects/' + this.projectId + '/channels'))
        }else if(this.routeName == 'HistoryPage'){
          nodes.push(this.getNode('/projects/' + this.projectId + '/history'))
        }else if(this.routeName == 'CommitPage'){
          nodes.push(this.getNode('/projects/' + this.projectId + '/history'))
          var commitNode = {
            name: this.commitHash,
            path: '/projects/' + this.projectId + '/history/' + this.commitHash
          }
          nodes.push(commitNode)
        }else{
          var path = '/projects/' + this.projectId + '/data/'
          var files = this.dataPath.split('/')
          for(var i=0;i<files.length;i++){
            if(i == 0){
              path += '%2F'
            }else if(i == 1){
              if(!files[i]) break
              path += encodeURIComponent(files[i])
            }else{
              path = path + encodeURIComponent('/' + files[i])
            }
            nodes.push(this.getNode(path))
          }
        }
      }else{
        var path = '/public/' + this.publicKey + '/data/' + encodeURIComponent(this.publicDataPath)
        nodes.push(this.getNode(path))
        if(this.dataPath != this.publicDataPath && this.dataPath.indexOf(this.publicDataPath) == 0){
          var vm = this
          this.dataPath.slice(this.publicDataPath.length + 1).split('/').forEach(function(s){
            path += encodeURIComponent('/' + s)
            nodes.push(vm.getNode(path))
          })
        }
      }

      return nodes
    },
    
  },
  methods: {
    getNode (path) {
      var node = this.nodeMap[path]
      if(node){
        return node
      }
      return {}
    },
    viewNode (node) {
      this.$router.push(node.path)
    },
    toggleNav () {
      this.$store.commit('projects/toggleNav')
    }
  },
}
</script>

<style lang="scss" scoped>

.nav-icon {
  cursor: pointer;
  position: relative;
  top: 3px;
  color: #2e1052;
}

.nav-icon:hover {
  color: #866ba6;
}

</style>
