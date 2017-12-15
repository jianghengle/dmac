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
        || JSON.stringify(this.oldMetaValues) != JSON.stringify(this.metaValues)
    },
    metaValues () {
      return this.metaData.map(function(m){
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
      var vm = this
      vm.waiting = true
      var message = {id: vm.project.id, name: vm.newName, description: vm.newDescription, status: vm.newStatus, metaDataFile: vm.metaDataFile, metaData: vm.metaValues.join('\t')}
      vm.$http.post(xHTTPx + '/update_project', message).then(response => {
        vm.waiting= false
        this.$emit('close-edit-project-modal', true)
      }, response => {
        vm.error = 'Failed to update project!'
        vm.waiting= false
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
          this.oldMetaValues.push(value)
        }
        this.metaDataFile = 'meta.txt'
      }, response => {
        this.metaDataFile = ''
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
</style>