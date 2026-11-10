import {afterEach, describe, expect, it,beforeEach} from "vitest";
import request from 'supertest'
import app from '../src/app.js'
import {prisma} from "../src/lib/prisma.ts";
import bcrypt from "bcryptjs";
import {createAndLoginUser} from "./helpers/auth.js";

describe("POST /register", ()=>{
    afterEach( async ()=>{
            await prisma.user.deleteMany({
                where:{
                    email:'teste@gmail.com'
                }
            })
        }
    )

    it('deveria criar um usuario e responder 200', async () => {

        const response = await request(app).post("/auth/register").send({
            name:'Teste',
            email:'teste@gmail.com',
            password:'123456'
        })

        expect(response.status).toBe(200)

    });

    it('erro email duplicado', async () => {

        await prisma.user.create({
           data:{ name:'Teste',
            email:'teste@gmail.com',
               password: await bcrypt.hash('123456', 10)}
        })
        const response = await request(app).post("/auth/register").send({
            name:'Teste',
            email:'teste@gmail.com',
            password:'123456'
        })
        expect(response.status).toBe(409)


    });
})

describe("POST /login",()=>{

    beforeEach(async ()=>{
        await prisma.user.create({
            data:{
                name:'Teste',
                email:'teste@gmail.com',
                password: await bcrypt.hash('123456', 10)
            }
        })
    })
    afterEach(async()=>{
        await prisma.user.deleteMany({
            where:{
                email:"teste@gmail.com"
            }
        })
    })


    it('deveria logar e setar tokens',async () => {

        const response = await request(app).post("/auth/login").send({
            email:'teste@gmail.com',
            password:'123456'
        })

        expect(response.status).toBe(200)

        const cookies = response.headers['set-cookie']

        expect(cookies.some(cookie => cookie.startsWith('accessToken'))).toBe(true)
        expect(cookies.some(cookie => cookie.startsWith('refreshToken'))).toBe(true)

    });

    it('should return an error because the password is invalid', async () => {

        const response = await request(app).post('/auth/login').send({
            email:"teste@gmail.com",
            password:"senhaErrada"
        })

        expect(response.status).toBe(401)
        
    });

    it('should return 401 when email is not registered',async () => {

        const response = await request(app).post("/auth/login").send({
            email:"invalidEmail@gmail.com",
            password:"123456"
        })

        expect(response.status).toBe(401)
        
    });
})

describe("POST /logout",()=>{

afterEach(async ()=>{
    await prisma.user.deleteMany({
        where:{
            email:"teste@gmail.com"
        }
    })
})

    it('should return a status 200 and clear the token cookies', async () => {

        const {agent} = await createAndLoginUser()
        
        const res = await agent.post("/auth/logout")
        
        expect(res.status).toBe(200)

        const cookies =res.headers['set-cookie']


        expect(cookies.some(cookie => cookie.startsWith('accessToken=;'))).toBe(true)
        expect(cookies.some(cookie => cookie.startsWith("refreshToken=;"))).toBe(true)

    });


})

describe("POST /refresh",()=>{

    it('should return a status 200 and renew the tokens',async () => {

        const {user, agent} = await createAndLoginUser()

        const tokenAntigo = agent.

        
    });


})