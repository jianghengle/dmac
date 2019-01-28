import Vue from 'vue'
import Router from 'vue-router'
import ProjectsPage from '@/components/ProjectsPage'
import ProjectPage from '@/components/ProjectPage'
import UsersPage from '@/components/UsersPage'
import PublicUrlsPage from '@/components/PublicUrlsPage'
import FolderFilePage from '@/components/FolderFilePage'
import HistoryPage from '@/components/HistoryPage'
import CommitPage from '@/components/CommitPage'
import SearchPage from '@/components/SearchPage'
import HelpPage from '@/components/HelpPage'
import DmacLogin from '@/components/DmacLogin'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      redirect: '/projects'
    },
    {
      path: '/help',
      name: 'Help',
      component: HelpPage
    },
    {
      path: '/login',
      name: 'DmacLogin',
      component: DmacLogin
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
      path: '/projects/:projectId/urls',
      name: 'PublicUrlsPage',
      component: PublicUrlsPage
    },
    {
      path: '/projects/:projectId/history',
      name: 'HistoryPage',
      component: HistoryPage
    },
    {
      path: '/projects/:projectId/history/:hash',
      name: 'CommitPage',
      component: CommitPage
    },
    {
      path: '/projects/:projectId/data/:dataPath',
      name: 'ProjectFolderFile',
      component: FolderFilePage
    },
    {
      path: '/projects/:projectId/search/:dataPath',
      name: 'ProjectSearch',
      component: SearchPage
    },
    {
      path: '/public/:publicKey/data/:dataPath',
      name: 'PublicFolderFile',
      component: FolderFilePage
    },
    {
      path: '/public/:publicKey/search/:dataPath',
      name: 'PublicSearch',
      component: SearchPage
    },
  ]
})
