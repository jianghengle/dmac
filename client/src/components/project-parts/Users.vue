<template>
  <div>
    <address-bar></address-bar>
    <div>users toolbar</div>
    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div>project name users</div>
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'

export default {
  name: 'users',
  components: {
  	AddressBar
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
