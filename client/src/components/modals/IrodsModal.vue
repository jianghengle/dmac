<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
        <header class="modal-card-head">
          <p class="modal-card-title">
            DMAC&nbsp;<icon name="exchange"></icon>&nbsp;CyVerse
          </p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
            <div class="columns">
              <div class="column dmac-column">
                <div class="column-header">DMAC</div>
                <div v-if="dmacError" class="notification is-danger">
                  <button class="delete" @click="dmacError=''"></button>
                  {{dmacError}}
                </div>
                <div class="spinner-container" v-if="dmacWaiting">
                  <icon name="spinner" class="icon is-medium fa-spin"></icon>
                </div>
                <div v-if="!dmacWaiting && dmacFolder">
                  <div>
                    <span v-for="(node, i) in dmacAddress">
                      <span v-if="i != 0">&nbsp;/</span>
                      <a class="main-link" @click="changeDmacFolder(node)">{{node.name}}</a>
                    </span>
                  </div>
                  <div>
                    <table class="table is-narrow is-fullwidth">
                      <thead>
                        <tr>
                          <th class="number-cell clickable" @click="toggleAll(dmacFiles)">{{dmacFiles.length}}</th>
                          <th class="text-cell">Type</th>
                          <th class="text-cell">Name</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="f in dmacFiles" :key="f.dataPath" class="entry" :class="{'selected': f.selected}">
                          <td class="number-cell">
                            <input type="checkbox" class="clickable" v-model="f.selected" @click="toggleSelected(dmacFiles, f)">
                          </td>
                          <td class="text-cell">
                            <icon class="type-icon" v-if="f.type=='folder'" name="folder"></icon>
                            <icon class="type-icon" v-if="f.type=='file'" name="file-o"></icon>
                          </td>
                          <td><span @click="changeDmacFolder(f)" :class="{'clickable': f.type=='folder'}">{{f.name}}</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
                <div class="column-button">
                  <a class="button is-primary" :disabled="!canTransterTo">
                    Transfer {{dmacSelected.length}} To CyVerse
                    &nbsp;<icon name="arrow-right"></icon>
                  </a>
                </div>
              </div>
              <div class="column irods-column">
                <div class="column-header">CyVerse</div>
                <div v-if="irodsError" class="notification is-danger">
                  <button class="delete" @click="irodsError=''"></button>
                  {{irodsError}}
                </div>
                <div class="spinner-container" v-if="irodsWaiting">
                  <icon name="spinner" class="icon is-medium fa-spin"></icon>
                </div>

                <div v-if="!irodsUsername" class="login-div">
                  <div class="login-text">Login CyVerse</div>
                  <div class="field">
                    <p class="control has-icons-left">
                      <input class="input" type="text" placeholder="Username" v-model="irodsUsernameInput">
                      <span class="icon is-small is-left">
                        <icon name="user"></icon>
                      </span>
                    </p>
                  </div>

                  <div class="field">
                    <p class="control has-icons-left">
                      <input class="input" type="password" placeholder="Password" v-model="irodsPasswordInput">
                      <span class="icon is-small is-left">
                        <icon name="key"></icon>
                      </span>
                    </p>
                  </div>

                  <div class="field is-grouped">
                    <p class="control">
                      <button class="button main-btn" :class="{'is-loading': irodsWaiting}" @click="loginIrods">Login</button>
                    </p>
                  </div>
                </div>

                <div v-if="!irodsWaiting && irodsUsername && irodsFolder">
                  <div>
                    <span v-for="(node, i) in irodsAddress">
                      <span>/</span>
                      <a class="main-link" @click="changeIrodsFolder(node)">{{node.name}}</a>&nbsp;
                    </span>
                  </div>
                  <div>
                    <table class="table is-narrow is-fullwidth">
                      <thead>
                        <tr>
                          <th class="number-cell clickable" @click="toggleAll(irodsFiles)">{{irodsFiles.length}}</th>
                          <th class="text-cell">Type</th>
                          <th class="text-cell">Name</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="f in irodsFiles" :key="f.path" class="entry" :class="{'selected': f.selected}">
                          <td class="number-cell">
                            <input type="checkbox" class="clickable" v-model="f.selected" @click="toggleSelected(irodsFiles, f)">
                          </td>
                          <td class="text-cell">
                            <icon class="type-icon" v-if="f.type=='folder'" name="folder"></icon>
                            <icon class="type-icon" v-if="f.type=='file'" name="file-o"></icon>
                          </td>
                          <td><span @click="changeIrodsFolder(f)" :class="{'clickable': f.type=='folder'}">{{f.name}}</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                  <div class="column-button">
                    <a class="button is-primary" :disabled="!canTransterFrom">
                      <icon name="arrow-left"></icon>&nbsp;Transfer {{irodsSelected.length}} To DMAC
                    </a>
                  </div>
                </div>
                
              </div>
            </div>
        </section>
        <footer class="modal-card-foot">
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'irods-modal',
  props: ['opened', 'folder'],
  data () {
    return {
      dmacError: '',
      dmacWaiting: false,
      dmacFolder: null,
      dmacFiles: null,
      irodsError: '',
      irodsWaiting: false,
      irodsFolder: null,
      irodsFiles: null,
      irodsUsernameInput: '',
      irodsPasswordInput: ''
    }
  },
  computed: {
    projectId () {
      return this.$route.params.projectId
    },
    nodeMap () {
      return this.$store.state.projects.nodeMap
    },
    project () {
      return this.nodeMap['/projects/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    dmacAddress () {
      var nodes = []
      if(!this.dmacFolder)
        return nodes
      var dataPath = this.dmacFolder.dataPath
      var ss = dataPath.split('/')
      var dp = ''
      for(var i=0;i<ss.length;i++){
        if(ss[i]){
          dp = dp + '/' + ss[i]
          var node = { name: ss[i], dataPath: dp }
          nodes.push(node)
        }else if(i == 0){
          var name = 'Project'
          var node = { name: name, dataPath: '/' }
          nodes.push(node)
        }
      }
      return nodes
    },
    dmacSelected () {
      var selected = []
      if(this.dmacFiles){
        this.dmacFiles.forEach(function(f){
          if(f.selected)
            selected.push(f)
        })
      }
      return selected
    },
    canTransterTo () {
      return this.dmacSelected.length
    },
    irodsUsername () {
      return this.$store.state.irods.username
    },
    irodsPassword () {
      return this.$store.state.irods.password
    },
    irodsPath () {
      var path = this.$store.state.irods.irodsPath
      if(!path){
        path = '/iplant/home/' + this.irodsUsername
      }
      return path
    },
    irodsAddress () {
      var nodes = []
      if(!this.irodsFolder)
        return nodes
      var path = this.irodsFolder.path
      var ss = path.split('/')
      var p = ''
      for(var i=1;i<ss.length;i++){
        p = p + '/' + ss[i]
        var node = { name: ss[i], path: p, type: 'folder' }
        nodes.push(node)
      }
      return nodes
    },
    irodsSelected () {
      var selected = []
      if(this.irodsFiles){
        this.irodsFiles.forEach(function(f){
          if(f.selected)
            selected.push(f)
        })
      }
      return selected
    },
    canTransterFrom () {
      return this.irodsSelected.length
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.dmacError = ''
        this.dmacWaiting = false
        this.dmacFolder = null
        this.dmacFiles = null
        this.requestDmacFolder(this.folder.dataPath)

        this.irodsError = ''
        this.irodsWaiting = false
        this.irodsFolder = null
        this.irodsFiles = null
        this.irodsUsernameInput = ''
        this.irodsPasswordInput = ''
        if(this.irodsUsername){
          this.requestIrodsFolder(this.irodsUsername, this.irodsPassword, this.irodsPath)
        }
      }
    }
  },
  methods: {
    close(){
      this.$emit('close-irods-modal')
    },
    requestDmacFolder (dp) {
      var dataPath = encodeURIComponent(dp)
      dataPath = encodeURIComponent(dataPath)
      this.dmacWaiting = true
      this.$http.get(xHTTPx + '/get_file/' + this.projectId + '/' + dataPath).then(response => {
        var resp = response.body
        this.updateDmacFolder(resp)
        this.dmacError = ''
        this.dmacWaiting = false
      }, response => {
        this.dmacError = 'Failed to get folder!'
        this.dmacWaiting = false
      })
    },
    updateDmacFolder (resp) {
      this.dmacFolder = resp[1]
      var files = resp.slice(2)
      files.forEach(function(f){
        f.selected = false
      })
      files.sort(function(a, b){
        if(a.type == b.type){
          return a.name.localeCompare(b.name)
        }
        if(a.type == 'folder')
          return -1
        return 1
      })
      this.dmacFiles = files
    },
    toggleSelected (files, f) {
      var index = files.indexOf(f)
      files.splice(index, 1, f)
    },
    toggleAll (files) {
      if(!files.length)
        return
      var firstSelected = files[0].selected
      for(var i=0;i<files.length;i++){
        var file = files[i]
        file.selected = !firstSelected
        files.splice(i, 1, file)
      }
    },
    changeDmacFolder (f) {
      if(f.type == 'file')
        return
      if(f.dataPath == this.dmacFolder.dataPath)
        return
      this.requestDmacFolder(f.dataPath)
    },
    requestIrodsFolder (username, password, path) {
      var message = {username: username, password: password, path: path}
      this.irodsWaiting = true
      this.$http.post(xHTTPx + '/list_irods_path', message).then(response => {
        var resp = response.body
        this.$store.commit('irods/setUsername', username)
        this.$store.commit('irods/setPassword', password)
        this.$store.commit('irods/setIrodsPath', path)
        var files = resp
        files.forEach(function(f){
          f.selected = false
        })
        files.sort(function(a, b){
          if(a.type == b.type){
            return a.name.localeCompare(b.name)
          }
          if(a.type == 'folder')
            return -1
          return 1
        })
        this.irodsFiles = files
        var ss = path.split('/')
        this.irodsFolder = {path: path, type: 'folder', name: ss[ss.length-1]}
        this.irodsWaiting = false
      }, response => {
        this.irodsError = 'Failed.'
        this.irodsWaiting = false
      })
    },
    loginIrods () {
      var path = '/iplant/home/' + this.irodsUsernameInput
      this.requestIrodsFolder(this.irodsUsernameInput, this.irodsPasswordInput, path)
    },
    changeIrodsFolder (f) {
      if(f.type == 'file')
        return
      if(f.path == this.irodsFolder.path)
        return
      this.requestIrodsFolder(this.irodsUsername, this.irodsPassword, f.path)
    },
  },
}
</script>

<style lang="scss" scoped>

.modal-body {
    color: black;
    font-size: 16px;
}

.wide-modal {
  width: 800px;
}

.column-header {
  font-weight: bold;
  text-align: center;
}

.column-button {
  text-align: center;
}

.dmac-column {
  padding-right: 30px;
}

.irods-column {
  padding-left: 30px;
}

.text-cell {
  text-align: center;
}

.number-cell {
  text-align: right;
}

.type-icon {
  position: relative;
  top: 3px;
}

.clickable {
  cursor: pointer;
}

.selected {
  background-color: #f2f2f2;
}

.login-div {
  padding: 20px;

  .login-text {
    padding-bottom: 10px;
  }
}


</style>