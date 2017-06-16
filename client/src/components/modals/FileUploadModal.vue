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
            <input type="file" @change="onFileChange">
        </section>
        <footer class="modal-card-foot">
          <a class="button is-info" :class="{'is-loading': waiting}" @click="uploadFile">Upload</a>
          <a class="button" @click="close">Cancel</a>
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
      file: null,
      waiting: false
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.file = null
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-file-upload-modal', false)
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      this.file = files[0]
    },
    uploadFile() {
      if(!this.file) return
      this.waiting = true
      var formData = new FormData();
      formData.append('file', this.file)
      var url = xHTTPx + '/upload_file/' + this.projectId + '/' + this.dataPath
      this.$http.post(url, formData).then((response) => {
        console.log('File sent...')
        console.log(response)
        this.waiting = false
        this.$emit('close-file-upload-modal', true)
      }, (response) => {
        this.waiting = false
        console.log('Error occurred...')
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
</style>