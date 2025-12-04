<template>
    <div class="forum-thread" v-if="thread">
        <!-- Thread Header -->
        <div class="thread-header">
            <h1 class="thread-title">{{ thread.title }}</h1>
            <div class="thread-meta">
                <span class="thread-category">{{ thread.category }}</span>
                <span class="thread-stats">
                    {{ thread.reply_count }} posts • {{ thread.view_count }} views
                </span>
            </div>
        </div>

        <!-- Posts List -->
        <div class="posts-container">
            <div v-for="(post, index) in thread.posts" :id="post.id" :key="post.id" class="post-item"
                :class="{ 'original-post': index === 0 }">
                <!-- Author Info -->
                <div class="author-info">
                    <div class="author-avatar">
                        <img :src="post.author.avatar || require('@/assets/user_icon.svg')" :alt="post.author.username"
                            @error="handleAvatarError" />
                    </div>
                    <div class="author-details">
                        <h3 class="author-name">{{ post.author.username }}</h3>
                        <p class="author-role">{{ post.author.role || 'Member' }}</p>
                        <div class="author-stats">
                            <span>Posts: {{ post.author.post_count || 0 }}</span>
                            <span>Joined: {{ formatDate(post.author.created_at) }}</span>
                        </div>
                    </div>
                </div>

                <!-- Post Content -->
                <div class="post-content">
                    <div class="post-header">
                        <span class="post-number">#{{ index + 1 }}</span>
                        <span class="post-date">{{ formatDate(post.created_at) }}</span>
                        <div class="post-actions">
                            <button class="action-btn" @click="quotePost(post)" title="Quote this post">
                                <i class="icon-quote"></i>
                            </button>
                            <button class="action-btn" @click="reportPost(post)" title="Report post">
                                <i class="icon-flag"></i>
                            </button>
                            <button class="action-btn" @click="deletePost(post)" title="Delete post" v-if="index === thread.posts.length - 1 && isLoggedIn() && (post.author.id === user.id || user.roles.includes(1))">
                                <i class="icon-trash"></i>
                            </button>
                        </div>
                    </div>posts

                    <div class="post-body" v-html="post.content_html"></div>

                    <!-- Post Footer -->
                    <div class="post-footer" v-if="post.edited_at">
                        <span class="edit-info">
                            Last edited {{ formatDate(post.edited_at) }} by {{ post.edited_by }}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Response Box -->
        <div class="quick-response" v-if="isLoggedIn()">
            <h3>Quick Reply</h3>
            <div class="response-form">
                <div class="response-toolbar">
                    <button v-for="tool in formatTools" :key="tool.name" class="format-btn"
                        @click="applyFormat(tool.tag)" :title="tool.title">
                        <i :class="tool.icon"></i>
                    </button>
                </div>

                <textarea ref="responseTextarea" v-model="newPost.content" class="response-textarea"
                    placeholder="Write your reply..." @keydown="handleKeydown"></textarea>

                <div class="response-actions">
                    <div class="response-options">
                        <label class="checkbox-label">
                            <input type="checkbox" v-model="newPost.subscribe" />
                            Subscribe to thread
                        </label>
                    </div>

                    <div class="response-buttons">
                        <button class="btn btn-secondary" @click="previewPost" :disabled="!newPost.content.trim()">
                            Preview
                        </button>
                        <button class="btn btn-primary" @click="submitPost"
                            :disabled="!newPost.content.trim() || isSubmitting">
                            {{ isSubmitting ? 'Posting...' : 'Post Reply' }}
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Login prompt for guests -->
        <div class="login-prompt" v-else>
            <p>Please <RouterLink to="/login" @click.prevent="$emit('login-required')">log in</RouterLink> to post a reply.</p>
        </div>

        <!-- Preview Modal -->
        <div class="preview-modal" v-if="showPreview" @click="closePreview">
            <div class="preview-content" @click.stop>
                <div class="preview-header">
                    <h3>Preview</h3>
                    <button class="close-btn" @click="closePreview">&times;</button>
                </div>
                <div class="preview-body" v-html="previewContent"></div>
                <div class="preview-footer">
                    <button class="btn btn-secondary" @click="closePreview">Edit</button>
                    <button class="btn btn-primary" @click="submitFromPreview">Post Reply</button>
                </div>
            </div>
        </div>
    </div>
    <div v-else class="forum-thread">
        <p>Loading thread...</p>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { defineProps, defineEmits } from 'vue'
import axios from 'axios'
import { LoggedInUser, isLoggedIn } from '@/models/user'
import { RouterLink } from 'vue-router'

// Props
const props = defineProps({
    threadId: {
        type: [String, Number],
        required: true
    }
})


