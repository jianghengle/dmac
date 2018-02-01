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
          <div class="field">
            <label class="label">Copy From</label>
            <div class="control">
              <div class="select">
                <select v-model="copyFromDataPath">
                  <option v-for="option in copyOptions" v-bind:value="option.dataPath">
                    {{ option.name }}
                  </option>
                </select>
              </div>
            </div>
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
      permissions: ['Normal', 'Readonly', 'Hidden'],
      newPermission: 'Normal',
      permissionTip: "Permission for Editors and Viewers: Normal - Editor (read/write), Viewer (read); Readonly - Editor/Viewer (readonly); Hidden - Editor/Viewer (hidden)",
      copyFromDataPath: '',
    }
  },
  computed: {
    newNameValid () {
      var newName = this.newName.trim()
      var len = newName.length
      if(len == 0 || len > 255) return false
      if(newName[0] == "." || newName[len-1] == ".") return false
      return true
    },
    copyOptions () {
      if(this.files){
        var options = this.files.filter(function(f){
          return f.type == 'file'
        })
        options.unshift({name: '(None)', dataPath: ''})
        return options
      }
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.newName = ''
        this.error = ''
        this.copyFromDataPath = ''
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-new-file-modal', false)
    },
    create(){
      if(!this.newNameValid) return
      this.waiting = true
      var dataPath = '/' + this.newName.trim()
      if(this.dataPath != '/'){
        dataPath = this.dataPath + dataPath
      }
      var message = {projectId: this.projectId, dataPath:  dataPath, permission: this.newPermission, copyFromDataPath: this.copyFromDataPath}
      this.$http.post(xHTTPx + '/create_file', message).then(response => {
        this.waiting= false
        this.$emit('close-new-file-modal', true)
      }, response => {
        this.error = 'Failed to create file!' + JSON.stringify(response.body)
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