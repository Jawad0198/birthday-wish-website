# #!/bin/bash

# # Birthday Wish Website Setup Script
# echo "🎉 Setting up Birthday Wish Website..."

# # Create project directory
# mkdir birthday-wish-website
# cd birthday-wish-website

# # Initialize Next.js project
# npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# # Install dependencies
# npm install @prisma/client prisma zod @hookform/react-hook-form @radix-ui/react-dialog @radix-ui/react-label @radix-ui/react-slot class-variance-authority clsx tailwind-merge lucide-react next-themes @vercel/blob

# # Install shadcn/ui
# npx shadcn@latest init -d

# # Add shadcn components
# npx shadcn@latest add button input label card dialog form select

# Create directory structure
mkdir -p src/components/ui
mkdir -p src/lib
mkdir -p src/app/admin
mkdir -p src/app/api/users
mkdir -p src/app/api/upload
mkdir -p public/uploads
mkdir -p prisma

# Create Prisma schema
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  firstName String
  lastName  String
  dateOfBirth DateTime
  images    String[] // JSON array of image paths
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
EOF

# Create lib files
cat > src/lib/db.ts << 'EOF'
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
EOF

cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

cat > src/lib/validations.ts << 'EOF'
import { z } from 'zod'

export const userSchema = z.object({
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().min(1, "Last name is required"),
  dateOfBirth: z.string().min(1, "Date of birth is required"),
  images: z.array(z.instanceof(File)).min(1, "At least one image is required")
})

export type UserFormData = z.infer<typeof userSchema>
EOF

# Create components
cat > src/components/BalloonAnimation.tsx << 'EOF'
"use client"

import { useEffect, useState } from 'react'

const Balloon = ({ color, delay, duration }: { color: string; delay: number; duration: number }) => (
  <div
    className={`absolute w-12 h-16 ${color} rounded-full shadow-lg animate-bounce`}
    style={{
      left: `${Math.random() * 90}%`,
      animationDelay: `${delay}s`,
      animationDuration: `${duration}s`,
      transform: 'translateY(100vh)',
      animation: `float ${duration}s ${delay}s infinite ease-in-out`
    }}
  >
    <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 w-0.5 h-8 bg-gray-600"></div>
  </div>
)

export default function BalloonAnimation() {
  const [balloons, setBalloons] = useState<JSX.Element[]>([])
  
  useEffect(() => {
    const colors = ['bg-red-400', 'bg-blue-400', 'bg-green-400', 'bg-yellow-400', 'bg-pink-400', 'bg-purple-400']
    const newBalloons = Array.from({ length: 15 }, (_, i) => (
      <Balloon
        key={i}
        color={colors[i % colors.length]}
        delay={i * 0.5}
        duration={4 + Math.random() * 2}
      />
    ))
    setBalloons(newBalloons)
  }, [])

  return (
    <>
      <style jsx global>{`
        @keyframes float {
          0% { transform: translateY(100vh) rotate(0deg); }
          100% { transform: translateY(-100px) rotate(360deg); }
        }
      `}</style>
      <div className="fixed inset-0 pointer-events-none overflow-hidden z-10">
        {balloons}
      </div>
    </>
  )
}
EOF

cat > src/components/UserForm.tsx << 'EOF'
"use client"

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card } from '@/components/ui/card'
import { userSchema } from '@/lib/validations'
import { z } from 'zod'

interface UserFormProps {
  onSuccess: (userData: any) => void
}

