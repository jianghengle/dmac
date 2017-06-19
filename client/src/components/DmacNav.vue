<template>

  <div class="nav-bar">
    <nav-node :path="'/projects'"></nav-node>
  </div>

</template>

<script>
import NavNode from './nav-parts/NavNode'

export default {
  name: 'dmac-nav',
  components: {
    NavNode
  },
}
</script>

<style lang="scss" scoped>

.nav-bar {
  padding: 10px;
  font-size: 14px;
  overflow: scroll;
}

</style>
