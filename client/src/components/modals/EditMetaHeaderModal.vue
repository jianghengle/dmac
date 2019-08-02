<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Header</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Columns</label>
            <div class="field is-grouped" v-for="(c, i) in newHeader">
              <p class="control">
                <input class="input" :class="{'is-danger': c.deleted, 'column-deleted': c.deleted, 'is-success': c.new}" type="text" placeholder="Column Name" v-model="c.name">
              </p>
              <p class="control is-expanded">
                <input class="input" :class="{'is-danger': c.deleted, 'column-deleted': c.deleted, 'is-success': c.new}" type="text" placeholder="Column Option" v-model="c.option">
              </p>
              <p class="control">
                <a class="button" v-if="c.deleted" @click="c.deleted = false">
                  <icon name="repeat"></icon>
                </a>
                <a class="button" v-if="!c.deleted" @click="deleleColumn(i)">
                  <icon name="minus"></icon>
                </a>
                <a class="button" @click="addColumn(i)">
                  <icon name="plus"></icon>
                </a>
              </p>
            </div>
            <p class="help is-info">{{fieldTip}}</p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!changed" @click="updateFile">Update</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'edit-meta-header-modal',
  props: ['opened', 'file', 'metaHeader', 'metaRows'],
  data () {
    return {
      error: '',
      waiting: false,
      newHeader: [],
      fieldTip: "Leave the option entry empty if not appliable. Selectable options must be seperated by '|', e.g. \"opt1 | opt2 | *\". Use '|*' to add an \"Other\" option for be specified. If you want to make multiple checkable options, use ',' to seperate the options, e.g. \"opt1, opt2\". Use ',*' to allow other options. If this is a channel meta data file, and you want to add a field for uploading files, fill the \"Option\" with \"file\" or \"files\". You could also specify the file types to be accepted by filling the \"Option\" with e.g.\"file: .txt, .pdf, .xls\"."
    }
  },
  computed: {
    newLine () {
      return this.makeHeaderLine(this.newHeader)
    },
    changed () {
      var oldLine = this.makeHeaderLine(this.metaHeader)
      return oldLine != this.newLine
    },

  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.newHeader = this.metaHeader.map(function(h){
          return {name: h.name, option: h.option, deleted: false, new: false}
        })
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-edit-meta-header-modal', false)
    },
    updateFile(){
      if(!this.changed) return
      this.waiting = true
      var text = this.newLine + '\n' + this.makeLines(this.metaRows)
      var message = {projectId: this.file.projectId, dataPath: this.file.dataPath, text: text}
      this.$http.post(xHTTPx + '/save_text_file', message).then(response => {
        this.waiting = false
        this.$emit('close-edit-meta-header-modal', true)
      }, response => {
        this.error = 'Failed to save file!'
        this.waiting = false
      })
    },
    deleleColumn (i) {
      var col = this.newHeader[i]
      if(col.new){
        this.newHeader.splice(i, 1)
      }else{
        col.deleted = true
      }
    },
    addColumn (i) {
      var newCol = {name: '', option: '', deleted: false, new: true}
      this.newHeader.splice(i+1, 0, newCol)
    },
    makeHeaderLine (header) {
      var ss = []
      for(var i=0;i<header.length;i++){
        if(header[i].deleted || !header[i].name)
          continue
        var s = header[i].name
        if(header[i].option)
          s += ' {' + header[i].option + '}'
        ss.push(s)
      }
      return ss.join('\t')
    },
    makeLines (metaRows) {
      var lines = []
      metaRows.forEach(function(row){
        var cells = []
        row.forEach(function(cell){
          if(Array.isArray(cell)){
            cells.push(cell.join(', '))
          }else{
            cells.push(cell)
          }
        })
        lines.push(cells.join('\t'))
      })
      return lines.join('\n')
    }
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

.column-deleted {
  text-decoration: line-through;
}
</style>