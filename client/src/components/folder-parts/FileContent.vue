<template>
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
        <tr v-for="(f, i) in content" :class="{'folder': f.type=='folder'}" @click="viewFile(f)">
          <td class="number-cell">{{i+1}}</td>
          <td class="text-cell">
            <icon v-if="f.type=='folder'" name="folder-o"></icon>
            <icon v-if="f.type=='file'" name="file-o"></icon>
          </td>
          <td class="text-cell">{{f.name}}</td>
          <td class="number-cell"><span v-if="f.type=='file'">{{f.size}}</span></td>
          <td class="text-cell">{{f.modifiedAt}}</td>
          <td class="text-cell">
            <a v-if="role!='Viewer' && ( role=='Editor' ? f.type=='file' : true )"
              @click.stop="openEditNameModal(f)"
              class="edit-icon">
              <icon name="edit"></icon>
            </a>
          </td>
        </tr>
      </tbody>
    </table>

    <edit-name-modal
      :opened="editNameModal.opened"
      :role="role"
      :files="content"
      :file="editNameModal.file"
      @close-edit-name-modal="closeEditNameModal">
    </edit-name-modal>
  </div>
</template>

<script>
import EditNameModal from '../modals/EditNameModal'

export default {
  name: 'file-content',
  components: {
    EditNameModal
  },
  props: ['content', 'project'],
  data () {
    return {
      editNameModal: {
        opened: false,
        file: null
      },
    }
  },
  computed: {
    role () {
      return this.project && this.project.projectRole
    }
  },
  methods: {
    viewFile (f) {
      if(f.type == 'folder'){
        this.$router.push(f.path)
      }
    },
    openEditNameModal(f){
      this.editNameModal.file = f
      this.editNameModal.opened = true
    },
    closeEditNameModal(result){
      this.editNameModal.opened = false
      if(result){
        this.$emit('file-changed', true)
      }
    }
  },
}
</script>

<style lang="scss" scoped>

.file-content {
  margin-top: 5px;
}

.folder{
  cursor: pointer;
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

.edit-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}


</style>
