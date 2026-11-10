import userService from "../services/userService.js";
import {ForbiddenError} from "../errors/AppError.js";

export const  isOwnerOrAdmin =async (paramUserId,reqUser)=>{
        const userReq = await userService.getUserById(paramUserId)
        const isOwner = userReq.id === reqUser.userId

        const isAdmin = reqUser.role === "ADMIN"

        if (!isAdmin && !isOwner) throw new ForbiddenError('Not allowed to access this user')
        return userReq

}