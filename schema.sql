-- MGW Design Database Schema
-- Generated on December 3, 2025

-- Drop existing database and create a new one
DROP DATABASE IF EXISTS mgw_design;
CREATE DATABASE mgw_design;

-- Create user and grant privileges
DROP USER IF EXISTS 'mgw_user'@'localhost';
CREATE USER 'mgw_user'@'localhost' IDENTIFIED BY 'Secure_Password123';
GRANT ALL PRIVILEGES ON mgw_design.* TO 'mgw_user'@'localhost';
FLUSH PRIVILEGES;

USE mgw_design;

-- Enable foreign key constraints

-- ============================================
-- USER MANAGEMENT TABLES
-- ============================================

-- Users table for authentication and basic info
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    login_attempts INTEGER DEFAULT 0,
    locked_until DATETIME
);

-- User privileges/roles table
CREATE TABLE user_roles (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for user-role relationships (many-to-many)
CREATE TABLE user_role_assignments (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    assigned_by INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE(user_id, role_id)
);

-- Permissions table
CREATE TABLE permissions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Role permissions junction table
CREATE TABLE role_permissions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    role_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE(role_id, permission_id)
);

-- User sessions for authentication tracking
CREATE TABLE user_sessions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- FORUM TABLES
-- ============================================

-- Forum categories
CREATE TABLE forum_categories (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE NOT NULL,
    color VARCHAR(7) DEFAULT '#007bff',
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Forum threads
CREATE TABLE forum_threads (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    category_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    last_post_id INTEGER,
    last_post_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES forum_categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Forum posts
CREATE TABLE forum_posts (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    thread_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    content_html TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_edited BOOLEAN DEFAULT FALSE,
    edit_count INTEGER DEFAULT 0,
    edited_at DATETIME,
    edited_by INTEGER,
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (edited_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Add contraint to forum_threads.last_post_id referencing forum_posts.id
ALTER TABLE forum_threads
ADD CONSTRAINT fk_last_post
FOREIGN KEY (last_post_id) REFERENCES forum_posts(id) ON DELETE SET NULL;



-- Post reactions (likes, dislikes, etc.)
CREATE TABLE post_reactions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    reaction_type VARCHAR(20) NOT NULL, -- 'like', 'dislike', 'love', 'laugh', etc.
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES forum_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(post_id, user_id, reaction_type)
);

-- Thread subscriptions
CREATE TABLE thread_subscriptions (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    thread_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(thread_id, user_id)
);

-- ============================================
-- MAP SYSTEM TABLES
-- ============================================

-- Maps table to store different maps
CREATE TABLE maps (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    image_width INTEGER NOT NULL,
    image_height INTEGER NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Map points/locations
CREATE TABLE map_points (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    map_id INTEGER NOT NULL,
    x DECIMAL(10,2) NOT NULL,
    y DECIMAL(10,2) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    link VARCHAR(500),
    link_type VARCHAR(20) DEFAULT 'internal', -- 'internal', 'external', 'modal'
    icon VARCHAR(50) DEFAULT 'default',
    color VARCHAR(7) DEFAULT '#ff4444',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (map_id) REFERENCES maps(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- AUDIT AND LOGGING TABLES
-- ============================================

-- Activity log for user actions
CREATE TABLE activity_log (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id INTEGER,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Moderation log for forum actions
CREATE TABLE moderation_log (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    moderator_id INTEGER NOT NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50) NOT NULL, -- 'thread', 'post', 'user'
    target_id INTEGER NOT NULL,
    reason TEXT,
    details TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (moderator_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Session indexes
CREATE INDEX idx_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);

-- Forum indexes
CREATE INDEX idx_threads_category ON forum_threads(category_id);
CREATE INDEX idx_threads_author ON forum_threads(author_id);
CREATE INDEX idx_threads_last_post ON forum_threads(last_post_at);
CREATE INDEX idx_threads_pinned ON forum_threads(is_pinned);
CREATE INDEX idx_threads_active ON forum_threads(is_deleted);

CREATE INDEX idx_posts_thread ON forum_posts(thread_id);
CREATE INDEX idx_posts_author ON forum_posts(author_id);
CREATE INDEX idx_posts_created ON forum_posts(created_at);
CREATE INDEX idx_posts_active ON forum_posts(is_deleted);

-- Map indexes
CREATE INDEX idx_map_points_map ON map_points(map_id);
CREATE INDEX idx_map_points_active ON map_points(is_active);
CREATE INDEX idx_map_points_coords ON map_points(x, y);

-- Activity log indexes
CREATE INDEX idx_activity_user ON activity_log(user_id);
CREATE INDEX idx_activity_resource ON activity_log(resource_type, resource_id);
CREATE INDEX idx_activity_created ON activity_log(created_at);

-- ============================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================

-- Update users.updated_at on user changes
DELIMITER //
CREATE TRIGGER update_users_timestamp 
    AFTER UPDATE ON users
    FOR EACH ROW
    BEGIN
        UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;//

-- Update thread reply count when posts are added/removed
CREATE TRIGGER update_thread_reply_count_insert
    AFTER INSERT ON forum_posts
    FOR EACH ROW
    BEGIN
        IF NEW.is_deleted = FALSE THEN
            UPDATE forum_threads 
            SET reply_count = reply_count + 1,
                last_post_id = NEW.id,
                last_post_at = NEW.created_at,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.thread_id;
        END IF;
    END;//

CREATE TRIGGER update_thread_reply_count_delete
    AFTER UPDATE ON forum_posts
    FOR EACH ROW
    BEGIN
        IF OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE THEN
            UPDATE forum_threads 
            SET reply_count = reply_count - 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.thread_id;
        END IF;
    END;//

-- Update thread view count (would be called from application)
CREATE TRIGGER log_thread_view
    AFTER UPDATE ON forum_threads
    FOR EACH ROW
    BEGIN
        IF NEW.view_count <=> OLD.view_count THEN
            INSERT INTO activity_log (action, resource_type, resource_id, description, created_at)
            VALUES ('view', 'thread', NEW.id, 'Thread viewed', CURRENT_TIMESTAMP);
        END IF;
    END;//
DELIMITER ;

-- ============================================
-- INITIAL DATA SETUP
-- ============================================

-- Insert default roles
INSERT INTO user_roles (name, description) VALUES
('admin', 'System administrator with full access'),
('moderator', 'Forum moderator with content management privileges'),
('member', 'Regular forum member'),
('guest', 'Unregistered user with limited access');

-- Insert default permissions
INSERT INTO permissions (name, description, resource, action) VALUES
-- User management
('manage_users', 'Create, edit, and delete users', 'user', 'manage'),
('view_users', 'View user profiles and information', 'user', 'view'),
('edit_own_profile', 'Edit own user profile', 'user', 'edit_own'),
-- Forum management
('manage_forums', 'Manage forum categories and settings', 'forum', 'manage'),
('moderate_posts', 'Edit, delete, and moderate forum posts', 'post', 'moderate'),
('create_threads', 'Create new forum threads', 'thread', 'create'),
('reply_to_threads', 'Reply to existing forum threads', 'thread', 'reply'),
('edit_own_posts', 'Edit own forum posts', 'post', 'edit_own'),
('delete_own_posts', 'Delete own forum posts', 'post', 'delete_own'),
-- Map management
('manage_maps', 'Create, edit, and delete maps', 'map', 'manage'),
('create_map_points', 'Add points to maps', 'map_point', 'create'),
('edit_map_points', 'Edit existing map points', 'map_point', 'edit'),
('view_maps', 'View maps and map points', 'map', 'view');

-- Assign permissions to roles
INSERT INTO role_permissions (role_id, permission_id) VALUES
-- Admin permissions (all)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13),
-- Moderator permissions
(2, 2), (2, 3), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), (2, 12), (2, 13),
-- Member permissions
(3, 2), (3, 3), (3, 6), (3, 7), (3, 8), (3, 9), (3, 12),
-- Guest permissions
(4, 2);

-- Insert default forum category
INSERT INTO forum_categories (name, description, slug, color, icon, sort_order) VALUES
('General Discussion', 'General topics and discussions', 'general-discussion', '#007bff', 'chat', 1),
('Announcements', 'Official announcements and news', 'announcements', '#28a745', 'bullhorn', 0),
('Support', 'Help and support topics', 'support', '#ffc107', 'question-circle', 2),
('Off Topic', 'Non-game related discussions', 'off-topic', '#6c757d', 'coffee', 3);

-- Insert default admin user
INSERT INTO users (username, email, password_hash, first_name, last_name, email_verified, is_active) VALUES
('admin', 'admin@example.com', '$2b$10$FMoxJ3xoI/2DM7guDmD7.u7UB347FUpnrgcZcX9R8SSUTh1r6WmMq', 'Admin', 'User', TRUE, TRUE);

-- Insert sample map
INSERT INTO maps (name, description, image_url, image_width, image_height, slug, created_by) VALUES
('World Map', 'Main game world map showing all locations', '/img/world-map.jpg', 1920, 1080, 'world-map', 1);
