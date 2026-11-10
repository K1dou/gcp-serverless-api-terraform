import {array, z} from "zod";




const createOrderItemSchema = z.object({
    productId:z.string().min(1),
    quantity: z.int().min(1).positive(),
})

export const createOrderSchema = z.object({
    items:array(createOrderItemSchema)
})

export const updateOrderSchema = z.object({
    status: z.enum(["pending", "shipped", "delivered", "cancelled"]),
})


