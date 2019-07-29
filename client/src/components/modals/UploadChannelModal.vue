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
                  <div v-if="meta.type == 'file'" class="field">
                    <div class="field">
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
                      <div v-if="meta.upload">
                        <table class="table is-narrow is-fullwidth files-table">
                          <tbody>
                            <tr>
                              <td class="file-cell"><input class="input" type="text" v-model="meta.upload.filename"></td>
                              <td class="number-cell">{{meta.upload.size}}</td>
                              <td class="number-cell">{{meta.upload.percentage}}%</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>

                  <div v-if="meta.type == 'files'" class="field">
                    <div class="field">
                      <div class="file">
                        <label class="file-label">
                          <input class="file-input" type="file" multiple :accept="meta.acceptFiles" @change="onFilesChange($event, i)">
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
                      <div v-if="meta.uploads">
                        <table class="table is-narrow is-fullwidth files-table">
                          <tbody>
                            <tr v-for="(v, k) in meta.uploads">
                              <td class="file-cell"><input class="input" type="text" v-model="v.filename"></td>
                              <td class="number-cell">{{v.size}}</td>
                              <td class="number-cell">{{v.percentage}}%</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
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
                    <input v-if="meta.value.includes('more...')" class="input other-input" type="text" placeholder="Please specify more items seperated by comma" v-model="meta.otherItems">
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
  data () {
    return {
      error: '',
      waiting: false,
      metaData: [],
      oldValues: {}
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.uploadChannelModal.opened
    },
    project () {
      return this.$store.state.modals.uploadChannelModal.project
    },
    channel () {
      return this.$store.state.modals.uploadChannelModal.channel
    },
    canUpload () {
      if(!this.channel) return false
      if(!this.channel.metaData) return false

      for(var i=0;i<this.metaData.length;i++){
        var meta = this.metaData[i]
        if(meta.type != 'file' && meta.type != 'files'){
          if(!meta.value)
            return false
          if(meta.value == '__other__' && !meta.otherValue)
            return false
        }else if(meta.type == 'file'){
          if(!meta.upload || !meta.upload.file || !meta.upload.filename)
            return false
        }else{
          var keys = Object.keys(meta.uploads)
          for(var j=0;j<keys.length;j++){
            var upload = meta.uploads[keys[j]]
            if(!upload.file || !upload.filename)
              return false
          }
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
        this.oldValues = {}
        for(var i=0;i<this.metaData.length;i++){
          var m = this.metaData[i]
          this.oldValues[m.name] = m.value
          if(m.type == 'select' && m.value == '__other__'){
            this.oldValues[m.name] = m.otherValue
          }
          if(m.type == 'checkboxes' && m.value.includes('more...')){
            var items = m.value.filter(function(i){
              return i != 'more...'
            })
            m.otherItems.split(',').forEach(function(i){
              if(i.trim()){
                items.push(i.trim())
              }
            })
            this.oldValues[m.name] = items
          }
        }
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
      this.$store.commit('modals/closeUploadChannelModal')
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
        return { name: m.trim(), type: 'string', value: this.oldValues[m.trim()] == undefined ? '' :  this.oldValues[m.trim()]}
      }
      var name = m.slice(0, codeStart).trim()
      var code = m.slice(codeStart+1, codeEnd)

      if(code == 'file' || code.startsWith('file:')){
        var acceptFiles = ''
        if(code.startsWith('file:')){
          acceptFiles = code.slice(5).trim()
        }
        return {name: name, type: 'file', acceptFiles: acceptFiles, upload: null}
      }

      if(code == 'files' || code.startsWith('files:')){
        var acceptFiles = ''
        if(code.startsWith('files:')){
          acceptFiles = code.slice(6).trim()
        }
        return {name: name, type: 'files', acceptFiles: acceptFiles, uploads: {}}
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
        var oldValue = this.oldValues[name]
        var newValue = ''
        if(oldValue){
          if(options.map(function(o){return o.value}).includes(oldValue)){
            newValue = oldValue
          }else if(options[options.length - 1].value == '__other__'){
            newValue = '__other__'
            otherValue = oldValue
          }else{
            newValue = oldValue
          }
        }
        return {name: name, type: 'select', value: newValue, options: options, otherValue: otherValue}
      }

      if(code.includes(',')){
        var items = []
        code.split(',').forEach(function(s){
          var item = s.trim()
          if(item){
            items.push(item)
          }
        })
        if(items[items.length-1] == '*'){
          items[items.length-1] = 'more...'
        }
        var oldValue = this.oldValues[name]
        var newValue = []
        var otherItems = []
        if(oldValue){
          oldValue.forEach(function(i){
            if(items.includes(i)){
              newValue.push(i)
            }else if(items[items.length-1] == 'more...'){
              otherItems.push(i)
            }
          })
        }
        if(items[items.length-1] == 'more...' && otherItems.length){
          newValue.push('more...')
        }
        return {name: name, type: 'checkboxes', value: newValue, items: items, otherItems: otherItems.join(', ')}
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
    },
    onFilesChange(e, i) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return

      var uploads = {}
      for(var j=0;j<files.length;j++){
        var file = files[j]
        var key = i + '-' + j
        var upload = {
          file: file,
          filename: file.name,
          size: file.size,
          loaded: 0,
          percentage: 0,
          done: false,
          request: null
        }
        uploads[key] = upload
      }
      this.metaData[i].uploads = uploads
    },
    upload(){
      if(!this.canUpload) return
      this.waiting = true

      var promises = []
      var vm = this
      this.metaData.forEach(function(m){
        if(!m.upload && !m.uploads) return
        var uploads = m.upload ? [m.upload] : Object.values(m.uploads)

        uploads.forEach(function(upload){
          var formData = new FormData()
          formData.append('newName', upload.filename)
          formData.append('file', upload.file)
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
      })

      var values = vm.metaData.map(function(m){
        if(m.type == 'select' && m.value == '__other__'){
          return m.otherValue
        }
        if(m.type == 'checkboxes'){
          var items = []
          m.value.forEach(function(i){
            if(i == 'more...'){
              m.otherItems.split(',').forEach(function(i){
                if(i.trim()){
                  items.push(i.trim())
                }
              })
            }else{
              items.push(i)
            }
          })
          return items.join(', ')
        }
        if(m.type == 'file'){
          return m.upload.filename
        }
        if(m.type == 'files'){
          var filenames = Object.values(m.uploads).map(function(upload){
            return upload.filename
          })
          return filenames.join(', ')
        }
        return m.value
      })
      var message = { metaData:  values.join('\t')}
      var url = xHTTPx + '/upload_meta_by_channel/' + vm.project.id + '/' + vm.channel.id

      if(promises.length){
        Promise.all(promises).then((response) => {
          this.$http.post(url, message).then(response => {
            this.waiting= false
            this.$store.commit('modals/closeUploadChannelModal')
          }, response => {
            this.error = 'Error in uploading meta data ...'
            this.waiting= false
          })
        }, (response) => {
          vm.waiting = false
          vm.error = 'Error in uploading file: ' + response
        })
      }else{
        this.$http.post(url, message).then(response => {
          this.waiting= false
          this.$store.commit('modals/closeUploadChannelModal')
        }, response => {
          this.error = 'Error in uploading meta data ...'
          this.waiting= false
        })
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

.number-cell {
  text-align: right;
  padding-top: 10px!important;
}

.file-cell {
  padding-left: 0px!important;
}

.files-table {
  margin-bottom: 0px;
}

</style>
