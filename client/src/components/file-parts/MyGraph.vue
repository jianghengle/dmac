<template>
  <div class="chart-container">
    <div class="delete-button"><a class="delete" @click="deleteGraph"></a></div>
    <div class="my-canvas" :id="'myCanvas' + graphData.id" style="width: calc(100%)"></div>
    <div class="chart-options">
      <span v-for="(v, i) in visibility" @change="visibilityToggled">
        <label class="checkbox">
          <input type="checkbox" v-model="v[1]">
          {{v[0]}}
        </label>&nbsp;&nbsp;
      </span>                
    </div>
  </div>
</template>


<script>
import Dygraph from 'dygraphs'

export default {
  name: 'my-graph',
  props: ['graphData'],
  data: function(){
    return {
      graph: null,
      visibility: [],
    }
  },
  methods: {
    buildGraph: function(){
      var options = {
        drawPoints: true,
        customBars: true,
        labels: this.graphData.labels,
        legend: 'always',
        showRoller: false,
        title: this.graphData.title,
        axes: { 
          x: {
            axisLabelFormatter: (decimal, granularity, opts, dygraph) =>{
              if(this.graphData.xs){
                if(this.graphData.xs[decimal])
                  return this.graphData.xs[decimal]
                return ""
              }
              return decimal
            },
            valueFormatter: (decimal, opts, seriesName, dygraphObj, row, col) =>{
              if(this.graphData.xs){
                return this.graphData.xs[decimal]
              }
              return decimal
            }
          },
          y: {
            valueFormatter: (decimal, opts, seriesName, dygraphObj, row, col) =>{
              return decimal
            }
          }
        },
      }

      var elem = document.getElementById('myCanvas'+this.graphData.id)
      this.graph = new Dygraph(elem, this.graphData.points, options)
    },
    visibilityToggled: function(){
      this.graph.updateOptions({ 
        visibility: this.visibility.map(function(v){
          return v[1]
        })
      })
    },
    deleteGraph: function(){
      this.$emit('delete-graph', this.graphData)
    }
  },
  mounted: function(){
    var visibility = []
    for(var i = 1;i < this.graphData.labels.length;i++){
      visibility.push([this.graphData.labels[i], true])
    }
    this.visibility = visibility
    this.$nextTick(function(){
      this.buildGraph()
    })
  },
  beforeDestroy: function(){
    if(this.graph){
      this.graph.destroy()
      this.graph = null
    }
  }
}

</script>

<style lang="scss" scoped>

.chart-container {
  padding: 10px;
  position: relative;
}

.delete-button {
  text-align: right;
  position: absolute;
  top: 30px;
  right: 10px;
  z-index: 20;
}

.my-canvas {
  margin-top: 20px;
  margin-bottom: 20px;
}

.chart-options {
  text-align: center;
  margin-top: -10px;
}

</style>
