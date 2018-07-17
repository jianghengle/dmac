<template>
  <div class="project-page">
    <address-bar></address-bar>
    <project-tab></project-tab>

    <div class="project-content">

      <div class="project-info" v-if="project && projectTab == 'Basic'">
        <div class="info-label">
          <span>Basic Info</span>&nbsp;
          <span class="edit-icon main-link"
            v-if="projectRole=='Owner' || projectRole=='Admin'"
            @click="openEditProjectModal(project)">
            <icon name="edit"></icon>
          </span>
        </div>
        <table class="table is-hoverable info-table">
          <tbody>
            <tr>
              <th class="info-name info-cell">Name</th>
              <td class="info-cell">{{project.name}}</td>
            </tr>
            <tr>
              <th class="info-name info-cell">Owner</th>
              <td class="info-cell">{{project.owner}}</td>
            </tr>
            <tr>
              <th class="info-name info-cell">Created Date:</th>
              <td class="info-cell">{{project.createdDate}}</td>
            </tr>
            <tr>
              <th class="info-name info-cell">Status</th>
              <td class="info-cell">{{project.status}}</td>
            </tr>
            <tr>
              <th class="info-name info-cell">Description</th>
              <td class="info-cell">
                <div class="control">
                  <textarea class="textarea field-text" :style="{height: textAreaHeight}" readonly>{{project.description}}</textarea>
                </div>
              </td>
            </tr>
            <tr>
              <th class="info-name info-cell">History</th>
              <td class="info-cell">{{project.autoHistory ? 'Automatically save history' : 'Manually save history'}}</td>
            </tr>
            <tr>
              <th class="info-name info-cell">Your Role</th>
              <td class="info-cell">{{projectRoleLabel}}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="project-info" v-if="project && projectTab == 'Meta'">
        <div class="info-label" v-if="projectRole=='Owner' || projectRole=='Admin'">
          <span>Meta Data</span>&nbsp;
          <span class="edit-icon main-link"
            v-if="projectRole=='Owner' || projectRole=='Admin'"
            @click="openEditProjectModal(project)">
            <icon name="edit"></icon>
          </span>
        </div>
        <table class="table is-hoverable info-table">
          <tbody>
            <tr>
              <th class="info-name info-cell">Meta Data File</th>
              <td class="info-cell">{{metaDataFile || '(None)'}}</td>
            </tr>
            <tr v-if="metaDataFile" v-for="meta in metaData">
              <th class="info-name info-cell">{{meta.name}}</th>
              <td class="info-cell">{{meta.value}}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="channels" v-if="project && projectTab=='Channels' && projectRole && projectRole!='Viewer'">
        <div class="channels-header columns">
          <div class="column label-column">
            <span class="channel-label">Channels</span>&nbsp;
          </div>
          <div class="column sort-column">
            <div class="select sort">
              <select v-model="channelSort">
                <option>Sort by Name</option>
                <option>Sort by Folder</option>
              </select>
            </div>
          </div>
          <div class="column button-column">
            <a class="button default-btn" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewChannelModal">
              <icon name="plus"></icon>&nbsp;New Channel
            </a>
          </div>
        </div>
        <div class="tabs channel-tab" v-if="project && projectRole && (projectRole=='Owner' || projectRole=='Admin')">
          <ul>
            <li v-for="cf in channelFilters" :key="'cf-' + cf" :class="{'is-active': channelFilter == cf}">
              <a @click="channelFilter = cf">{{cf}} ({{channelCounts[cf]}})</a>
            </li>
          </ul>
        </div>

        <div class="columns is-multiline">
          <div class="column is-half" v-for="channel in channels":key="channel.id"
            v-show="channelFilter=='All' || channelFilter==channel.status">
            <div class="box channel-box"
              @click="openUploadChannelModal(channel)">
              <div class="header">
                <span class="info">
                  <a class="button delete" @click.stop="deleteChannel(channel)" v-if="projectRole=='Owner'|| projectRole=='Admin'"></a>
                </span>
                <span class="name">
                  <span class="tag" :class="{
                    'is-success': channel.status!='Closed',
                    'is-danger': channel.status=='Closed'
                  }">{{channel.status=='Closed' ? 'Closed' : 'Open'}}</span>
                  {{channel.name}}
                </span>&nbsp;
                <span class="edit-icon main-link"
                  v-if="projectRole=='Owner' || projectRole=='Admin'"
                  @click.stop="openEditChannelModal(channel)">
                  <icon name="edit"></icon>
                </span>
                <br/>
                <span class="target">{{channel.path}}</span>&nbsp;
                <span class="edit-icon main-link"
                  @click.stop="openChannelPath(channel)">
                  <icon name="sign-in"></icon>
                </span>
              </div>
              <div class="description">{{channel.instruction}}</div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <edit-project-modal
      :opened="editProjectModal.opened"
      :project="editProjectModal.project"
      @close-edit-project-modal="closeEditProjectModal">
    </edit-project-modal>

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
import AddressBar from './AddressBar'
import ProjectTab from './ProjectTab'
import EditProjectModal from './modals/EditProjectModal'
import ConfirmModal from './modals/ConfirmModal'
import NewChannelModal from './modals/NewChannelModal'
import EditChannelModal from './modals/EditChannelModal'
import UploadChannelModal from './modals/uploadChannelModal'

