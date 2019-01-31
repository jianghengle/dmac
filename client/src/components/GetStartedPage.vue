<template>

  <div class="container get-started-page">

    <div class="back-btn">
      <a class="button default-btn" @click="$router.go(-1)">
        <icon name="arrow-left"></icon>&nbsp;Back
      </a>
    </div>

    <div class="content">
      <h2 class="get-started-title">Get Started with DMAC</h2>
    </div>

    <div class="get-started-nav">
      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('loginDMAC')">
          Login DMAC
        </a>
        <ul class="nav-list">
          <li>
            <a @click="scrollToElement('loginThroughGlobus')">Login through Globus</a>
          </li>
          <li>
            <a @click="scrollToElement('loginLocally')">Login locally</a>
          </li>
        </ul>
      </div>
      
      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('workOnProjects')">
          Work on Projects
        </a>
        <ul class="nav-list">
          <li>
            <a @click="scrollToElement('createAProject')">Create a Project</a>
          </li>
          <li>
            <a @click="scrollToElement('workOnAProject')">Work on a Project</a>
          </li>
        </ul>
      </div>

      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('transferData')">
          Transfer Data
        </a>
        <ul class="nav-list">
          <li>
            <a @click="scrollToElement('uploadFiles')">Upload Files</a>
          </li>
          <li>
            <a @click="scrollToElement('channels')">Channels</a>
          </li>
          <li>
            <a @click="scrollToElement('transferByGlobus')">Transfer by Globus</a>
          </li>
          <li>
            <a @click="scrollToElement('transferToFromCyverse')">Transfer to/from CyVerse</a>
          </li>
        </ul>
      </div>

      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('exploreData')">
          Explore Data
        </a>
        <ul class="nav-list">
          <li>
            <a @click="scrollToElement('exploreFolderFiles')">Explore Folder & Files</a>
          </li>
          <li>
            <a @click="scrollToElement('folderFilePermissions')">Folder & File Permissions</a>
          </li>
        </ul>
      </div>

      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('publishData')">
          Publish Data
        </a>
      </div>

      <div class="nav-section">
        <a class="has-text-weight-bold" @click="scrollToElement('projectHistory')">
          Project History
        </a>
      </div>
    </div>

    <div class="content get-started-content">
      
      <div>
        <h3 id="loginDMAC">Login DMAC</h3>

        <h4 id="loginThroughGlobus">Login through Globus</h4>
        <p>The easiest way to login the DMAC system is through Globus Authentication, which allows anyone to login DMAC using their university accounts.</p>
        <ol>
          <li>
            Open your web browser and navigate to <a href="https://dmac.unl.edu">https://dmac.unl.edu</a>, and then click the <span class="quote">Globus login</span> as shown in the screenshot below.
            <span class="screenshot"><img src="static/get_started/login1.png"></img></span>
          </li>
          <li>
            Then your browser will redirect you to the Globus Login page, where you should pick your university from the dropdown menu and then click <em>Continue</em>.
            <span class="screenshot"><img src="static/get_started/login2.png"></img></span>
          </li>
          <li>
            Now your browser should redirect you to your school Login page, where you should login to your university account.
            <span class="screenshot"><img src="static/get_started/login3.png"></img></span>
          </li>
          <li>
            After login successfully, the browser should redirect back to the DMAC Projects page, where the header should show the username of your DMAC account. And if you hover on the username, it will also show the email address of your DMAC account.
            <span class="screenshot"><img src="static/get_started/login4.png"></img></span>
          </li>
        </ol>
        <p>Please note that if this is the first time you login to DMAC through Globus, the system actually just created a new DMAC account for you using your university's email address.</p>

        <h4 id="loginLocally">Login locally</h4>
        <p>
          Alternatively, if you already have an account, you could login the DMAC system locally by your username or email and your password.
          If you created your account by logging in through Globus, you could set your DMAC account password by clicking <span class="quote">Forgot your password?</span>.
          If you do not have a DMAC account yet, instead of logging in through Globus, you could also create a new account by clicking <span class="quote">Register new account</span>.
          <span class="screenshot"><img src="static/get_started/login5.png"></img></span>
        </p>
      </div>

      <div>
        <h3 id="workOnProjects">Work on Projects</h3>

        <h4 id="createAProject">Create a Project</h4>
        <p>
          To create a new project you could simply click <span class="quote">+ New Project</span> button on the projects page. (Please note that only the DMAC <em>Project Managers</em> could create a new project. If you do not see the <span class="quote">+ New Project</span> button, you are a normal user who does not have permission of creating projects. But, you could contact <a href="mailto:jianghengle@gmail.com">jianghengle@gmail.com</a> to request that permission if you need to.) After clicking the button, the new project form will pop up as shown below.
          <span class="screenshot"><img src="static/get_started/project1.png"></img></span>
          Other than the <em>Name</em> and <em>Description</em> fields, you could also click the <em>Template</em> dropdown to select a template, where you might also need to fill out some metadata to create your new project.
        </p>

        <h4 id="workOnAProject">Work on a Project</h4>
        <p>
          A project is simply a data container associated with some basic information such as <em>Name, Owner, Description, Status etc.</em>, and a group of <em>users</em>. The basic information could be edited by clicking the <span class="inline-icon"><icon name="edit"></icon></span> icon. The project status could be one of <em>Active, Archived, Template, Public Template</em>, which affects the project's accessibility and usage. For example, <em>Template</em> projects could be accessed by its owner to create new projects, while <em>Public Template</em> projects could be accessed by all DMAC users to create new projects.
        </p>
        <p>
          A project can only be accessed by its users. These users are shown in the <em>Users</em> tab inside the project. Each user is identified by the email address of its DMAC account, and each user has a particular role which specifies how the user could access the project and work on the data.
          <ul>
            <li><em>Owner</em> is the user who created the project, who has full permission on the project, project users and project data inside.</li>
            <li><em>Admin</em>s also have full permission on the project and its data inside, except for deleting the project and adding/removing other project <em>Admin</em>s.</li>
            <li><em>Editor</em>s can only access <em>Active</em> projects. They do not have permission to edit any project information or project users. They are only allowed to view/add/edit files based on the individual files' permissions.</li>
            <li><em>Viewer</em>s can only access <em>Active</em> projects. They do not have permission to edit any project information or project users. They are only allowed to view files based on the individual files' permissions.</li>
          </ul>
          To add a new user in a project, you could click <span class="quote">+ User</span> button, and then fill in the email and assign a role in the popped form. You could also edit existing users by clicking the <span class="inline-icon"><icon name="edit"></icon></span> icon in the users' table.
          <span class="screenshot"><img src="static/get_started/project2.png"></img></span>
        </p>
      </div>

      <div>
        <h3 id="transferData">Transfer Data</h3>

        <h4 id="uploadFiles">Upload Files</h4>
        <p>The project data is under the <em>Data</em> tab, where the UI looks very similar to a Window File Explorer or a Mac Finder. Similarly, the data or files could be organized into folders just as your local file system does. At any folder view, the <em>Upload File</em> is in the <em>Actions</em> menu when hovering on it, by which you could upload any files from your local computer.
        <span class="screenshot"><img src="static/get_started/transfer1.png"></img></span></p>

        <h4 id="channels">Channels</h4>
        <p>Alternatively, files could be also uploaded through channels, which is provided for uploading data along with specified metadata. All the project channels are under the <em>Channels</em> tab. Each channel targets a metadata file, which is essentially a CSV file with a formatted header that defines the input types in the channel UI.<span class="screenshot"><img src="static/get_started/transfer2.png"></img></span></p>

        <h4 id="transferByGlobus">Transfer by Globus</h4>
        <p>For files bigger than 2GB or folders which are not able to be uploaded directly through the web browser, you should utilize Globus to accomplish the transfer task. The endpoint of the DMAC system on Globus is <em>hcc#dmac</em>. As shown below, in the Globus UI you need to specify the endpoint (collection) and fill in your DMAC username and password. After authorized by the DMAC server, you should  be able to see your projects and transfer data from/to the DMAC server.<span class="screenshot"><img src="static/get_started/transfer3.png"></img></span></p>

        <h4 id="transferToFromCyverse">Transfer to/from CyVerse</h4>
        <p>You could also transfer data between DMAC and CyVerse. At any folder view, you can find the <em>CyVerse</em> in the <em>Actions</em> menu. After clicking <em>CyVerse</em>, a window will pop up where you could login CyVerse and transfer your data.<span class="screenshot"><img src="static/get_started/transfer4.png"></img></span></p>
      </div>

      <div>
        <h3 id="exploreData">Explore Data</h3>

        <h4 id="exploreFolderFiles">Explore Folder & Files</h4>
        <p>The project data explorer UI looks very similar to a Window File Explorer in the web browser, where you can navigate by the sidebar or click on the folder or file directly. You could preview almost any type of files in the browser from plain text to Excel document. And you could even manipulate the data online directly, for example, create/update/delete/copy folders and files.
        <span class="screenshot"><img src="static/get_started/explore1.png"></img></span></p>
        <p>For CSV files, several data visualization tools are provided including historgrams and correlation matrix etc., so that users could visualize and analyze the data online in the web browser directly.
        <span class="screenshot"><img src="static/get_started/explore2.png"></img></span></p>

        <h4 id="folderFilePermissions">Folder & File Permissions</h4>
        <p>
          In addition to project-level permission control, you could put extra permissions on individual folders and files to define how you want them to be accessed by <em>Editors</em> and <em>Viewers</em>. You could edit this property by clicking the <span class="inline-icon"><icon name="edit"></icon></span> icon on individual folders and files.
          <ul>
            <li><em>Normal</em> means no extra control.</li>
            <li><em>Readonly</em> indicates that even the project <em>Editors</em> cannot modify it.</li>
            <li><em>Hidden</em> folders and files are not viewable for the project <em>Editors</em> and <em>Viewers</em>.</li>
          </ul>
          <span class="screenshot"><img src="static/get_started/explore3.png"></img></span>
        </p>
      </div>

      <div>
        <h3 id="publishData">Publish Data</h3>
        <p>You could publish any folder in your project, which will allow anyone (even without the DMAC account) to view the data in this folder through a public URL. The <em>Publish</em> button is in the folder's <em>Actions</em> menu, and you can see all the public URLs in the project's <em>Public URLs</em> tab, where you can also delete any public URLs generated before.<span class="screenshot"><img src="static/get_started/publish1.png"></img></span></p>
      </div>

      <div>
        <h3 id="projectHistory">Project History</h3>
        <p>In the project <em>History</em> tab, you can see all edit history recorded for this project. You can also see the detail of each recorded point, even rollback to any point. You can record the current state of the project by clicking the <em>New History Record</em> button in any folder's <em>Actions</em> menu. The project has an <em>Auto History</em> attribute, and if it is turned on, every change will be recorded as a history point.<span class="screenshot"><img src="static/get_started/history1.png"></img></span></p>
      </div>
    </div>

  </div>

