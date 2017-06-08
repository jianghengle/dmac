<template>
  <div class="projects-page">
  	<address-bar></address-bar>
    <div>toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div>Active Projects:</div> 
    <div class="box project-box" v-for="project in projects">
      <div class="header" @click="viewProject(project)">
        <span class="name">{{project.name}}</span>
        <span class="info">{{project.createdDate}}</span>
      </div>
      <div class="description">{{project.description}}</div>          
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
      error: ''
    }
  },
  computed: {
    projects () {
      if(this.$store.state.projects.root)
        return this.$store.state.projects.root.children
      return []
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
      vm.$http.get(xHTTPx + '/get_projects').then(response => {
        var resp = response.body
        this.$store.commit('projects/setProjects', resp)
      }, response => {
        vm.error = 'Failed to get projects!'
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
  margin-top:10px;
  padding-top: 10px;
  
  

  .header {
    cursor: pointer;
    
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
