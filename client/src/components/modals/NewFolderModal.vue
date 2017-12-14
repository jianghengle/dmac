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

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Name</label>
            </div>
            <div class="field-body">
              <div class="field">
                <div class="control">
                  <input class="input" type="text" v-model="newName">
                </div>
                <p class="help is-info">{{nameTip}}</p>
              </div>
            </div>
          </div>

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Permission</label>
            </div>
            <div class="field-body">
              <div class="field is-narrow">
                <div class="control">
                  <div class="select">
                    <select v-model="newPermission">
                      <option v-for="opt in permissions">{{opt}}</option>
                    </select>
                  </div>
                </div>
                <p class="help is-info">{{permissionTip}}</p>
              </div>
            </div>
          </div>

          <div class="meta-fields">
            <div class="field is-horizontal meta-field">
              <div class="field-label is-normal">
                <label class="label">Copy From</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <span class="select">
                      <select v-model="copyFromDataPath">
                        <option v-for="option in folders" v-bind:value="option.dataPath">
                          {{ option.name }}
                        </option>
                      </select>
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="field is-horizontal meta-field" v-for="meta in metaData">
              <div class="field-label is-normal">
                <label class="label">{{meta.name}}</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <div v-if="meta.options">
                      <div class="select">
                        <select v-model="meta.value">
                          <option v-for="option in meta.options">{{option}}</option>
                        </select>
                      </div>
                    </div>
                    <div v-else>
                      <input class="input" type="text" v-model="meta.value">
                    </div>
                  </div>
                </div>
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
  name: 'new-folder-modal',
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
      metaData: []
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
    },
    folders () {
      if(this.files){
        var folders = this.files.filter(function(f){
          return f.type == 'folder'
        })
        folders.unshift({name: '(None)', dataPath: ''})
        return folders
      }
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.newName = ''
        this.error = ''
        this.copyFromDataPath = ''
        this.metaData = []
      }
    },
    copyFromDataPath: function(val) {
      if(val){
        this.requestMetaData(val)
      }
    }
  },
  methods: {
    close(){
      this.$emit('close-new-folder-modal', false)
    },
    create(){
      if(!this.newNameValid) return
      var vm = this
      vm.waiting = true
      var dataPath = '/' + vm.newName.trim()
      if(vm.dataPath != ''){
        dataPath = vm.dataPath + dataPath
      }
      var metaDataValues = vm.metaData.map(function(m){
        return m.value
      })
      var message = {projectId: vm.projectId, dataPath:  dataPath, permission: vm.newPermission,
        copyFromDataPath: vm.copyFromDataPath, metaData: metaDataValues.join('\t')}
      vm.$http.post(xHTTPx + '/create_folder', message).then(response => {
        vm.waiting= false
        vm.$emit('close-new-folder-modal', true)
      }, response => {
        vm.error = 'Failed to create folder!'
        vm.waiting= false
      })
    },
    requestMetaData(dp){
      this.metaData = []
      this.waiting= true
      var dataPath = encodeURIComponent(dp)
      dataPath = encodeURIComponent(dataPath)
      this.$http.get(xHTTPx + '/get_meta_by_data_path/' + this.projectId + '/' + dataPath).then(response => {
        this.waiting= false
        var lines = response.body
        var headers = []
        if(lines.length > 0){
          headers = lines[0].split('\t')
        }
        var values = []
        if(lines.length > 1){
          values = lines[1].split('\t')
        }
        for(var i=0;i<headers.length;i++){
          var header = headers[i]
          var optionsStart = header.indexOf('{')
          var optionsEnd = header.indexOf('}')
          var name = ''
          var options = null
          var value = ''
          if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
            name = header
          }else{
            name = header.slice(0, optionsStart).trim()
            options = header.slice(optionsStart+1, optionsEnd).split('|').map(function(s){
              return s.trim()
            })
          }
          if(i < values.length){
            value = values[i]
          }
          this.metaData.push({name: name, value: value, options: options})
        }
      }, response => {
        this.waiting= false
      })
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