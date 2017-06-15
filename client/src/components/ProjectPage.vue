<template>
  <div class="project-page">
    <address-bar></address-bar>
    
    <div class="columns">
      <div class="view-title column">
        <icon name="folder-open"></icon>&nbsp;
        {{project && project.name}}
      </div>
    </div>

    <div>
      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Status</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <p class="input field-text">{{project && project.status}}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Description</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <p class="input field-text">{{project && project.description}}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Created Date</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <p class="input field-text">{{project && project.createdDate}}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Role</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <p class="input field-text">{{project && project.projectRole}}</p>
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
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'


export default {
  name: 'project-page',
  components: {
    AddressBar,
  },
  data () {
    return {
      error: '',
      waiting: false,
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
}

.actions {
  margin-top: 30px;
}

.action {
  text-align: center;
}



</style>
