<template>

  <div class="nav-bar">
    <nav-node :path="root"></nav-node>
  </div>

</template>

<script>
import NavNode from './nav-parts/NavNode'

export default {
  name: 'dmac-nav',
  components: {
    NavNode
  },
  computed: {
    publicKey () {
      return this.$route.params.publicKey
    },
    publicDataPath () {
      return this.$store.state.projects.publicDataPath
    },
    root () {
      if(this.publicKey){
        return '/public/' + this.publicKey + '/data/' + encodeURIComponent(this.publicDataPath)
      }
      return '/projects'
    }
  }
}
</script>

<style lang="scss" scoped>

.nav-bar {
  padding: 10px;
  font-size: 14px;
  overflow: scroll;
}

</style>
