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

          <div class="channel-details">

            <div class="field is-horizontal channel-field">
              <div class="field-label is-normal">
                <label class="label">Folder</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input field-text" type="text" readonly :value="channel && channel.path">
                  </div>
                </div>
              </div>
            </div>

            <div class="field is-horizontal channel-field" v-if="channel && channel.metaData">
              <div class="field-label is-normal">
                <label class="label">Metadata</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input field-text" type="text" readonly :value="channel.metaData">
                  </div>
                </div>
              </div>
            </div>

            <div class="field is-horizontal channel-field">
              <div class="field-label is-normal">
                <label class="label">Instruction</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <textarea class="textarea field-text" readonly>{{channel && channel.instruction}}</textarea>
                  </div>
                </div>
              </div>
            </div>

          </div>


          <div v-if="error" class="notification is-danger">
            <button class="delete" @click="error=''"></button>
              {{error}}
          </div>

          <div class="field file-field">
            <input v-if="opened" type="file" class="upload-file-input" multiple @change="onFileChange">
            &nbsp;
            <span v-if="channel" class="upload-info">
              Must Select <strong>{{channel.files}}</strong> File(s)
            </span>
            <div v-if="channel">
              <table class="table is-narrow">
                <tbody>
                  <tr v-for="(v, k) in uploads">
                    <td>{{v.filename}}</td>
                    <td v-if="channel.rename">
                      <input class="input" v-model="v.newName" type="text" placeholder="New Name">
                    </td>
                    <td>{{v.percentage}}%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="meta-fields">
            <div v-if="channel && channel.metaData">
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
      uploads: [],
      metaData: []
    }
  },
  computed: {
    canUpload () {
      if(!this.channel) return false
      if(this.uploads.length != this.channel.files) return false
      for(var i=0;i<this.uploads.length;i++){
        var upload = this.uploads[i]
        if(!upload.file || !upload.newName){
          return false
        }
      }
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
        this.uploads = []
        this.metaData = []
        if(this.channel && this.channel.metaData){
          this.requestMetaData()
        }
      }
    },
  },
  methods: {
    close(){
      this.uploads.forEach(function(upload){
        if(!upload.done && upload.request){
          upload.request.abort()
        }
      })
      this.$emit('close-upload-channel-modal', false)
    },
    requestMetaData(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_meta_by_channel/' + this.project.id + '/' + this.channel.id).then(response => {
        this.waiting= false
        this.metaData = response.body.map(function(m){
          var optionsStart = m.indexOf('{')
          var optionsEnd = m.indexOf('}')
          if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
            return { name: m, value: '' }
          }
          var name = m.slice(0, optionsStart).trim()
          var options = m.slice(optionsStart+1, optionsEnd).split('|').map(function(s){
            return s.trim()
          })
          return {name: name, value: '', options: options}
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
      var uploads = []
      for(var i=0;i<Math.min(files.length, this.channel.files);i++){
        var file = files[i]
        var upload = {
          file: file,
          filename: file.name,
          newName: file.name,
          size: file.size,
          loaded: 0,
          percentage: 0,
          done: false,
          request: null
        }
        uploads.push(upload)
      }
      this.uploads = uploads
    },
    upload(){
      if(!this.canUpload) return
      this.waiting = true

      var promises = []
      var vm = this
      this.uploads.forEach(function(upload){
        var formData = new FormData()
        formData.append('file', upload.file)
        formData.append('newName', upload.newName)
        var url = xHTTPx + '/upload_file_by_channel/' + vm.project.id + '/' + vm.channel.id
        var promise = vm.$http.post(url, formData, {
          before: request => {
            upload.request = request
          },
          progress: e => {
            upload.loaded = e.loaded
            upload.percentage = Math.round((e.loaded / e.total) * 100)
          }
        }).then((response) => {
          upload.loaded = upload.size
          upload.percentage = 100
          upload.done = true
          upload.request = null
        }, (response) => {
          upload.loaded = 0
          upload.percentage = 0
          upload.request = null
          return Promise.reject(JSON.stringify(response.body))
        })
        promises.push(promise)
      })

      Promise.all(promises).then((response) => {
        if(vm.channel && vm.channel.metaData){
          var url = xHTTPx + '/upload_meta_by_channel/' + vm.project.id + '/' + vm.channel.id
          var values = vm.metaData.map(function(d){
            return d.value
          })
          var message = { metaData:  values.join('\t')}
          this.$http.post(url, message).then(response => {
            this.waiting= false
            this.$emit('close-upload-channel-modal', true)
          }, response => {
            this.error = 'Error in uploading meta data ...'
            this.waiting= false
          })
        }else{
          this.waiting= false
          this.$emit('close-upload-channel-modal', true)
        }
      }, (response) => {
        vm.waiting = false
        vm.error = 'Error in uploading file: ' + response
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

.channel-details {
  margin-bottom: 20px;
}

.channel-field {
  margin-bottom: 0px;
}

.field-text {
  border-style: none;
  box-shadow: none;
  resize: none;
  position: relative;
  top: -2px;
}

.file-field {
  margin: 20px;
}

.upload-file-input {
  font-size: 14px;
}

.upload-info {
  font-size: 14px;
}

</style>