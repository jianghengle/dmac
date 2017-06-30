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
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteFile">Delete</a>
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!newNameValid" @click="updateName">Update</a>
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
      }
    }
  },
  computed: {
    nameTip () {
      if(this.role == 'Editor'){
        return "Name must be less or equal than 255 charactors and only contain charactors from 'a'~'z', '0'~'9', '.', '_' and '-', and it must not start or end with '.' or '-' or '_' or '~' or contain '--'"
      }
      return "Name must be less or equal than 255 charactors and only contain charactors from 'a'~'z', '0'~'9', '.', '_' and '-', and it must not start with '-' or end with '-' or contain '--'"
    },
    nameMap () {
      if(!this.files) return {}
      var nm = {}
      this.files.forEach(function(f){
        nm[f.name] = true
      })
      return nm
    },
    newNameValid () {
      var len = this.newName.length
      if(len > 255) return false
      var re = /^[a-zA-Z0-9\._-~]+$/
      if(!re.test(this.newName)) return false
      if(this.newName[0] == '-' || this.newName[len-1] == '-') return false
      if(this.newName.indexOf('..') > -1) return false
      if(this.newName[len-1] == '.') return false
      if(this.role == 'Editor' && (this.newName[0] == '.' || this.newName[0] == '_' || this.newName[0] == '~')) return false
      if(this.nameMap[this.newName]) return false
      return true
    },
    changed () {
      return this.file && this.file.name != this.newName
    }
  },
  watch: {
    opened: function (val) {
      if(val && this.file){
        this.newName = this.file.name
        this.error = ''
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-edit-name-modal', false)
    },
    updateName(){
      if(!this.newNameValid) return
      var vm = this
      vm.waiting = true
      var message = {projectId: vm.file.projectId, dataPath: vm.file.dataPath, newName: vm.newName}
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