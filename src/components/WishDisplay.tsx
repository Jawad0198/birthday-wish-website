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
