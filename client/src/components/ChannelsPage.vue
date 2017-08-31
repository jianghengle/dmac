<template>
  <div class="projects-page">
  	<address-bar></address-bar>

    <div class="columns">
      <div class="view-title column">
        <icon name="upload"></icon>
        Project Channels
      </div>
      <div class="column buttons">
        <a class="button main-btn" @click="openNewChannelModal" v-if="projectRole=='Owner'|| projectRole=='Admin'">
          <icon name="plus"></icon>&nbsp;
          Channel
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="box project-box" v-for="channel in channels":key="channel.id" @click="openUploadChannelModal(channel)">
      <div class="header">
        <span class="name">
          <a class="main-link" @click.stop="openChannelPath(channel)">{{channel.relPath}}</a>
        </span>&nbsp;
        <span class="edit-icon main-link"
          v-if="projectRole=='Owner' || projectRole=='Admin'"
          @click.stop="openEditChannelModal(channel)">
          <icon name="edit"></icon>
        </span>
        <span class="info">
          <a class="button delete" @click.stop="deleteChannel(channel)" v-if="projectRole=='Owner'|| projectRole=='Admin'"></a>
        </span>
      </div>
      <div class="description">{{channel.instruction}}</div>
    </div>

    <div v-if="channels && channels.length == 0">
      No channels in this project yet.
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <confirm-modal
      :opened="confirmModal.opened"
      :message="confirmModal.message"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>

    <new-channel-modal
      :opened="newChannelModal.opened"
      :project="project"
      @close-new-channel-modal="closeNewChannelModal">
    </new-channel-modal>

    <edit-channel-modal
      :opened="editChannelModal.opened"
      :project="project"
      :channel="editChannelModal.channel"
      @close-edit-channel-modal="closeEditChannelModal">
    </edit-channel-modal>

    <upload-channel-modal
      :opened="uploadChannelModal.opened"
      :channel="uploadChannelModal.channel"
      :project="project"
      @close-upload-channel-modal="closeUploadChannelModal">
    </upload-channel-modal>
  </div>
</template>

<script>
import DateForm from 'dateformat'
import AddressBar from './AddressBar'
import ConfirmModal from './modals/ConfirmModal'
import NewChannelModal from './modals/NewChannelModal'
import EditChannelModal from './modals/EditChannelModal'
import UploadChannelModal from './modals/uploadChannelModal'

export default {
  name: 'channels-page',
  components: {
    AddressBar,
    ConfirmModal,
    NewChannelModal,
    EditChannelModal,
    UploadChannelModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      confirmModal: {
        opened: false,
        message: '',
        context: null
      },
      newChannelModal: {
        opened: false
      },
      editChannelModal: {
        opened: false,
        channel: null
      },
      uploadChannelModal: {
        opened: false,
        channel: null
      },
      channels: []
    }
  },
  computed: {
    email () {
      return this.$store.state.user.email
    },
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
  },
  watch: {
    projectId: function (val) {
      this.requestPublicUrls()
      if(!this.project){
        this.requestChannels()
      }
    },
  },
  methods: {
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        vm.$store.commit('projects/setProject', resp)
        vm.$store.commit('projects/openNode', '/projects/' + vm.projectId)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project!'
        vm.waiting = false
      })
    },
    requestChannels () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_channels/' + vm.projectId).then(response => {
        var resp = response.body
        vm.channels = resp.map(function(u){
          u.relPath = u.path.replace(/--/g, '/')
          return u
        })
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project channels!'
        vm.waiting = false
      })
    },
    deleteChannel(channel){
      var message = 'Are you sure to delete this channel?'
      var context = {callback: this.deleteChannelConfirmed, args: [channel]}
      this.openConfirmModal(message, context)
    },
    deleteChannelConfirmed(channel){
      var message = {
        'projectId': this.projectId,
        'id': channel.id
      }
      this.$http.post(xHTTPx + '/delete_channel', message).then(response => {
        this.requestChannels()
      }, response => {
        this.waiting = false
        console.log('failed to delete channel')
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
    openNewChannelModal(){
      this.newChannelModal.opened = true
    },
    closeNewChannelModal(result){
      this.newChannelModal.opened = false
      if(result){
        this.requestChannels()
      }
    },
    openEditChannelModal(channel){
      this.editChannelModal.channel = channel
      this.editChannelModal.opened = true
    },
    closeEditChannelModal(result){
      this.editChannelModal.opened = false
      if(result){
        this.requestChannels()
      }
    },
    openUploadChannelModal(channel){
      this.uploadChannelModal.channel = channel
      this.uploadChannelModal.opened = true
    },
    closeUploadChannelModal(result){
      this.uploadChannelModal.opened = false
      this.uploadChannelModal.channel = null
    },
    openChannelPath(channel){
      var path = '/projects/' + this.projectId + '/data/' + channel.path.slice(0, -2)
      this.$router.push(path)
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestChannels()
      if(!vm.project){
        vm.requestProject()
      }
    })
  }
}
</script>

<style lang="scss" scoped>

.projects-page {
  padding: 10px;
}

.buttons {
  text-align: right;
  padding-right: 20px;
}

.options {
  float: right;
  font-size: 16px;
  font-weight: normal;
  line-height: 2.5;
}

.project-box {
  margin-top:10px;
  padding-top: 10px;
  padding-bottom: 10px;
  margin-bottom: 15px;
  cursor: pointer;

  .header {
    
    .name {
      font-size: 18px;
      font-weight: bold;
    }

    .edit-icon {
      font-size: 14px;
      position: relative;
      top: 3px;
    }
    
    .info {
      font-size: 14px;
      float: right;
      padding-top: 5px;
    }
  }

  .action {
    font-size: 14px;
    text-align: right;
  }

}

.project-box:hover{
  background-color: #f2f2f2; 
}

.link{
  color: #3273dc;
}



</style>
