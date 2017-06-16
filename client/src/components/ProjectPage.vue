<template>
  <div class="project-page">
    <address-bar></address-bar>
    
    <div class="columns">
      <div class="view-title column">
        <icon name="folder-open"></icon>&nbsp;
        {{project && project.name}}&nbsp;
        <span class="edit-icon"
          v-if="projectRole=='Owner' || projectRole=='Admin'"
          @click="openEditProjectModal(project)">
          <icon name="edit"></icon>
        </span>

      </div>
    </div>

    <div>
      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Created By:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="project && project.owner">
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Created Date:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="project && project.createdDate">
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Status:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="project && project.status">
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Description:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <textarea class="textarea field-text" :style="{height: textAreaHeight}" readonly>{{project && project.description}}</textarea>
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Your Role:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="project && project.projectRole">
            </div>
          </div>
        </div>
      </div>

    </div>

    
    <div class="columns actions">
      <div class="column action">
        <a class="button is-info" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewData">
          <icon name="folder-open"></icon>&nbsp;
          Data Explorer
        </a>
      </div>
      <div class="column action">
        <a class="button is-info" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewUsers">
          <icon name="user"></icon>&nbsp;
          Users Management
        </a>
      </div>
    </div>

    <edit-project-modal
      :opened="editProjectModal.opened"
      :project="editProjectModal.project"
      @close-edit-project-modal="closeEditProjectModal">
    </edit-project-modal>
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import EditProjectModal from './modals/EditProjectModal'

export default {
  name: 'project-page',
  components: {
    AddressBar,
    EditProjectModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      editProjectModal: {
        opened: false,
        project: null
      },
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    project () {
      return this.nodeMap['/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    textAreaHeight () {
      if(!this.project) return 1
      var lines = this.project.description.split('\n').length
      return 20*lines + 'px'
    }
  },
  methods: {
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project!'
        vm.waiting = false
      })
    },
    viewUsers () {
      this.$router.push('/' + this.projectId + '/users')
    },
    viewData () {
      this.$router.push('/' + this.projectId + '/data/-root-')
    },
    openEditProjectModal(){
      this.editProjectModal.project = this.project
      this.editProjectModal.opened = true
    },
    closeEditProjectModal(result){
      this.editProjectModal.opened = false
      if(result){
        if(result == 'deleted'){
          this.$router.push('/')
        }else{
          this.requestProject()
        }
      }
    },
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestProject()
    })
  }
}
</script>

<style lang="scss" scoped>

.project-page {
  padding: 10px;
}

.field-text {
  border-style: none;
  box-shadow: none;
  resize: none;
  min-height: 40px;
}

.actions {
  margin-top: 30px;
}

.action {
  text-align: center;
}

.edit-icon {
  font-size: 14px;
  position: relative;
  top: 3px;
  cursor: pointer;
}

</style>
