<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Edit Row</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>

          <div class="field" v-for="(c, i) in newRow">
            <label class="label">{{metaHeader[i] ? metaHeader[i].name : '(None)'}}</label>
            <div class="field is-grouped column-value">
              <p class="control is-expanded">
                <input class="input" :class="{'is-danger': c.deleted, 'column-deleted': c.deleted, 'is-success': c.new}" type="text" placeholder="Column Value" v-model="c.value">
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
            <p class="help is-info" v-if="metaHeader[i] && metaHeader[i].option">{{metaHeader[i].option}}</p>
          </div>
          
        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!changed" @click="updateFile">Update</a>
          <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteRow">Delete Row</a>
          <a class="button button-right" @click="close">Cancel</a>
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'edit-meta-row-modal',
  props: ['opened', 'file', 'metaHeader', 'metaRows', 'rowIndex'],
  data () {
    return {
      error: '',
      waiting: false,
      newRow: [],
      oldLines: ''
    }
  },
  computed: {
    newLines () {
      return this.makeLines(this.metaRows, this.rowIndex, this.newRow)
    },
    changed () {
      return this.oldLines != this.newLines
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.newRow = this.metaRows[this.rowIndex].map(function(cell){
          var value = cell
          if(Array.isArray(cell)){
            value = cell.join(', ')
          }
          return {value: value, deleted: false, new: false}
        })
        this.oldLines = this.makeLines(this.metaRows, this.newRow, this.newRow)
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-edit-meta-row-modal', false)
    },
    updateFile(){
      if(!this.changed) return
      this.waiting = true
      var text = this.makeHeaderLine(this.metaHeader) + '\n' + this.newLines
      var message = {projectId: this.file.projectId, dataPath: this.file.dataPath, text: text}
      this.$http.post(xHTTPx + '/save_text_file', message).then(response => {
        this.waiting = false
        this.$emit('close-edit-meta-row-modal', true)
      }, response => {
        this.error = 'Failed to save file!'
        this.waiting = false
      })
    },
    deleteRow(){
      if(this.changed) return
      this.waiting = true
      var text = this.makeHeaderLine(this.metaHeader) + '\n' + this.makeLines(this.metaRows, this.rowIndex)
      var message = {projectId: this.file.projectId, dataPath: this.file.dataPath, text: text}
      this.$http.post(xHTTPx + '/save_text_file', message).then(response => {
        this.waiting = false
        this.$emit('close-edit-meta-row-modal', true)
      }, response => {
        this.error = 'Failed to save file!'
        this.waiting = false
      })
    },
    deleleColumn (i) {
      var col = this.newRow[i]
      if(col.new){
        this.newRow.splice(i, 1)
      }else{
        col.deleted = true
      }
    },
    addColumn (i) {
      var newCol = {value: '', deleted: false, new: true}
      this.newRow.splice(i+1, 0, newCol)
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
    makeLines (metaRows, index, newRow) {
      var lines = []
      for(var i=0;i<metaRows.length;i++){
        var cells = []
        if(i == index){
          if(!newRow)
            continue
          for(var j=0;j<newRow.length;j++){
            var cell = newRow[j]
            if(!cell.deleted){
              cells.push(cell.value)
            }
          }
        }else{
          var row = metaRows[i]
          for(var j=0;j<row.length;j++){
            var cell = row[j]
            if(Array.isArray(cell)){
              cells.push(cell.join(', '))
            }else{
              cells.push(cell)
            }
          }          
        }
        lines.push(cells.join('\t'))
      }
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

.column-value {
  margin-bottom: 0px;
}

.column-deleted {
  text-decoration: line-through;
}
</style>