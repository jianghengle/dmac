<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New File</p>
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
              <input v-if="opened" class="input" type="text" v-model="newName" v-focus @keyup.enter="create">
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
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!newNameValid" @click="create">Create</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'new-file-modal',
  props: ['opened', 'role', 'files', 'projectId', 'dataPath'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      nameTip: "Name must be less or equal than 255 charactors and do not start or end with '.'",
      permissions: ['Normal', 'Read', 'Hidden'],
      newPermission: 'Normal',
      permissionTip: "Permission for Editors and Viewers: Normal - Editor (read/write), Viewer (read); Read - Editor/Viewer (readonly); Hidden - Editor/Viewer (hidden)"
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
      if(this.nameMap[newName]) return false
      if(newName[0] == "." || newName[len-1] == ".") return false
      return true
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.newName = ''
        this.error = ''
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-new-file-modal', false)
    },
    create(){
      if(!this.newNameValid) return
      var vm = this
      vm.waiting = true
      var dataPath = '/' + vm.newName.trim()
      if(vm.dataPath != '/'){
        dataPath = vm.dataPath + dataPath
      }
      var message = {projectId: vm.projectId, dataPath:  dataPath, permission: vm.newPermission}
      vm.$http.post(xHTTPx + '/create_file', message).then(response => {
        vm.waiting= false
        vm.$emit('close-new-file-modal', true)
      }, response => {
        vm.error = 'Failed to create file!'
        vm.waiting= false
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