const user = isLoggedIn() ? new LoggedInUser() : null;


// Emits
const emit = defineEmits(['post-submitted', 'login-required', 'post-quoted', 'post-reported'])

// Reactive data
const thread = ref(null)

const newPost = reactive({
    content: '',
    subscribe: false
})

const isSubmitting = ref(false)
const showPreview = ref(false)
const previewContent = ref('')
const responseTextarea = ref(null)

// Format tools for the toolbar
const formatTools = [
    { name: 'bold', tag: 'strong', icon: 'icon-bold', title: 'Bold' },
    { name: 'italic', tag: 'em', icon: 'icon-italic', title: 'Italic' },
    { name: 'underline', tag: 'u', icon: 'icon-underline', title: 'Underline' },
    { name: 'quote', tag: 'blockquote', icon: 'icon-quote-left', title: 'Quote' },
    { name: 'code', tag: 'code', icon: 'icon-code', title: 'Inline Code' },
    { name: 'link', tag: 'a', icon: 'icon-link', title: 'Link' }
]

// Methods
const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const handleAvatarError = (event) => {
    event.target.src = require('@/assets/user_icon.svg')
}

const applyFormat = (tag) => {
    if (!responseTextarea.value) return

    const textarea = responseTextarea.value
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = textarea.value.substring(start, end)

    let replacement
    if (tag === 'a') {
        const url = prompt('Enter URL:')
        if (url) {
            replacement = `<a href="${url}">${selectedText || 'Link text'}</a>`
        } else return
    } else if (tag === 'blockquote') {
        replacement = `<blockquote>${selectedText || 'Quote text'}</blockquote>`
    } else {
        replacement = `<${tag}>${selectedText || 'Text'}</${tag}>`
    }

    const newContent =
        textarea.value.substring(0, start) +
        replacement +
        textarea.value.substring(end)

    newPost.content = newContent

    // Set cursor position after the inserted text
    setTimeout(() => {
        textarea.focus()
        const newPosition = start + replacement.length
        textarea.setSelectionRange(newPosition, newPosition)
    }, 0)
}

const handleKeydown = (event) => {
    // Ctrl+Enter to submit
    if (event.ctrlKey && event.key === 'Enter') {
        submitPost()
    }
}

const quotePost = (post) => {
    const quote = `<blockquote><strong>${post.author.username} wrote:</strong><br>${post.content}</blockquote><br>`
    newPost.content += quote
    responseTextarea.value?.focus()
    emit('post-quoted', post)
}

const reportPost = (post) => {
    if (confirm('Are you sure you want to report this post?')) {
        emit('post-reported', post)
    }
}

const previewPost = () => {
    previewContent.value = newPost.content
    showPreview.value = true
}

const closePreview = () => {
    showPreview.value = false
}

const submitPost = async () => {
    if (!newPost.content.trim() || isSubmitting.value) return

    isSubmitting.value = true

    try {
        const postData = {
            thread_id: thread.value.id,
            content_html: newPost.content
        }

        // API call
        const response = await axios.post(`/api/post`, postData, {
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('jwt') || localStorage.getItem('jwt')}`
            }
        });

        const addedPost = response.data.data;
        addedPost; // I need id to route to it in future

        emit('post-submitted', postData)

        window.location.reload();

    } catch (error) {
        console.error('Failed to submit post:', error)
        alert('Failed to submit post. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

const submitFromPreview = () => {
    closePreview()
    submitPost()
}

const deletePost = async (post) => {
    if (!confirm('Are you sure you want to delete this post?')) return;

    try {
        // API call to delete post
        await axios.delete(`/api/post/${post.id}`, {
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('jwt') || localStorage.getItem('jwt')}`
            }
        });
        window.location.reload();

    } catch (error) {
        console.error('Failed to delete post:', error);
    }
};

// Load thread data (in real app, this would fetch from API)
const loadThread = async () => {
    // Simulate API call
    const response = await axios.get(`/api/thread/${props.threadId}`);
    thread.value = await response.data.data;
}

onMounted(() => {
    loadThread()
})
</script>

