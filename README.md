# 🎉 Birthday Wish Website

A beautiful birthday celebration website where users can upload photos and receive personalized birthday wishes with animations!

## Features

- 📝 User form with name, date of birth, and multiple photo uploads
- 🎈 Animated balloons and festive UI elements
- 🖼️ Photo collage display with hover effects
- 💝 Roman Urdu birthday quotes and wishes
- 👨‍💼 Simple admin dashboard to view all users
- 🎨 Beautiful gradient backgrounds and animations

## Tech Stack

- **Frontend**: Next.js 13 with App Router
- **Styling**: Tailwind CSS + shadcn/ui components
- **Database**: SQLite with Prisma ORM
- **Validation**: Zod schema validation
- **Images**: Next.js Image component with local storage

## Getting Started

### Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your database URL and blob token
   ```

3. Set up the database:
   ```bash
   npm run db:push
   ```

4. Run the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser

### 🚀 Vercel Deployment

#### Step 1: Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/birthday-wish-website.git
git push -u origin main
```

#### Step 2: Deploy on Vercel
1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "New Project"
3. Import your GitHub repository
4. Vercel will auto-detect Next.js settings

#### Step 3: Set up Database (FREE)
**Option A - Neon (Recommended):**
1. Go to [neon.tech](https://neon.tech)
2. Create free account (3GB free)
3. Create new database
4. Copy the connection string

**Option B - Supabase:**
1. Go to [supabase.com](https://supabase.com)
2. Create free project (500MB free)
3. Get PostgreSQL connection string from settings

#### Step 4: Configure Environment Variables
In your Vercel project dashboard:
1. Go to Settings → Environment Variables
2. Add these variables:
   - `DATABASE_URL`: Your PostgreSQL connection string
   - `BLOB_READ_WRITE_TOKEN`: Vercel Blob storage token

#### Step 5: Set up Vercel Blob Storage
1. In Vercel dashboard, go to Storage tab
2. Create a new Blob store
3. Copy the `BLOB_READ_WRITE_TOKEN`

#### Step 6: Final Deployment
1. Push any changes to GitHub
2. Vercel will automatically deploy
3. Run database migration in production:
   ```bash
   npx prisma db push
   ```

### 🌐 Production URLs
- **Main Site**: `https://your-project.vercel.app`
- **Admin Panel**: `https://your-project.vercel.app/admin`

## Admin Access

- Visit `/admin` route
- Password: `admin123`
- View all user submissions with photos and details

## Project Structure

```
birthday-wish-website/
├── src/
│   ├── app/
│   │   ├── admin/           # Admin dashboard
│   │   ├── api/             # API routes
│   │   └── globals.css      # Global styles
│   ├── components/          # React components
│   └── lib/                 # Utilities and database
├── prisma/                  # Database schema
└── public/uploads/          # Uploaded images
```

## Created with ❤️ by Jawad
