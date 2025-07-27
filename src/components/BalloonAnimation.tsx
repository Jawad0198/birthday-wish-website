"use client"

import { JSX, useEffect, useState } from 'react'

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
