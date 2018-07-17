<template>
  <div class="projects-page">
  	<address-bar></address-bar>
    <div class="projects-title">
      <div class="columns">
        <div class="column">
          <icon name="database"></icon>
          Projects
        </div>
        <div class="column">
          <div class="field is-grouped is-grouped-right">
            <p class="control">
              <a class="button main-btn" v-if="!isSubscriber" @click="openNewProjectModal">
                <icon name="plus"></icon>&nbsp;New Project
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="tabs">
      <ul>
        <li v-for="pf in projectFilters" :key="'pf-' + pf" :class="{'is-active': projectFilter == pf}">
          <a @click="projectFilter = pf">{{pf}} ({{projectCounts[pf]}})</a>
        </li>
      </ul>
    </div>

    <div class="columns is-multiline">
      <div class="column is-half" v-for="project in projects":key="project.id"
        v-show="projectFilter=='All' || projectFilter==project.status">
        <div class="box project-box" @click="viewProject(project)">
          <div class="header">
            <span class="info">{{project.createdDate}}</span>
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
          </div>
          <div class="description">{{project.description}}</div>
        </div>
      </div>
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
      projectFilter: 'Active',
      projectFilters: ['Active', 'Archived', 'Template', 'Public Template', 'All'],
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
    },
    projectCounts () {
      var counts = {}
      this.projectFilters.forEach(function(f){
        counts[f] = 0
      })
      this.projects.forEach(function(p){
        counts[p.status]++
        counts['All']++
      })
      return counts
    }
  },
  watch: {
    projectFilter: function (val) {
      this.$store.commit('options/setProjectFilter', val)
    }
  },
  methods: {
    requestProjects(){
      this.waiting = true
      this.$http.get(xHTTPx + '/get_projects').then(response => {
        var resp = response.body
        this.isSubscriber = resp[0] == 'Subscriber'
        this.$store.commit('projects/setProjects', resp.slice(1))
        this.waiting= false
      }, response => {
        this.error = 'Failed to get projects!'
        this.waiting= false
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
        if(this.projectFilter != 'Active' && this.projectFilter != 'All'){
          this.projectFilter = 'All'
        }
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
    }
  },
  mounted () {
    this.projectFilter = this.$store.state.options.projectFilter
    this.$nextTick(function(){
      this.requestProjects()
    })
  },
}
</script>

<style lang="scss" scoped>

.projects-page {
  padding: 10px;
}

.projects-title {
  font-size: 24px;
  font-weight: bold;
  color: #2e1052;
}

.projects-filter {
  text-align: center;
  font-size: 16px;
  font-weight: normal;

  .filter-label {
    margin-right: 0.5rem;
  }
}

.project-box {
  cursor: pointer;
  padding-top: 10px;
  padding-bottom: 10px;
  min-height: 100px;
  max-height: 100px;
  overflow: auto;
  
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