</template>

<script>

export default {
  name: 'get-started-page',
  methods: {
    scrollToElement(id){
      var el = document.getElementById(id)
      window.scroll(0, el.offsetTop)
    },
  }
}
</script>

<style lang="scss" scoped>

.get-started-page {
  padding: 10px;
}

.back-btn {
  margin-left: 10px;
}

.get-started-title {
  margin-top: 20px;
  margin-left: 10px;
  font-weight: bold;
  color: #2e1052;
}

.get-started-nav {
  display: inline-block;
  margin-left: 10px;
  margin-top: 5px;
  margin-bottom: 20px;
  padding: 30px;
  border: 1px solid #EEEEEE;
  border-radius: 5px;
  background-color: #EEEEEE;
}

.nav-list {
  list-style-type: inherit;
  padding-left: 30px;

}

.nav-section {
  margin-bottom: 10px;
}

.get-started-content {
  padding: 10px;
  color: black!important;

  h3 {
    color: #2e1052;
    font-weight: bold;
    padding-top: 10px;
  }

  h4 {
    color: #2e1052;
    padding-top: 10px;
  }

  em {
    color: #2e1052;
  }
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

.screenshot {
  max-width: 800px;
  display: block;
}

.inline-icon {
  color: #2e1052;
  position: relative;
  top: 3px;
}


</style>
