<template>
  <div class="modal"
      :class="{'is-active': opened}">
    <div class="modal-background"></div>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">File Upload</p>
        <button class="delete" @click="close"></button>
      </header>
      <section class="modal-card-body modal-body">
        <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <input v-if="opened" type="file" class="files-input" multiple @change="onFileChange">
        <div v-if="Object.keys(uploads).length">
          <table class="table is-narrow">
            <thead>
              <tr>
                <th>File Name</th>
                <th class="number-cell">Size</th>
                <th class="number-cell">Progress</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(v, k) in uploads">
                <td>{{v.filename}}</td>
                <td class="number-cell">{{v.size}}</td>
                <td class="number-cell">{{v.percentage}}%</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <footer class="modal-card-foot">
        <a class="button main-btn" :class="{'is-loading': waiting}" @click="uploadFiles">Upload</a>
        <a class="button button-right" @click="close">Cancel</a>
      </footer>
    </div>
  </div>
</template>

<script>
export default {
  name: 'file-upload-modal',
  props: ['opened', 'projectId', 'dataPath'],
  data () {
    return {
      files: null,
      uploads: {},
      waiting: false,
      error: ''
    }
  },
  watch: {
    opened: function (val) {
      this.uploads = {}
      this.waiting = false
    },
  },
  methods: {
    close(){
      Object.values(this.uploads).forEach(function(upload){
        if(!upload.done && upload.request){
          upload.request.abort()
        }
      })
      this.$emit('close-file-upload-modal', true)
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      this.files = files
      var newKeys = {}
      for(var i=0;i<files.length;i++){
        var file = files[i]
        newKeys[file.name] = true
        if(!this.uploads[file.name]){
          var upload = {
            filename: file.name,
            size: file.size,
            loaded: 0,
            percentage: 0,
            done: false,
            request: null
          }
          this.$set(this.uploads, file.name, upload)
        }
      }
      var oldKeys = Object.keys(this.uploads)
      for(var i=0;i<oldKeys.length;i++){
        var oldKey = oldKeys[i]
        if(!newKeys[oldKey]){
          delete this.uploads[oldKey]
        }
      }
    },
    uploadFiles() {
      if(!this.files.length) return
      this.waiting = true

      var vm = this
      var promises = []
      for(var i=0;i<vm.files.length;i++){
        let file = vm.files[i]
        if(vm.uploads[file.name].done)
          continue

        var formData = new FormData()
        formData.append('file', file)
        var url = xHTTPx + '/upload_file/' + vm.projectId + '/' + vm.dataPath
        var promise = vm.$http.post(url, formData, {
          before: request => {
            vm.uploads[file.name].request = request
          },
          progress: e => {
            var upload = vm.uploads[file.name]
            upload.loaded = e.loaded
            upload.percentage = Math.round((e.loaded / e.total) * 100)
          }
        }).then((response) => {
          var upload = vm.uploads[file.name]
          upload.loaded = upload.size
          upload.percentage = 100
          upload.done = true
          upload.request = null
        }, (response) => {
          var upload = vm.uploads[file.name]
          upload.loaded = 0
          upload.percentage = 0
          upload.request = null
        })

        promises.push(promise)
      }

      Promise.all(promises).then((response) => {
        vm.waiting = false
        vm.$emit('close-file-upload-modal', true)
      }, (response) => {
        vm.waiting = false
        vm.error = 'Some uploads failed...'
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

.files-input {
  font-size: 14px;
}

.number-cell {
  text-align: right;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}


</style>
