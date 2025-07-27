"use client"

import { useState } from 'react'
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

  const adminPassword = 'admin1234' // Simple password as requested

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
