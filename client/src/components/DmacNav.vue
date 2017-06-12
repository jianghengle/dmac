<template>
  <div class="nav-bar">
    <nav-node :path="'/'"></nav-node>
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
}

</style>
