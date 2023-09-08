import { createRouter, createWebHashHistory } from 'vue-router'
import Play from './views/Play.vue'
import World from './views/World.vue'
import Mechanics from './views/Mechanics.vue'
import Managment from './views/Managment.vue'
import Settings from './views/Settings.vue'
import Login from './views/Login.vue'
import Profile from './views/Profile.vue'

const routes = [
  {
    path: '/',
    name: 'play',
    component: Play
  },
  {
    path: '/world',
    name: 'world',
    component: World
  },
  {
    path: '/mechanics',
    name: 'mechanics',
    component: Mechanics
  },
  {
    path: '/managment',
    name: 'managment',
    component: Managment
  },
  {
    path: '/settings',
    name: 'settings',
    component: Settings
  },
  {
    path: '/login',
    name: 'login',
    component: Login
  },
  {
    path: '/profile',
    name: 'profile',
    component: Profile
  }
  
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
