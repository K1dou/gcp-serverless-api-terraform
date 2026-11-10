import {Router} from "express";
import {authenticate} from "../middlewares/authenticate.js";
import {authorize} from "../middlewares/authorize.js";
import {validate} from "../middlewares/validate.js";
import {createProductSchema, updateProductSchema} from "../schemas/productSchema.js";
import productController from "../controllers/productController.js";


const router = Router()


// Leitura: qualquer usuario logado. Escrita no catalogo: so ADMIN.
router.post("/",authenticate,authorize("ADMIN"),validate(createProductSchema),productController.createProduct)
router.get("/:id",authenticate,productController.getProductById)
router.get("/",authenticate,productController.getProducts)
router.delete("/:id",authenticate,authorize("ADMIN"),productController.deleteProduct)
router.patch("/:id",authenticate,authorize("ADMIN"),validate(updateProductSchema),productController.updateProduct)





export default router