<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Folder / File</p>
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
            <p class="help is-info">{{nameTip}}</p>
          </div>
          <div class="field" v-if="role=='Owner' || role=='Admin'">
            <label class="label">Permission</label>
            <p class="control">
              <span class="select">
                <select v-model="newPermission">
                  <option v-for="opt in permissions">{{opt}}</option>
                </select>
              </span>
            </p>
            <p class="help is-info">{{permissionTip}}</p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteFile">Delete</a>
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!changed" @click="updateName">Update</a>
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
  name: 'edit-name-modal',
  components: {
    ConfirmModal,
  },
  props: ['opened', 'role', 'files', 'file'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      confirmModal: {
        opened: false,
        message: '',
        context: null
      },
      permissions: ['Normal', 'Readonly', 'Hidden'],
      newPermission: 'Normal',
      nameTip: "Name must be less or equal than 255 charactors and not start or end with '.'",
      permissionTip: "Permission for Editors and Viewers: Normal - Editor (read/write), Viewer (read); Readonly - Editor/Viewer (readonly); Hidden - Editor/Viewer (hidden)"
    }
  },
  computed: {
    nameMap () {
      if(!this.files) return {}
      var nm = {}
      this.files.forEach(function(f){
        nm[f.name] = true
      })
      return nm
    },
    newNameValid () {
      var newName = this.newName.trim()
      var len = newName.length
      if(len == 0 || len > 255) return false
      if(newName[0] == '.' || newName[len-1] == '.') return false
      if(this.nameMap[newName]) return false
      return true
    },
    oldPermission () {
      return this.file && this.permissions[this.file.access]
    },
    changed () {
      if(!this.file) return false
      var nameChanged = this.file.name != this.newName.trim()
      var permissionChanged = this.newPermission != this.oldPermission
      return nameChanged || permissionChanged
    }
  },
  watch: {
    opened: function (val) {
      if(val && this.file){
        this.newName = this.file.name
        this.error = ''
        this.newPermission = this.permissions[this.file.access]
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-edit-name-modal', false)
    },
    updateName(){
      if(!this.changed) return
      var vm = this
      vm.waiting = true
      var message = {projectId: vm.file.projectId, dataPath: vm.file.dataPath, newName: vm.newName.trim(),
        newPermission: vm.newPermission, oldPermission: vm.oldPermission}
      vm.$http.post(xHTTPx + '/update_folder_file_name', message).then(response => {
        var resp = response.body
        vm.waiting= false
        this.$emit('close-edit-name-modal', true)
      }, response => {
        vm.error = 'Failed to udpate user!'
        vm.waiting= false
      })
    },
    deleteFile(){
      if(this.changed) return
      var message = 'Are you sure to delete this ' + this.file.type + ": " + this.file.name + ' ?'
      var context = {callback: this.deleteFileConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteFileConfirmed(){
      var vm = this
      vm.waiting = true
      var message = {projectId: vm.file.projectId, dataPath: vm.file.dataPath}
      vm.$http.post(xHTTPx + '/delete_folder_file', message).then(response => {
        vm.waiting= false
        this.$emit('close-edit-name-modal', 'deleted')
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
      this.newName = this.file.name
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