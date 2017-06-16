<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Project</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Name</label>
            <p class="control">
              <input class="input" type="text" v-model="newName">
            </p>
          </div>
          <div class="field">
            <label class="label">Status</label>
            <p class="control">
              <span class="select">
                <select v-model="newStatus">
                  <option>Active</option>
                  <option>Archived</option>
                </select>
              </span>
            </p>
          </div>
          <div class="field">
            <label class="label">Description</label>
            <p class="control">
              <textarea class="textarea" v-model="newDescription"></textarea>
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger"
            v-if="project && project.projectRole=='Owner'"
            :class="{'is-loading': waiting}"
            :disabled="projectChanged"
            @click="deleteProject">
            Delete
          </a>
          <a class="button is-info"
            :class="{'is-loading': waiting}"
            :disabled="!newName.length || !projectChanged"
            @click="update">
            Update
          </a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
      <confirm-modal
        :opened="confirmModal.opened"
        :message="confirmModal.message"
        @close-confirm-modal="closeConfirmModal">
      </confirm-modal>
    </div>
</template>

<script>
import ConfirmModal from './ConfirmModal'

export default {
  name: 'edit-project-modal',
  components: {
    ConfirmModal,
  },
  props: ['opened', 'project'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      newDescription: '',
      newStatus: '',
      confirmModal: {
        opened: false,
        message: '',
        context: null
      }
    }
  },
  computed: {
    projectChanged () {
      if(!this.project) return false
      return this.project.name != this.newName
        || this.project.description != this.newDescription
        || this.project.status != this.newStatus
    },
  },
  watch: {
    opened: function (val) {
      if (val) {
        this.newName = this.project.name
        this.newDescription = this.project.description
        this.newStatus = this.project.status
      }
    }
  },
  methods: {
    close(){
      this.$emit('close-edit-project-modal', false)
    },
    update(){
      if(!this.newName.length || !this.projectChanged) return
      var vm = this
      vm.waiting = true
      var message = {id: vm.project.id, name: vm.newName, description: vm.newDescription, status: vm.newStatus}
      vm.$http.post(xHTTPx + '/update_project', message).then(response => {
        vm.waiting= false
        this.$emit('close-edit-project-modal', true)
      }, response => {
        vm.error = 'Failed to update project!'
        vm.waiting= false
      })
    },
    deleteProject(){
      if(this.projectChanged) return
      var message = 'Are you sure to delete this project and all its data inside'
      var context = {callback: this.deleteProjectConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteProjectConfirmed(){
      var vm = this
      vm.waiting = true
      var message = {id: this.project.id}
      vm.$http.post(xHTTPx + '/delete_project', message).then(response => {
        vm.waiting = false
        this.$emit('close-edit-project-modal', 'deleted')
      }, response => {
        vm.error = 'Failed to delete project!'
        vm.waiting = false
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