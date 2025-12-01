# mgw-design
My take for proposing design of modern PBF-oriented page. Primarly for PBF named MageGuildWars.

# Setup

Create `.env.local` file in current directory:

```
# ./.env.local

MONGODB_URI=
MONGODB_DB_NAME=
MONGODB_COLLECTION_NAME=
API_PORT=3000
VUE_APP_API_URL=http://localhost:3000
```

Create mongodb database with empty collection and fill .env file mentioned above.  
Then run in the terminal:

```
cd express
npm install
npm update

cd ..
npm install
npm update
npm run dev
```