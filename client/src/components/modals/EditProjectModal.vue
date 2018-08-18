<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Project</p>
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
              </div>
            </div>
          </div>

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Status</label>
            </div>
            <div class="field-body">
              <div class="field is-narrow">
                <div class="control">
                  <div class="select">
                    <select v-model="newStatus">
                      <option>Active</option>
                      <option>Archived</option>
                      <option>Template</option>
                      <option>Public Template</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Description</label>
            </div>
            <div class="field-body">
              <div class="field">
                <div class="control">
                  <textarea class="textarea" v-model="newDescription"></textarea>
                </div>
              </div>
            </div>
          </div>

          <div class="field is-horizontal">
            <div class="field-label">
              <label class="label">History</label>
            </div>
            <div class="field-body">
              <div class="field">
                <div class="control">
                  <label class="checkbox">
                    <input type="checkbox" v-model="newAutoHistory">
                    &nbsp;Auto Save History
                  </label>
                </div>
                <p class="help is-info">
                  In spite of manually saving history, automatically save every edit as a history record.
                </p>
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
          <a class="button is-danger"
            v-if="project && project.projectRole=='Owner'"
            :class="{'is-loading': waiting}"
            :disabled="projectChanged"
            @click="deleteProject">
            Delete
          </a>
          <a class="button main-btn"
            :class="{'is-loading': waiting}"
            :disabled="!newName.length || !projectChanged"
            @click="update">
            Update
          </a>
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
  name: 'edit-project-modal',
  components: {
    ConfirmModal,
  },
  props: ['opened', 'project'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      newDescription: '',
      newStatus: '',
      newAutoHistory: false,
      metaDataFile: '',
      metaData: [],
      oldMetaValues: [],
      fileOptions: [],
      confirmModal: {
        opened: false,
        message: '',
        context: null
      }
    }
  },
  computed: {
    projectChanged () {
      if(!this.project) return false
      return this.project.name != this.newName
        || this.project.description != this.newDescription
        || this.project.status != this.newStatus
        || this.project.autoHistory != this.newAutoHistory
        || JSON.stringify(this.oldMetaValues) != JSON.stringify(this.metaValues)
    },
    metaValues () {
      return this.metaData.map(function(m){
        if(m.type == 'select' && m.value == '__other__')
          return m.otherValue
        if(m.type == 'checkboxes')
          return m.value.join(', ')
        return m.value
      })
    }
  },
  watch: {
    opened: function (val) {
      if (val) {
        this.newName = this.project.name
        this.newDescription = this.project.description
        this.newStatus = this.project.status
        this.newAutoHistory = this.project.autoHistory
        this.metaDataFile = ''
        this.metaData = []
        this.oldMetaValues = []
        this.requestMetaData()
      }
    }
  },
  methods: {
    close(){
      this.$emit('close-edit-project-modal', false)
    },
    update(){
      if(!this.newName.length || !this.projectChanged) return
      this.waiting = true
      var message = {
        id: this.project.id,
        name: this.newName,
        description: this.newDescription,
        status: this.newStatus,
        autoHistory: this.newAutoHistory,
        metaDataFile: this.metaDataFile,
        metaData: this.metaValues.join('\t')
      }
      this.$http.post(xHTTPx + '/update_project', message).then(response => {
        this.waiting= false
        this.$emit('close-edit-project-modal', true)
      }, response => {
        this.error = 'Failed to update project!'
        this.waiting= false
      })
    },
    deleteProject(){
      if(this.projectChanged) return
      var message = 'Are you sure to delete this project and all its data inside'
      var context = {callback: this.deleteProjectConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteProjectConfirmed(){
      var vm = this
      vm.waiting = true
      var message = {id: this.project.id}
      vm.$http.post(xHTTPx + '/delete_project', message).then(response => {
        vm.waiting = false
        this.$emit('close-edit-project-modal', 'deleted')
      }, response => {
        vm.error = 'Failed to delete project!'
        vm.waiting = false
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
      var dataPath = encodeURIComponent('/')
      dataPath = encodeURIComponent(dataPath)
      this.$http.get(xHTTPx + '/get_meta_by_data_path/' + this.project.id + '/' + dataPath).then(response => {
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

.meta-fields {
  margin-top: 20px;
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
