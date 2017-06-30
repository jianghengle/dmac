<template>
  <div class="modal"
      :class="{'is-active': opened}">
    <div class="modal-background"></div>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">File Upload</p>
        <button class="delete" @click="close"></button>
      </header>
      <section class="modal-card-body modal-body">
        <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <input v-if="opened" type="file" class="files-input" @change="onFileChange">
        <div v-if="newUsers.length">
          <table class="table is-narrow">
            <thead>
              <tr>
                <th>#</th>
                <th>Email</th>
                <th>Role</th>
                <th>Group</th>
                <th class="center-text">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(u, i) in newUsers">
                <td :class="{'removed': u.deleted}">{{i+1}}</td>
                <td :class="{'removed': u.deleted}">{{u.email}}</td>
                <td :class="{'removed': u.deleted}">{{u.role}}</td>
                <td :class="{'removed': u.deleted}">{{u.group}}</td>
                <td class="center-text">
                  <a class="action-icon main-link" @click="toggleDeleted(u)">
                    <icon v-if="!u.deleted" name="minus"></icon>
                    <icon v-if="u.deleted" name="plus"></icon>
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <footer class="modal-card-foot">
        <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!validNewUsers.length" @click="importUsers">Import</a>
        <a class="button button-right" @click="close">Cancel</a>
      </footer>
    </div>
  </div>
</template>

<script>
const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
const groupRegex = /^[a-zA-Z0-9]*$/

export default {
  name: 'import-users-modal',
  props: ['opened', 'projectId', 'users'],
  data () {
    return {
      newUsers: [],
      waiting: false,
      error: ''
    }
  },
  computed: {
    validNewUsers () {
      return this.newUsers.filter(function(u){
        return !u.deleted
      })
    },
  },
  watch: {
    opened: function (val) {
      this.newUsers = []
      this.waiting = false
      error: ''
    },
  },
  methods: {
    close(){
      this.$emit('close-import-users-modal', false)
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      var file = files[0]

      this.newUsers = []
      var emails = {}
      this.users.forEach(function(u){
        emails[u.email] = true
      })
      var roles = {Editor: 'Editor', Admin: 'Admin', Owner: 'Owner'}

      var vm = this
      var reader = new FileReader()
      reader.onload = function(e) {
        var text = reader.result
        var lines = text.split('\n')
        for(var i=0;i<lines.length;i++){
          var ss = lines[i].split(',')
          if(!ss.length) continue
          var email = ss[0].trim().toLowerCase()
          if(emails[email]) continue
          if(!emailRegex.test(email)) continue
          var role = 'Viewer'
          if(ss.length > 1){
            var r = ss[1].trim()
            if(roles[r]){
              role = roles[r]
            }
          }
          var group = ''
          if(ss.length > 2){
            var g = ss[2].trim()
            if(groupRegex.test(g)){
              group = g
            }
          }
          vm.newUsers.push({
            email: email,
            role: role,
            group: group,
            deleted: false
          })
          emails[email] = true
        }
      }

      reader.readAsText(file);
      
    },
    toggleDeleted(user){
      user.deleted = !user.deleted
    },
    importUsers() {
      this.waiting = true

      var vm = this
      var promises = []
      for(var i=0;i<vm.validNewUsers.length;i++){
        var user = vm.validNewUsers[i]
        var message = {projectId: vm.projectId, email: user.email, role: user.role, group: user.group}
        promises.push(vm.$http.post(xHTTPx + '/add_project_control', message))
      }

      Promise.all(promises).then((response) => {
        vm.waiting = false
        vm.$emit('close-import-users-modal', true)
      }, (response) => {
        vm.waiting = false
        vm.error = 'Some impots failed...'
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

.files-input {
  font-size: 14px;
}

.center-text {
  text-align: center;
}

.action-icon {
  position: relative;
  top: 3px;
  cursor: pointer;
}

.removed{
  text-decoration: line-through;
}


.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}


</style>
