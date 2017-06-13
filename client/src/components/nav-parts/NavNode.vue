<template>
  <div class="node-container">
    <div class="node" v-if="node">
      <span class="node-icon" @click="toggleOpen">
        <icon v-if="node.type=='projects'" name="database"></icon>
        <icon class="is-clickable" v-if="open && node.type=='project'" name="folder-open"></icon>
        <icon class="is-clickable" v-if="!open && node.type=='project'" name="folder"></icon>
        <icon class="is-clickable" v-if="open && node.type=='folder'" name="folder-open-o"></icon>
        <icon class="is-clickable" v-if="!open && node.type=='folder'" name="folder-o"></icon>
        <icon v-if="node.type=='file'" name="file-o"></icon>
        <icon v-if="node.type=='users'" name="user-o"></icon>
      </span>
      <span class="node-name"
        :class="{'is-current': isCurrent, 'is-clickable': node.type!='file'}"
        @click="viewNode">
        {{node.name}}
      </span>
    </div>
    <div v-if="open && children" class="node-children">
      <div class="spinner-container" v-if="waiting">
        <icon name="spinner" class="icon is-small fa-spin"></icon>
      </div>
      <div v-for="child in children">
        <nav-node :path="child"></nav-node>
      </div>
    </div>
  </div>
</template>

<script>
import NavNode from './NavNode'

export default {
  name: 'nav-node',
  components: {
    NavNode
  },
  props: ['path'],
  data () {
    return {
      waiting: false,
    }
  },
  computed: {
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    node () {
      return this.nodeMap[this.path]
    },
    routeProjectId () {
      return this.$route.params.projectId
    },
    routeDataPath () {
      return this.$route.params.dataPath
    },
    routePath () {
      var path
      if(this.routeProjectId){
        if(this.routeDataPath){
          path = '/' + this.routeProjectId + '/' + this.routeDataPath
        }else{
          path = '/' + this.routeProjectId
        }
      }else{
        path = '/'
      }
      return path
    },
    isCurrent () {
      return this.node && this.routePath == this.node.path
    },
    open () {
      return this.node && this.node.options && this.node.options.open
    },
    children () {
      return this.node && this.node.children
    }
  },
  watch: {
    isCurrent: function (val) {
      if(val)
        this.openNode()
    },
  },
  methods: {
    viewNode () {
      if(this.node.type != 'file')
        this.$router.push(this.node.path)
    },
    toggleOpen () {
      var type = this.node && this.node.type
      if(type == 'project' || type == 'folder'){
        if(this.node.options.open){
          this.closeNode()
        }else{
          this.requestData()
          this.openNode()
        }
      }
    },
    openNode () {
      this.$store.commit('projects/openNode', this.node.path)
    },
    closeNode () {
      var nodePath = this.node.path
      if(this.node.type == 'project'){
        nodePath = nodePath.slice(0, -7)
      }
      var routePath = this.routePath
      if(this.routeDataPath == '-root-'){
        routePath = routePath.slice(0, -7)
      }
      if(nodePath == routePath){
        this.$store.commit('projects/closeNode', this.node.path)
      }else{
        var canClose = false
        var np = nodePath.replace(/\-\-/g, '/').split('/')
        var cp = routePath.replace(/\-\-/g, '/').split('/')
        for(var i=0;i<np.length;i++){
          if(i >= cp.length || np[i] != cp[i]){
            canClose = true
            break
          }
        }
        if(canClose){
          this.$store.commit('projects/closeNode', this.node.path)
        } 
      }
    },
    requestData () {
      var type = this.node.type
      if(type == 'project'){
        this.requestProject()
      }else{
        this.requestFile()
      }
    },
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.node.id).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
        vm.waiting = false
      }, response => {
        vm.waiting = false
      })
    },
    requestFile () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_file/' + vm.node.projectId + "/" + vm.node.dataPath).then(response => {
        var resp = response.body
        this.$store.commit('projects/setFile', resp)
        vm.waiting = false
      }, response => {
        vm.waiting = false
      })
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      if(vm.isCurrent){
        vm.openNode()
      }
    })
  }
}
</script>

<style lang="scss" scoped>

.node-children {
  position: relative;
  left: 15px;
}

.node {
  
}

.node-icon {
  position: relative;
  top: 3px;
}

.node-name {
  padding: 3px;
  bordor-radius: 3px;
}

.is-current {
  color: white;
  background-color: #3273dc;
  font-weight: bold;
}

.is-clickable {
  cursor: pointer;
}

</style>
