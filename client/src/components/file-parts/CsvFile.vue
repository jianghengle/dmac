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
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div class="columns">
      <div class="column tabs is-toggle csv-tabs">
        <ul>
          <li :class="{'is-active': activeTab=='table'}">
            <a class="tab-button" @click="activeTab = 'table'">Table</a>
          </li>
          <li :class="{'is-active': activeTab=='graphs'}">
            <a class="tab-button" @click="activeTab = 'graphs'">Graph</a>
          </li>
        </ul>
      </div>

      <nav class="column pagination is-right csv-pages" v-show="activeTab=='table'">
        <ul class="pagination-list">
          <li v-show="currentPage > 0"><a class="pagination-link" @click="showPage(0)">1</a></li>
          <li v-show="currentPage-1 > 0"><a class="pagination-link" @click="showPage(currentPage-1)">Pre</a></li>
          <li><a class="pagination-link is-current">{{currentRange}}</a></li>
          <li v-show="currentPage+1 < totalPages-1"><a class="pagination-link" @click="showPage(currentPage+1)">Next</a></li>
          <li v-show="currentPage < totalPages-1"><a class="pagination-link" @click="showPage(totalPages-1)">{{totalPages}}</a></li>
        </ul>
      </nav>
    </div>

    <div v-show="activeTab=='table'" class="csv-table">
      <table class="table is-narrow" v-if="yCols.length">
        <thead>
          <tr>
            <th class="number-cell">#</th>
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
          <tr v-for="(row, i) in pageData">
            <td class="number-cell">{{i+1}}</td>
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
      waiting: false,
      error: '',
      activeTab: 'table',
      xCol: 0,
      yCols: [],
      graphs: [],
      sortIndex: 0,
      asc: true,
      currentPage: 0,
      pageSize: 1000,
      tableHeader: [],
      tableData: []
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
    pageData () {
      var index = this.currentPage * this.pageSize
      var page = this.tableData.slice(index, index + this.pageSize)
      return page
    },
    totalCount () {
      return this.tableData.length
    },
    totalPages () {
      return Math.ceil(this.totalCount / this.pageSize)
    },
    currentRange () {
      var start = this.currentPage * this.pageSize + 1
      var end = (this.currentPage + 1) * this.pageSize
      if(end > this.totalCount){
        end = this.totalCount
      }
      return start + '~' + end
    },
  },
  watch: {
    path: function (val) {
      this.loadTable()
    },
    file: function (val) {
      this.loadTable()
    },
  },
  methods: {
    loadTable(){
      if(!this.file.text) return []
      var re=/\r\n|\n\r|\n|\r/g
      var lines = this.file.text.replace(re,'\n').split('\n')
      this.loadHeader(lines)
      this.loadData(lines)
      this.loadCheckboxes()
    },
    loadHeader(lines){
      if(!lines.length) return []
      var header = ['Ln#']
      var firstLine = lines[0]
      firstLine.split(/,|\t/g).forEach(function(s){
        header.push(s.trim())
      })
      this.tableHeader = header
    },
    loadData(lines){
      if(lines.length < 2) return []
      var tableData = []
      for(var i=1;i<lines.length;i++){
        var line = lines[i]
        var row = [i]
        var ss = line.split(',')
        for(var j=0;j<ss.length;j++){
          row.push(ss[j].trim())
        }
        tableData.push(row)
      }
      this.tableData = tableData
    },
    loadCheckboxes(){
      if(!this.tableHeader.length) return
      var yCols = []
      for(var i=0;i<this.tableHeader.length;i++){
        var yCol = false
        if(i < this.yCols.length){
          yCol = this.yCols[i]
        }
        yCols.push(yCol)
      }
      this.yCols = yCols
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
                  data[x][j] = null
                }else{
                  y = Number(y)
                  d.count = d.count ? d.count + 1 : 1
                  d.max = d.max === undefined ? y : Math.max(y, d.max)
                  d.min = d.min === undefined ? y : Math.min(y, d.min)
                  d.average = d.average === undefined ? y : (d.average * (d.count - 1)/d.count + y/d.count)
                }
              }
            }
          }
        }
      }

      var xs = Object.keys(data)
      var xIsNum = true
      if(xs.length){
        if(isNaN(xs[0])){
          xIsNum = false
        }
      }

      xs.sort(function(a,b){
        if(isNaN(a) || isNaN(b)){
          xIsNum = false
          return a.localeCompare(b)
        }
        return a - b
      })
      var points = []

      for(var i=0;i<xs.length;i++){
        var x = Number(xs[i])
        if(!xIsNum){
          x = i
        }
        var point = [x]
        var d = data[xs[i]]
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
      var result = {points: points}
      if(!xIsNum){
        result.xs = xs
        if(xs.length){
          var first = points[0].slice()
          for(var i=0;i<first.length;i++){
            if(i == 0){
              first[i] = first[i] - 1
            }else{
              first[i] = null
            }
          }
          points.unshift(first)
          var last = points[points.length-1].slice()
          for(var i=0;i<last.length;i++){
            if(i == 0){
              last[i] = last[i] + 1
            }else{
              last[i] = null
            }
          }
          points.push(last)
        }
      }
      return result
    },
    addGraph() {
      var result = this.getGraphPoints()
      var points = result.points
      var xLabel = this.tableHeader[this.xCol]
      var yLabels = []
      for(var j=0;j<this.yCols.length;j++){
        if(!this.yCols[j]) continue
        var name = this.tableHeader[j]
        if(j == this.xCol){
          yLabels.push('Count(' + name + ')')
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

      var graph = {
        ordinal: ordinal,
        id: 'csvGraph' + ordinal,
        title: 'Graph ' + ordinal,
        labels: labels,
        points: points,
      }
      if(result.xs){
        graph.xs = result.xs
      }
      this.graphs.unshift(graph)
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
      var vm = this
      vm.tableData.sort(function(a, b){
        return vm.compareData(a, b)
      })
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
    showPage(pageNumber){
      this.currentPage = pageNumber
    }
  },
  mounted () {
    this.loadTable()
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
  margin-bottom: 0px;
  padding-top: 0px;
  padding-bottom: 0px;
}

.tab-button {
  padding-top: 5px;
  padding-bottom: 5px;
}

.csv-pages {
  padding-top: 0px;
  padding-bottom: 0px;
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
