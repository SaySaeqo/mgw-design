<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h1 class="login-title">Welcome Back</h1>
        <p class="login-subtitle">Sign in to your account</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input
            id="email"
            v-model="loginForm.email"
            type="email"
            class="form-input"
            :class="{ 'error': errors.email }"
            placeholder="Enter your email"
            required
          />
          <span v-if="errors.email" class="error-message">{{ errors.email }}</span>
        </div>

        <div class="form-group">
          <label for="password" class="form-label">Password</label>
          <div class="password-input">
            <input
              id="password"
              v-model="loginForm.password"
              :type="showPassword ? 'text' : 'password'"
              class="form-input"
              :class="{ 'error': errors.password }"
              placeholder="Enter your password"
              required
            />
            <button
              type="button"
              @click="togglePassword"
              class="password-toggle"
              :title="showPassword ? 'Hide password' : 'Show password'"
            >
              {{ showPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
          <span v-if="errors.password" class="error-message">{{ errors.password }}</span>
        </div>

        <div class="form-options">
          <label class="checkbox-label">
            <input
              v-model="loginForm.rememberMe"
              type="checkbox"
              class="checkbox"
            />
            <span class="checkmark"></span>
            Remember me
          </label>
          <a href="/forgot-password" class="forgot-link">Forgot password?</a>
        </div>

        <button
          type="submit"
          class="login-btn"
          :disabled="isLoading"
          :class="{ 'loading': isLoading }"
        >
          <span v-if="!isLoading">Sign In</span>
          <span v-else class="loading-spinner"></span>
        </button>
      </form>

      <div class="login-footer">
        <p class="signup-prompt">
          Don't have an account?
          <RouterLink to="/signup" class="signup-link">Sign up</RouterLink>
        </p>
      </div>

      <!-- Success/Error Messages -->
      <div v-if="message" class="message" :class="messageType">
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { RouterLink, useRouter } from 'vue-router'

const router = useRouter()

// Reactive form data
const loginForm = reactive({
  email: '',
  password: '',
  rememberMe: false
})

// Reactive state
const isLoading = ref(false)
const showPassword = ref(false)
const message = ref('')
const messageType = ref('success') // 'success' or 'error'

// Reactive errors
const errors = reactive({
  email: '',
  password: ''
})

// Computed validation
// const isFormValid = computed(() => {
//   return loginForm.email && 
//          loginForm.password && 
//          !errors.email && 
//          !errors.password
// })

// Methods
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

const validateForm = () => {
  // Clear previous errors
  errors.email = ''
  errors.password = ''

  // Validate email
  if (!loginForm.email) {
    errors.email = 'Email is required'
  } else if (!validateEmail(loginForm.email)) {
    errors.email = 'Please enter a valid email'
  }

  // Validate password
  if (!loginForm.password) {
    errors.password = 'Password is required'
  } else if (loginForm.password.length < 6) {
    errors.password = 'Password must be at least 6 characters'
  }

  return !errors.email && !errors.password
}

const togglePassword = () => {
  showPassword.value = !showPassword.value
}

const showMessage = (msg, type = 'success') => {
  message.value = msg
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

const handleLogin = async () => {
  if (!validateForm()) return

  isLoading.value = true
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // Mock successful login
    const mockUser = {
      id: 1,
      email: loginForm.email,
      name: 'John Doe',
      token: 'mock-jwt-token'
    }

    // Store user data (in real app, you'd use a store like Pinia)
    localStorage.setItem('user', JSON.stringify(mockUser))
    if (loginForm.rememberMe) {
      localStorage.setItem('rememberLogin', 'true')
    }

    showMessage('Login successful! Redirecting...', 'success')
    
    // Redirect after short delay
    setTimeout(() => {
      router.push('/')
    }, 1000)

  } catch (error) {
    console.error('Login error:', error)
    showMessage('Invalid email or password. Please try again.', 'error')
  } finally {
    isLoading.value = false
  }
}

// Watch for real-time validation
import { watch } from 'vue'

watch(() => loginForm.email, (newEmail) => {
  if (newEmail && errors.email) {
    errors.email = validateEmail(newEmail) ? '' : 'Please enter a valid email'
  }
})

watch(() => loginForm.password, (newPassword) => {
  if (newPassword && errors.password) {
    errors.password = newPassword.length >= 6 ? '' : 'Password must be at least 6 characters'
  }
})
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  padding: 40px;
  width: 100%;
  max-width: 400px;
  position: relative;
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px 0;
}

.login-subtitle {
  color: #666;
  margin: 0;
  font-size: 16px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-label {
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
  font-size: 14px;
}

.form-input {
  padding: 12px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.3s ease;
  background: #fff;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input.error {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.password-input {
  position: relative;
}

.password-toggle {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  font-size: 18px;
  color: #666;
  padding: 4px;
}

.password-toggle:hover {
  color: #333;
}

.error-message {
  color: #ef4444;
  font-size: 14px;
  margin-top: 6px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #666;
  font-size: 14px;
}

.checkbox {
  margin-right: 8px;
  accent-color: #667eea;
}

.forgot-link {
  color: #667eea;
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.forgot-link:hover {
  color: #5a67d8;
  text-decoration: underline;
}

.login-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px 20px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 10px;
  position: relative;
  overflow: hidden;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
}

.login-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.loading-spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 2px solid #ffffff40;
  border-top: 2px solid #ffffff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.login-footer {
  text-align: center;
  margin-top: 30px;
}

.signup-prompt {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.signup-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s ease;
}

.signup-link:hover {
  color: #5a67d8;
  text-decoration: underline;
}

.message {
  margin-top: 20px;
  padding: 12px 16px;
  border-radius: 8px;
  text-align: center;
  font-weight: 500;
  animation: slideDown 0.3s ease;
}

.message.success {
  background: #d1fae5;
  color: #065f46;
  border: 1px solid #a7f3d0;
}

.message.error {
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive design */
@media (max-width: 480px) {
  .login-card {
    padding: 30px 20px;
    margin: 10px;
  }
  
  .login-title {
    font-size: 24px;
  }
  
  .form-options {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
}
</style>
