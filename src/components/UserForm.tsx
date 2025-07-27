"use client"

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card } from '@/components/ui/card'
import { userSchema } from '@/lib/validations'
import { z } from 'zod'

interface UserFormProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
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
        error.issues.forEach((err) => {
          if (err.path) {
            const key = String(err.path[0])
            fieldErrors[key] = err.message
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
