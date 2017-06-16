<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit User</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Email</label>
            <p class="control">
              <input class="input" type="text" v-model="newEmail">
            </p>
          </div>
          <div class="field">
            <label class="label">Role</label>
            <p class="control">
              <span class="select">
                <select v-model="newRole">
                  <option v-for="opt in roleOptions">{{opt}}</option>
                </select>
              </span>
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteUser">Delete</a>
          <a class="button is-info" :class="{'is-loading': waiting}" :disabled="!changeValid" @click="updateUser">Update</a>
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

const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

export default {
  name: 'edit-user-modal',
  components: {
    ConfirmModal,
  },
  props: ['opened', 'users', 'isOwner', 'user'],
  data () {
    return {
      error: '',
      waiting: false,
      newEmail: '',
      newRole: '',
      confirmModal: {
        opened: false,
        message: '',
        context: null
      }
    }
  },
  computed: {
    roleOptions () {
      if(this.isOwner)
        return ['Admin', 'Editor', 'Viewer']
      return ['Editor', 'Viewer']
    },
    userMap () {
      var um = {}
      this.users.forEach(function(u){
        um[u.email] = u
      })
      return um
    },
    changeValid () {
      if(!emailRegex.test(this.newEmail)){
        return false
      }
      if(this.user.role == this.newRole){
        return !this.userMap[this.newEmail]
      }
      return !this.userMap[this.newEmail] || this.newEmail == this.user.email
    },
    changed () {
      if(!this.user) return false
      var changed = this.newEmail != this.user.email || this.newRole != this.user.role
      return changed
    }
  },
  watch: {
    opened: function (val) {
      if(val && this.user){
        this.newEmail = this.user.email
        this.newRole = this.user.role
        this.error = ''
      }
    },
  },
  methods: {
    close(){
      this.newEmai = ''
      this.$emit('close-edit-user-modal', null)
    },
    updateUser(){
      if(!this.changeValid) return
      var vm = this
      vm.newEmail = vm.newEmail.toLowerCase()
      vm.waiting = true
      var message = {projectId: vm.user.projectId, id: vm.user.id, email: vm.newEmail, role: vm.newRole}
      vm.$http.post(xHTTPx + '/update_project_control', message).then(response => {
        var resp = response.body
        vm.waiting= false
        this.$emit('close-edit-user-modal', resp)
      }, response => {
        vm.error = 'Failed to udpate user!'
        vm.waiting= false
      })
    },
    deleteUser(){
      if(this.changed) return
      var message = 'Are you sure to delete this user: ' + this.user.email + ' ?'
      var context = {callback: this.deleteUserConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteUserConfirmed(){
      var vm = this
      vm.waiting = true
      var message = {projectId: vm.user.projectId, id: vm.user.id}
      vm.$http.post(xHTTPx + '/delete_project_control', message).then(response => {
        vm.waiting= false
        this.$emit('close-edit-user-modal', {id: vm.user.id, deleted: true})
      }, response => {
        vm.error = 'Failed to udpate user!'
        vm.waiting= false
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
    if(this.user){
      this.newEmail = this.user.email
      this.newRole = this.user.role
    }
  }
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