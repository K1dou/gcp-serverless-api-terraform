import {prisma} from "../lib/prisma.ts";
import {NotFoundError} from "../errors/AppError.js";


const createProduct = (product) =>{
    return prisma.product.create({
        data: product
    })
}

const getProductById = async (productId) =>{
    const product = await prisma.product.findUnique({
        where:{
            id:productId
        }
    })
    if(!product) throw new NotFoundError("Product not found")

    return product
}

const getProducts = ()=>{
    return   prisma.product.findMany()
}

const deleteProduct = async (productId) =>{

    const product = await prisma.product.findUnique({
        where:{
            id:productId
        }
    })

    if (!product) throw new NotFoundError("Product not found")

    await prisma.product.delete({
        where:{
            id:productId
        }
    })

}
const updateProduct = async (productId,data)=>{
    const produto = await prisma.product.findUnique({
        where:{
            id:productId
        }
    })
    if (!produto) throw new NotFoundError("Product not found")

    return prisma.product.update({
        where:{
            id:productId
        },
        data
    })


}


export default {
    createProduct,
    getProductById,
    getProducts,
    deleteProduct,
    updateProduct
}