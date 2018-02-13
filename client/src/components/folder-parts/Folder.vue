<template>
  <div>
    <nav class="navbar is-transparent" role="navigation" aria-label="dropdown navigation">
      <div class="navbar-menu is-active">
        <div class="navbar-start">
          <div class="view-title">
            <span class="main-link search-button" @click="openSearch">
              <icon name="search"></icon>
            </span>&nbsp;
            {{folder && folder.name}}
            <a class="main-link" v-if="folder.publicUrl" :href="folder.publicUrl" target="_blank">
              <icon class="action-icon" name="share-alt"></icon>
            </a>
            <span class="tag is-warning folder-tag" v-if="folder && folder.dataPath!='/' && folder.access==1">Readonly</span>
            <span class="tag is-danger folder-tag" v-if="folder && folder.dataPath!='/' && folder.access==2">Hidden</span>
            <a v-if="folder.dataPath != '/' && canEditFolder"
              @click="emitOpenEditFolderModal"
              class="main-link">
              <icon class="action-icon" name="edit"></icon>
            </a>
          </div>
        </div>
        <div class="navbar-end">
          <div class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link actions-label">
              Actions
            </a>

            <div class="navbar-dropdown is-right is-boxed">
              <a class="navbar-item action-item" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewFolderModal">
                <icon name="plus"></icon>&nbsp;&nbsp;New Folder
              </a>
              <a class="navbar-item action-item" v-if="canEditFolder" @click="openNewFileModal">
                <icon name="plus"></icon>&nbsp;&nbsp;New File
              </a>
              <a class="navbar-item action-item" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewMetaModal">
                <icon name="plus"></icon>&nbsp;&nbsp;Meta Data File
              </a>
              <a class="navbar-item action-item" v-if="canEditFolder" @click="openFileUploadModal">
                <icon name="upload"></icon>&nbsp;&nbsp;Upload File
              </a>
              <a class="navbar-item action-item" v-if="(projectRole=='Owner' || projectRole=='Admin') && folder.dataPath != '/'" @click="openNewChannelModal">
                <icon name="plus"></icon>&nbsp;&nbsp;New Channel
              </a>
              <a class="navbar-item action-item" v-if="(projectRole=='Owner' || projectRole=='Admin') && selectedDataPaths.length" @click="deleteSelection">
                <icon name="minus"></icon>&nbsp;&nbsp;Delete Selected ({{selectedDataPaths.length}})
              </a>
              <hr class="navbar-divider" v-if="canEditFolder">
              <a class="navbar-item action-item" v-if="projectRole" @click="copySelection">
                <icon name="copy"></icon>&nbsp;&nbsp;Copy Selected ({{selectedDataPaths.length}})
              </a>
              <a class="navbar-item action-item" v-if="canEditFolder && canPaste" @click="pasteSelection">
                <icon name="paste"></icon>&nbsp;&nbsp;Paste ({{clipboardSize}}) Here
              </a>
              <hr class="navbar-divider" v-if="(projectRole=='Owner' || projectRole=='Admin')">
              <a class="navbar-item action-item" v-if="(projectRole=='Owner' || projectRole=='Admin')" @click="openSaveHistoryModal">
                <icon name="history"></icon>&nbsp;&nbsp;New History Record
              </a>
              <hr class="navbar-divider" v-if="(projectRole=='Owner' || projectRole=='Admin') && folder.dataPath != '/'">
              <a class="navbar-item action-item" v-if="(projectRole=='Owner' || projectRole=='Admin') && folder.dataPath != '/'" @click="publicFolder">
                <icon name="share-alt"></icon>&nbsp;&nbsp;Publish
              </a>
            </div>
          </div>
        </div>
      </div>
    </nav>


    <div class="file-content" @drop.prevent="dropFiles" @dragover.prevent>
      <table class="table is-narrow is-fullwidth is-hoverable">
        <thead>
          <tr>
            <th class="number-cell is-clickable" @click="toggleAll">{{files.length}}</th>
            <th class="text-cell is-clickable" @click="sortNodeChildren('type', typeOrder)">Type
              <span v-if="sortOption.field=='type'">
                <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                <icon name="sort-desc" v-if="!sortOption.asc"></icon>
              </span>
            </th>
            <th class="is-clickable" @click="sortNodeChildren('name', 'string')">Name
              <span v-if="sortOption.field=='name'">
                <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                <icon name="sort-desc" v-if="!sortOption.asc"></icon>
              </span>
            </th>
            <th class="number-cell is-clickable" @click="sortNodeChildren('size', 'number')">Size
              <span v-if="sortOption.field=='size'">
                <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                <icon name="sort-desc" v-if="!sortOption.asc"></icon>
              </span>
            </th>
            <th class="text-cell is-clickable" @click="sortNodeChildren('modifiedTime', 'number')">Modified At
              <span v-if="sortOption.field=='modifiedTime'">
                <icon class="asc-icon" name="sort-asc" v-if="sortOption.asc"></icon>
                <icon name="sort-desc" v-if="!sortOption.asc"></icon>
              </span>
            </th>
            <th class="text-cell">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(f, i) in files" class="entry" :class="{'folder': f.type=='folder'}" @click="viewFile(f)">
            <td class="number-cell" @click.stop="toggleSelected(f)">
              <input v-if="projectRole" type="checkbox" v-model="selection[f.path]" @click.stop="toggleSelected(f)">
            </td>
            <td class="text-cell">
              <icon class="type-icon" v-if="f.type=='folder'" name="folder-o"></icon>
              <span v-if="f.type=='file'">
                <icon class="type-icon" :name="f.icon"></icon>
              </span>
            </td>
            <td>
              {{f.name}}
              <span v-if="f.publicUrl">*</span>
              <span v-if="folder.dataPath=='/' || folder.access < f.access">
                <span class="tag is-warning" v-if="f.access==1">Readonly</span>
                <span class="tag is-danger" v-if="f.access==2">Hidden</span>
              </span>
            </td>
            <td class="number-cell">
              <span class="tooltip">
                {{f.sizeLabel}}
                <span class="tooltiptext">{{f.size}}</span>
              </span>
            </td>
            <td class="text-cell">{{f.modifiedAt}}</td>
            <td class="text-cell">
              <a v-if="projectRole && projectRole!='Viewer' && ( projectRole=='Editor' ? (project.status=='Active' && f.type=='file' && f.access==0) : true )"
                @click.stop="openEditModal(f)"
                class="action-icon main-link">
                <icon name="edit"></icon>
              </a>
              <a v-if="!urls[f.path]"
                @click.stop="getDownloadUrl(f)"
                class="action-icon main-link">
                <icon name="download"></icon>
              </a>
              <a class="main-link" v-if="urls[f.path]" :href="urls[f.path]" @click.stop="">link</a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="empty-label" v-if="!waiting && (!files || !files.length)">(Empty)</div>

    <new-folder-modal
      :opened="newFolderModal.opened"
      :role="projectRole"
      :files="files"
      :project-id="projectId"
      :data-path="folder && folder.dataPath"
      @close-new-folder-modal="closeNewFolderModal">
    </new-folder-modal>

    <new-file-modal
      :opened="newFileModal.opened"
      :role="projectRole"
      :files="files"
      :project-id="projectId"
      :data-path="folder && folder.dataPath"
      @close-new-file-modal="closeNewFileModal">
    </new-file-modal>

    <new-meta-modal
      :opened="newMetaModal.opened"
      :role="projectRole"
      :files="files"
      :project-id="projectId"
      :data-path="folder && folder.dataPath"
      @close-new-meta-modal="closeNewMetaModal">
    </new-meta-modal>

    <file-upload-modal
      :opened="fileUploadModal.opened"
      :project-id="projectId"
      :data-path="folder && folder.dataPath"
      :drop-files="fileUploadModal.dropFiles"
      @close-file-upload-modal="closeFileUploadModal">
    </file-upload-modal>

    <edit-folder-modal
      :opened="editFolderModal.opened"
      :role="projectRole"
      :files="files"
      :file="editFolderModal.file"
      @close-edit-folder-modal="closeEditFolderModal">
    </edit-folder-modal>

    <edit-file-modal
      :opened="editFileModal.opened"
      :role="projectRole"
      :file="editFileModal.file"
      @close-edit-file-modal="closeEditFileModal">
    </edit-file-modal>

    <confirm-modal
      :opened="confirmModal.opened"
      :message="confirmModal.message"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>

    <save-history-modal
      :opened="saveHistoryModal.opened"
      :project-id="projectId"
      @close-save-history-modal="closeSaveHistoryModal">
    </save-history-modal>

    <new-channel-modal
      :opened="newChannelModal.opened"
      :project="project"
      :target="folder && folder.dataPath"
      @close-new-channel-modal="closeNewChannelModal">
    </new-channel-modal>
  </div>
