<template>
  <div class="project-page">
    <div v-if="pageType == 'project'">
      <project></project>
    </div>
    <div v-if="pageType == 'users'">
      <users></users>
    </div>
    <div v-if="pageType == 'folder'">
      <file></file>
    </div>
  </div>
</template>

<script>
import AddressBar from './project-parts/AddressBar'
import Project from './project-parts/Project'
import Users from './project-parts/Users'
import File from './project-parts/File'

export default {
  name: 'project-page',
  components: {
    AddressBar,
    Project,
    Users,
    File
  },
  computed: {
    pageType () {
      var pageType = ''
      var dataPath = this.$route.params.dataPath
      if(dataPath == '-root-'){
        pageType = 'project'
      }else if(dataPath == '-users-'){
        pageType = 'users'
      }else if(dataPath != ''){
        pageType = 'folder'
      }
      return pageType
    }
  },
}
</script>

<style lang="scss" scoped>

.project-page {
  padding: 10px;
}


</style>