<style scoped>
.forum-thread {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.thread-header {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
}

.thread-title {
    margin: 0 0 10px 0;
    color: #333;
    font-size: 24px;
}

.thread-meta {
    display: flex;
    gap: 15px;
    align-items: center;
    color: #666;
    font-size: 14px;
}

.thread-category {
    background: #007bff;
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
}

.posts-container {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.post-item {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    display: flex;
    overflow: hidden;
}

.original-post {
    border-left: 4px solid #007bff;
}

.author-info {
    flex-shrink: 0;
    width: 200px;
    padding: 20px;
    background: #f8f9fa;
    border-right: 1px solid #e9ecef;
    text-align: center;
}

.author-avatar {
    margin-bottom: 10px;
}

.author-avatar img {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #ddd;
}

.author-name {
    margin: 0 0 5px 0;
    font-size: 16px;
    color: #333;
}

.author-role {
    margin: 0 0 10px 0;
    font-size: 12px;
    color: #666;
    font-style: italic;
}

.author-stats {
    font-size: 11px;
    color: #888;
}

.author-stats span {
    display: block;
    margin-bottom: 2px;
}

.post-content {
    flex: 1;
    padding: 20px;
}

.post-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #e9ecef;
}

.post-number {
    font-weight: bold;
    color: #007bff;
}

.post-date {
    color: #666;
    font-size: 14px;
}

.post-actions {
    display: flex;
    gap: 5px;
}

.action-btn {
    background: none;
    border: 1px solid #ddd;
    padding: 5px 8px;
    border-radius: 4px;
    cursor: pointer;
    color: #666;
    font-size: 12px;
}

.action-btn:hover {
    background: #f8f9fa;
    color: #333;
}

.post-body {
    line-height: 1.6;
    color: #333;
}

.post-body p {
    margin-bottom: 10px;
}

.post-body blockquote {
    margin: 10px 0;
    padding: 10px 15px;
    background: #f8f9fa;
    border-left: 4px solid #007bff;
    font-style: italic;
}

.post-footer {
    margin-top: 15px;
    padding-top: 10px;
    border-top: 1px solid #e9ecef;
}

.edit-info {
    font-size: 12px;
    color: #888;
    font-style: italic;
}

.quick-response {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin-top: 20px;
}

.quick-response h3 {
    margin: 0 0 15px 0;
    color: #333;
}

.response-toolbar {
    display: flex;
    gap: 5px;
    margin-bottom: 10px;
    padding: 10px;
    background: #f8f9fa;
    border-radius: 4px;
}

.format-btn {
    background: none;
    border: 1px solid #ddd;
    padding: 8px 10px;
    border-radius: 4px;
    cursor: pointer;
    color: #666;
}

.format-btn:hover {
    background: #fff;
    color: #333;
}

.response-textarea {
    width: 100%;
    min-height: 120px;
    border: 1px solid #ddd;
    border-radius: 4px;
    resize: vertical;
    font-family: inherit;
    font-size: 14px;
    line-height: 1.5;
}

.response-textarea:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.response-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
}

.checkbox-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #666;
    cursor: pointer;
}

.response-buttons {
    display: flex;
    gap: 10px;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    transition: all 0.2s;
}

.btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-primary {
    background: #007bff;
    color: white;
}

.btn-primary:hover:not(:disabled) {
    background: #0056b3;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.btn-secondary:hover:not(:disabled) {
    background: #545b62;
}

.login-prompt {
    background: #fff3cd;
    padding: 15px;
    border-radius: 4px;
    border: 1px solid #ffeaa7;
    text-align: center;
    margin-top: 20px;
}

.login-prompt a {
    color: #007bff;
    text-decoration: none;
}

.login-prompt a:hover {
    text-decoration: underline;
}

.preview-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
}

.preview-content {
    background: white;
    border-radius: 8px;
    max-width: 800px;
    max-height: 80vh;
    width: 90%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.preview-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    border-bottom: 1px solid #e9ecef;
}

.preview-header h3 {
    margin: 0;
    color: #333;
}

.close-btn {
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: #666;
    padding: 0;
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.preview-body {
    padding: 20px;
    overflow-y: auto;
    flex: 1;
    line-height: 1.6;
}

.preview-footer {
    padding: 20px;
    border-top: 1px solid #e9ecef;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
}

/* Responsive design */
@media (max-width: 768px) {
    .post-item {
        flex-direction: column;
    }

    .author-info {
        width: 100%;
        padding: 15px;
    }

    .author-avatar img {
        width: 40px;
        height: 40px;
    }

    .response-actions {
        flex-direction: column;
        align-items: stretch;
        gap: 15px;
    }

    .response-buttons {
        justify-content: stretch;
    }

    .response-buttons .btn {
        flex: 1;
    }
}

/* Icons (you can replace with your preferred icon font) */
.icon-quote::before {
    content: '"';
}

.icon-flag::before {
    content: '⚑';
}

.icon-trash::before {
    content: '🗑️';
}

.icon-bold::before {
    content: 'B';
    font-weight: bold;
}

.icon-italic::before {
    content: 'I';
    font-style: italic;
}

.icon-underline::before {
    content: 'U';
    text-decoration: underline;
}

.icon-quote-left::before {
    content: '"';
}

.icon-code::before {
    content: '<>';
}

.icon-link::before {
    content: '🔗';
}
</style>
