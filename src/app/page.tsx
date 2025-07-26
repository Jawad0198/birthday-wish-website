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
