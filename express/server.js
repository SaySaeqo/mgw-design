import express from 'express';
import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';
// import path from 'path';
// import { fileURLToPath } from 'url';
// import { dirname } from 'path';

// const __filename = fileURLToPath(import.meta.url);
// const __dirname = dirname(__filename);
// const envPath = path.join(__dirname, '.env');

dotenv.config({path: '.env.local'});
const app = express();

// MongoDB connection string - replace with your actual connection string
const mongoUrl = process.env.MONGODB_URI;
const dbName = process.env.MONGODB_DB_NAME;
const collectionName = process.env.MONGODB_COLLECTION_NAME;
const apiPort = process.env.API_PORT;

let db;

// Connect to MongoDB
async function connectToMongoDB() {
    try {
        const client = new MongoClient(mongoUrl);
        await client.connect();
        db = client.db(dbName);
        console.log('Connected to MongoDB successfully!');
    } catch (error) {
        console.error('Failed to connect to MongoDB:', error);
        process.exit(1);
    }
}

// Middleware to parse JSON
app.use(express.json());

// Example route that uses MongoDB
app.get('/', async (req, res) => {
    try {
        // Example: Get all documents from a collection
        const collection = db.collection(collectionName);
        const documents = await collection.find({}).toArray();
        res.json({ success: true, data: documents });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/', async (req, res) => {
    try {
        const newPost = req.body;
        const collection = db.collection(collectionName);
        const result = await collection.insertOne(newPost);
        res.json({ success: true, data: result.insertedId });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.delete('/', async (req, res) => {
    try {
        const collection = db.collection(collectionName);
        const result = await collection.deleteMany({});
        res.json({ success: true, deletedCount: result.deletedCount });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Initialize MongoDB connection and start server
connectToMongoDB().then(() => {
    app.listen(apiPort, () => {
        console.log(`Server is running on port ${apiPort}`);
    });
});