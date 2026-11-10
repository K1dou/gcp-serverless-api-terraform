import {prisma} from "../../src/lib/prisma.ts";
import bcrypt from "bcryptjs";
import request from "supertest";
import app from "../../src/app.js";

export const createAndLoginUser = async (overrides = {})=>{

    const password = overrides.password ?? '123456'

    const user = await prisma.user.create(
        {
            data:{
                name: overrides.name ?? 'Teste',
                email: overrides.email?? 'teste@gmail.com',
                password: await bcrypt.hash(password,10)
            }
    })

    const agent = request.agent(app)
    await agent.post("/auth/login").send({
        email:user.email,
        password:password
    })

    return{agent,user}
}