<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New Meta Data File</p>
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
          <div class="field">
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
            <label class="label">Fields</label>
            <div class="control" v-for="(field, i) in fields" :key="'field-'+i">
              <div class="columns">
                <div class="column field-column">
                  <input class="input" type="text" :placeholder="'Name'" v-model="field.name">
                </div>
                <div class="column middle-column">
                  <input class="input" type="text" placeholder="Options" v-model="field.options">
                </div>
                <div class="column field-column">
                  <input class="input" type="text" placeholder="Value" v-model="field.value">
                </div>
              </div>
            </div>
            <div class="field-button">
              <a class="button" @click="addField">
                <icon name="plus"></icon>&nbsp;&nbsp;Field
              </a>
              &nbsp;
              <a class="button button-right" @click="removeField">
                <icon name="minus"></icon>&nbsp;&nbsp;Field
              </a>
            </div>
            <p class="help is-info">{{fieldTip}}</p>
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
  name: 'new-meta-modal',
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
      fields: [],
      fieldTip: "Leave entry empty if not appliable. Options must be seperated by '|', e.g. \"opt1 | opt2 | *\". Use '|*' to add an \"Other\" option for be specified. If you want to make multiple checkable options, use ',' to seperate the options, e.g. \"opt1, opt2\". If this is a channel meta data file, and you want to add a field for uploading a file, fill the \"Option\" with \"file\". You could also specify the file types to be accepted by filling the \"Option\" with e.g.\"file: .txt, .pdf, .xls\"."
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
        this.newName = 'meta.txt'
        this.error = ''
        this.fields = []
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-new-meta-modal', false)
    },
    create(){
      if(!this.newNameValid) return
      var vm = this
      vm.waiting = true
      var dataPath = '/' + vm.newName.trim()
      if(vm.dataPath != '/'){
        dataPath = vm.dataPath + dataPath
      }
      var row1 = []
      var row2 = []
      this.fields.forEach(function(f){
        var name = f.name.trim()
        if(!name.length)
          return
        var c1 = name
        var options = f.options.trim()
        if(options.length)
          c1 += ' {' + options + '}'
        row1.push(c1)
        row2.push(f.value.trim())
      })
      var content = ''
      if(row1.length){
        content = row1.join('\t')
        var empty = true
        for(var i=0;i<row2.length;i++){
          if(row2[i].length){
            empty = false
            break
          }
        }
        if(!empty)
          content += '\n' + row2.join('\t')
      }
      var message = {projectId: vm.projectId, dataPath:  dataPath, permission: vm.newPermission, content: content, copyFromDataPath: ''}
      vm.$http.post(xHTTPx + '/create_file', message).then(response => {
        vm.waiting= false
        vm.$emit('close-new-meta-modal', true)
      }, response => {
        vm.error = 'Failed to create meta data file!'
        vm.waiting= false
      })
    },
    addField(){
      var field = {name: '', options: '', value: ''}
      this.fields.push(field)
    },
    removeField() {
      if(!this.fields.length)
        return
      this.fields.splice(this.fields.length-1, 1)
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

.middle-column {
  padding-left: 0px;
  padding-right: 0px;
}

.field-button {
  margin-top: 10px;
}
</style>
