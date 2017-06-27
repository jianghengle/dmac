<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        <a class="button" :disabled="!textChanged" :class="{'is-danger': textChanged}" v-if="canEdit" @click="saveTextFile">
          <icon name="save"></icon>&nbsp;
          Save
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div class="tabs csv-tabs">
      <ul>
        <li :class="{'is-active': activeTab=='text'}">
          <a @click="activeTab = 'text'">Text</a>
        </li>
        <li :class="{'is-active': activeTab=='table'}">
          <a @click="activeTab = 'table'">Table</a>
        </li>
        <li :class="{'is-active': activeTab=='graphs'}">
          <a @click="activeTab = 'graphs'">Graphs</a>
        </li>
      </ul>
    </div>

    <div class="field" v-show="activeTab=='text'">
      <p class="control">
        <textarea class="textarea"
          :class="{'is-danger': textChanged}"
          :style="{'height': textAreaHeight}"
          v-model="textData">
        </textarea>
      </p>
    </div>

    <div v-show="activeTab=='table'" class="csv-table">
      <table class="table is-narrow">
        <thead>
          <tr>
            <th v-for="(h, i) in tableHeader">
              <div><span>{{h}}</span></div>
              <div>
                <label class="radio">
                  <input type="radio" name="xData">
                </label>
                <label class="checkbox">
                  <input type="checkbox">
                </label>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in tableData">
            <td v-for="cell in row">
              {{cell}}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-show="activeTab=='graphs'">
      Graphs
    </div>

  </div>
</template>

<script>

export default {
  name: 'csv-file',
  props: ['file'],
  data () {
    return {
      textData: '',
      textLines: [],
      tableHeader: [],
      tableData: [],
      waiting: false,
      error: '',
      waiting: '',
      activeTab: 'table'
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
    path () {
      return this.$route.path
    },
    textAreaHeight () {
      var re=/\r\n|\n\r|\n|\r/g
      var textLines = this.textData.replace(re,'\n').split('\n')
      return 25*textLines.length + 'px'
    },
    textChanged () {
      return this.textData != this.file.text
    },
    canEdit () {
      if(!this.file) return false
      if(!this.projectRole) return false
      if(this.projectRole == 'Viewer') return false
      if(this.projectRole == 'Owner' || this.projectRole == 'Admin') return true
      return !this.file.readonly
    }
  },
  watch: {
    path: function (val) {
      this.updateText()
    },
    file: function (val) {
      this.updateText()
    },
  },
  methods: {
    updateText() {
      this.textData = this.file.text
      this.textToTable()
    },
    textToTable() {
      var re=/\r\n|\n\r|\n|\r/g
      var tableHeader = []
      var tableData = []
      var lines = this.textData.replace(re,'\n').split('\n')
      for(var i=0;i<lines.length;i++){
        var line = lines[i]
        var ss = line.split(',')
        if(!tableHeader.length){
          tableHeader.push('#')
          for(var j=0;j<ss.length;j++){
            tableHeader.push(ss[j].trim())
          }
        }else{
          var row = [tableData.length + 1]
          for(var j=0;j<ss.length;j++){
            row.push(ss[j].trim())
          }
          tableData.push(row)
        }
      }
      this.tableHeader = tableHeader
      this.tableData = tableData
    },
    saveTextFile(){
      this.waiting = true
      var message = {projectId: this.projectId, dataPath: this.file.dataPath, text: this.textData}
      this.$http.post(xHTTPx + '/save_text_file', message).then(response => {
        this.waiting = false
        this.$emit('content-changed', true)
      }, response => {
        this.error = 'Failed to save file!'
        this.waiting = false
      })
    }
  },
  mounted () {
    this.updateText()
  }
}
</script>

<style lang="scss" scoped>

.buttons {
  text-align: right;
}

.action-icon {
  color: #3273dc;
  position: relative;
  top: 3px;
}

.text-area-container {
  margin-top: 5px;
  height: 100%;
}

.csv-tabs {
  margin-top: -30px;
  margin-bottom: 0px;
}

.csv-table {
  max-width: 100%;
  overflow-x: scroll;
}

</style>
