import {Router} from "express";
import {authenticate} from "../middlewares/authenticate.js";
import {validate} from "../middlewares/validate.js";
import {createProductSchema, updateProductSchema} from "../schemas/productSchema.js";
import productController from "../controllers/productController.js";


const router = Router()


router.post("/",authenticate,validate(createProductSchema),productController.createProduct)
router.get("/:id",authenticate,productController.getProductById)
router.get("/",authenticate,productController.getProducts)
router.delete("/:id",authenticate,productController.deleteProduct)
router.patch("/:id",authenticate,validate(updateProductSchema),productController.updateProduct)





export default router