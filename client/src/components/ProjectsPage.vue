<template>
  <div class="projects-page">
  	<address-bar></address-bar>
    <div class="view-title">Projects</div>
    <div>toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="box project-box" v-for="project in projects"  @click="viewProject(project)">
      <div class="header">
        <span class="name">{{project.name}}</span>
        <span class="info">{{project.createdDate}}</span>
      </div>
      <div class="description">{{project.description}}</div>          
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
  </div>
</template>

<script>
import AddressBar from './project-parts/AddressBar'

export default {
  name: 'projects-page',
  components: {
    AddressBar
  },
  data () {
    return {
      error: '',
      waiting: false
    }
  },
  computed: {
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    projects () {
      var node = this.nodeMap['/']
      if(!node) return []
      var vm = this
      return node.children.map(function(c){
        return vm.nodeMap[c]
      })
    }
  },
  methods: {
    viewProject (project) {
      this.$router.push(project.path)
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_projects').then(response => {
        var resp = response.body
        this.$store.commit('projects/setProjects', resp)
        vm.waiting= false
      }, response => {
        vm.error = 'Failed to get projects!'
        vm.waiting= false
      })
    })
  },
}
</script>

<style lang="scss" scoped>

.projects-page {
  padding: 10px;  
}

.project-box {
  cursor: pointer;
  margin-top:10px;
  padding-top: 10px;
  padding-bottom: 10px;
  margin-bottom: 15px;
  
  

  .header {
    
    .name {
      font-size: 18px;
      font-weight: bold;
    }
    
    .info {
      font-size: 14px;
      float: right;
      padding-top: 5px;
    }
  }
}


.project-box:hover{
  background-color: #f2f2f2; 
}




</style>
