<template>
  <div class="history-page">
    <address-bar></address-bar>

    <div class="columns">
      <div class="view-title column">
        <icon name="history"></icon>&nbsp;
        {{commit.date}}
      </div>
      <div class="column commit-buttons">
        <a class="button default-btn" @click="revertCommits">
          Rollback to This Point
        </a>
        <a class="button default-btn" @click="deleteHistory">
          Delete History before This Point
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div class="commit-content" v-html="commit.content">
      
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <confirm-modal
      :opened="confirmModal.opened"
      :message="confirmModal.message"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'CommitPage',
  components: {
    AddressBar,
    ConfirmModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      commit: {},
      confirmModal: {
        opened: false,
        message: '',
        context: null
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
    hash () {
      return this.$route.params.hash
    },
  },
  methods: {
    requestProject () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_project/' + this.projectId).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
        this.$store.commit('projects/openNode', '/projects/' + this.projectId)
        this.waiting = false
      }, response => {
        this.error = 'Failed to get project!'
        this.waiting = false
      })
    },
    requestCommit () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_commit/' + this.projectId + '/' + this.hash).then(response => {
        this.commit = response.body
        this.waiting = false
      }, response => {
        this.error = 'Failed to get commit!'
        this.waiting = false
      })
    },
    revertCommits(){
      var message = 'Are you sure to rollback to this point, which means ALL THE FOLLOWING CHANGES till the latest will be reverted? '
      message += "It would NOT delete any history though, so you still can come back any point later."
      var context = {callback: this.revertCommitsConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    revertCommitsConfirmed(){
      var message = {
        'projectId': this.projectId,
        'hash': this.hash
      }
      this.waiting = true
      this.$http.post(xHTTPx + '/revert_commits', message).then(response => {
        var path = '/projects/' + this.projectId + '/history'
        this.$router.push(path)
        this.waiting = false
      }, response => {
        this.waiting = false
        this.error = 'Failed to revert commits!'
      })
    },
    deleteHistory(){
      var message = 'Are you sure to delete ALL the history before this point, which is NOT reversible? '
      message += "Although it won't change the current state of the project, you will NOT be able to rollback to any points before this point then. It may take couple minutes to finish."
      var context = {callback: this.deleteHistoryConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteHistoryConfirmed(){
      var message = {
        'projectId': this.projectId,
        'hash': this.hash
      }
      this.waiting = true
      this.$http.post(xHTTPx + '/delete_history', message).then(response => {
        var path = '/projects/' + this.projectId + '/history'
        this.$router.push(path)
        this.waiting = false
      }, response => {
        this.waiting = false
        this.error = 'Failed to delete history!'
      })
    },
    openConfirmModal(message, context){
      this.confirmModal.message = message
      this.confirmModal.context = context
      this.confirmModal.opened = true
    },
    closeConfirmModal(result){
      this.confirmModal.message = ''
      this.confirmModal.opened = false
      if(result && this.confirmModal.context){
        var context = this.confirmModal.context
        if(context.callback){
            context.callback.apply(this, context.args)
        }
      }
      this.confirmModal.context = null
    },
  },
  mounted () {
    this.$nextTick(function(){
      this.requestCommit()
      if(!this.project){
        this.requestProject()
      }
    })
  }
}
</script>

<style lang="scss">
.history-page {
  padding: 10px;
}

.commit-content{
  padding: 10px;

  .commit-description {
    font-size: 20px;
    margin-bottom: 10px;
  }

  .commit-diff {
    font-weight: bold;
    padding-top: 20px;
  }

  .commit-lines {
    color: blue;
  }

  .commit-plus {
    color: green;
  }

  .commit-minus {
    color: red;
  }
}

.commit-buttons {
  text-align: right;
}


</style>
