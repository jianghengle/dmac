<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">New User</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Email</label>
            <p class="control">
              <input class="input" type="text" v-model="newEmail">
            </p>
          </div>
          <div class="field">
            <label class="label">Role</label>
            <p class="control">
              <span class="select">
                <select v-model="newRole">
                  <option v-for="opt in roleOptions">{{opt}}</option>
                </select>
              </span>
            </p>
          </div>
          <div class="field" v-if="false">
            <label class="label">Group</label>
            <p class="control">
              <input class="input" type="text" v-model="newGroup">
            </p>
            <p class="help is-info">
              Group Name must only contain charactors from 'a'~'z', 'A'~'Z' and '0'~'9'
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!newEmailValid || !newGroupValid" @click="addUser">Add</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

export default {
  name: 'new-user-modal',
  props: ['opened', 'users', 'isOwner', 'projectId'],
  data () {
    return {
      error: '',
      waiting: false,
      newEmail: '',
      newRole: '',
      newGroup: ''
    }
  },
  computed: {
    roleOptions () {
      if(this.isOwner)
        return ['Admin', 'Editor', 'Viewer']
      return ['Editor', 'Viewer']
    },
    userMap () {
      var um = {}
      this.users.forEach(function(u){
        um[u.email] = u
      })
      return um
    },
    newEmailValid () {
      if(!emailRegex.test(this.newEmail)){
        return false
      }
      return !this.userMap[this.newEmail]
    },
    newGroupValid () {
      var re = /^[a-zA-Z0-9]*$/
      return re.test(this.newGroup)
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.newEmail = ''
        this.error = ''
      }
    },
  },
  methods: {
    close(){
      this.newEmai = ''
      this.$emit('close-new-user-modal', null)
    },
    addUser(){
      if(!this.newEmailValid) return
      var vm = this
      vm.newEmail = vm.newEmail.toLowerCase()
      vm.waiting = true
      var message = {projectId: vm.projectId, email: vm.newEmail, role: vm.newRole, group: vm.newGroup}
      vm.$http.post(xHTTPx + '/add_project_control', message).then(response => {
        var resp = response.body
        vm.waiting= false
        vm.newEmai = ''
        this.$emit('close-new-user-modal', resp)
      }, response => {
        vm.error = 'Failed to add user!'
        vm.waiting= false
      })
    }
  },
  mounted () {
    this.newRole = this.roleOptions[this.roleOptions.length-1]
  }
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