export default {
  name: 'project-page',
  components: {
    AddressBar,
    ProjectTab,
    EditProjectModal,
    ConfirmModal,
    NewChannelModal,
    EditChannelModal,
    UploadChannelModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      editProjectModal: {
        opened: false,
        project: null
      },
      channels: [],
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
      metaDataFile: '',
      metaData: [],
      channelFilter: 'Open',
      channelFilters: ['Open', 'Closed', 'All'],
      channelSort: 'Sort by Folder'
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
    projectRoleLabel () {
      if(!this.projectRole) return ''
      return this.projectRole
    },
    textAreaHeight () {
      if(!this.project) return 1
      var lines = this.project.description.split('\n').length
      return 25*lines + 'px'
    },
    channelCounts () {
      var counts = {}
      this.channelFilters.forEach(function(f){
        counts[f] = 0
      })
      this.channels.forEach(function(c){
        counts[c.status]++
        counts['All']++
      })
      return counts
    },
    projectTab () {
      return this.$store.state.options.projectTab
    }
  },
  watch: {
    projectId: function (val) {
      this.requestProject()
      this.requestChannels()
    },
    channelFilter: function (val) {
      this.$store.commit('options/setChannelFilter', val)
    },
    channelSort: function (val) {
      this.$store.commit('options/setChannelSort', val)
      this.sortChannels()
    }
  },
  methods: {
    requestProject () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_project/' + this.projectId).then(response => {
        var resp = response.body
        this.$store.commit('projects/setProject', resp)
        this.waiting = false
        this.$nextTick(function(){
          this.requestMetaData()
          if(this.projectRole=='Editor' || this.projectRole=='Viewer'){
            this.channelFilter = 'Open'
          }
        })
      }, response => {
        this.error = 'Failed to get project!'
        this.waiting = false
      })
    },
    viewUsers () {
      this.$router.push('/projects/' + this.projectId + '/users')
    },
    viewPublicUrls () {
      this.$router.push('/projects/' + this.projectId + '/urls')
    },
    viewChannels () {
      this.$router.push('/projects/' + this.projectId + '/channels')
    },
    viewHistory () {
      this.$router.push('/projects/' + this.projectId + '/history')
    },
    viewData () {
      this.$router.push('/projects/' + this.projectId + '/data/%2F')
    },
    openEditProjectModal(){
      this.editProjectModal.project = this.project
      this.editProjectModal.opened = true
    },
    closeEditProjectModal(result){
      this.editProjectModal.opened = false
      if(result){
        if(result == 'deleted'){
          this.$router.push('/projects')
        }else{
          this.requestProject()
        }
      }
    },
    requestChannels () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_channels/' + this.projectId).then(response => {
        var resp = response.body
        this.channels = resp
        this.sortChannels()

        this.waiting = false
      }, response => {
        this.error = 'Failed to get project channels!'
        this.waiting = false
      })
    },
    requestMetaData(){
      this.metaDataFile = ''
      this.metaData = []
      this.waiting= true
      var dataPath = encodeURIComponent('/')
      dataPath = encodeURIComponent(dataPath)
      this.$http.get(xHTTPx + '/get_meta_by_data_path/' + this.project.id + '/' + dataPath).then(response => {
        this.waiting= false
        var lines = response.body
        var headers = []
        if(lines.length > 0){
          headers = lines[0].split('\t')
        }
        var values = []
        if(lines.length > 1){
          values = lines[1].split('\t')
        }
        for(var i=0;i<headers.length;i++){
          var header = headers[i]
          var optionsStart = header.indexOf('{')
          var optionsEnd = header.indexOf('}')
          var name = ''
          var value = ''
          if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
            name = header
          }else{
            name = header.slice(0, optionsStart).trim()
          }
          if(i < values.length){
            value = values[i]
          }
          this.metaData.push({name: name, value: value})
        }
        this.metaDataFile = 'meta.txt'
      }, response => {
        this.metaDataFile = ''
        this.waiting= false
      })
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
    openChannelPath(channel){
      var path = '/projects/' + this.projectId + '/data/' + encodeURIComponent(channel.path)
      this.$router.push(path)
    },
    sortChannels(){
      this.channels.sort(this.compareChannels)
    },
    compareChannels(c1, c2){
      var name1 = c1.name ? c1.name : ''
      var name2 = c2.name ? c2.name : ''
      var path1 = c1.path ? c1.path : ''
      var path2 = c2.path ? c2.path : ''
      if(this.channelSort == 'Sort by Folder'){
        if(path1 == path2) {
          return name1.localeCompare(name2)
        }
        return path1.localeCompare(path2)
      }else if(this.channelSort == 'Sort by Name'){
        if(name1 == name2) {
          return path1.localeCompare(path2)
        }
        return name1.localeCompare(name2)
      }
      return 0
    }
  },
  mounted () {
    if(this.projectTab == 'Data'){
      this.$router.push('/projects/' + this.projectId + '/data/%2F')
    }else{
      this.channelFilter = this.$store.state.options.channelFilter
      this.channelSort = this.$store.state.options.channelSort
      this.$nextTick(function(){
        this.requestProject()
        this.requestChannels()
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.project-page {
  padding: 10px;
}

.project-icon {
  position: relative;
  top: 1px;
}

.action {
  text-align: center;
}

.edit-icon {
  font-size: 14px;
  position: relative;
  top: 3px;
  cursor: pointer;
}

.detail-header {
  font-size: 20px;
  font-weight: bold;
}

.project-content {
  width: 100%;
}

.project-buttons {
  margin-right: 10px;
}

.project-info {

  .info-label {
    color: #2e1052;
    font-size: 20px;
    font-weight: bold;
  }

  .info-name {
    text-align: right;
  }

  .info-table {
    margin-top: 5px;
  }

  .field-text {
    border-style: none;
    box-shadow: none;
    resize: none;
    min-height: 40px;
    position: relative;
    top: -2px;
  }
}

.channels {

  .channels-header{
    margin-top: -15px;
    margin-bottom: -5px;

    .label-column{
      padding: 15px;

      .channel-label {
        color: #2e1052;
        font-size: 20px;
        font-weight: bold;
      }
    }

    .sort-column {
      text-align: center;
    }

    .button-column {
      text-align: right;
    }
  }

  .channel-tab {
    margin-bottom: 15px;
  }

  .channel-box {
    padding-top: 10px;
    padding-bottom: 10px;
    cursor: pointer;
    min-height: 100px;
    max-height: 100px;
    overflow: auto;

    .header {
      .name {
        font-size: 18px;
        font-weight: bold;
        color: #2e1052;
      }

      .target {
        font-size: 16px;
        color: #2e1052;
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

  .channel-box:hover{
    background-color: #f2f2f2;
  }
}




</style>
