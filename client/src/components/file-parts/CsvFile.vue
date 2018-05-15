<template>
  <div>
    <div class="view-title">
      <span class="main-link search-button" @click="openSearch">
        <icon name="search"></icon>
      </span>&nbsp;
      {{file && file.name}}
      <span class="tag is-warning file-tag" v-if="file && file.access==1">Readonly</span>
      <span class="tag is-danger file-tag" v-if="file && file.access==2">Hidden</span>
      <a v-if="projectRole && projectRole!='Viewer' && ( projectRole=='Editor' ? (project.status=='Active' && file.access==0) : true )"
        @click="openEditFileModal"
        class="main-link">
        <icon name="edit"></icon>
      </a>

      <div class="is-pulled-right checkboxes">
        <label class="checkbox">
          <input type="checkbox" v-model="showTable">
          Table
        </label>
        &nbsp;&nbsp;
        <label class="checkbox">
          <input type="checkbox" v-model="showCharts">
          Charts
        </label>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>

    <div class="columns" v-if="tableHeader.length">
      <div class="column" :class="{'is-half': showTable && showCharts}" v-show="showTable">
        <div v-show="totalPages > 1">
          <nav class="pagination is-small csv-pages">
            <ul class="pagination-list">
              <li v-show="currentPage > 0"><a class="pagination-link default-btn" @click="showPage(0)">P1</a></li>
              <li v-show="currentPage-1 > 0"><a class="pagination-link default-btn" @click="showPage(currentPage-1)">Pre</a></li>
              <li><a class="pagination-link is-current active-btn">{{currentRange}}</a></li>
              <li v-show="currentPage+1 < totalPages-1"><a class="pagination-link default-btn" @click="showPage(currentPage+1)">Next</a></li>
              <li v-show="currentPage < totalPages-1"><a class="pagination-link default-btn" @click="showPage(totalPages-1)">P{{totalPages}}</a></li>
            </ul>
          </nav>
        </div>

       <div class="csv-table">
          <table class="table is-narrow">
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
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, i) in pageData">
                <td class="number-cell">{{i}}</td>
                <td class="number-cell" v-for="cell in row">
                  {{cell}}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="column" :class="{'is-half': showTable && showCharts}" v-show="showCharts">
        <div class="dropdown is-hoverable">
          <div class="dropdown-trigger">
            <button class="button default-btn dropdown-trigger-button" aria-haspopup="true" aria-controls="dropdown-menu">
              <span class="plus-icon"><icon name="plus"></icon></span>&nbsp;&nbsp;
              <span>Chart</span>
              <span class="icon is-small">
                <icon name="chevron-down" scale="0.8"></icon>
              </span>
            </button>
          </div>
          <div class="dropdown-menu" id="dropdown-menu" role="menu">
            <div class="dropdown-content">
              <a class="dropdown-item new-chart-button" @click="addChart('Simple')">
                Simple Chart
              </a>
              <a class="dropdown-item new-chart-button" @click="addChart('XY')">
                XY Chart
              </a>
              <a class="dropdown-item new-chart-button" @click="addChart('Parallel Coordinates')">
                Parallel Coordinates
              </a>
              <a class="dropdown-item new-chart-button" @click="addChart('Histogram')">
                Histogram
              </a>
              <a class="dropdown-item new-chart-button" @click="addChart('Histograms')">
                Histograms
              </a>
              <a class="dropdown-item new-chart-button" @click="addChart('Correlations')">
                Correlation Matrix
              </a>
            </div>
          </div>
        </div>

        <div v-for="c in charts" :key="c.id">
          <simple-chart
            v-if="c.type == 'Simple'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            @delete-chart="deleteChart">
          </simple-chart>
          <simple-xy
            v-if="c.type == 'XY'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            :groupOptions="groupOptions"
            :groupColors="groupColors"
            @delete-chart="deleteChart">
          </simple-xy>
          <parallel-coordinates
            v-if="c.type == 'Parallel Coordinates'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            :groupOptions="groupOptions"
            :groupColors="groupColors"
            @delete-chart="deleteChart">
          </parallel-coordinates>
          <histogram-chart
            v-if="c.type == 'Histogram'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            :groupOptions="groupOptions"
            :groupColors="groupColors"
            @delete-chart="deleteChart">
          </histogram-chart>
          <histogram-array
            v-if="c.type == 'Histograms'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            :groupOptions="groupOptions"
            :groupColors="groupColors"
            @delete-chart="deleteChart">
          </histogram-array>
          <correlation-matrix
            v-if="c.type == 'Correlations'"
            :chart="c"
            :headers="tableHeader"
            :rows="tableData"
            :showTable="showTable"
            :showCharts="showCharts"
            @delete-chart="deleteChart">
          </correlation-matrix>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import SimpleChart from './csv-charts/SimpleChart'
