import userService from "../services/userService.js";
import responseHelper from "../utils/response.utils.js";
import {isOwnerOrAdmin} from "../utils/isOwnerOrAdmin.js";


const getUsers = async (req,res,next)=>{
  try {
  const users = await userService.getUsers()
    return responseHelper.success(res,users,'Success')
  }catch (e) {
    next(e)
  }
}

const getUserById = async (req,res,next)=>{
  
   try {
     const userReq = await isOwnerOrAdmin(req.params.userId, req.user)

     const {password,...userWithoutPassword}=userReq
     return responseHelper.success(res,userWithoutPassword,'Success')

   }catch (e) {
     next(e)
   }

}
const updateUser = async (req,res,next) =>{

  try {
    const userReq = await isOwnerOrAdmin(req.params.userId, req.user)
     const{password,...userWithoutPassword} = await userService.updateUser(userReq.id,req.body)

    return responseHelper.success(res,userWithoutPassword,'Success')
  }catch (e) {
    next(e)
  }
}
const deleteUser = async (req,res,next)=>{
  try {
    const userReq = await isOwnerOrAdmin(req.params.userId, req.user)
    await userService.deleteUser(userReq.id)
    return responseHelper.success(res, null, 'User deleted')
  }catch (e) {
    next(e)
  }
}

export default {
  getUsers,
  getUserById,
  updateUser,
  deleteUser
};

