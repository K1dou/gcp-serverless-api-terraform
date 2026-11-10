import {prisma} from "../lib/prisma.ts";
import {ConflictError, NotFoundError, UnauthorizedError} from "../errors/AppError.js";
import bcrypt from "bcryptjs";




const getUsers = ()=> {
  return prisma.user.findMany()
}

const getUserById = async (userId) =>{
  const user = await prisma.user.findUnique({
    where:{
      id:userId
    }
  })
  if(!user)throw new NotFoundError("User not found")

  return user
}

const updateUser = async (userId,data)=>{

  let user = await getUserById(userId)

  return prisma.user.update({where:{
    id:user.id
    },
    data
  })

}

const deleteUser = async (userId)=>{
   let user = await  getUserById(userId)
  return prisma.user.delete({
    where:{
      id:user.id
    }
  })
}

const createUser = async (user) =>{

const {email,password,name} = user
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw  new ConflictError('This user already exist')
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  return prisma.user.create({
    data: { name, email, password: hashedPassword },
  });
}

const validateCredentials = async (email, password) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new UnauthorizedError('Invalid credentials');

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) throw new UnauthorizedError('Invalid credentials');

  return user;
};

const logout = (token)=>{

    if (token) {
        return  prisma.refreshToken.deleteMany({ where: { token } });
    }


}

const refreshToken =async (token)=>{



    // Check if token exists in DB
    const storedToken = await prisma.refreshToken.findUnique({
        where: { token },
        include: { user: true },
    });

    if (!storedToken) {
        throw new UnauthorizedError('Invalid refresh token');
    }

    if (storedToken.expiresAt < new Date()) {
        await prisma.refreshToken.delete({ where: { token } });
        throw new UnauthorizedError('Refresh token expired');
    }

    // Token rotation: delete old token, issue new one
    await prisma.refreshToken.delete({ where: { token } });

    return storedToken
}

const saveRefreshToken = (data) => {
    return prisma.refreshToken.create({ data })
}



export default {
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  createUser,
  validateCredentials,
    logout,
    refreshToken,
    saveRefreshToken
}