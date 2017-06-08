<template>
  <div>
    <address-bar></address-bar>
    <div>folder toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div>folder name</div>
    <folder-content></folder-content>
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import FolderContent from './FolderContent'

export default {
  name: 'folder',
  components: {
  	AddressBar,
    FolderContent
  },
  data () {
    return {
      error: ''
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
