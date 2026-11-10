import productService from "../services/productService.js";
import responseHelper from "../utils/response.utils.js";


const createProduct = async (req,res) =>{
    try {
        const produto = await productService.createProduct(req.body)

        return responseHelper.success(res,produto,"produto criado com sucesso")

    }catch (e) {
        console.error(e)
        return responseHelper.error(res,"Internal server error")
    }
}

const getProductById = async (req,res,next) =>{
    try {
        const produto = await productService.getProductById(req.params.id)
        return responseHelper.success(res,produto,"Success")

    }catch (e) {
        next(e)
    }
}

const getProducts = async (req,res,next)=>{
    try {
        const produtos = await productService.getProducts()
        return responseHelper.success(res,produtos,"Success")
    }catch (e) {
        next(e)
    }
}

const deleteProduct =async (req,res,next) =>{
    try {
        await productService.deleteProduct(req.params.id)

        return responseHelper.success(res,null,"Produto deletado")

    }catch (e) {
        next(e)
    }
}
const updateProduct = async (req,res,next)=>{
    try {
        const produto = await productService.updateProduct(req.params.id,req.body)
        return responseHelper.success(res,produto,"Success")

    }catch (e) {
        next(e)
    }
}


export default {
    createProduct,
    getProductById,
    getProducts,
    deleteProduct,
    updateProduct
}