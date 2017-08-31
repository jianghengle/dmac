<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Channel</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
            <button class="delete" @click="error=''"></button>
              {{error}}
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
            <label class="label">Instruction</label>
            <p class="control">
              <textarea class="textarea" v-model="instruction"></textarea>
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

        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!canUpdate" @click="update">Update</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'edit-channel-modal',
  props: ['opened', 'project', 'channel'],
  data () {
    return {
      error: '',
      waiting: false,
      folderOptions: [],
      targetFolder: null,
      fileOptions: [],
      metadataFile: '',
      instruction: '',
      rename: true,
    }
  },
  computed: {
    canUpdate () {
      return this.project && this.channel &&
        (this.targetFolder != this.channel.path
        || this.metadataFile != this.channel.metaData
        || this.instruction != this.channel.instruction
        || this.rename != this.channel.rename)
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.folderOptions = []
        this.targetFolder = this.channel.path
        this.fileOptions = []
        this.metadataFile = this.channel.metaData
        this.instruction = this.channel.instruction
        this.rename = this.channel.rename
        this.requestFolders()
        this.requestFiles()
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
      this.$emit('close-edit-channel-modal', false)
    },
    requestFolders(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_directories/' + this.project.id).then(response => {
        this.waiting= false
        this.folderOptions = response.body.map(function(f){
          var path = f.replace(/\//g, '--')
          return {
            name: f,
            path: f.replace(/\//g, '--')
          }
        })
        this.targetFolder = this.channel.path
      }, response => {
        this.error = 'Failed to get folders!'
        this.waiting= false
      })
    },
    requestFiles(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_files/' + this.project.id + '/' + this.targetFolder).then(response => {
        this.waiting= false
        this.fileOptions = response.body.map(function(f){
          return { name: f, value: f }
        })
        this.fileOptions.unshift({name: '(None)', value: ''})
        this.metadataFile = this.channel.metaData
      }, response => {
        this.error = 'Failed to get files!'
        this.waiting= false
      })
    },
    update(){
      this.waiting= true
      var message = { projectId: this.project.id, id: this.channel.id, path: this.targetFolder, metaData: this.metadataFile, instruction: this.instruction, rename: this.rename }
      this.$http.post(xHTTPx + '/update_channel', message).then(response => {
        this.waiting= false
        this.$emit('close-edit-channel-modal', true)
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