</template>

<script>
import NewFolderModal from '../modals/NewFolderModal'
import NewFileModal from '../modals/NewFileModal'
import NewMetaModal from '../modals/NewMetaModal'
import FileUploadModal from '../modals/FileUploadModal'
import EditFolderModal from '../modals/EditFolderModal'
import EditFileModal from '../modals/EditFileModal'
import ConfirmModal from '../modals/ConfirmModal'
import SaveHistoryModal from '../modals/SaveHistoryModal'
import NewChannelModal from '../modals/NewChannelModal'

export default {
  name: 'folder',
  props: ['waiting', 'folder'],
  components: {
    NewFolderModal,
    NewFileModal,
    NewMetaModal,
    FileUploadModal,
    EditFolderModal,
    EditFileModal,
    ConfirmModal,
    SaveHistoryModal,
    NewChannelModal
  },
  data () {
    return {
      newFolderModal: {
        opened: false
      },
      newFileModal: {
        opened: false
      },
      newMetaModal: {
        opened: false
      },
      fileUploadModal: {
        opened: false,
        dropFiles: null
      },
      editFolderModal: {
        opened: false,
        file: null
      },
      editFileModal: {
        opened: false,
        file: null
      },
      confirmModal: {
        opened: false,
        message: '',
        context: null
      },
      saveHistoryModal: {
        opened: false
      },
      urls: {},
      typeOrder: ['folder', 'file'],
      pasting: false,
      selection: {},
      newChannelModal: {
        opened: false
      },
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
    canEditFolder () {
      if(!this.folder) return false
      if(!this.projectRole) return false
      if(this.projectRole == 'Viewer') return false
      if(this.projectRole == 'Owner' || this.projectRole == 'Admin') return true
      if(this.project.status != "Active") return false
      if(this.folder.dataPath == '/') return false
      return this.folder.access == 0
    },
    files () {
      if(this.folder){
        var vm = this
        return this.folder.children.map(function(c){
          return vm.nodeMap[c]
        })
      }
      return []
    },
    sortOption () {
      if(this.folder) return this.folder.options.sortOption
      return {}
    },
    clipboard () {
      return this.$store.state.projects.clipboard
    },
    clipboardSize () {
      return this.clipboard.dataPaths.length
    },
    canPaste () {
      return this.clipboard.projectId && this.clipboardSize
    },
    selectedDataPaths () {
      var dataPaths =[]
      for(var i=0;i<this.files.length;i++){
        var f = this.files[i]
        if(f.options.selected){
          dataPaths.push(f.dataPath)
        }
      }
      return dataPaths
    },
    publicKey () {
      return this.$route.params.publicKey
    },
  },
  watch: {
    files: function (val) {
      this.reloadSelection()
    },
  },
  methods: {
    openNewFolderModal(){
      this.newFolderModal.opened = true
    },
    closeNewFolderModal(result){
      this.newFolderModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    openNewFileModal(){
      this.newFileModal.opened = true
    },
    closeNewFileModal(result){
      this.newFileModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    openNewMetaModal(){
      this.newMetaModal.opened = true
    },
    closeNewMetaModal(result){
      this.newMetaModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    openFileUploadModal(){
      this.fileUploadModal.dropFiles = null
      this.fileUploadModal.opened = true
    },
    closeFileUploadModal(result){
      this.fileUploadModal.dropFiles = null
      this.fileUploadModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    viewFile (f) {
      this.$router.push(f.path)
    },
    openEditModal(f){
      if(f.type == 'folder'){
        this.openEditFolderModal(f)
      }else{
        this.openEditFileModal(f)
      }
    },
    openEditFolderModal(f){
      this.editFolderModal.file = f
      this.editFolderModal.opened = true
    },
    closeEditFolderModal(result){
      this.editFolderModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    openEditFileModal(f){
      this.editFileModal.file = f
      this.editFileModal.opened = true
    },
    closeEditFileModal(result){
      this.editFileModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    getDownloadUrl(f) {
      var dataPath = encodeURIComponent(f.dataPath)
      dataPath = encodeURIComponent(dataPath)
      if(this.publicKey){
        this.$http.get(xHTTPx + '/get_public_download_url/' + this.publicKey + "/" + f.projectId + "/" + dataPath).then(response => {
          var url = xHTTPx + response.body
          this.$set(this.urls, f.path, url)
        }, response => {
          console.log('failed to get url')
        })
      }else{
        this.$http.get(xHTTPx + '/get_download_url/' + f.projectId + "/" + dataPath).then(response => {
          var url = xHTTPx + response.body
          this.$set(this.urls, f.path, url)
        }, response => {
          console.log('failed to get url')
        })
      }
    },
    sortNodeChildren(field, order){
      this.$store.commit('projects/sortNodeChildren', {path: this.folder.path, field: field, order: order})
    },
    reloadSelection(){
      var selection = {}
      for(var i=0;i<this.files.length;i++){
        var f = this.files[i]
        selection[f.path] = f.options.selected
      }
      this.selection = selection
    },
    toggleSelected(f){
      this.$store.commit('projects/toggleSelected', f.path)
      this.selection[f.path] = f.options.selected
    },
    toggleAll(){
      for(var i=0;i<this.files.length;i++){
        var f = this.files[i]
        this.toggleSelected(f)
      }
    },
    copySelection(){
      this.$store.commit('projects/copySelection', {projectId: this.projectId, dataPaths: this.selectedDataPaths})
    },
    pasteSelection(){
      if(!this.canPaste) return
      this.pasting = true
      var message = {
        'sourceProjectId': this.clipboard.projectId,
        'sourceDataPaths': this.clipboard.dataPaths.join(','),
        'targetProjectId': this.projectId,
        'targetDataPath': this.folder.dataPath
      }
      this.$http.post(xHTTPx + '/copy_folder_file', message).then(response => {
        this.pasting = false
        this.$emit('content-changed', true)
      }, response => {
        this.pasting = false
        console.log('failed to paste')
      })
    },
    publicFolder(){
      var message = 'Are you sure to make this folder public?'
      var context = {callback: this.publicFolderConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    publicFolderConfirmed(){
      var message = {
        'projectId': this.projectId,
        'dataPath': this.folder.dataPath
      }
      this.$http.post(xHTTPx + '/make_folder_public', message).then(response => {
        this.$emit('content-changed', true)
      }, response => {
        console.log('failed to make public')
      })
    },
    openConfirmModal(message, context){
      this.confirmModal.message = message
      this.confirmModal.context = context
      this.confirmModal.opened = true
    },
    closeConfirmModal(result){
      this.confirmModal.message = ''
      this.confirmModal.opened = false
      if(result && this.confirmModal.context){
          var context = this.confirmModal.context
          if(context.callback){
              context.callback.apply(this, context.args)
          }
      }
      this.confirmModal.context = null
    },
    openSearch(){
      var searchPath = this.$route.path.replace('/data/', '/search/')
      this.$router.push(searchPath)
    },
    deleteSelection(){
      var message = 'Are you sure to delete the selected ' + this.selectedDataPaths.length + ' item(s)?'
      var context = {callback: this.deleteSelectionConfirmed, args: []}
      this.openConfirmModal(message, context)
    },
    deleteSelectionConfirmed(){
      var message = {
        'projectId': this.projectId,
        'dataPaths': this.selectedDataPaths.join(',')
      }
      this.$http.post(xHTTPx + '/delete_multiple', message).then(response => {
        this.$emit('content-changed', true)
      }, response => {
        console.log('failed to delete files')
      })
    },
    dropFiles(e){
      this.fileUploadModal.dropFiles = e.target.files || e.dataTransfer.files
      this.$nextTick(function(){
        this.fileUploadModal.opened = true
      })
    },
    openSaveHistoryModal () {
      this.saveHistoryModal.opened = true
    },
    closeSaveHistoryModal(result){
      this.saveHistoryModal.opened = false
    },
    emitOpenEditFolderModal(){
      this.$emit('open-edit-folder-modal')
    },
    openNewChannelModal(){
      this.newChannelModal.opened = true
    },
    closeNewChannelModal(result){
      this.newChannelModal.opened = false
    }
  },
  mounted () {
    this.reloadSelection()
  }
}
</script>

<style lang="scss" scoped>

.empty-label {
  text-align: center;
}

.file-content {
  margin-top: 5px;
}

.entry {
  cursor: pointer;
}

.folder{
  background-color: #f2f2f2;
}

.folder:hover{
  background-color: #EEEEEE;
}

.text-cell {
  text-align: center;
}

.number-cell {
  text-align: right;
}

.action-icon {
  position: relative;
  top: 3px;
}

.type-icon {
  position: relative;
  top: 3px;
}

.asc-icon {
  position: relative;
  top: 5px;
}

.is-clickable {
  cursor: pointer;
}

.tooltip {
  position: relative;
  display: inline-block;
}
.tooltip .tooltiptext {
  visibility: hidden;
  background-color: #363636;
  color: white;
  font-size: 14px;
  text-align: center;
  border-radius: 5px;
  padding: 5px 5px;
  /* Position the tooltip */
  position: absolute;
  left: 0px;
  z-index: 10;
}
.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 0.9;
}

.folder-tag {
  position: relative;
  top: -3px;
}

.actions-label {
  color: #2e1052;
  font-weight: bold;
}

.action-item {
  font-weight: bold;
  color: #2e1052;
}

.action-item:hover {
  color: #866ba6!important;
  font-weight: bold;
}
</style>
