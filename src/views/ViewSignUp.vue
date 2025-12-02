<template>
  <div class="signup-container">
    <div class="signup-card">
      <div class="signup-header">
        <h1 class="signup-title">Create Account</h1>
        <p class="signup-subtitle">Join our community today</p>
      </div>

      <form @submit.prevent="handleSignup" class="signup-form">
        <div class="form-row">
          <div class="form-group">
            <label for="firstName" class="form-label">First Name</label>
            <input
              id="firstName"
              v-model="signupForm.firstName"
              type="text"
              class="form-input"
              :class="{ 'error': errors.firstName }"
              placeholder="Enter first name"
              required
            />
            <span v-if="errors.firstName" class="error-message">{{ errors.firstName }}</span>
          </div>

          <div class="form-group">
            <label for="lastName" class="form-label">Last Name</label>
            <input
              id="lastName"
              v-model="signupForm.lastName"
              type="text"
              class="form-input"
              :class="{ 'error': errors.lastName }"
              placeholder="Enter last name"
              required
            />
            <span v-if="errors.lastName" class="error-message">{{ errors.lastName }}</span>
          </div>
        </div>

        <div class="form-group">
          <label for="username" class="form-label">Username</label>
          <input
            id="username"
            v-model="signupForm.username"
            type="text"
            class="form-input"
            :class="{ 'error': errors.username, 'success': validUsername }"
            placeholder="Choose a username"
            required
          />
          <span v-if="errors.username" class="error-message">{{ errors.username }}</span>
          <span v-if="validUsername && !errors.username" class="success-message">Username available!</span>
        </div>

        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input
            id="email"
            v-model="signupForm.email"
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
              v-model="signupForm.password"
              :type="showPassword ? 'text' : 'password'"
              class="form-input"
              :class="{ 'error': errors.password }"
              placeholder="Create a password"
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
          
          <!-- Password Strength Indicator -->
          <div class="password-strength" v-if="signupForm.password">
            <div class="strength-bar">
              <div 
                class="strength-fill" 
                :class="passwordStrength.class"
                :style="{ width: passwordStrength.width }"
              ></div>
            </div>
            <span class="strength-text" :class="passwordStrength.class">
              {{ passwordStrength.text }}
            </span>
          </div>
        </div>

        <div class="form-group">
          <label for="confirmPassword" class="form-label">Confirm Password</label>
          <div class="password-input">
            <input
              id="confirmPassword"
              v-model="signupForm.confirmPassword"
              :type="showConfirmPassword ? 'text' : 'password'"
              class="form-input"
              :class="{ 'error': errors.confirmPassword, 'success': passwordsMatch }"
              placeholder="Confirm your password"
              required
            />
            <button
              type="button"
              @click="toggleConfirmPassword"
              class="password-toggle"
              :title="showConfirmPassword ? 'Hide password' : 'Show password'"
            >
              {{ showConfirmPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
          <span v-if="errors.confirmPassword" class="error-message">{{ errors.confirmPassword }}</span>
          <span v-if="passwordsMatch && !errors.confirmPassword" class="success-message">Passwords match!</span>
        </div>

        <div class="form-group">
          <label class="checkbox-label">
            <input
              v-model="signupForm.agreeToTerms"
              type="checkbox"
              class="checkbox"
              required
            />
            <span class="checkmark"></span>
            I agree to the 
            <a href="/terms" target="_blank" class="terms-link">Terms of Service</a> 
            and 
            <a href="/privacy" target="_blank" class="terms-link">Privacy Policy</a>
          </label>
          <span v-if="errors.agreeToTerms" class="error-message">{{ errors.agreeToTerms }}</span>
        </div>

        <div class="form-group">
          <label class="checkbox-label">
            <input
              v-model="signupForm.newsletter"
              type="checkbox"
              class="checkbox"
            />
            <span class="checkmark"></span>
            Subscribe to newsletter for updates and news
          </label>
        </div>

        <button
          type="submit"
          class="signup-btn"
          :disabled="isLoading || !isFormValid"
          :class="{ 'loading': isLoading }"
        >
          <span v-if="!isLoading">Create Account</span>
          <span v-else class="loading-spinner"></span>
        </button>
      </form>

      <div class="signup-footer">
        <p class="login-prompt">
          Already have an account?
          <a href="/login" class="login-link">Sign in</a>
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
import { ref, reactive, computed, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// Reactive form data
const signupForm = reactive({
  firstName: '',
  lastName: '',
  username: '',
  email: '',
  password: '',
  confirmPassword: '',
  agreeToTerms: false,
  newsletter: false
})

// Reactive state
const isLoading = ref(false)
const showPassword = ref(false)
const showConfirmPassword = ref(false)
const message = ref('')
const messageType = ref('success')
const checkingUsername = ref(false)
const validUsername = ref(false)

// Reactive errors
const errors = reactive({
  firstName: '',
  lastName: '',
  username: '',
  email: '',
  password: '',
  confirmPassword: '',
  agreeToTerms: ''
})

// Computed properties
const isFormValid = computed(() => {
  return signupForm.firstName &&
         signupForm.lastName &&
         signupForm.username &&
         signupForm.email &&
         signupForm.password &&
         signupForm.confirmPassword &&
         signupForm.agreeToTerms &&
         !Object.values(errors).some(error => error !== '') &&
         passwordsMatch.value
})

const passwordsMatch = computed(() => {
  return signupForm.password && 
         signupForm.confirmPassword && 
         signupForm.password === signupForm.confirmPassword
})

const passwordStrength = computed(() => {
  const password = signupForm.password
  if (!password) return { width: '0%', class: '', text: '' }
  
  let score = 0
  let feedback = []
  
  // Length check
  if (password.length >= 8) score++
  else feedback.push('8+ characters')
  
  // Uppercase check
  if (/[A-Z]/.test(password)) score++
  else feedback.push('uppercase letter')
  
  // Lowercase check
  if (/[a-z]/.test(password)) score++
  else feedback.push('lowercase letter')
  
  // Number check
  if (/\d/.test(password)) score++
  else feedback.push('number')
  
  // Special character check
  if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) score++
  else feedback.push('special character')
  
  const strength = {
    0: { width: '20%', class: 'very-weak', text: 'Very Weak' },
    1: { width: '30%', class: 'weak', text: 'Weak' },
    2: { width: '50%', class: 'fair', text: 'Fair' },
    3: { width: '70%', class: 'good', text: 'Good' },
    4: { width: '90%', class: 'strong', text: 'Strong' },
    5: { width: '100%', class: 'very-strong', text: 'Very Strong' }
  }
  
  return strength[score] || strength[0]
})

// Methods
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

const validateUsername = async (username) => {
  if (!username || username.length < 3) return false
  
  checkingUsername.value = true
  
  // Simulate API call to check username availability
  await new Promise(resolve => setTimeout(resolve, 500))
  
  // Mock validation - in real app, check against API
  const unavailableUsernames = ['admin', 'user', 'test', 'root']
  const available = !unavailableUsernames.includes(username.toLowerCase())
  
  checkingUsername.value = false
  validUsername.value = available
  
  return available
}

const validateForm = () => {
  // Clear previous errors
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })

  // Validate first name
  if (!signupForm.firstName) {
    errors.firstName = 'First name is required'
  } else if (signupForm.firstName.length < 2) {
    errors.firstName = 'First name must be at least 2 characters'
  }

  // Validate last name
  if (!signupForm.lastName) {
    errors.lastName = 'Last name is required'
  } else if (signupForm.lastName.length < 2) {
    errors.lastName = 'Last name must be at least 2 characters'
  }

  // Validate username
  if (!signupForm.username) {
    errors.username = 'Username is required'
  } else if (signupForm.username.length < 3) {
    errors.username = 'Username must be at least 3 characters'
  } else if (!/^[a-zA-Z0-9_]+$/.test(signupForm.username)) {
    errors.username = 'Username can only contain letters, numbers, and underscores'
  } else if (!validUsername.value) {
    errors.username = 'Username is not available'
  }

  // Validate email
  if (!signupForm.email) {
    errors.email = 'Email is required'
  } else if (!validateEmail(signupForm.email)) {
    errors.email = 'Please enter a valid email'
  }

  // Validate password
  if (!signupForm.password) {
    errors.password = 'Password is required'
  } else if (signupForm.password.length < 8) {
    errors.password = 'Password must be at least 8 characters'
  }

  // Validate confirm password
  if (!signupForm.confirmPassword) {
    errors.confirmPassword = 'Please confirm your password'
  } else if (signupForm.password !== signupForm.confirmPassword) {
    errors.confirmPassword = 'Passwords do not match'
  }

  // Validate terms agreement
  if (!signupForm.agreeToTerms) {
    errors.agreeToTerms = 'You must agree to the terms and conditions'
  }

  return !Object.values(errors).some(error => error !== '')
}

