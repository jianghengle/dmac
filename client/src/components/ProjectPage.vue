<template>
  <div class="project-page">
    <address-bar></address-bar>
    
    <div class="columns">
      <div class="view-title column">
        <span class="project-icon">
          <icon name="folder-open"></icon>
        </span>&nbsp;
        {{project && project.name}}&nbsp;
        <span class="edit-icon main-link"
          v-if="projectRole=='Owner' || projectRole=='Admin'"
          @click="openEditProjectModal(project)">
          <icon name="edit"></icon>
        </span>

      </div>
    </div>

    <nav class="nav">
      <div class="nav-left">
        <div class="nav-item">
          <div class="field is-grouped">
            <p class="control">
              <a class="button main-btn"  @click="viewData">
                <icon name="folder-open"></icon>&nbsp;
                <span>Data Explorer</span>
              </a>
            </p>
          </div>
        </div>
      </div>

      <div class="nav-right">
        <div class="nav-item">
          <div class="field is-grouped">
            <p class="control">
              <a class="button default-btn" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewHistory">
                <icon name="history"></icon>&nbsp;
                <span>History</span>
              </a>
            </p>
            <p class="control">
              <a class="button default-btn" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewPublicUrls">
                <icon name="share-alt"></icon>&nbsp;
                <span>Public Urls</span>
              </a>
            </p>
            <p class="control">
              <a class="button default-btn" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="viewUsers">
                <icon name="user"></icon>&nbsp;
                <span>Users</span>
              </a>
            </p>
          </div>
        </div>
      </div>
    </nav>

    <div class="details">
      <div class="field is-horizontal project-field">
        <div class="field-label is-normal">
          <label class="label">Owner:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="project && project.owner">
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal project-field">
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

      <div class="field is-horizontal project-field">
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

      <div class="field is-horizontal project-field">
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

      <div class="field is-horizontal project-field">
        <div class="field-label is-normal">
          <label class="label">Your Project Role:</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input field-text" type="text" readonly :value="projectRoleLabel">
            </div>
          </div>
        </div>
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
      return this.nodeMap['/projects/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    projectRoleLabel () {
      if(!this.projectRole) return ''
      var label = this.project.projectUser + ' as ' + this.projectRole
      if(this.projectRole == 'Owner' || this.projectRole == 'Admin')
        return label
      if(this.project.projectGroup)
        return label + '(' + this.project.projectGroup + ')'
      return label
    },
    textAreaHeight () {
      if(!this.project) return 1
      var lines = this.project.description.split('\n').length
      return 25*lines + 'px'
    }
  },
  watch: {
    projectId: function (val) {
      this.requestProject()
    },
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
      this.$router.push('/projects/' + this.projectId + '/users')
    },
    viewPublicUrls () {
      this.$router.push('/projects/' + this.projectId + '/urls')
    },
    viewHistory () {
      this.$router.push('/projects/' + this.projectId + '/history')
    },
    viewData () {
      this.$router.push('/projects/' + this.projectId + '/data/-root-')
    },
    openEditProjectModal(){
      this.editProjectModal.project = this.project
      this.editProjectModal.opened = true
    },
    closeEditProjectModal(result){
      this.editProjectModal.opened = false
      if(result){
        if(result == 'deleted'){
          this.$router.push('/projects')
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

.project-icon {
  position: relative;
  top: 3px;
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

.detail-header {
  font-size: 20px;
  font-weight: bold;
}

.details {
  margin-top: 20px;
}

.project-field {
  margin-bottom: 0px;
}

.field-text {
  border-style: none;
  box-shadow: none;
  resize: none;
  min-height: 40px;
  position: relative;
  top: -2px;
}

</style>
