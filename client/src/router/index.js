import Vue from 'vue'
import Router from 'vue-router'
import ProjectsPage from '@/components/ProjectsPage'
import ProjectPage from '@/components/ProjectPage'
import UsersPage from '@/components/UsersPage'
import PublicUrlsPage from '@/components/PublicUrlsPage'
import ChannelsPage from '@/components/ChannelsPage'
import FolderFilePage from '@/components/FolderFilePage'
import HistoryPage from '@/components/HistoryPage'
import CommitPage from '@/components/CommitPage'
import HelpPage from '@/components/HelpPage'

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
      path: '/projects/:projectId/channels',
      name: 'ChannelsPage',
      component: ChannelsPage
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
      name: 'FolderFile',
      component: FolderFilePage
    },
    {
      path: '/projects/:projectId/data',
      name: 'FolderFile',
      component: FolderFilePage
    },
    {
      path: '/public/:publicKey/:dataPath',
      name: 'FolderFile',
      component: FolderFilePage
    }
  ]
})
