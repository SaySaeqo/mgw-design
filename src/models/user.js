import {jwtDecode} from 'jwt-decode';

const RoleName = {
    1: "admin",
    2: "moderator",
    3: "member",
    4: "guest"
} 

function getRoleName(roleId) {
    return RoleName[roleId] || "Unknown";
}

/**
 * User model for managing user-related database operations
 * Corresponds to the users table schema with the following fields:
 * - id, username, email, password_hash, first_name, last_name
 * - avatar_url, email_verified, is_active, created_at, updated_at
 * - last_login, login_attempts, locked_until
 */
class LoggedInUser {

    constructor() {

        const jwt = sessionStorage.getItem('jwt') || localStorage.getItem('jwt');
        if (!jwt || jwt === '') {
            throw new Error('Cannot construct User: No JWT found.');
        }
        
        const userData = jwtDecode(jwt);
        this.id = userData.id || null;
        this.username = userData.username || '';
        this.email = userData.email || '';
        this.first_name = userData.first_name || '';
        this.last_name = userData.last_name || '';
        this.avatar_url = userData.avatar_url || null;
        this.email_verified = userData.email_verified || false;
        this.is_active = userData.is_active !== undefined ? userData.is_active : true;
        this.created_at = userData.created_at || null;
        this.updated_at = userData.updated_at || null;
        this.last_login = userData.last_login || null;
        this.login_attempts = userData.login_attempts || 0;
        this.locked_until = userData.locked_until || null;
        this.post_count = userData.post_count || 0;
        this.roles = userData.roles || [];
        this.role = getRoleName(this.roles.length > 0 ? this.roles[0] : null);
    }
}

function isLoggedIn() {
    return !!(sessionStorage.getItem('jwt') || localStorage.getItem('jwt'));
}

export {LoggedInUser, isLoggedIn, getRoleName};