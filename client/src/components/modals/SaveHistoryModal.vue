<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New History Record</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Record</label>
            <p class="control">
              <input v-if="opened" class="input" type="text" v-model="commitMessage" v-focus @keyup.enter="commit">
            </p>
            <p class="help is-info">
              This will create a new history record from the whole project current state.
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!commitMessage" @click="commit">Submit</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'save-history-modal',
  props: ['opened', 'projectId'],
  data () {
    return {
      error: '',
      waiting: false,
      commitMessage: ''
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.commitMessage = ''
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-save-history-modal', false)
    },
    commit(){
      if(!this.commitMessage) return
      this.waiting = true
      var message = {projectId: this.projectId, commitMessage:  this.commitMessage}
      this.$http.post(xHTTPx + '/commit_history', message).then(response => {
        this.waiting= false
        this.$emit('close-save-history-modal', true)
      }, response => {
        this.error = JSON.stringify(response.body)
        this.waiting= false
      })
    }
  },
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}
</style>