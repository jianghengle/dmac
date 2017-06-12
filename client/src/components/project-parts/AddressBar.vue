<template>
  <div>
    <span class="nav-icon" @click="toggleNav">
      <icon name="navicon"></icon>
    </span>
    &nbsp
    <span v-for="(node, i) in nodes" class="address-text">
      <span v-if="i != 0">&nbsp;/</span>
      <a @click="viewNode(node)">{{node.name}}</a>
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
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    nodes () {
      var nodes = []
      nodes.push(this.getNode('/'))

      if(!this.projectId) return nodes
      nodes.push(this.getNode('/' + this.projectId + '/-root-'))

      if(this.dataPath){
        var files = this.dataPath.split('--')
        var path = '/' + this.projectId
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
  
}

.nav-icon {
  cursor: pointer;
}

</style>
