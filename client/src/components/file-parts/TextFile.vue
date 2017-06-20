<template>
  <div>
    <div class="columns">
      <div class="view-title column">
        <icon :name="file.icon"></icon>&nbsp;
        {{file && file.name}}
      </div>
      <div class="column buttons">
        <a class="button" :disabled="!textChanged" :class="{'is-danger': textChanged}" v-if="projectRole && projectRole!='Viewer'" @click="saveTextFile">
          <icon name="save"></icon>&nbsp;
          Save
        </a>
      </div>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="field">
      <p class="control">
        <textarea class="textarea"
          :readonly="!projectRole || projectRole=='Viewer'"
          :class="{'is-danger': textChanged}"
          :style="{height: textAreaHeight}"
          v-model="textInput">
        </textarea>
      </p>
    </div>
  </div>
</template>

<script>

export default {
  name: 'text-file',
  props: ['file'],
  data () {
    return {
      textInput: '',
      waiting: false,
      error: ''
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
    path () {
      return this.$route.path
    },
    textAreaHeight () {
      var lines = this.textInput.split('\n').length
      return 25*lines + 'px'
    },
    textChanged () {
      return this.textInput != this.file.text
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
      this.textInput = this.file.text
    },
    saveTextFile(){
      this.waiting = true
      var message = {projectId: this.projectId, dataPath: this.file.dataPath, text: this.textInput}
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

</style>
