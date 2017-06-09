import Vue from 'vue'
import Router from 'vue-router'
import ProjectsPage from '@/components/ProjectsPage'
import ProjectPage from '@/components/ProjectPage'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'ProjectsPage',
      component: ProjectsPage
    },
    {
      path: '/:projectId/:path',
      name: 'ProjectPage',
      component: ProjectPage
    },
  ]
})
