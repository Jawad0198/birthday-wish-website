import { z } from 'zod'

export const userSchema = z.object({
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().min(1, "Last name is required"),
  dateOfBirth: z.string().min(1, "Date of birth is required"),
  images: z.array(z.instanceof(File)).min(1, "At least one image is required")
})

export type UserFormData = z.infer<typeof userSchema>
