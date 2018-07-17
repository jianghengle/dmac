<template>
  <div class="projects-page">
  	<address-bar></address-bar>
    <project-tab></project-tab>

    <div class="view-title">
      <a class="main-link" @click="$router.go(-1)">
        <icon name="arrow-left"></icon>
      </a>&nbsp;
      Public URLs
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="box project-box" v-for="url in publicUrls":key="url.id">
      <div class="header">
        <span class="name">
          <a class="main-link" @click="openPublicPath(url)">{{url.relPath}}</a>
        </span>
        <span class="info">{{url.createdAt}}</span>
      </div>
      <div class="description"><a class="main-link" :href="url.url" target="_blank">{{url.url}}</a></div>
      <div class="action">
        <a class="button is-danger" @click="deleteUrl(url)">
          Delete
        </a>
      </div>
    </div>
    <div v-if="publicUrls && publicUrls.length == 0">
      No public url in this project yet.
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <confirm-modal
      :opened="confirmModal.opened"
      :message="confirmModal.message"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>
  </div>
</template>

<script>
import DateForm from 'dateformat'
import AddressBar from './AddressBar'
import ProjectTab from './ProjectTab'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'public-urls-page',
  components: {
    AddressBar,
    ProjectTab,
    ConfirmModal
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
      publicUrls: []
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
  },
  watch: {
    projectId: function (val) {
      this.requestPublicUrls()
      if(!this.project){
        this.requestProject()
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
    requestPublicUrls () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_publics/' + vm.projectId).then(response => {
        var resp = response.body
        vm.publicUrls = resp.map(function(u){
          u.createdAt = DateForm(u.createdTime*1000, 'mmm dd yyyy HH:MM')
          u.relPath = u.dataPath.replace(/--/g, '/')
          u.url = window.location.origin + '/#/public/' + u.key + '/data/' + encodeURIComponent(u.dataPath)
          return u
        })
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project public urls!'
        vm.waiting = false
      })
    },
    deleteUrl(url){
      var message = 'Are you sure to delete this public URL?'
      var context = {callback: this.deleteUrlConfirmed, args: [url]}
      this.openConfirmModal(message, context)
    },
    deleteUrlConfirmed(url){
      var message = {
        'projectId': this.projectId,
        'publicKey': url.key
      }
      this.$http.post(xHTTPx + '/remove_folder_public', message).then(response => {
        var index = this.publicUrls.indexOf(url)
        this.publicUrls.splice(index, 1)
        this.waiting = false
      }, response => {
        this.waiting = false
        console.log('failed to delete')
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
    openPublicPath(url){
      var path = '/projects/' + this.projectId + '/data/' + encodeURIComponent(url.dataPath)
      this.$router.push(path)
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestPublicUrls()
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
  
  &.archived {
    color: #7a7a7a;
  }

  .header {
    
    .name {
      font-size: 18px;
      font-weight: bold;
    }

    .edit-icon {
      color: #ff3860;
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

.link{
  color: #3273dc;
}



</style>