const togglePassword = () => {
  showPassword.value = !showPassword.value
}

const toggleConfirmPassword = () => {
  showConfirmPassword.value = !showConfirmPassword.value
}

const showMessage = (msg, type = 'success') => {
  message.value = msg
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

const handleSignup = async () => {
  if (!validateForm()) return

  isLoading.value = true
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Mock successful signup
    const newUser = {
      id: Date.now(),
      firstName: signupForm.firstName,
      lastName: signupForm.lastName,
      username: signupForm.username,
      email: signupForm.email,
      newsletter: signupForm.newsletter
    }

    newUser;

    showMessage('Account created successfully! Please check your email to verify your account.', 'success')
    
    // Reset form
    Object.keys(signupForm).forEach(key => {
      if (typeof signupForm[key] === 'boolean') {
        signupForm[key] = false
      } else {
        signupForm[key] = ''
      }
    })
    
    // Redirect to login after delay
    setTimeout(() => {
      router.push('/login')
    }, 2000)

  } catch (error) {
    console.error('Signup error:', error)
    showMessage('An error occurred during signup. Please try again.', 'error')
  } finally {
    isLoading.value = false
  }
}

// Watch for real-time validation
watch(() => signupForm.username, async (newUsername) => {
  if (newUsername && newUsername.length >= 3) {
    await validateUsername(newUsername)
  } else {
    validUsername.value = false
  }
})

