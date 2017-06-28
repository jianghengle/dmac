<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        <a class="button" @click="addGraph">
          <icon name="line-chart"></icon>&nbsp;
          Draw Graph
        </a>
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
        <textarea class="textarea csv-textarea"
          :class="{'is-danger': textChanged}"
          :style="{'height': textAreaHeight}"
          v-model="textData">
        </textarea>
      </p>
    </div>

    <div v-show="activeTab=='table'" class="csv-table">
      <table class="table is-narrow" v-if="yCols.length">
        <thead>
          <tr>
            <th class="number-cell" v-for="(h, i) in tableHeader">
              <div class="csv-header" @click="sortData(i)">
                <span>{{h}}</span>
                <span class="sort-icon" v-if="sortIndex==i">
                  <icon class="asc-icon" name="sort-asc" v-if="asc"></icon>
                  <icon name="sort-desc" v-if="!asc"></icon>
                </span>
              </div>
              <div>
                <label class="radio">
                  <input type="radio" name="xCol" :value="i" v-model="xCol">
                </label>
                <label class="checkbox">
                  <input type="checkbox" v-model="yCols[i]">
                </label>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in tableData">
            <td class="number-cell" v-for="cell in row">
              {{cell}}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-show="activeTab=='graphs'">
      <div v-for="g in graphs" :key="g.id">
        <my-graph :graph-data="g" @delete-graph="deleteGraph"></my-graph>
      </div>
    </div>

  </div>
</template>

<script>
import MyGraph from './MyGraph'

export default {
  name: 'csv-file',
  components: {
    MyGraph
  },
  props: ['file'],
  data () {
    return {
      textData: '',
      waiting: false,
      error: '',
      activeTab: 'table',
      xCol: 0,
      yCols: [],
      graphs: [],
      sortIndex: 0,
      asc: true,
      lineNumbers: [],
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
    textLines () {
      var re=/\r\n|\n\r|\n|\r/g
      return this.textData.replace(re,'\n').split('\n')
    },
    textAreaHeight () {
      return 25*this.textLines.length + 'px'
    },
    tableHeader () {
      if(!this.textLines.length) return []
      var header = ['Ln#']
      var firstLine = this.textLines[0]
      firstLine.split(/,|\t/g).forEach(function(s){
        header.push(s.trim())
      })
      return header
    },
    tableData () {
      if(this.textLines.length < 2) return []
      var tableData = []

      for(var i=1;i<this.textLines.length;i++){
        var line = this.textLines[i]
        var row = [i]
        if(this.lineNumbers[i-1] == undefined){
          this.lineNumbers.push(i)
        }else{
          var row = [this.lineNumbers[i-1]]
        }
        var ss = line.split(/,|\t/g)
        for(var j=0;j<ss.length;j++){
          row.push(ss[j].trim())
        }
        tableData.push(row)
      }

      return tableData
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
    tableHeader: function (val) {
      if(!val.length) return
      var yCols = []
      for(var i=0;i<val.length;i++){
        var yCol = false
        if(i < this.yCols.length){
          yCol = this.yCols[i]
        }
        yCols.push(yCol)
      }
      this.yCols = yCols
    },
  },
  methods: {
    updateText() {
      this.textData = this.file.text
    },
    getGraphPoints(){
      var data = {}
      for(var i=0;i<this.tableData.length;i++){
        var row = this.tableData[i]
        var x = row[this.xCol]
        if(!data[x]) data[x] = {}
        for(var j=0;j<this.yCols.length;j++){
          if(!this.yCols[j]) continue
          var y = row[j]
          if(this.yCols[j]){
            if(data[x][j] == undefined){
              data[x][j] = {}
            }
            if(data[x][j]){
              var d = data[x][j]
              if(this.xCol == j){
                d.count = d.count ? d.count + 1 : 1
              }else{
                if(isNaN(y)){
                  d = null
                }else{
                  d.count = d.count ? d.count + 1 : 1
                  d.max = d.max == undefined ? Number(y) : Math.max(y, d.max)
                  d.min = d.min == undefined ? Number(y) : Math.min(y, d.max)
                  d.average = d.average == undefined ? Number(y) : (d.average * (d.count - 1)/d.count + y/d.count)
                }
              }
              data[x][j] = d
            }
          }
        }
      }

      var xs = Object.keys(data)
      xs.sort(function(a,b){
        return a - b
      })
      var points = []
      for(var i=0;i<xs.length;i++){
        var d = data[xs[i]]
        var point = [Number(xs[i])]
        for(var j=0;j<this.yCols.length;j++){
          if(!this.yCols[j]) continue
          if(!d[j]){
            point.push(null)
          }else if(!d[j].average){
            var count = d[j].count
            point.push([count, count, count])
          }else{
            point.push([d[j].min, d[j].average, d[j].max])
          }
        }
        points.push(point)
      }
      return points
    },
    addGraph() {
      var points = this.getGraphPoints()
      var xLabel = this.tableHeader[this.xCol]
      var yLabels = []
      for(var j=0;j<this.yCols.length;j++){
        if(!this.yCols[j]) continue
        var name = this.tableHeader[j]
        if(j == this.xCol){
          yLabels.push('count(' + name + ')')
        }else{
          yLabels.push(name)
        }
      }

      var labels = [xLabel].concat(yLabels)

      var ordinal = 1
      if(this.graphs.length){
        ordinal = this.graphs[0].ordinal + 1
      }

      this.activeTab = 'graphs'

      this.graphs.unshift({
        ordinal: ordinal,
        id: 'csvGraph' + ordinal,
        title: 'Graph ' + ordinal,
        labels: labels,
        points: points,
      })
    },
    deleteGraph(graph){
      var index = this.graphs.indexOf(graph)
      this.graphs.splice(index, 1)
    },
    sortData(index){
      if(this.sortIndex == index){
        this.asc = !this.asc
      }else{
        this.sortIndex = index
      }
      var data = this.tableData.slice()
      var vm = this
      data.sort(function(a, b){
        return vm.compareData(a, b)
      })

      this.textData = this.makeText(data)
    },
    compareData(a, b) {
      if(isNaN(a[this.sortIndex]) || isNaN(b[this.sortIndex])){
        if(this.asc){
          return a[this.sortIndex].localeCompare(b[this.sortIndex])
        }
        return -a[this.sortIndex].localeCompare(b[this.sortIndex])
      }

      if(this.asc){
        return a[this.sortIndex] - b[this.sortIndex]
      }
      return b[this.sortIndex] - a[this.sortIndex]
    },
    makeText(data) {
      var ext = this.file.name.slice(-4)
      var separator = ext == '.csv' ? ',' : '\t'
      var lines = [this.tableHeader.slice(1).join(separator)]
      var lineNumbers = []
      for(var i=0;i<data.length;i++){
        lineNumbers.push(data[i][0])
        lines.push(data[i].slice(1).join(separator))
      }
      this.lineNumbers = lineNumbers
      return lines.join('\n')
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

.csv-textarea {
  font-size: 14px;
}

.csv-tabs {
  margin-top: -30px;
  margin-bottom: 0px;
}

.csv-table {
  max-width: 100%;
  overflow-x: auto;
}

.number-cell {
  text-align: right;
  font-size: 14px;
}

.csv-header {
  white-space: nowrap;
  cursor: pointer;
}

.asc-icon {
  position: relative;
  top: 5px;
}

</style>
