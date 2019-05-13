<template>
  <div>
    <div class="view-title">
      <span class="project-icon">
        <icon name="folder-open"></icon>
      </span>&nbsp;
      <span class="project-name">{{project && project.name}}</span>
    </div>

    <div class="tabs project-tab">
      <ul>
        <li :class="{'is-active': currentTab=='Basic'}"><a @click="viewBasic">Basic</a></li>
        <li :class="{'is-active': currentTab=='Meta'}"><a @click="viewMeta">Meta</a></li>
        <li :class="{'is-active': currentTab=='Channels'}"><a @click="viewChannels">Channels</a></li>
        <li :class="{'is-active': currentTab=='Data'}"><a @click="viewData">Data</a></li>
        <li :class="{'is-active': currentTab=='Users'}" v-if="projectRole=='Owner' || projectRole=='Admin'"><a @click="viewUsers">Users</a></li>
        <li :class="{'is-active': currentTab=='Public URLs'}" v-if="projectRole=='Owner' || projectRole=='Admin'"><a @click="viewPublicUrls">Public URLs</a></li>
        <li :class="{'is-active': currentTab=='History'}" v-if="projectRole=='Owner' || projectRole=='Admin'"><a @click="viewHistory">History</a></li>
      </ul>
    </div>

  </div>
</template>

<script>
export default {
  name: 'project-tab',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    publicKey () {
      return this.$route.params.publicKey
    },
    dataPath () {
      return this.$route.params.dataPath
    },
    routeName () {
      return this.$route.name
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
    projectTab () {
      return this.$store.state.options.projectTab
    },
    currentTab () {
      if(this.routeName == 'ProjectFolderFile')
        return 'Data'
      if(this.routeName == 'ProjectSearch')
        return 'Data'
      if(this.routeName == 'HistoryPage')
        return 'History'
      if(this.routeName == 'CommitPage')
        return 'History'
      if(this.routeName == 'PublicUrlsPage')
        return 'Public URLs'
      if(this.routeName == 'ProjectUsers')
        return 'Users'
      if(this.routeName == 'Project')
        return this.projectTab
      return null
    }
  },
  methods: {
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
      this.$store.commit('options/setProjectTab', 'Data')
      this.$router.push('/projects/' + this.projectId + '/data/%2F')
    },
    viewChannels () {
      this.$store.commit('options/setProjectTab', 'Channels')
      if(this.routeName != 'Project'){
        this.$router.push('/projects/' + this.projectId)
      }
    },
    viewMeta () {
      this.$store.commit('options/setProjectTab', 'Meta')
      if(this.routeName != 'Project'){
        this.$router.push('/projects/' + this.projectId)
      }
    },
    viewBasic () {
      this.$store.commit('options/setProjectTab', 'Basic')
      if(this.routeName != 'Project'){
        this.$router.push('/projects/' + this.projectId)
      }
    },
  },
}
</script>

<style lang="scss" scoped>

.project-icon {
  position: relative;
  top: 1px;
}

.project-name {
  font-size: 24px;
  font-weight: bold;
}

.project-tab {
  margin-top: -5px;
  margin-bottom: 15px;
}

</style>
