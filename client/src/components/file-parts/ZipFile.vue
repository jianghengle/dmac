<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        <a class="button default-btn" v-if="projectRole == 'Owner' || projectRole == 'Admin'" @click="unzipFile">
          Unzip here
        </a>
      </div>
    </div>

    <div class="file-content">
      You could extract it to the same folder ...
      <div>{{status}}</div>
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div class="spinner-container" v-if="waiting">
        <icon name="spinner" class="icon is-medium fa-spin"></icon>
      </div>
    </div>
    <br/>
    <a v-if="!url"
      @click="getDownloadUrl"
      class="button main-btn">
      <icon name="download"></icon> &nbsp;
      Download
    </a>
    <a class="main-link" v-if="url" :href="url">Download Link</a>

    <confirm-modal
      :opened="confirmModal.opened"
      :message="confirmModal.message"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>
  </div>
</template>

<script>
import ConfirmModal from '../modals/ConfirmModal'

export default {
  name: 'zip-file',
  components: {
    ConfirmModal
  },
  props: ['file'],
  
  data () {
    return {
      url: null,
      confirmModal: {
        opened: false,
        message: '',
        context: null
      },
      error: '',
      waiting: false,
      status: ''
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    project () {
      return this.nodeMap['/projects/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    path () {
      return this.$route.path
    },
    publicKey () {
      return this.$route.params.publicKey
    },
  },
  watch: {
    path: function (val) {
      this.url = null
    },
  },
  methods: {
    getDownloadUrl() {
      if(this.publicKey){
        this.$http.get(xHTTPx + '/get_public_download_url/' + this.publicKey + "/" + this.file.projectId + "/" + this.file.dataPath).then(response => {
          this.url = xHTTPx + response.body
        }, response => {
          console.log('failed to get url')
        })
      }else{
        this.$http.get(xHTTPx + '/get_download_url/' + this.file.projectId + "/" + this.file.dataPath).then(response => {
          this.url = xHTTPx + response.body
        }, response => {
          console.log('failed to get url')
        })
      }
    },
    unzipFile(){
      var message = 'Are you sure to extract the content to the same folder?'
      var context = {callback: this.unzipFileConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    unzipFileConfirmed(){
      this.status = 'Extracting...'
      this.waiting = true
      var message = {
        'projectId': this.projectId,
        'dataPath': this.file.dataPath
      }
      this.$http.post(xHTTPx + '/unzip_file', message).then(response => {
        this.status = 'Done extracting.'
        this.waiting = false
      }, response => {
        this.status = 'Extracting stopped.'
        this.error = 'Error occurred.'
        this.waiting = false
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
  }
}
</script>

<style lang="scss" scoped>

.buttons {
  text-align: right;
}

.file-content {
  margin-top: 5px;
}

.action-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}

</style>