export default function UserForm({ onSuccess }: UserFormProps) {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    dateOfBirth: '',
  })
  const [images, setImages] = useState<File[]>([])
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(false)

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setImages(Array.from(e.target.files))
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setErrors({})

    try {
      const validatedData = userSchema.parse({
        ...formData,
        images
      })

      const formDataToSend = new FormData()
      formDataToSend.append('firstName', validatedData.firstName)
      formDataToSend.append('lastName', validatedData.lastName)
      formDataToSend.append('dateOfBirth', validatedData.dateOfBirth)
      
      validatedData.images.forEach((image, index) => {
        formDataToSend.append(`image_${index}`, image)
      })

      const response = await fetch('/api/users', {
        method: 'POST',
        body: formDataToSend,
      })

      if (response.ok) {
        const userData = await response.json()
        onSuccess(userData)
      } else {
        throw new Error('Failed to submit form')
      }
    } catch (error) {
      if (error instanceof z.ZodError) {
        const fieldErrors: Record<string, string> = {}
        error.errors.forEach((err) => {
          if (err.path) {
            fieldErrors[err.path[0]] = err.message
          }
        })
        setErrors(fieldErrors)
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="max-w-md mx-auto p-6 bg-white/90 backdrop-blur-sm shadow-xl">
      <h2 className="text-2xl font-bold text-center mb-6 text-purple-800">Birthday Celebration Form</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Label htmlFor="firstName">First Name</Label>
          <Input
            id="firstName"
            value={formData.firstName}
            onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
            className={errors.firstName ? 'border-red-500' : ''}
          />
          {errors.firstName && <p className="text-red-500 text-sm mt-1">{errors.firstName}</p>}
        </div>

        <div>
          <Label htmlFor="lastName">Last Name</Label>
          <Input
            id="lastName"
            value={formData.lastName}
            onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
            className={errors.lastName ? 'border-red-500' : ''}
          />
          {errors.lastName && <p className="text-red-500 text-sm mt-1">{errors.lastName}</p>}
        </div>

        <div>
          <Label htmlFor="dateOfBirth">Date of Birth</Label>
          <Input
            id="dateOfBirth"
            type="date"
            value={formData.dateOfBirth}
            onChange={(e) => setFormData({ ...formData, dateOfBirth: e.target.value })}
            className={errors.dateOfBirth ? 'border-red-500' : ''}
          />
          {errors.dateOfBirth && <p className="text-red-500 text-sm mt-1">{errors.dateOfBirth}</p>}
        </div>

        <div>
          <Label htmlFor="images">Upload Images</Label>
          <Input
            id="images"
            type="file"
            multiple
            accept="image/*"
            onChange={handleImageChange}
            className={errors.images ? 'border-red-500' : ''}
          />
          {errors.images && <p className="text-red-500 text-sm mt-1">{errors.images}</p>}
          {images.length > 0 && (
            <p className="text-sm text-gray-600 mt-1">{images.length} image(s) selected</p>
          )}
        </div>

        <Button type="submit" className="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600" disabled={loading}>
          {loading ? 'Creating Magic...' : 'Create Birthday Wish! 🎉'}
        </Button>
      </form>
    </Card>
  )
}
EOF

cat > src/components/WishDisplay.tsx << 'EOF'
"use client"

import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import Image from 'next/image'

interface User {
  id: string
  firstName: string
  lastName: string
  dateOfBirth: string
  images: string[]
}

interface WishDisplayProps {
  user: User
  onBack: () => void
}

const romanUrduQuotes = [
  "Zindagi ke har pal mein khushi ho, har din ek naya tohfa ho! 🎁",
  "Tumhara har sapna pura ho, har din nayi umang laaye! ✨",
  "Dil mein umang, aankhon mein chamak, yahi hai hamari dua! 🌟",
  "Har janamdin pe nayi khushiyan mile, nayi ummeedein jage! 🎈",
  "Zindagi ka ye din tumhare liye khas ho, har gham dur ho jaye! 💖",
  "Tumhari muskaan hamesha aise hi chamke, dil khush rahe! 😊"
]

