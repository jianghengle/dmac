<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon name="folder-open-o"></icon>&nbsp;
        {{folder && folder.name}}
      </div>
      <div class="column buttons">
        <a class="button" v-if="projectRole=='Owner' || projectRole=='Admin'" @click="openNewFolderModal">
          <icon name="plus"></icon>&nbsp;
          Folder
        </a>
        <a class="button" v-if="projectRole && projectRole!='Viewer'" @click="openFileUploadModal">
          <icon name="upload"></icon>&nbsp;
          File
        </a>
      </div>
    </div>

    <div class="file-content">
      <table class="table is-narrow">
        <thead>
          <tr>
            <th class="number-cell">#</th>
            <th class="text-cell">Type</th>
            <th class="text-cell">Name</th>
            <th class="number-cell">Size</th>
            <th class="text-cell">Modified At</th>
            <th class="text-cell">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(f, i) in files" class="entry" :class="{'folder': f.type=='folder'}" @click="viewFile(f)">
            <td class="number-cell">{{i+1}}</td>
            <td class="text-cell">
              <icon v-if="f.type=='folder'" name="folder-o"></icon>
              <span v-if="f.type=='file'">
                <icon :name="f.icon"></icon>
              </span>
            </td>
            <td class="text-cell">{{f.name}}</td>
            <td class="number-cell"><span v-if="f.type=='file'">{{f.size}}</span></td>
            <td class="text-cell">{{f.modifiedAt}}</td>
            <td class="text-cell">
              <a v-if="projectRole!='Viewer' && ( projectRole=='Editor' ? f.type=='file' : true )"
                @click.stop="openEditNameModal(f)"
                class="action-icon">
                <icon name="edit"></icon>
              </a>
              <a v-if="f.type=='file' && !urls[f.path]"
                @click.stop="getDownloadUrl(f)"
                class="action-icon">
                <icon name="download"></icon>
              </a>
              <a v-if="urls[f.path]" :href="urls[f.path]">link</a>
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

    <file-upload-modal
      :opened="fileUploadModal.opened"
      :project-id="projectId"
      :data-path="folder && folder.dataPath"
      @close-file-upload-modal="closeFileUploadModal">
    </file-upload-modal>

    <edit-name-modal
      :opened="editNameModal.opened"
      :role="projectRole"
      :files="files"
      :file="editNameModal.file"
      @close-edit-name-modal="closeEditNameModal">
    </edit-name-modal>
  </div>
</template>

<script>
import NewFolderModal from '../modals/NewFolderModal'
import FileUploadModal from '../modals/FileUploadModal'
import EditNameModal from '../modals/EditNameModal'

export default {
  name: 'folder',
  props: ['waiting', 'folder'],
  components: {
    NewFolderModal,
    FileUploadModal,
    EditNameModal
  },
  data () {
    return {
      newFolderModal: {
        opened: false
      },
      fileUploadModal: {
        opened: false
      },
      editNameModal: {
        opened: false,
        file: null
      },
      urls: {}
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
      return this.nodeMap['/' + this.projectId]
    },
    projectRole () {
      return this.project && this.project.projectRole
    },
    files () {
      if(this.folder){
        var vm = this
        return this.folder.children.map(function(c){
          return vm.nodeMap[c]
        })
      }
      return []
    }
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
    openFileUploadModal(){
      this.fileUploadModal.opened = true
    },
    closeFileUploadModal(result){
      this.fileUploadModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    viewFile (f) {
      this.$router.push(f.path)
    },
    openEditNameModal(f){
      this.editNameModal.file = f
      this.editNameModal.opened = true
    },
    closeEditNameModal(result){
      this.editNameModal.opened = false
      if(result){
        this.$emit('content-changed', true)
      }
    },
    getDownloadUrl(f) {
      this.$http.get(xHTTPx + '/get_download_url/' + this.projectId + "/" + f.dataPath).then(response => {
        var url = xHTTPx + response.body
        this.$set(this.urls, f.path, url)
      }, response => {
        console.log('failed to get url')
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.empty-label {
  text-align: center;
}

.buttons {
  text-align: right;
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
  color: #3273dc;
  position: relative;
  top: 3px;
}
</style>
