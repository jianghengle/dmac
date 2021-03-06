<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
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
                <div v-if="meta.type == 'string'" class="field">
                  <div class="control">
                    <input class="input" type="text" v-model="meta.value">
                  </div>
                </div>
                <div v-if="meta.type == 'select'" class="field">
                  <div class="control">
                    <div class="select">
                      <select v-model="meta.value">
                        <option v-for="option in meta.options" v-bind:value="option.value">{{option.text}}</option>
                      </select>
                    </div>
                    <input v-if="meta.value == '__other__'" class="input other-input" type="text" placeholder="Please specify..." v-model="meta.otherValue">
                  </div>
                </div>
                <div v-if="meta.type == 'checkboxes'" class="field">
                  <div class="control checkbox-control">
                    <label v-for="item in meta.items" class="checkbox checkbox-label">
                      <input type="checkbox" :value="item" v-model="meta.value">
                      {{item}}
                    </label>
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
      if(vm.dataPath != '/'){
        dataPath = vm.dataPath + dataPath
      }
      var metaDataValues = vm.metaData.map(function(m){
        if(m.type == 'select' && m.value == '__other__')
          return m.otherValue
        if(m.type == 'checkboxes')
          return m.value.join(', ')
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
          var value = ''
          if(i < values.length) value = values[i]
          this.metaData.push(this.parseMeta(header, value))
        }
      }, response => {
        this.waiting= false
      })
    },
    parseMeta(header, value){
      var codeStart = header.indexOf('{')
      var codeEnd = header.indexOf('}')
      if(codeStart == -1 || codeEnd == -1 || codeStart >= codeEnd){
        return { name: header, type: 'string', value: value }
      }
      var name = header.slice(0, codeStart).trim()
      var code = header.slice(codeStart+1, codeEnd)

      if(code.includes('|')){
        var options = []
        code.split('|').forEach(function(s){
          var opt = s.trim()
          if(opt){
            options.push({text: opt, value: opt})
          }
        })
        if(options.length && options[options.length - 1].text == '*'){
          options[options.length - 1] = {text: 'Other', value: '__other__'}
        }
        var hasValue = false
        for(var i=0;i<options.length;i++){
          if(value == options[i].value){
            hasValue = true
            break
          }
        }
        if(hasValue){
          return {name: name, type: 'select', value: value, options: options, otherValue: ''}
        }
        if(!options.length || options[options.length-1].value != '__other__'){
          options.push({text: 'Other', value: '__other__'})
        }
        return {name: name, type: 'select', value: '__other__', options: options, otherValue: value}
      }

      if(code.includes(',')){
        var items = []
        code.split(',').forEach(function(s){
          var item = s.trim()
          if(item) items.push(item)
        })
        var values = []
        value.split(',').forEach(function(s){
          var v = s.trim()
          if(v && items.includes(v)) values.push(v)
        })
        return {name: name, type: 'checkboxes', items: items, value: values}
      }
      return {name: header, type: 'string', value: header}
    },
  },
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.wide-modal {
  width: 800px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}

.other-input {
  margin-top: 5px;
}

.checkbox-control {
  margin-top: 6px
}

.checkbox-label {
  margin-right: 10px;
}
</style>
