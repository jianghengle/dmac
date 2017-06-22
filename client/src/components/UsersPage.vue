<template>
  <div class="users-page">
    <address-bar></address-bar>

    <div class="columns">
      <div class="view-title column">
        <icon name="user-o"></icon>&nbsp;
        Project Users
      </div>
      <div class="column buttons">
        <a class="button is-info" @click="openNewUserModal">
          <icon name="plus"></icon>&nbsp;
          User
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
 
    <div>
      <table class="table">
        <thead>
          <tr>
            <th class="number-cell">#</th>
            <th class="text-cell">Email</th>
            <th class="text-cell">Role</th>
            <th class="text-cell">Joined At</th>
            <th class="text-cell">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(u, i) in users" :key="u.id">
            <td class="number-cell">{{i+1}}</td>
            <td class="text-cell">
              <span :class="{'self-email': u.self}">{{u.email}}</span>
              <span v-if="u.self">(Me)</span>
            </td>
            <td class="text-cell">{{u.role}}</td>
            <td class="text-cell">{{u.joinedAt}}</td>
            <td class="text-cell">
              <a class="edit-icon"
                v-if="!u.self && (isOwner || u.role=='Editor' || u.role=='Viewer')"
                @click="openEditUserModal(u)">
                <icon name="edit"></icon>
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div class="empty-label" v-if="!waiting && !users.length">(Empty)</div>

    <new-user-modal
      :opened="newUserModal.opened"
      :is-owner="isOwner"
      :users="users"
      :project-id="projectId"
      @close-new-user-modal="closeNewUserModal">
    </new-user-modal>

    <edit-user-modal
      :opened="editUserModal.opened"
      :is-owner="isOwner"
      :users="users"
      :user="editUserModal.user"
      @close-edit-user-modal="closeEditUserModal">
    </edit-user-modal>
    
  </div>
</template>

<script>
import AddressBar from './AddressBar'
import DateForm from 'dateformat'
import NewUserModal from './modals/NewUserModal'
import EditUserModal from './modals/EditUserModal'

export default {
  name: 'UsersPage',
  components: {
    AddressBar,
    NewUserModal,
    EditUserModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      user: null,
      users: [],
      isOwner: false,
      sortBy: 'role',
      roles: ['Owner', 'Admin', 'Editor', 'Viewer'],
      asc: true,
      newUserModal: {
        opened: false
      },
      editUserModal: {
        opened: false,
        user: null
      },
    }
  },
  computed: {
    email () {
      return this.$store.state.user.email
    },
    projectId () {
      return this.$route.params.projectId
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    project () {
      return this.nodeMap['/projects/' + this.projectId]
    },
  },
  watch: {
    projectId: function (val) {
      this.requestUsers()
      if(!this.project){
        this.requestProject()
      }
    },
  },
  methods: {
    requestProject () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project/' + vm.projectId).then(response => {
        var resp = response.body
        vm.$store.commit('projects/setProject', resp)
        vm.$store.commit('projects/openNode', '/projects/' + this.projectId)
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project!'
        vm.waiting = false
      })
    },
    requestUsers () {
      var vm = this
      vm.waiting = true
      vm.$http.get(xHTTPx + '/get_project_controls/' + vm.projectId).then(response => {
        var resp = response.body
        vm.users = resp.map(function(u){
          u.joinedAt = DateForm(u.createdTime*1000, 'mmm dd yyyy HH:MM')
          if(u.email == vm.email){
            u.self = true
            vm.isOwner = u.role == 'Owner'
            vm.user = u
          }
          return u
        })
        vm.sortUsers()
        vm.waiting = false
      }, response => {
        vm.error = 'Failed to get project users!'
        vm.waiting = false
      })
    },
    sortUsers () {
      var vm = this
      vm.users.sort(function(u1, u2){
        if(vm.sortBy == 'role'){
          var index1 = vm.roles.indexOf(u1.role)
          var index2 = vm.roles.indexOf(u2.role)
          if(index1 == index2){
            return vm.compareEmails(u1, u2)
          }
          if(vm.asc){
            return index1 - index2
          }
          return index2 - index1
        }else if(vm.sortBy == 'joinedAt'){
          if(vm.asc){
            return u1.createdTime - u2.createdTime
          }
          return u2.createdTime - u1.createdTime
        }
        return vm.compareEmails(u1, u2)
      })
    },
    compareEmails(u1, u2){
      if(this.asc){
        return u1.email.localeCompare(u2.email)
      }
      return -u1.email.localeCompare(u2.email)
    },
    openNewUserModal(){
      this.newUserModal.opened = true
    },
    closeNewUserModal(result){
      this.newUserModal.opened = false
      if(result){
        result.joinedAt = DateForm(result.createdTime*1000, 'mmm dd yyyy HH:MM')
        this.users.push(result)
        this.sortUsers()
      }
    },
    openEditUserModal(u){
      this.editUserModal.user = u
      this.editUserModal.opened = true
    },
    closeEditUserModal(result){
      this.editUserModal.opened = false
      if(result){
        var index = this.findUserIndex(result)
        if(result.deleted){
          this.users.splice(index, 1)
        }else{
          this.users[index].email = result.email
          this.users[index].role = result.role
          this.sortUsers()
        }
      }
    },
    findUserIndex(user){
      for(var i=0;i<this.users.length;i++){
        if(this.users[i].id == user.id)
          return i
      }
    }
  },
  mounted () {
    var vm = this
    vm.$nextTick(function(){
      vm.requestUsers()
      if(!vm.project){
        vm.requestProject()
      }
    })
  }
}
</script>

<style lang="scss" scoped>
.users-page {
  padding: 10px;
}

.buttons {
  text-align: right;
  padding-right: 20px;
}

.self-email {
  font-weight: bold;
}

.text-cell {
  text-align: center;
}

.number-cell {
  text-align: right;
}

.edit-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}

</style>
