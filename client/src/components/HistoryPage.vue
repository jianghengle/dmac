<template>
  <div class="history-page">
    <address-bar></address-bar>

    <div class="columns">
      <div class="view-title column">
        <icon name="history"></icon>&nbsp;
        Project History
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div>
      <table class="table is-fullwidth is-hoverable">
        <thead>
          <tr>
            <th>#</th>
            <th>Date</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(c, i) in commits" :key="c.hash" class="entry" @click="viewCommit(c)">
            <td>{{commits.length - i}}</td>
            <td>{{c.date}}</td>
            <td>{{c.message}}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div class="empty-label" v-if="!waiting && !commits.length">(Empty)</div>
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'

export default {
  name: 'HistoryPage',
  components: {
    AddressBar
  },
  data () {
    return {
      error: '',
      waiting: false,
      commits: [],
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
  },
  watch: {
    projectId: function (val) {
      this.requestCommits()
      if(!this.project){
        this.requestProject()
      }
    },
  },
  methods: {
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        vm.$store.commit('projects/setProject', resp)
        vm.$store.commit('projects/openNode', '/projects/' + this.projectId)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project!'
        vm.waiting = false
      })
    },
    requestCommits () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_logs/' + vm.projectId).then(response => {
        var resp = response.body
        vm.commits = resp
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project history!'
        vm.waiting = false
      })
    },
    viewCommit (c) {
      var path = '/projects/' + this.projectId + '/history/' + c.hash
      this.$router.push(path)
    } 
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestCommits()
      if(!vm.project){
        vm.requestProject()
      }
    })
  }
}
</script>

<style lang="scss" scoped>
.history-page {
  padding: 10px;
}

.entry {
  cursor: pointer;
}

</style>
