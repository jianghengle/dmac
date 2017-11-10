<template>
  <div class="projects-page">
  	<address-bar></address-bar>
    <div class="view-title">
      <div class="columns">
        <div class="column">
          <icon name="database"></icon>
          Projects
        </div>
        <div class="column  projects-filter">
          <div class="field is-horizontal">
            <div class="field-label is-normal filter-label">
              <label class="label">Show</label>
            </div>
            <div class="field-body">
              <div class="field is-narrow">
                <div class="control">
                  <div class="select is-fullwidth">
                    <select v-model="showOption">
                      <option>Active</option>
                      <option>Archived</option>
                      <option>Template</option>
                      <option>Public Template</option>
                      <option>All</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="column">
          <a class="button main-btn project-button" v-if="!isSubscriber" @click="openNewProjectModal">
            <icon name="plus"></icon>&nbsp;New Project
          </a>
        </div>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="box project-box" v-for="project in projects":key="project.id" @click="viewProject(project)"
      v-show="showOption=='All' || showOption==project.status">
      <div class="header">
        <span class="name">
          <span class="tag" :class="{
            'is-success': project.status=='Active',
            'is-dark': project.status=='Archived',
            'is-warning': project.status=='Template',
            'is-danger': project.status=='Public Template'
          }">
            {{project.status}}
          </span>
          {{project.name}}
        </span>&nbsp;
        <span class="edit-icon main-link"
          v-if="project.projectRole=='Owner' || project.projectRole=='Admin'"
          @click.stop="openEditProjectModal(project)">
          <icon name="edit"></icon>
        </span>
        <span class="info">{{project.createdDate}}</span>
      </div>
      <div class="description">{{project.description}}</div>          
    </div>
    <div v-if="projects && projects.length == 0">
    You have no projects yet.
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <new-project-modal
      :opened="newProjectModal.opened"
      :templates="templates"
      @close-new-project-modal="closeNewProjectModal">
    </new-project-modal>

    <edit-project-modal
      :opened="editProjectModal.opened"
      :project="editProjectModal.project"
      @close-edit-project-modal="closeEditProjectModal">
    </edit-project-modal>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import NewProjectModal from './modals/NewProjectModal'
import EditProjectModal from './modals/EditProjectModal'

export default {
  name: 'projects-page',
  components: {
    AddressBar,
    NewProjectModal,
    EditProjectModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      newProjectModal: {
        opened: false
      },
      editProjectModal: {
        opened: false,
        project: null
      },
      showOption: 'Active',
      isSubscriber: true
    }
  },
  computed: {
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    projects () {
      var node = this.nodeMap['/projects']
      if(!node) return []
      var vm = this
      return node.children.map(function(c){
        return vm.nodeMap[c]
      })
    },
    templates () {
      var templates = this.projects.filter(function(p){
        return (p.status == 'Template' || p.status == 'Public Template') && (p.projectRole == 'Owner' || p.projectRole == 'Admin')
      })
      return templates
    }
  },
  watch: {
    showOption: function (val) {
      this.$store.commit('projects/setShowOption', this.showOption)
    },
    projects: function(val) {
      this.initShowOption()
    }
  },
  methods: {
    requestProjects(){
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_projects').then(response => {
        var resp = response.body
        vm.isSubscriber = resp[0] == 'Subscriber'
        this.$store.commit('projects/setProjects', resp.slice(1))
        vm.waiting= false
      }, response => {
        vm.error = 'Failed to get projects!'
        vm.waiting= false
      })
    },
    viewProject (project) {
      this.$router.push(project.path)
    },
    openNewProjectModal(){
      this.newProjectModal.opened = true
    },
    closeNewProjectModal(result){
      this.newProjectModal.opened = false
      if(result){
        this.requestProjects()
      }
    },
    openEditProjectModal(project){
      this.editProjectModal.project = project
      this.editProjectModal.opened = true
    },
    closeEditProjectModal(result){
      this.editProjectModal.opened = false
      if(result){
        this.requestProjects()
      }
    },
    initShowOption(){
      if(this.projects && this.projects.length){
        var noActive = true
        for(var i=0;i<this.projects.length;i++){
          if(this.projects[i].status == 'Active'){
            noActive = false
            break
          }
        }
        if(noActive){
          this.$store.commit('projects/setShowOption', 'All')
        }
      }
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestProjects()
    })
    this.showOption = this.$store.state.projects.showOption
    this.initShowOption()
  },
}
</script>

<style lang="scss" scoped>

.projects-page {
  padding: 10px;
}

.projects-filter {
  text-align: center;
  font-size: 16px;
  font-weight: normal;

  .filter-label {
    margin-right: 0.5rem;
  }
}

.project-button {
  float: right;
  font-size: 16px;
  font-weight: normal;
  line-height: 2.5;
}

.project-box {
  cursor: pointer;
  margin-top:10px;
  padding-top: 10px;
  padding-bottom: 10px;
  margin-bottom: 15px;
  
  &.inactive {
    color: #7a7a7a;
  }

  .header {
    
    .name {
      font-size: 18px;
      font-weight: bold;

      
    }

    .edit-icon {
      font-size: 14px;
      position: relative;
      top: 3px;
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
