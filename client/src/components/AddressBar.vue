<template>
  <div>
    <span class="nav-icon" @click="toggleNav">
      <icon name="navicon"></icon>
    </span>
    &nbsp
    <span v-for="(node, i) in nodes">
      <span v-if="i != 0">&nbsp;/</span>
      <a @click="viewNode(node)" class="address-text">{{node.name}}</a>
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
    dataPath () {
      return this.$route.params.dataPath
    },
    routeName () {
      return this.$route.name
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    nodes () {
      var nodes = []
      nodes.push(this.getNode('/projects'))

      if(!this.projectId) return nodes
      nodes.push(this.getNode('/projects/' + this.projectId))
      if(this.routeName == 'Project') return nodes
        
      if(this.routeName == 'ProjectUsers'){
        nodes.push(this.getNode('/projects/' + this.projectId + '/users'))
      }else{
        nodes.push(this.getNode('/projects/' + this.projectId + '/data/-root-'))
        var files = this.dataPath.split('--')
        var path = '/projects/' + this.projectId + '/data'
        for(var i=0;i<files.length;i++){
          if(i == 0){
            path = path + '/' + files[i]
          }else{
            path = path + '--' + files[i]
          }
          if(files[i] != '-root-'){
            nodes.push(this.getNode(path))
          }
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

.address-text {
  color: #3273dc;
}

.nav-icon {
  cursor: pointer;
}

</style>
