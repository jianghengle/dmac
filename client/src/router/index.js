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
      redirect: '/projects'
    },
    {
      path: '/projects',
      name: 'Projects',
      component: ProjectsPage
    },
    {
      path: '/projects/:projectId',
      name: 'Project',
      component: ProjectPage
    },
    {
      path: '/projects/:projectId/users',
      name: 'ProjectUsers',
      component: UsersPage
    },
    {
      path: '/projects/:projectId/data/:dataPath',
      name: 'FolderFile',
      component: FolderFilePage
    },
  ]
})
