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
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Database error' });
    } finally {
        if (conn) conn.release();
    }

    if (!user || user.length === 0 || ! (await bcrypt.compare(password, user[0].password_hash))) {
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    delete user[0].password_hash;
    const token = jwt.sign(user[0], jwtSecret, {
        expiresIn: 86400 // 24 hours
    });
    return res.json({ success: true, token });
});

// Example route that uses MongoDB
app.get('/', async (req, res) => {
    let connection;
    try {
        // Example: Get all documents from a collection
        connection = await db.getConnection();
        const [rows] = await connection.query('SELECT * FROM forum_posts');
        res.json({ success: true, data: rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    } finally {
        // Ensure the connection is released in case of error
        if (connection) connection.release();
    }
});

app.post('/', async (req, res) => {
    try {
        const newPost = req.body;
        const connection = await db.getConnection();
        const [result] = await connection.query('INSERT INTO forum_posts SET ?', newPost);
        res.json({ success: true, data: result.insertId });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.delete('/', async (req, res) => {
    try {
        const connection = await db.getConnection();
        const [result] = await connection.query('DELETE FROM forum_posts');
        res.json({ success: true, deletedCount: result.affectedRows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


app.listen(apiPort, () => {
    console.log(`Server is running on port ${apiPort}`);
});