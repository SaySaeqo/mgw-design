# mgw-design
My take for proposing design of modern PBF-oriented page. Primarly for PBF named MageGuildWars.

# Setup

1. Start local mysql server.
2. Run [schema.sql](./schema.sql) using your mysql server's root user.
3. Install all node dependencies:
```
cd express
npm install
npm update

cd ..
npm install
npm update
```
4. Run backend and frontend locally:
```
npm run dev
```