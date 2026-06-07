import { z } from 'zod'
import { pageResultSchema } from '../../shared/schemas'

export const employeeSchema = z.object({
  employeeId: z.number(),
  employeeName: z.string(),
  departmentName: z.string(),
  jobTitle: z.string(),
  salary: z.number(),
  hireDate: z.string(),
  isActive: z.boolean(),
  managerName: z.string().nullable(),
})

export const employeePageSchema = pageResultSchema(employeeSchema)

export type Employee = z.infer<typeof employeeSchema>
export type EmployeePage = z.infer<typeof employeePageSchema>