watch(() => signupForm.email, (newEmail) => {
  if (newEmail && errors.email) {
    errors.email = validateEmail(newEmail) ? '' : 'Please enter a valid email'
  }
})

watch(() => signupForm.confirmPassword, (newConfirmPassword) => {
  if (newConfirmPassword && errors.confirmPassword) {
    errors.confirmPassword = signupForm.password === newConfirmPassword ? '' : 'Passwords do not match'
  }
})
</script>

<style scoped>
.signup-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.signup-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  padding: 40px;
  width: 100%;
  max-width: 500px;
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

.signup-header {
  text-align: center;
  margin-bottom: 30px;
}

.signup-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px 0;
}

.signup-subtitle {
  color: #666;
  margin: 0;
  font-size: 16px;
}

.signup-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
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

.form-input.success {
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
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

.success-message {
  color: #10b981;
  font-size: 14px;
  margin-top: 6px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.password-strength {
  margin-top: 8px;
}

.strength-bar {
  width: 100%;
  height: 4px;
  background: #e1e5e9;
  border-radius: 2px;
  overflow: hidden;
  margin-bottom: 6px;
}

.strength-fill {
  height: 100%;
  transition: all 0.3s ease;
  border-radius: 2px;
}

.strength-text {
  font-size: 12px;
  font-weight: 600;
}

.very-weak { background: #ef4444; color: #ef4444; }
.weak { background: #f97316; color: #f97316; }
.fair { background: #eab308; color: #eab308; }
.good { background: #22c55e; color: #22c55e; }
.strong { background: #10b981; color: #10b981; }
.very-strong { background: #059669; color: #059669; }

.checkbox-label {
  display: flex;
  align-items: flex-start;
  cursor: pointer;
  color: #666;
  font-size: 14px;
  line-height: 1.5;
}

.checkbox {
  margin-right: 8px;
  margin-top: 2px;
  accent-color: #667eea;
  flex-shrink: 0;
}

.terms-link {
  color: #667eea;
  text-decoration: none;
}

.terms-link:hover {
  text-decoration: underline;
}

.signup-btn {
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

.signup-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
}

.signup-btn:disabled {
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

.signup-footer {
  text-align: center;
  margin-top: 30px;
}

.login-prompt {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.login-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s ease;
}

.login-link:hover {
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
@media (max-width: 640px) {
  .signup-card {
    padding: 30px 20px;
    margin: 10px;
  }
  
  .signup-title {
    font-size: 24px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
    gap: 20px;
  }
}
</style>
