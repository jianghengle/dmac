<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
        <header class="modal-card-head">
          <p class="modal-card-title">Channel</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">

          <div class="channel-details">

            <div class="field is-horizontal channel-field">
              <div class="field-label is-normal">
                <label class="label">Name</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input field-text is-static" type="text" readonly :value="channel && channel.name">
                  </div>
                </div>
              </div>
            </div>

            <div class="field is-horizontal channel-field">
              <div class="field-label is-normal">
                <label class="label">Folder</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input field-text is-static" type="text" readonly :value="channel && channel.path">
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
                    <input class="input field-text is-static" type="text" readonly :value="channel.metaData">
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
                    <textarea class="textarea field-text is-static" readonly>{{channel && channel.instruction}}</textarea>
                  </div>
                </div>
              </div>
            </div>

          </div>


          <div v-if="error" class="notification is-danger">
            <button class="delete" @click="error=''"></button>
              {{error}}
          </div>

          <div class="meta-fields">
            <div v-if="channel && channel.metaData">
              <div class="field is-horizontal meta-field" v-for="(meta, i) in metaData">
                <div class="field-label is-normal">
                  <label class="label">{{meta.name}}</label>
                </div>

                <div class="field-body">
                  <div v-if="meta.type == 'file'" class="field is-expanded">
                    <div class="field has-addons">
                      <div class="file">
                      <label class="file-label">
                        <input class="file-input" type="file" :accept="meta.acceptFiles" @change="onFileChange($event, i)">
                        <span class="file-cta">
                          <span class="file-icon">
                            <icon name="upload"></icon>
                          </span>
                          <span class="file-label">
                            {{meta.acceptFiles}}
                          </span>
                        </span>
                      </label>
                    </div>
                      <p class="control is-expanded">
                        <input class="input" type="text" v-model="meta.value">
                      </p>
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
                  <div v-if="meta.type == 'string'" class="field">
                    <div class="control">
                      <input class="input" type="text" v-model="meta.value">
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
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!canUpload" @click="upload">Submit</a>
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
      metaData: []
    }
  },
  computed: {
    canUpload () {
      if(!this.channel) return false
      if(!this.channel.metaData) return false

      for(var i=0;i<this.metaData.length;i++){
        if(!this.metaData[i].value)
          return false
        if(this.metaData[i].value == '__other__' && !this.metaData[i].otherValue)
          return false
        if(this.metaData[i].acceptFiles != null){
          if(!this.metaData[i].upload)
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
        this.metaData = []
        if(this.channel && this.channel.metaData){
          this.requestMetaData()
        }
      }
    },
  },
  methods: {
    close(){
      this.metaData.forEach(function(m){
        if(m.upload){
          if(!m.upload.done && m.upload.request){
            m.upload.request.abort()
          }
        }
      })
      this.$emit('close-upload-channel-modal', false)
    },
    requestMetaData(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_meta_by_channel/' + this.project.id + '/' + this.channel.id).then(response => {
        this.waiting= false
        this.metaData = response.body.map(this.parseMeta)
      }, response => {
        this.error = 'Failed to get meta data!'
        this.waiting= false
      })
    },
    parseMeta(m){
      var codeStart = m.indexOf('{')
      var codeEnd = m.indexOf('}')
      if(codeStart == -1 || codeEnd == -1 || codeStart >= codeEnd){
        return { name: m.trim(), type: 'string', value: '' }
      }
      var name = m.slice(0, codeStart).trim()
      var code = m.slice(codeStart+1, codeEnd)

      if(code == 'file' || code.startsWith('file:')){
        var acceptFiles = ''
        if(code.startsWith('file:')){
          acceptFiles = code.slice(5).trim()
        }
        return {name: name, type: 'file', value: '', acceptFiles: acceptFiles, upload: null}
      }

      if(code.includes('|')){
        var options = []
        code.split('|').forEach(function(s){
          var opt = s.trim()
          if(opt){
            options.push({text: opt, value: opt})
          }
        })
        var otherValue = ''
        if(options.length && options[options.length - 1].text == '*'){
          options[options.length - 1] = {text: 'Other', value: '__other__'}
        }
        return {name: name, type: 'select', value: '', options: options, otherValue: otherValue}
      }

      if(code.includes(',')){
        var items = []
        code.split(',').forEach(function(s){
          var item = s.trim()
          if(item){
            items.push(item)
          }
        })
        return {name: name, type: 'checkboxes', value: [], items: items}
      }
      return {name: name, type: 'unknown'}
    },
    onFileChange(e, i) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return

      var file = files[0]
      var upload = {
        file: file,
        filename: file.name,
        size: file.size,
        loaded: 0,
        percentage: 0,
        done: false,
        request: null
      }
      this.metaData[i].upload = upload
      this.metaData[i].value = file.name
    },
    upload(){
      if(!this.canUpload) return
      this.waiting = true

      var promises = []
      var vm = this
      this.metaData.forEach(function(m){
        if(!m.upload) return
        var upload = m.upload
        var formData = new FormData()
        formData.append('file', upload.file)
        formData.append('newName', m.value)
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

      if(promises.length){
        Promise.all(promises).then((response) => {
          if(vm.channel && vm.channel.metaData){
            var url = xHTTPx + '/upload_meta_by_channel/' + vm.project.id + '/' + vm.channel.id
            var values = vm.metaData.map(function(m){
              if(m.type == 'select' && m.value == '__other__')
                return m.otherValue
              if(m.type == 'checkboxes')
                return m.value.join(', ')
              return m.value
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
      }else{
        if(vm.channel && vm.channel.metaData){
          var url = xHTTPx + '/upload_meta_by_channel/' + vm.project.id + '/' + vm.channel.id
          var values = vm.metaData.map(function(d){
            return d.value == '__other__' ? d.otherValue : d.value
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
      }
    }
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
  margin-bottom: 10px;
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