export default function WishDisplay({ user, onBack }: WishDisplayProps) {
  const randomQuote = romanUrduQuotes[Math.floor(Math.random() * romanUrduQuotes.length)]
  const age = new Date().getFullYear() - new Date(user.dateOfBirth).getFullYear()

  return (
    <div className="max-w-4xl mx-auto">
      <Card className="p-8 bg-gradient-to-br from-purple-100 to-pink-100 shadow-2xl">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-purple-800 mb-2">
            🎉 Happy Birthday {user.firstName} {user.lastName}! 🎂
          </h1>
          <p className="text-xl text-pink-600 mb-4">
            Aaj aap {age} saal ke ho gaye! Mubarak ho! 🎈
          </p>
          <div className="bg-white/80 p-4 rounded-lg shadow-inner">
            <p className="text-lg text-gray-700 italic">{randomQuote}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          {user.images.map((image, index) => (
            <div key={index} className="relative aspect-square rounded-lg overflow-hidden shadow-lg transform hover:scale-105 transition-transform">
              <Image
                src={image}
                alt={`Memory ${index + 1}`}
                fill
                className="object-cover"
              />
            </div>
          ))}
        </div>

        <div className="text-center space-y-4">
          <div className="text-6xl">🎊🎈🎁🎂🎉</div>
          <p className="text-lg font-semibold text-purple-700">
            Great Wishes by Jawad 💝
          </p>
          <p className="text-gray-600">
            Khuda aapko hamesha khush rakhe aur lambi zindagi de! Ameen! 🤲
          </p>
          <Button 
            onClick={onBack}
            className="mt-6 bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600"
          >
            Create Another Wish 🌟
          </Button>
        </div>
      </Card>
    </div>
  )
}
EOF

# Create API routes
cat > src/app/api/users/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import { put } from '@vercel/blob'

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    
    const firstName = formData.get('firstName') as string
    const lastName = formData.get('lastName') as string
    const dateOfBirth = formData.get('dateOfBirth') as string
    
    const imageFiles: File[] = []
    let index = 0
    while (formData.get(`image_${index}`)) {
      imageFiles.push(formData.get(`image_${index}`) as File)
      index++
    }

    // Upload images to Vercel Blob
    const imagePaths: string[] = []
    for (let i = 0; i < imageFiles.length; i++) {
      const file = imageFiles[i]
      const fileName = `${Date.now()}_${i}_${file.name}`
      
      const blob = await put(fileName, file, {
        access: 'public',
      })
      
      imagePaths.push(blob.url)
    }

    // Save to database
    const user = await prisma.user.create({
      data: {
        firstName,
        lastName,
        dateOfBirth: new Date(dateOfBirth),
        images: imagePaths,
      },
    })

    return NextResponse.json(user)
  } catch (error) {
    console.error('Error creating user:', error)
    return NextResponse.json({ error: 'Failed to create user' }, { status: 500 })
  }
}

export async function GET() {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
    })
    return NextResponse.json(users)
  } catch (error) {
    console.error('Error fetching users:', error)
    return NextResponse.json({ error: 'Failed to fetch users' }, { status: 500 })
  }
}
EOF

# Create main page
cat > src/app/page.tsx << 'EOF'
"use client"

import { useState } from 'react'
import UserForm from '@/components/UserForm'
import WishDisplay from '@/components/WishDisplay'
import BalloonAnimation from '@/components/BalloonAnimation'

interface User {
  id: string
  firstName: string
  lastName: string
  dateOfBirth: string
  images: string[]
}

export default function Home() {
  const [user, setUser] = useState<User | null>(null)
  const [showBalloons, setShowBalloons] = useState(false)

  const handleSuccess = (userData: User) => {
    setUser(userData)
    setShowBalloons(true)
  }

  const handleBack = () => {
    setUser(null)
    setShowBalloons(false)
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-purple-400 via-pink-400 to-blue-400 p-4 relative overflow-hidden">
      {showBalloons && <BalloonAnimation />}
      
      <div className="container mx-auto py-8 relative z-20">
        {!user ? (
          <div className="text-center mb-8">
            <h1 className="text-5xl font-bold text-white mb-4 drop-shadow-lg">
              🎉 Birthday Wish Maker 🎂
            </h1>
            <p className="text-xl text-white/90 mb-8">
              Apne janamdin ko yaadgar banayein! Upload kariye apni photos aur banayiye beautiful wishes!
            </p>
            <UserForm onSuccess={handleSuccess} />
          </div>
        ) : (
          <WishDisplay user={user} onBack={handleBack} />
        )}
      </div>

      {/* Decorative elements */}
      <div className="fixed bottom-0 left-0 text-8xl opacity-20 animate-bounce">🎈</div>
      <div className="fixed top-10 right-10 text-6xl opacity-30 animate-pulse">⭐</div>
      <div className="fixed bottom-20 right-20 text-7xl opacity-25 animate-spin slow-spin">🎁</div>
      
      <style jsx global>{`
        .slow-spin {
          animation: spin 8s linear infinite;
        }
      `}</style>
    </main>
  )
}
EOF

