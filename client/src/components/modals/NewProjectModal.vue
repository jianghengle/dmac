<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card wide-modal">
        <header class="modal-card-head">
          <p class="modal-card-title">New Project</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Name</label>
            </div>
            <div class="field-body">
              <div class="field">
                <div class="control">
                  <input v-if="opened" class="input" type="text" v-model="newName" v-focus>
                </div>
              </div>
            </div>
          </div>

          <div class="field is-horizontal">
            <div class="field-label is-normal">
              <label class="label">Description</label>
            </div>
            <div class="field-body">
              <div class="field">
                <div class="control">
                  <textarea class="textarea" v-model="newDescription"></textarea>
                </div>
              </div>
            </div>
          </div>

          <div class="meta-fields">
            <div class="field is-horizontal meta-field">
              <div class="field-label is-normal">
                <label class="label">Template</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <span class="select">
                      <select v-model="templateId">
                        <option v-for="option in allTemplates" v-bind:value="option.id">
                          {{ option.name }}
                        </option>
                      </select>
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div class="field is-horizontal meta-field" v-if="templateId && !isPublicTemplate">
              <div class="field-label">
                <label class="label">Copy Users</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <label class="checkbox">
                      <input type="checkbox" v-model="copyUsers">
                    </label>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="metaData && metaData.length">
              <div class="field is-horizontal meta-field">
                <div class="field-label is-normal">
                  <label class="label">Meta Data</label>
                </div>
                <div class="field-body">
                  <div class="field">
                    <div class="control">
                      <input class="input is-static" type="text" value="meta.txt" readonly>
                    </div>
                  </div>
                </div>
              </div>
              <div class="field is-horizontal meta-field" v-for="meta in metaData">
                <div class="field-label is-normal">
                  <label class="label">{{meta.name}}</label>
                </div>
                <div class="field-body">
                  <div class="field">
                    <div class="control">
                      <div v-if="meta.options">
                        <div class="select">
                          <select v-model="meta.value">
                            <option v-for="option in meta.options" v-bind:value="option.value">{{option.text}}</option>
                          </select>
                        </div>
                        <input v-if="meta.value == '__other__'" class="input other-input" type="text" placeholder="Please specify..." v-model="meta.otherValue">
                      </div>
                      <div v-else>
                        <input class="input" type="text" v-model="meta.value">
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </section>
        <footer class="modal-card-foot">
          <a class="button main-btn" :class="{'is-loading': waiting}" :disabled="!canCreate" @click="create">Create</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'new-project-modal',
  props: ['opened', 'templates'],
  data () {
    return {
      error: '',
      waiting: false,
      newName: '',
      newDescription: '',
      templateId: '',
      metaData: [],
      copyUsers: '',
      allTemplates: []
    }
  },
  computed: {
    isPublicTemplate () {
      if(!this.templateId)
        return false
      for(var i=0;i<this.allTemplates.length;i++){
        var template = this.allTemplates[i]
        if(template.id == this.templateId){
          return template.public
        }
      }
      return false
    },
    canCreate () {
      if(!this.newName) return false
      for(var i=0;i<this.metaData.length;i++){
        var m = this.metaData[i]
        if(!m.value)
          return false
        if(m.value == '__other__' && !m.otherValue)
          return false
      }
      return true
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.newName = ''
        this.newDescription = ''
        this.templateId = ''
        this.metaData = []
        this.error = ''
        this.waiting = false
        this.requestTemplates()
      }
    },
    templateId: function (val) {
      if(val){
        this.requestMetaData()
      }else{
        this.metaData = []
      }
    }
  },
  methods: {
    close(){
      this.newName = ''
      this.newDescription = ''
      this.$emit('close-new-project-modal', false)
    },
    create(){
      if(!this.canCreate) return
      var vm = this
      vm.waiting = true
      var metaDataValues = vm.metaData.map(function(m){
        return m.value == '__other__' ? m.otherValue : m.value
      })
      var message = {name: vm.newName, description: vm.newDescription, templateId: vm.templateId, copyUsers: vm.copyUsers, metaData: metaDataValues.join('\t')}
      vm.$http.post(xHTTPx + '/create_project', message).then(response => {
        vm.waiting= false
        vm.newName = ''
        vm.newDescription = ''
        vm.$emit('close-new-project-modal', true)
      }, response => {
        vm.error = 'Failed to create project! ' + JSON.stringify(response.body)
        vm.waiting= false
      })
    },
    requestMetaData(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_meta_by_template/' + this.templateId).then(response => {
        this.waiting= false
        var lines = response.body
        var headers = []
        if(lines.length > 0){
          headers = lines[0].split('\t')
        }
        var values = []
        if(lines.length > 1){
          values = lines[1].split('\t')
        }
        this.metaData = []
        for(var i=0;i<headers.length;i++){
          var header = headers[i]
          var optionsStart = header.indexOf('{')
          var optionsEnd = header.indexOf('}')
          var name = ''
          var options = null
          var value = ''
          if(optionsStart == -1 || optionsEnd == -1 || optionsStart >= optionsEnd){
            name = header
          }else{
            name = header.slice(0, optionsStart).trim()
            options = header.slice(optionsStart+1, optionsEnd).split('|').map(function(s){
              s = s.trim()
              return {text: s, value: s}
            })
            var otherValue = ''
            if(options.length && options[options.length - 1].text == '*'){
              options[options.length - 1] = {text: 'Other', value: '__other__'}
            }
          }
          if(i < values.length){
            value = values[i]
          }
          this.metaData.push({name: name, value: value, options: options, otherValue: otherValue})
        }
      }, response => {
        this.waiting= false
      })
    },
    requestTemplates(){
      this.waiting= true
      this.$http.get(xHTTPx + '/get_public_templates').then(response => {
        this.waiting= false
        var templates = this.templates
        var publicTemplates = response.body.filter(function(p){
          for(var i=0;i<templates.length;i++){
            if(templates[i].id == p.id){
              return false
            }
          }
          p.public = true
          return true
        })
        var allTemplates = templates.concat(publicTemplates)
        allTemplates.unshift({id: '', name: '(blank)'})
        this.allTemplates = allTemplates
      }, response => {
        this.error = 'Failed to get templates!'
        this.waiting= false
      })
    }
  },
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.wide-modal {
  width: 800px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}

.meta-fields {
  margin-top: 20px;
}

.other-input {
  margin-top: 5px;
}
</style>
