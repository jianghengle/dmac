<template>
  <div class="node-container" v-if="showNode">
    <div class="node">
      <span class="node-icon" @click="toggleOpen">
        <icon v-if="node.type=='projects'" name="database"></icon>
        <icon class="is-clickable" v-if="open && node.type=='project'" name="folder-open"></icon>
        <icon class="is-clickable" v-if="!open && node.type=='project'" name="folder"></icon>
        <icon class="is-clickable" v-if="open && node.type=='folder'" name="folder-open-o"></icon>
        <icon class="is-clickable" v-if="!open && node.type=='folder'" name="folder-o"></icon>
        <span v-if="node.type=='file'">
          <icon :name="node.icon"></icon>
        </span>
        <icon v-if="node.type=='users'" name="user-o"></icon>
        <icon v-if="node.type=='urls'" name="share-alt"></icon>
        <icon v-if="node.type=='history'" name="history"></icon>
      </span>
      <span class="node-name is-clickable main-link"
        :class="{'is-current': isCurrent}"
        @click="viewNode">
        {{node.name}}
        <span v-if="node.publicUrl">*</span>
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
      return this.$route.path
    },
    isCurrent () {
      if(!this.node) return false
      if(this.node.type == 'history'){
        return this.routePath.indexOf(this.node.path) == 0
      }
      if(this.$route.name == 'ProjectSearch' || this.$route.name == 'PublicSearch'){
        return this.node.path.replace('/data/', '/search/') == this.routePath
      }
      return this.routePath == this.node.path
    },
    open () {
      return this.node && this.node.options && this.node.options.open
    },
    children () {
      return this.node && this.node.children
    },
    showOption () {
      return this.$store.state.projects.showOption
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    publicDataPath () {
      return this.$store.state.projects.publicDataPath
    },
    nodeProject () {
      if(this.node)
        return this.nodeMap['/projects/' + this.node.projectId]
      return null
    },
    nodeProjectRole () {
      return this.nodeProject && this.nodeProject.projectRole
    },
    showNode () {
      var node = this.node
      if(!node) return false
      if(this.publicKey) return true

      var type = node && node.type
      if(type == 'projects') return true
      if(type == 'project'){
        if(this.showOption == 'All') return true
        return node.status == this.showOption
      }

      var role = this.nodeProjectRole
      if(!role) return false
      if(type == 'users' || type == 'urls' || type == 'history'){
        return this.isCurrent
      }
      return true
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
      var routePath = this.routePath
      if(nodePath == routePath){
        this.$store.commit('projects/closeNode', this.node.path)
      }else if(routePath.indexOf(nodePath) < 0){
        this.$store.commit('projects/closeNode', this.node.path)
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
      var dataPath = encodeURIComponent(vm.node.dataPath)
      dataPath = encodeURIComponent(dataPath)
      if(!this.publicKey){
        vm.$http.get(xHTTPx + '/get_file/' + vm.node.projectId + "/" + dataPath).then(response => {
          var resp = response.body
          this.$store.commit('projects/setFile', resp)
          vm.waiting = false
        }, response => {
          vm.waiting = false
        })
      }else{
        vm.$http.get(xHTTPx + '/get_public_file/' + vm.publicKey + "/" + dataPath).then(response => {
          var resp = response.body
          vm.$store.commit('projects/setPublicFile', resp)
          vm.waiting = false
        }, response => {
          vm.waiting = false
        })
      }
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
  color: #2e1052;
}

.node-name {
  padding: 3px;
  border-radius: 3px;
}

.is-current {
  color: white;
  background-color: #2e1052;
  font-weight: bold;
}

.is-clickable {
  cursor: pointer;
}

</style>