# Create admin page
cat > src/app/admin/page.tsx << 'EOF'
"use client"

import { useState, useEffect } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import Image from 'next/image'

interface User {
  id: string
  firstName: string
  lastName: string
  dateOfBirth: string
  images: string[]
  createdAt: string
}

export default function AdminPage() {
  const [authenticated, setAuthenticated] = useState(false)
  const [password, setPassword] = useState('')
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(false)

  const adminPassword = 'admin123' // Simple password as requested

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (password === adminPassword) {
      setAuthenticated(true)
      fetchUsers()
    } else {
      alert('Incorrect password!')
    }
  }

  const fetchUsers = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/users')
      const data = await response.json()
      setUsers(data)
    } catch (error) {
      console.error('Error fetching users:', error)
    } finally {
      setLoading(false)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const calculateAge = (dateOfBirth: string) => {
    const today = new Date()
    const birthDate = new Date(dateOfBirth)
    let age = today.getFullYear() - birthDate.getFullYear()
    const monthDiff = today.getMonth() - birthDate.getMonth()
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--
    }
    return age
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-800 to-gray-900 flex items-center justify-center p-4">
        <Card className="max-w-md w-full p-6">
          <h1 className="text-2xl font-bold text-center mb-6">Admin Dashboard</h1>
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter admin password"
              />
            </div>
            <Button type="submit" className="w-full">
              Login
            </Button>
          </form>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 p-4">
      <div className="container mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-800">Admin Dashboard</h1>
          <Button 
            onClick={() => setAuthenticated(false)}
            variant="outline"
          >
            Logout
          </Button>
        </div>

        {loading ? (
          <div className="text-center">Loading users...</div>
        ) : (
          <div className="grid gap-6">
            {users.length === 0 ? (
              <Card className="p-6 text-center">
                <p className="text-gray-500">No users found</p>
              </Card>
            ) : (
              users.map((user) => (
                <Card key={user.id} className="p-6">
                  <div className="grid md:grid-cols-2 gap-6">
                    <div className="space-y-4">
                      <h2 className="text-xl font-semibold text-purple-800">
                        {user.firstName} {user.lastName}
                      </h2>
                      <div className="space-y-2 text-sm">
                        <p><span className="font-medium">Date of Birth:</span> {formatDate(user.dateOfBirth)}</p>
                        <p><span className="font-medium">Age:</span> {calculateAge(user.dateOfBirth)} years</p>
                        <p><span className="font-medium">Created:</span> {formatDate(user.createdAt)}</p>
                        <p><span className="font-medium">Images:</span> {user.images.length} photo(s)</p>
                        <p><span className="font-medium">User ID:</span> {user.id}</p>
                      </div>
                    </div>
                    
                    <div>
                      <h3 className="font-medium mb-2">Uploaded Images:</h3>
                      <div className="grid grid-cols-2 lg:grid-cols-3 gap-2">
                        {user.images.map((image, index) => (
                          <div key={index} className="relative aspect-square rounded-lg overflow-hidden">
                            <Image
                              src={image}
                              alt={`User image ${index + 1}`}
                              fill
                              className="object-cover hover:scale-110 transition-transform"
                            />
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </Card>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  )
}
EOF

# Create layout
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Birthday Wish Maker - Great Wishes by Jawad',
  description: 'Create beautiful birthday wishes with photos and animations',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

# Update globals.css
# cat > src/app/globals.css << 'EOF'
# @tailwind base;
# @tailwind components;
# @tailwind utilities;

# @layer base {
#   :root {
#     --background: 0 0% 100%;
#     --foreground: 222.2 84% 4.9%;
#     --card: 0 0% 100%;
#     --card-foreground: 222.2 84% 4.9%;
#     --popover: 0 0% 100%;
#     --popover-foreground: 222.2 84% 4.9%;
#     --primary: 222.2 47.4% 11.2%;
#     --primary-foreground: 210 40% 98%;
#     --secondary: 210 40% 96%;
#     --secondary-foreground: 222.2 47.4% 11.2%;
#     --muted: 210 40% 96%;
#     --muted-foreground: 215.4 16.3% 46.9%;
#     --accent: 210 40% 96%;
#     --accent-foreground: 222.2 47.4% 11.2%;
#     --destructive: 0 84.2% 60.2%;
#     --destructive-foreground: 210 40% 98%;
#     --border: 214.3 31.8% 91.4%;
#     --input: 214.3 31.8% 91.4%;
#     --ring: 222.2 84% 4.9%;
#     --radius: 0.5rem;
#   }

#   .dark {
#     --background: 222.2 84% 4.9%;
#     --foreground: 210 40% 98%;
#     --card: 222.2 84% 4.9%;
#     --card-foreground: 210 40% 98%;
#     --popover: 222.2 84% 4.9%;
#     --popover-foreground: 210 40% 98%;
#     --primary: 210 40% 98%;
#     --primary-foreground: 222.2 47.4% 11.2%;
#     --secondary: 217.2 32.6% 17.5%;
#     --secondary-foreground: 210 40% 98%;
#     --muted: 217.2 32.6% 17.5%;
#     --muted-foreground: 215 20.2% 65.1%;
#     --accent: 217.2 32.6% 17.5%;
#     --accent-foreground: 210 40% 98%;
#     --destructive: 0 62.8% 30.6%;
#     --destructive-foreground: 210 40% 98%;
#     --border: 217.2 32.6% 17.5%;
#     --input: 217.2 32.6% 17.5%;
#     --ring: 212.7 26.8% 83.9%;
#   }
# }

# @layer base {
#   * {
#     @apply border-border;
#   }
#   body {
#     @apply bg-background text-foreground;
#   }
# }
# EOF

# # Update next.config.js for image handling
# cat > next.config.js << 'EOF'
# /** @type {import('next').NextConfig} */
# const nextConfig = {
#   images: {
#     remotePatterns: [
#       {
#         protocol: 'https',
#         hostname: '*.public.blob.vercel-storage.com',
#       },
#       {
#         protocol: 'https',
#         hostname: 'localhost',
#         port: '3000',
#       },
#     ],
#   },
# }

# module.exports = nextConfig
# EOF

# # Update package.json scripts
# cat > package.json << 'EOF'
# {
#   "name": "birthday-wish-website",
#   "version": "0.1.0",
#   "private": true,
#   "scripts": {
#     "dev": "next dev",
#     "build": "prisma generate && next build",
#     "start": "next start",
#     "lint": "next lint",
#     "db:push": "prisma db push",
#     "db:generate": "prisma generate",
#     "postinstall": "prisma generate"
#   },
#   "dependencies": {
#     "@hookform/react-hook-form": "^7.45.4",
#     "@prisma/client": "^5.1.1",
#     "@radix-ui/react-dialog": "^1.0.4",
#     "@radix-ui/react-label": "^2.0.2",
#     "@radix-ui/react-slot": "^1.0.2",
#     "@vercel/blob": "^0.15.1",
#     "class-variance-authority": "^0.7.0",
#     "clsx": "^2.0.0",
#     "lucide-react": "^0.263.1",
#     "next": "13.4.19",
#     "next-themes": "^0.2.1",
#     "react": "18.2.0",
#     "react-dom": "18.2.0",
#     "tailwind-merge": "^1.14.0",
#     "zod": "^3.22.2"
#   },
#   "devDependencies": {
#     "@types/node": "20.5.0",
#     "@types/react": "18.2.20",
#     "@types/react-dom": "18.2.7",
#     "autoprefixer": "10.4.15",
#     "eslint": "8.47.0",
#     "eslint-config-next": "13.4.19",
#     "postcss": "8.4.27",
#     "prisma": "^5.1.1",
#     "tailwindcss": "3.3.3",
#     "typescript": "5.1.6"
#   }
# }
# EOF

# # Create components.json for shadcn
# cat > components.json << 'EOF'
# {
#   "$schema": "https://ui.shadcn.com/schema.json",
#   "style": "default",
#   "rsc": true,
#   "tsx": true,
#   "tailwind": {
#     "config": "tailwind.config.js",
#     "css": "src/app/globals.css",
#     "baseColor": "slate",
#     "cssVariables": true
#   },
#   "aliases": {
#     "components": "@/components",
#     "utils": "@/lib/utils"
#   }
# }
# EOF

# Create README.md
cat > README.md << 'EOF'
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
EOF

# Initialize the project
echo "🚀 Initializing project..."

# Generate Prisma client and push database
npx prisma generate

# Create .env.example file
cat > .env.example << 'EOF'
# Database
DATABASE_URL="postgresql://username:password@hostname:port/database"

# Vercel Blob Storage
BLOB_READ_WRITE_TOKEN="your_blob_token_here"
EOF

# Create .env.local file
cat > .env.local << 'EOF'
# This file is for local development only
# For production, set these in Vercel dashboard

# Database (use your local PostgreSQL or get free from Neon/Supabase)
DATABASE_URL="postgresql://username:password@localhost:5432/birthday_wishes"

# Vercel Blob Storage (get this from Vercel dashboard)
BLOB_READ_WRITE_TOKEN="your_blob_token_here"
EOF

# Create vercel.json for deployment config
cat > vercel.json << 'EOF'
{
  "functions": {
    "src/app/api/**/*.ts": {
      "maxDuration": 30
    }
  },
  "build": {
    "env": {
      "PRISMA_GENERATE_SKIP_AUTOINSTALL": "true"
    }
  }
}
EOF

echo "✅ Setup complete!"
echo ""
echo "🚀 Ready for Vercel deployment!"
echo ""
echo "🎯 DEPLOYMENT STEPS:"
echo ""
echo "1. 📁 Push to GitHub:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/yourusername/birthday-wish-website.git"
echo "   git push -u origin main"
echo ""
echo "2. 🌐 Deploy on Vercel:"
echo "   - Go to vercel.com and sign in"
echo "   - Click 'New Project'"
echo "   - Import your GitHub repository"
echo "   - Vercel will auto-detect Next.js"
echo ""
echo "3. 🗄️ Set up Database (FREE options):"
echo "   Option A - Neon (Recommended):"
echo "   - Go to neon.tech"
echo "   - Create free account"
echo "   - Create database"
echo "   - Copy connection string"
echo ""
echo "   Option B - Supabase:"
echo "   - Go to supabase.com"
echo "   - Create free project"
echo "   - Get PostgreSQL connection string"
echo ""
echo "4. ⚙️ Configure Environment Variables in Vercel:"
echo "   - Go to your project settings"
echo "   - Add Environment Variables:"
echo "     DATABASE_URL=your_postgres_connection_string"
echo "     BLOB_READ_WRITE_TOKEN=your_vercel_blob_token"
echo ""
echo "5. 📦 Vercel Blob Storage:"
echo "   - In Vercel dashboard, go to Storage tab"
echo "   - Create Blob store"
echo "   - Copy the token to BLOB_READ_WRITE_TOKEN"
echo ""
echo "6. 🚀 Deploy:"
echo "   - Push changes to GitHub"
echo "   - Vercel will auto-deploy"
echo "   - Run database migration in Vercel dashboard terminal:"
echo "     npx prisma db push"
echo ""
echo "Great Wishes by Jawad! 🎂✨"