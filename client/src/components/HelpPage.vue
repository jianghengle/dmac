<template>

  <div class="help-page">
    <div class="main-link close-btn" @click="toggleHelpPage"><icon name="times" scale="1.5"></icon></div>

    <div class="help-nav">
      <a class="main-link" @click="scrollToElement('helpOnProject')">
        Create a Project
      </a>
      <br/>
      <a class="main-link" @click="scrollToElement('helpOnPermission')">
        Project Status, Role and Permission
      </a>
      <br/>
      <a class="main-link" @click="scrollToElement('helpOnChannel')">
        Channel
      </a>
      <br/>
      <a class="main-link" @click="scrollToElement('helpOnFileTypes')">
        File Types
      </a>
      <br/>
      <a class="main-link" @click="scrollToElement('helpOnPublicUrl')">
        Public Url
      </a>
      <br/>
      <a class="main-link" @click="scrollToElement('helpOnHistory')">
        History
      </a>
    </div>

    <div class="content help-content">
      
      <h3 id="helpOnProject">Create a Project</h3>

      <p>A project is a file container associated with a group of users</p>
      <p>On your projects page, you could create a blank project or from an existing template. A template is simply a project with status of <span class="quote">Template</span> or <span class="quote">Public Template</span>. When creating from a template, all the content from the template will be copied into the new project. If applicable, you could fill in the project metadata (will be saved in the project metadata file) and/or check the <span class="quote">Copy Users</span> check box (will copy all users from the template to the new one).</p>

      <h3 id="helpOnPermission">Project Status, Role and Permission</h3>

      <p>A project can be of one of the four status: <span class="quote">Active</span>(default), <span class="quote">Archived</span>, <span class="quote">Template</span> and <span class="quote">Public Template</span>. You could change a project's status by clicking <span class="icon"><icon name="edit"></icon></span> on the project.</p>
      <p>On the projects page, you could see all <span class="quote">Active</span> projects by default. Change the filter <span class="quote">Show</span> if you want to see other projects.</p>
      <p>A user must be a project user to access the project. He/She can be of one of the four roles: <span class="quote">Owner</span>(assigned automatically when creating the project), <span class="quote">Admin</span>, <span class="quote">Editor</span> and <span class="quote">Viewer</span>.
        <ul>
          <li><span class="quote">Owner</span> can do any thing include managing the project, users, folders, and files.</li>
          <li><span class="quote">Admins</span> can do also manage project (CANNOT delete), users (only <span class="quote">Editors</span> and <span class="quote">Viewers</span>), folder and files.</li>
          <li><span class="quote">Editors</span> can ONLY edit editable files in an <span class="quote">Active</span> project. <span class="quote">Editors</span> CANNOT add or edit folders. <span class="quote">Editors</span> could NOT access <span class="quote">Archived</span> or <span class="quote">Template</span> or <span class="quote">Public Template</span> projects.</li>
          <li><span class="quote">Viewers</span> can ONLY view accessible folders and files in an <span class="quote">Active</span> project. <span class="quote">Viewers</span> could NOT access <span class="quote">Archived</span> or <span class="quote">Template</span> or <span class="quote">Public Template</span> projects.</li>
        </ul>
      </p>
      <p>Each folder or file has a permission attribute to put more access control to <span class="quote">Editors</span> and <span class="quote">Viewers</span>.
        <ul>
          <li><span class="quote">Normal</span> means <span class="quote">Editors</span> can read and write, while <span class="quote">Viewers</span> can only read.</li>
          <li><span class="quote">Readonly</span> means both <span class="quote">Editors</span> or <span class="quote">Viewers</span> can only read.</li>
          <li><span class="quote">Hidden</span> means neither <span class="quote">Editors</span> nor <span class="quote">Viewers</span> can access.</li>
        </ul>
      </p>

      <h3 id="helpOnChannel">Channel</h3>

      <p>A channel is a shortcut for users to upload their data and input the metadata at the same time. It also a way to enforce some rules of uploads like file renaming and metadata collection.</p>
      <p>To create a channel, go to the project page, click <span class="quote">+ Channel</span>, and in the popped up form specify the target folder, metadata file, how many files per upload, instruction and rename rule. You could also edit or delete existing channels by clicking the corresponding icons on the channel.</p>
      <p>To upload through a channel, click the channel which will pop up a form containing the required metadata. The user must select the correct number of files and fill out all the fields to upload. The files will be uploaded to the target folder, and the metadata input will be appended in the metadata file of the channel, as the required fields are actually extracted from the first line of the same file (split by "tab"). Note that <span class="quote">Editors</span> could upload files to a hidden or readonly folder through channels.</p>

      <h3 id="helpOnFileTypes">File Types</h3>

      <p>The application uses file name and file extension to determine what kind file it is and how to open it in the browser. Currently it can open <span class="quote">image</span>, <span class="quote">document</span>, <span class="quote">plain text</span>, <span class="quote">csv</span> and <span class="quote">zip</span> files.
        <ul>
          <li><span class="quote">image</span>: <span class="quote">.png</span>, <span class="quote">.jpg</span>, <span class="quote">.jpeg</span>, <span class="quote">.gif</span>, <span class="quote">.bmp</span></li>
          <li><span class="quote">document</span>: <span class="quote">.pdf</span>, <span class="quote">.doc</span>, <span class="quote">.docx</span>, <span class="quote">.xls</span>, <span class="quote">.xlsx</span>, <span class="quote">.ppt</span>, <span class="quote">.pptx</span>, <span class="quote">.rtf</span>, <span class="quote">.tif</span>, <span class="quote">.tiff</span>, <span class="quote">.ai</span>, <span class="quote">.psd</span>, <span class="quote">.dxf</span>, <span class="quote">.svg</span>, <span class="quote">.eps</span>, <span class="quote">.ps</span>, <span class="quote">.ttf</span>, <span class="quote">.xps</span></li>
          <li><span class="quote">plain text</span>: <span class="quote">.txt</span>, <span class="quote">.md</span>, <span class="quote">.r</span>, <span class="quote">.m</span>, <span class="quote">.py</span>, <span class="quote">.rb</span>, <span class="quote">.sh</span>, <span class="quote">makefile</span>, <span class="quote">.c</span>, <span class="quote">.h</span>, <span class="quote">.cpp</span>, <span class="quote">.hpp</span>, <span class="quote">.js</span>, <span class="quote">.json</span>, <span class="quote">.cr</span>, <span class="quote">.html</span>, <span class="quote">.css</span>, <span class="quote">.vue</span>, <span class="quote">.php</span> They are also editable in browser.</li>
          <li><span class="quote">csv</span>: <span class="quote">.csv</span>, <span class="quote">.tsv</span> Columns could be drawn into different kinds of charts.</li>
          <li><span class="quote">zip</span>: <span class="quote">.zip</span> They can be unzipped online.</li>
          <li>Other files will be only opened for download.</li>
        </ul>
      </p>
      
      <h3 id="helpOnPublicUrl">Public URL</h3>

      <p>A public URL allows other people to access a folder inside of a project. Those people do not need to be the project users or even DMAC users as long as they know the URL.</p>
      <p>To generate a public URL, go to the folder you want to make public and click <span class="quote">Publish</span> button, then a public URL is generated. You could test it by clicking <span class="icon"><icon name="share-alt"></icon></span> near folder name. You could send it to anyone you want to let them to view your folder. Anyone accesses the folder through public URL can ONLY view but not edit the files inside.</p>
      <p>To view and manage public URLs of a project, click <span class="quote">Public URLs</span> button on the project page, and then you could see all the public URLs of this project, and delete anyone if you want.</p>

      <h3 id="helpOnHistory">History</h3>

      <p>History allows you view all this edit history of files in your project. To view the history, click <span class="quote">History</span> button on the project page, then you will see a list of edit history from latest to oldest.</p>
      <p>You could click into each record to see what changes it made. The red lines starting with <span class="quote red">-</span> are what was deleted, while the green lines starting with <span class="quote green">+</span> are what was added.</p>
      <p>By clicking <span class="quote">Rollback to This Point</span> button, you could rollback to this record, which means all the following changes will be reverted until this one, and your project goes back to the state of this record.</p>
      <p>Rolling back does not delete any history. Instead, it reverts the changes and added another record in the history. So you are not going to lose any data, and you still can go back to any other record freely.</p>
      <p>By clicking <span class="quote">Delete History before This Point</span> button, you could delete history until this record. Although it won't change the current state of the project, you will NOT be able to rollback to any point before this record after doing that.</p>

    </div>

  </div>

</template>

<script>

export default {
  name: 'help-page',
  methods: {
    scrollToElement(id){
      var el = document.getElementById(id)
      window.scroll(0, el.offsetTop)
    },
    toggleHelpPage(){
      this.$emit('toggle-help-page')
    }
  }
}
</script>

<style lang="scss" scoped>

.help-page {
  padding: 10px;
}

.close-btn {
  margin-right: 15px;
  margin-top: 10px;
  float: right;
}

.help-nav {
  display: inline-block;
  margin: 10px;
  padding: 10px;
  border: 1px solid #EEEEEE;
  border-radius: 5px;
  background-color: #EEEEEE;
}

.help-content {
  padding: 10px;
  color: black!important;
}

h3 {
  color: #2e1052;
}

.quote {
  color: #2e1052;
  border: 1px solid #EEEEEE;
  border-radius: 3px;
  padding-top: 1px;
  padding-bottom: 1px;
  padding-left: 3px;
  padding-right: 3px;
  margin-left: 3px;
  margin-right: 3px;
  background-color: #EEEEEE;
}

.icon {
  color: #2e1052;
  position: relative;
  top: 3px;
}

.red {
  color: red;
}

.green {
  color: green;
}

</style>
