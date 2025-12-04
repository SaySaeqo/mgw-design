import express from 'express';
import { createPool } from 'mysql2/promise';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
// import path from 'path';
// import { fileURLToPath } from 'url';
// import { dirname } from 'path';

// const __filename = fileURLToPath(import.meta.url);
// const __dirname = dirname(__filename);
// const envPath = path.join(__dirname, '.env');

dotenv.config();
const app = express();

// MongoDB connection string - replace with your actual connection string
const apiPort = process.env.API_PORT;
const db = createPool(process.env.MYSQL_URI);
const jwtSecret = process.env.JWT_SECRET;
console.log("Hashed password: '" + bcrypt.hashSync('admin', 10) + "'");

// Middleware to parse JSON
app.use(express.json());

// JWT Authentication Login
app.post('/login', async (req, res) => {
    const username = req.body.username || '';
    const email = req.body.email || '';
    const password = req.body.password || '';

    let conn;
    let user;

    try {
        conn = await db.getConnection();
        [user] = await conn.query('SELECT * FROM users WHERE username = ? OR email = ?', [username, email]);
        if (!user || user.length === 0 || ! (await bcrypt.compare(password, user[0].password_hash))) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
        const [roles] = await conn.query('SELECT ura.role_id FROM user_role_assignments ura JOIN user_roles ur ON ura.role_id = ur.id ' +
            'WHERE ura.user_id = ? ORDER BY ur.privilege_level ASC', [user[0].id]);
        user[0].roles = roles.map(r => r.role_id);
        
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    } finally {
        if (conn) conn.release();
    }

    delete user[0].password_hash;
    const token = jwt.sign(user[0], jwtSecret, {
        expiresIn: 86400 // 24 hours
    });
    return res.json({ success: true, token });
});

// Example route that uses MongoDB
app.get('/thread/:id', async (req, res) => {
    let connection;
    try {
        // Example: Get all documents from a collection
        connection = await db.getConnection();
        const [rows] = await connection.query(
            'SELECT t.*, c.name AS category FROM forum_threads t JOIN forum_categories c ON t.category_id = c.id WHERE t.id = ?',
             [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Thread not found' });
        }
        const thread = rows[0];
        
        // Fetch associated posts
        const [posts] = await connection.query('SELECT * FROM forum_posts WHERE thread_id = ? AND is_deleted = FALSE', [thread.id]);
        for (const post of posts) {
            const [author] = await connection.query(
                'SELECT u.*, ur.name as role FROM user_role_assignments ura JOIN users u ON u.id = ura.user_id JOIN user_roles ur ON ura.role_id = ur.id ' +
                'WHERE u.id = ? ORDER BY ur.privilege_level ASC', 
                [post.author_id]);
            post.author = author.length > 0 ? author[0] : null;
            if (post.author) {
                delete post.author.password_hash;
            }
        }
        thread.posts = posts;
        res.json({ success: true, data: thread });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    } finally {
        // Ensure the connection is released in case of error
        if (connection) connection.release();
    }
});

app.post('/post', async (req, res) => {
    let connection;
    try {
        const postData = req.body;
        const token = req.headers.authorization?.split(' ')[1];
        if (!jwt.verify(token, jwtSecret)) {
            return res.status(401).json({ success: false, message: 'Unauthorized' });
        }
        const user = jwt.decode(token);
        const newPost = {
            thread_id: postData.thread_id,
            author_id: user.id,
            content: postData.content || '',
            content_html: postData.content_html || '',
            created_at: new Date()
        };

        connection = await db.getConnection();
        const [result] = await connection.query('INSERT INTO forum_posts SET ?', newPost);
        const [post] = await connection.query('SELECT * FROM forum_posts WHERE id = ?', [result.insertId]);
        res.json({ success: true, data: post[0] });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    } finally {
        if (connection) connection.release();
    }
});

app.delete('/post/:id', async (req, res) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!jwt.verify(token, jwtSecret)) {
            return res.status(401).json({ success: false, message: 'Unauthorized' });
        }
        const user = jwt.decode(token);

        const connection = await db.getConnection();
        const [post] = await connection.query('SELECT * FROM forum_posts WHERE id = ?', [req.params.id]);
        if (post.length === 0) {
            return res.status(404).json({ success: false, message: 'Post not found' });
        }
        const [roles] = await connection.query('SELECT ura.role_id FROM user_role_assignments ura WHERE ura.user_id = ?', [user.id]);
        if (post[0].author_id !== user.id && !roles.some(r => r.role_id === 1)) { // Assuming role ID 1 is admin
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        const [result] = await connection.query('UPDATE forum_posts SET is_deleted = TRUE WHERE id = ?', [req.params.id]);
        res.json({ success: true, deletedCount: result.affectedRows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


app.listen(apiPort, () => {
    console.log(`Server is running on port ${apiPort}`);
});