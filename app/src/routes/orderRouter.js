import express from "express";
import {authenticate} from "../middlewares/authenticate.js";
import orderController from "../controllers/orderController.js";
import {validate} from "../middlewares/validate.js";
import {createOrderSchema, updateOrderSchema} from "../schemas/orderSchema.js";


const router = express.Router()

router.get("/",authenticate,orderController.getOrders)
router.get("/:id",authenticate,orderController.getOrderById)
router.post("/",authenticate,validate(createOrderSchema),orderController.createOrder)
router.delete("/:id",authenticate,orderController.deleteOrder)
router.patch("/:id",authenticate,validate(updateOrderSchema),orderController.updateOrder)




export default router