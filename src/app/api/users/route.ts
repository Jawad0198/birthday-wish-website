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
