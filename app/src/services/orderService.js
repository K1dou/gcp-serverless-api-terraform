import {prisma} from "../lib/prisma.ts";
import {NotFoundError} from "../errors/AppError.js";


const createOrder = async (userId, data) =>{
    const user = await prisma.user.findUnique({
        where:{
            id:userId
        }
    })
    if (!user) throw new NotFoundError("User not found")

    let totalPedido =0;
    const orderItemsData = []

    for (const item of data.items) {
      const produto = await prisma.product.findUnique({
            where:{
                id:item.productId
            }
        })
        if (!produto) throw new NotFoundError("Product not found")
        totalPedido += produto.price * item.quantity
        orderItemsData.push({
            productId: item.productId,
            quantity: item.quantity,
            price: produto.price,
        });

    }


    return prisma.order.create({
        data:{
            userId:user.id,
            total:totalPedido,
            items: {
                create:orderItemsData
            }
        }
    })

}

const getOrders =  (userId) =>{
    return prisma.order.findMany({
        where:{
            userId:userId
        }
    })
}

const getOrderById = async (orderId) =>{
    const order = await prisma.order.findUnique({
        where:{
            id:orderId
        }
    })
    if (!order)throw new NotFoundError("Order not found")
    return order
}

const deleteOrder =  (orderId) =>{
    return prisma.order.delete({where:{
        id:orderId
        }})
}

const updateOrder = (orderId,order) =>{
    return prisma.order.update({
        where:{
            id:orderId
        },
        data:order
    })
}


export default {
    createOrder,
    getOrders,
    getOrderById,
    deleteOrder,
    updateOrder
}