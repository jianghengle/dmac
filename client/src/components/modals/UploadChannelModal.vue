<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Upload Data</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">

          <div class="field">
            <label class="label">Target Folder: <span class="channel-info">{{channel && channel.relPath}}</span></label>
          </div>

          <div class="field" v-if="channel && channel.metaData">
            <label class="label">Metadata File: <span class="channel-info">{{channel.metaData}}</span></label>
          </div>

          <div class="field instruction-field">
            <label class="label">Instruction:</label>
            <p class="control">
              <textarea class="textarea field-text" :value="channel && channel.instruction" readonly></textarea>
            </p>
          </div>

          <div v-if="error" class="notification is-danger login-text">
            <button class="delete" @click="error=''"></button>
              {{error}}
          </div>

          <div v-if="success" class="notification is-success login-text">
            <button class="delete" @click="success=''"></button>
              {{success}}
          </div>

          <div class="field">
            <input v-if="opened" type="file" class="files-input" @change="onFileChange">
            &nbsp;
            <span class="upload-progress">Uploaded: {{percentage}}%</span>
          </div>

          <div class="field" v-if="channel && channel.rename">
            <label class="label">Rename File</label>
            <p class="control">
              <input class="input" type="text" v-model="newName">
            </p>
          </div>

          <div v-if="channel && channel.metaData">
            <div class="field" v-for="meta in metaData">
              <label class="label">{{meta.name}}</label>
              <p class="control">
                <input class="input" type="text" v-model="meta.value">
              </p>
            </div>
          </div>

        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!canUpload" @click="upload">Upload</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'upload-channel-modal',
  props: ['opened', 'channel', 'project'],
  data () {
    return {
      error: '',
      waiting: false,
      file: null,
      newName: '',
      metaData: [],
      percentage: 0,
      success: ''
    }
  },
  computed: {
    canUpload () {
      if(!this.channel) return false
      if(!this.file) return false
      if(this.channel.rename && !this.newName) return false
      if(this.channel.metaData){
        for(var i=0;i<this.metaData.length;i++){
          if(!this.metaData[i].value)
            return false
        }
      }
      return true
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.file = null
        this.newName = ''
        this.metaData = []
        this.percentage = 0
        this.success = ''
        if(this.channel && this.channel.metaData){
          this.requestMetaData()
        }
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-upload-channel-modal', false)
    },
    requestMetaData(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_metadata/' + this.project.id + '/' + this.channel.id).then(response => {
        this.waiting= false
        this.metaData = response.body.map(function(m){
          return { name: m, value: '' }
        })
      }, response => {
        this.error = 'Failed to get meta data!'
        this.waiting= false
      })
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      this.file = files[0]
    },
    upload(){
      if(!this.canUpload) return

      var formData = new FormData()
      formData.append('file', this.file)
      var values = this.metaData.map(function(d){
        return d.value
      })
      formData.append('metaData', values.join('\t'))
      formData.append('newName', this.newName)
      var url = xHTTPx + '/upload_channel/' + this.project.id + '/' + this.channel.id
      this.percentage = 0

      var vm = this
      vm.$http.post(url, formData, {
        progress: e => {
          vm.percentage = Math.round((e.loaded / e.total) * 100)
        }
      }).then((response) => {
        vm.percentage = 100
        vm.waiting = false
        vm.success = 'Succeed! You can continue uploading other file or exit.'
      }, (response) => {
        vm.percentage = 0
        vm.waiting = false
        vm.error = 'failed to upload file'
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

.channel-info {
  font-weight: normal;
}

.instruction-field {

}

.field-text {
  border-style: none;
  box-shadow: none;
  resize: none;
  position: relative;
  top: -15px;
}

.files-input {
  font-size: 14px;
}

.upload-progress {
  font-size: 14px;
}

</style>