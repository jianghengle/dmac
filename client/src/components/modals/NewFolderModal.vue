<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New Folder</p>
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
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!newNameValid" @click="create">Create</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'new-folder-modal',
  props: ['opened', 'role', 'files', 'projectId', 'dataPath'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: ''
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
      var newName = this.newName.trim()
      var len = newName.length
      if(len > 255) return false
      var re = /^[a-zA-Z0-9\._-~]+$/
      if(!re.test(newName)) return false
      if(newName[0] == '-' || newName[len-1] == '-') return false
      if(newName.indexOf('..') > -1) return false
      if(newName[len-1] == '.') return false
      if(this.role == 'Editor' && (newName[0] == '.' || newName[0] == '_' || newName[0] == '~')) return false
      if(this.nameMap[newName]) return false
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
      this.$emit('close-new-folder-modal', false)
    },
    create(){
      if(!this.newNameValid) return
      var vm = this
      vm.waiting = true
      var dataPath = vm.newName.trim()
      if(vm.dataPath != '-root-'){
        dataPath = vm.dataPath + '--' + dataPath
      }
      var message = {projectId: vm.projectId, dataPath:  dataPath}
      vm.$http.post(xHTTPx + '/create_folder', message).then(response => {
        vm.waiting= false
        vm.$emit('close-new-folder-modal', true)
      }, response => {
        vm.error = 'Failed to create folder!'
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