import { createRouter, createWebHashHistory } from 'vue-router'
import Play from './views/ViewPlay.vue'
import World from './views/World.vue'
import Mechanics from './views/Mechanics.vue'
import Managment from './views/Managment.vue'
import Settings from './views/Settings.vue'
import Login from './views/ViewLogin.vue'
import Profile from './views/Profile.vue'
import Help from './views/Help.vue'
import ForumThread from './views/ForumThread.vue'
import SignUp from './views/ViewSignUp.vue'

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
    path: '/signup',
    name: 'signup',
    component: SignUp
  },
  {
    path: '/profile',
    name: 'profile',
    component: Profile
  },
  {
    path: '/help',
    name: 'help',
    component: Help
  },
  {
    path: '/thread/:threadId',
    name: 'thread',
    component: ForumThread,
    props: true
  }
  
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
