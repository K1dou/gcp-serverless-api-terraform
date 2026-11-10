import {describe, it,expect} from "vitest";
import request from "supertest"
import app from "../src/app.js";


describe('GET /',()=>{
    it("Deveria responder 200",async ()=>{
        const response = await request(app).get("/")
        expect(response.status).toBe(200)
    })
})