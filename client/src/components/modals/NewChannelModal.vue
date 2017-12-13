<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New Channel</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
            <button class="delete" @click="error=''"></button>
              {{error}}
          </div>

          <div class="field">
            <label class="label">Status</label>
            <p class="control">
              <span class="select">
                <select v-model="status">
                  <option>Open</option>
                  <option>Closed</option>
                </select>
              </span>
            </p>
          </div>

          <div class="field">
            <label class="label">Target Folder</label>
            <p class="control">
              <span class="select">
                <select v-model="targetFolder">
                  <option v-for="option in folderOptions" v-bind:value="option.path">
                    {{ option.name }}
                  </option>
                </select>
              </span>
            </p>
          </div>

          <div class="field">
            <label class="label">Metadata File</label>
            <p class="control">
              <span class="select">
                <select v-model="metadataFile">
                  <option v-for="option in fileOptions" v-bind:value="option.value">
                    {{ option.name }}
                  </option>
                </select>
              </span>
            </p>
          </div>

          <div class="field">
            <label class="label">Files per Upload</label>
            <p class="control">
              <span class="select">
                <select v-model="filesUpload">
                  <option>1</option>
                  <option>2</option>
                  <option>3</option>
                  <option>4</option>
                  <option>5</option>
                </select>
              </span>
            </p>
          </div>

          <div class="field">
            <p class="control">
              <label class="checkbox">
                <input type="checkbox" v-model="rename">
                Rename uploaded file
              </label>
            </p>
          </div>

          <div class="field">
            <label class="label">Instruction</label>
            <p class="control">
              <textarea class="textarea" v-model="instruction"></textarea>
            </p>
          </div>

        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!canCreate" @click="create">Create</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'new-channel-modal',
  props: ['opened', 'project'],
  data () {
    return {
      error: '',
      waiting: false,
      folderOptions: [],
      targetFolder: null,
      fileOptions: [],
      metadataFile: '',
      instruction: '',
      filesUpload: 1,
      rename: true,
      status: 'Open'
    }
  },
  computed: {
    canCreate () {
      return this.project && this.targetFolder
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.folderOptions = []
        this.targetFolder = null
        this.fileOptions = []
        this.metadataFile = ''
        this.requestFolders()
      }
    },
    targetFolder: function (val) {
      if(val) {
        this.requestFiles()
      }
    }
  },
  methods: {
    close(){
      this.$emit('close-new-channel-modal', false)
    },
    requestFolders(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_directories/' + this.project.id).then(response => {
        this.waiting= false
        this.folderOptions = response.body.map(function(f){
          return {
            name: f,
            path: f
          }
        })
      }, response => {
        this.error = 'Failed to get folders!'
        this.waiting= false
      })
    },
    requestFiles(){
      this.waiting= true
      var dataPath = encodeURIComponent(this.targetFolder)
      dataPath = encodeURIComponent(dataPath)
      this.$http.get(xHTTPx + '/get_files/' + this.project.id + '/' + dataPath).then(response => {
        this.waiting= false
        this.fileOptions = response.body.map(function(f){
          return { name: f, value: f }
        })
        this.fileOptions.unshift({name: '(None)', value: ''})
        this.metadataFile = ''
      }, response => {
        this.error = 'Failed to get files!'
        this.waiting= false
      })
    },
    create(){
      this.waiting= true
      var message = { projectId: this.project.id, path: this.targetFolder, metaData: this.metadataFile, instruction: this.instruction, rename: this.rename, files: this.filesUpload, status: this.status }
      this.$http.post(xHTTPx + '/create_channel', message).then(response => {
        this.waiting= false
        this.$emit('close-new-channel-modal', true)
      }, response => {
        this.error = 'Failed to create channel!'
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