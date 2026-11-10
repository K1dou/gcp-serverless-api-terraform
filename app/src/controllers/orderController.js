import orderService from "../services/orderService.js";
import responseHelper from "../utils/response.utils.js";
import {ForbiddenError} from "../errors/AppError.js";


const createOrder = async (req,res,next)=>{
    try {
        const pedido = await orderService.createOrder(req.user.userId,req.body)
        return responseHelper.success(res,pedido,"Success")
    }catch (e) {
        next(e)
    }
}

const getOrders = async (req,res,next)=>{
    const userId = req.user.role === "ADMIN" ? req.query.userId : req.user.userId
    try {
      const orders = await orderService.getOrders(userId)
        return responseHelper.success(res,orders,'Success')

    }catch (e) {
        next(e)
    }
}

const getOrderById = async (req,res,next) =>{

    try {
        const order = await orderService.getOrderById(req.params.id)

        const isOwner = order.userId === req.user.userId
        const isAdmin = req.user.role === "ADMIN"

        if (!isOwner && !isAdmin) throw new ForbiddenError("Not allowed to view this order")
        return responseHelper.success(res,order,"Success")

    }catch (e) {
        next(e)
    }
}
const deleteOrder = async (req,res,next)=>{

    try {
        const order = await orderService.getOrderById(req.params.id)
        const isOwner = order.userId === req.user.userId
        const isAdmin = req.user.role === "ADMIN"

        if (!isOwner && !isAdmin) throw new ForbiddenError("Not allowed to delete this order")

        await orderService.deleteOrder(req.params.id)
        return responseHelper.success(res, null, "Order deleted")

    }catch (e){
        next(e)
    }
}

const updateOrder = async (req,res,next) =>{
    try {
        let order = await orderService.getOrderById(req.params.id)
        const isOwner = order.userId === req.user.userId
        const isAdmin = req.user.role === "ADMIN"

        if (!isOwner && !isAdmin) throw new ForbiddenError("Not allowed to update this order")

        if (!isAdmin && req.body.status !== 'cancelled') throw new ForbiddenError("User can only update status to 'cancelled'")
        

        order = await orderService.updateOrder(req.params.id,req.body)
        return responseHelper.success(res,order,'Success')
    }catch (e) {
        next(e)
    }
}


export default {
    createOrder,
    getOrders,
    getOrderById,
    deleteOrder,
    updateOrder
}