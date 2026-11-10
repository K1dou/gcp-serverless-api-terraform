import {z} from "zod";


export const createProductSchema = z.object({
   name: z.string().min(2),
   price: z.number().positive(),
    imageUrl: z.string().url().optional().or(z.literal("")),
})

export const updateProductSchema = z.object({
    name: z.string().min(2).optional(),
    price: z.number().positive().optional(),
    imageUrl: z.string().url().optional().or(z.literal("")),
}).refine(data => Object.keys(data).length > 0, {
    message: "Envie ao menos um campo para atualizar"
})



