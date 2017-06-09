<template>
  <div class="project-page">
    <div v-if="pageType == 'project'">
      <project></project>
    </div>
    <div v-if="pageType == 'users'">
      <users></users>
    </div>
    <div v-if="pageType == 'folder'">
      <folder></folder>
    </div>
  </div>
</template>

<script>
import AddressBar from './project-parts/AddressBar'
import Project from './project-parts/Project'
import Users from './project-parts/Users'
import Folder from './project-parts/Folder'

export default {
  name: 'project-page',
  components: {
    AddressBar,
    Project,
    Users,
    Folder
  },
  computed: {
    pageType () {
      var pageType = ''
      var path = this.$route.params.path
      if(path == '-root-'){
        pageType = 'project'
      }else if(path == '-users-'){
        pageType = 'users'
      }else if(path != ''){
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
