<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Folder</p>
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
                <label class="label">Meta Data</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input is-static" type="text" :value="metaDataFile || '(None)'" readonly>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="metaDataFile">
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
          </div>

        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteFile">Delete</a>
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!changed" @click="updateFolder">Update</a>
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
  name: 'edit-folder-modal',
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
      permissionTip: "Permission for Editors and Viewers: Normal - Editor (read/write), Viewer (read); Readonly - Editor/Viewer (readonly); Hidden - Editor/Viewer (hidden)",
      metaDataFile: '',
      metaData: [],
      oldMetaValues: [],
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
    metaValues () {
      return this.metaData.map(function(m){
        if(m.type == 'select' && m.value == '__other__')
          return m.otherValue
        if(m.type == 'checkboxes')
          return m.value.join(', ')
        return m.value
      })
    },
    changed () {
      if(!this.file) return false
      var nameChanged = this.file.name != this.newName.trim()
      var permissionChanged = this.newPermission != this.oldPermission
      var metaChanged = JSON.stringify(this.oldMetaValues) != JSON.stringify(this.metaValues)
      return nameChanged || permissionChanged || metaChanged
    }
  },
  watch: {
    opened: function (val) {
      if(val && this.file){
        this.newName = this.file.name
        this.error = ''
        this.newPermission = this.permissions[this.file.access]
        this.requestMetaData()
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-edit-folder-modal', false)
    },
    updateFolder(){
      if(!this.changed) return
      this.waiting = true
      var message = {projectId: this.file.projectId, dataPath: this.file.dataPath, newName: this.newName.trim(),
        newPermission: this.newPermission, oldPermission: this.oldPermission, 
        metaDataFile: this.metaDataFile, metaData: this.metaValues.join('\t')}
      this.$http.post(xHTTPx + '/update_folder', message).then(response => {
        var resp = response.body
        this.waiting= false
        this.$emit('close-edit-folder-modal', this.newName.trim())
      }, response => {
        this.error = 'Failed to udpate folder!'
        this.waiting= false
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
        this.$emit('close-edit-folder-modal', '.deleted.')
      }, response => {
        vm.error = 'Failed to udpate folder!'
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
    requestMetaData(){
      this.metaDataFile = ''
      this.metaData = []
      this.oldMetaValues = []
      this.waiting= true
      var dataPath = encodeURIComponent(this.file.dataPath)
      dataPath = encodeURIComponent(dataPath)
      this.$http.get(xHTTPx + '/get_meta_by_data_path/' + this.file.projectId + '/' + dataPath).then(response => {
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
          this.oldMetaValues.push(value)
        }
        this.metaDataFile = 'meta.txt'
      }, response => {
        this.metaDataFile = ''
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
  }
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
