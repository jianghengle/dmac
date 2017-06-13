<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New Project</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Name</label>
            <p class="control">
              <input class="input" type="text" v-model="newName">
            </p>
          </div>
          <div class="field">
            <label class="label">Description</label>
            <p class="control">
              <textarea class="textarea" v-model="newDescription"></textarea>
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-info" :class="{'is-loading': waiting}" :disabled="!newName.length" @click="create">Create</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'new-project-modal',
  props: ['opened'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      newDescription: ''
    }
  },
  methods: {
    close(){
      this.newName = ''
      this.newDescription = ''
      this.$emit('close-new-project-modal', false)
    },
    create(){
      var vm = this
      vm.waiting = true
      var message = {name: vm.newName, description: vm.newDescription}
      vm.$http.post(xHTTPx + '/create_project', message).then(response => {
        vm.waiting= false
        this.newName = ''
        this.newDescription = ''
        this.$emit('close-new-project-modal', true)
      }, response => {
        vm.error = 'Failed to create project!'
        vm.waiting= false
      })
    }
  },
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}
</style>