import SimpleXy from './csv-charts/SimpleXy'
import ParallelCoordinates from './csv-charts/ParallelCoordinates'
import HistogramChart from './csv-charts/HistogramChart'
import HistogramArray from './csv-charts/HistogramArray'
import CorrelationMatrix from './csv-charts/CorrelationMatrix'

export default {
  name: 'csv-file',
  components: {
    SimpleChart,
    SimpleXy,
    ParallelCoordinates,
    HistogramChart,
    HistogramArray,
    CorrelationMatrix
  },
  props: ['file'],
  data () {
    return {
      waiting: false,
      error: '',
      sortIndex: 0,
      asc: true,
      currentPage: 0,
      pageSize: 1000,
      tableHeader: [],
      tableData: [],
      showTable: true,
      showCharts: true,
      charts: [],
      groupOptions: [],
      groupColors: ['#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf', '#1f77b4']
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
      var start = this.currentPage * this.pageSize
      var end = (this.currentPage + 1) * this.pageSize - 1
      if(end > this.totalCount - 1){
        end = this.totalCount - 1
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
      this.loadGroups()
      this.sortIndex = 0
      this.asc = true
      this.charts = []
    },
    loadHeader(lines){
      if(!lines.length) return []
      var header = ['Row']
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
        var row = [i-1]
        var ss = line.split(',')
        for(var j=0;j<ss.length;j++){
          row.push(ss[j].trim())
        }
        tableData.push(row)
      }
      this.tableData = tableData
    },
    loadGroups(){
      this.groupOptions = []
      if(this.tableData.length > 10){
        for(var i=0;i<this.tableHeader.length;i++){
          var opt = {name: this.tableHeader[i], dataIndex: i, values: {}}
          this.groupOptions.push(opt)
        }
        for(var i=0;i<this.tableData.length;i++){
          var row = this.tableData[i]
          for(var j=0;j<row.length;j++){
            var value = row[j]
            var opt = this.groupOptions[j]
            if(!opt.values) continue
            if(opt.values[value]) continue
            opt.values[value] = true
            if(Object.keys(opt.values).length > 10){
              opt.values = null
            }
          }
        }
        for(var i=this.groupOptions.length-1;i>=0;i--){
          var opt = this.groupOptions[i]
          if(!opt.values){
            this.groupOptions.splice(i, 1)
          }
        }
        this.groupOptions.unshift({name: 'none'})
      }
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
    },
    addChart (type) {
      var id = this.charts.length ? (this.charts[0].id + 1) : 0
      var chart = {
        id: id,
        type: type
      }
      this.charts.unshift(chart)
    },
    deleteChart (chart) {
      var index = this.charts.indexOf(chart)
      if(index > -1){
        this.charts.splice(index, 1)
      }
    },
    openSearch(){
      var searchPath = this.$route.path.replace('/data/', '/search/')
      this.$router.push(searchPath)
    },
    openEditFileModal(){
      this.$emit('open-edit-file-modal')
    },
  },
  mounted () {
    this.loadTable()
  }
}
</script>

<style lang="scss" scoped>

.checkboxes {
  font-size: 16px;
  font-weight: normal;
}

.active-btn {
  background-color: #2e1052!important;
  border-color: #2e1052!important;
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

.new-chart-button {
  color: #2e1052;
}

.file-tag {
  position: relative;
  top: -3px;
}


.dropdown-trigger-button {
  border: none;
}

.plus-icon {
  position: relative;
  top: 2px;
}

</style>
