import Vue from 'vue'
import Router from 'vue-router'
import ProjectsPage from '@/components/ProjectsPage'
import ProjectPage from '@/components/ProjectPage'
import UsersPage from '@/components/UsersPage'
import FolderFilePage from '@/components/FolderFilePage'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Projects',
      component: ProjectsPage
    },
    {
      path: '/:projectId',
      name: 'Project',
      component: ProjectPage
    },
    {
      path: '/:projectId/users',
      name: 'ProjectUsers',
      component: UsersPage
    },
    {
      path: '/:projectId/data/:dataPath',
      name: 'FolderFile',
      component: FolderFilePage
    },
  ]
})
