<template>
  <div>
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
            <icon v-if="f.type=='folder'" name="folder"></icon>
            <icon v-if="f.type=='file'" name="file"></icon>
          </td>
          <td class="text-cell">{{f.name}}</td>
          <td class="number-cell"><span v-if="f.type=='file'">{{f.size}}</span></td>
          <td class="text-cell">{{f.modifiedAt}}</td>
          <td class="text-cell"><a><icon v-if="f.type=='file'" name="trash"></icon></a></td>
        </tr>
      </tbody>
    </table>
    <div v-if="!content || !content.length">Folder is empty.</div>
  </div>
</template>

<script>
export default {
  name: 'folder-content',
  props: ['content'],
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  methods: {
    viewFile (f) {
      if(f.type == 'folder'){
        this.$router.push(f.path)
      }
    }
  },
}
</script>

<style lang="scss" scoped>

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


</style>
