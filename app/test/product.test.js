import {afterEach, beforeEach, describe, expect, it} from "vitest";
import request from "supertest";
import app from "../src/app.js";
import {prisma} from "../src/lib/prisma.ts";
import {createAndLoginUser} from "./helpers/auth.js";

// Emails proprios deste arquivo: os testes rodam em paralelo com auth.test.js,
// que apaga 'teste@gmail.com'. Assim um arquivo nao derruba o outro.
const ADMIN_EMAIL = "admin-product@test.com";
const CUSTOMER_EMAIL = "customer-product@test.com";
const PRODUCT_NAME = "Produto de Teste";

const cleanup = async () => {
    await prisma.product.deleteMany({where: {name: {startsWith: PRODUCT_NAME}}});
    await prisma.user.deleteMany({where: {email: {in: [ADMIN_EMAIL, CUSTOMER_EMAIL]}}});
};

describe("Produtos: controle de acesso", () => {
    let admin;
    let customer;
    let product;

    beforeEach(async () => {
        await cleanup();
        admin = (await createAndLoginUser({email: ADMIN_EMAIL, role: "ADMIN"})).agent;
        customer = (await createAndLoginUser({email: CUSTOMER_EMAIL, role: "CUSTOMER"})).agent;
        product = await prisma.product.create({data: {name: PRODUCT_NAME, price: 10}});
    });

    afterEach(cleanup);

    describe("sem login", () => {
        it("POST /product responde 401", async () => {
            const res = await request(app).post("/product").send({name: `${PRODUCT_NAME} novo`, price: 20});
            expect(res.status).toBe(401);
        });
    });

    describe("como CUSTOMER", () => {
        it("pode listar produtos (GET /product)", async () => {
            const res = await customer.get("/product");
            expect(res.status).toBe(200);
        });

        it("POST /product responde 403 e nao cria o produto", async () => {
            const res = await customer.post("/product").send({name: `${PRODUCT_NAME} novo`, price: 20});
            expect(res.status).toBe(403);

            const criado = await prisma.product.count({where: {name: `${PRODUCT_NAME} novo`}});
            expect(criado).toBe(0);
        });

        it("PATCH /product/:id responde 403 e nao altera o produto", async () => {
            const res = await customer.patch(`/product/${product.id}`).send({price: 999});
            expect(res.status).toBe(403);

            const depois = await prisma.product.findUnique({where: {id: product.id}});
            expect(depois.price).toBe(10);
        });

        it("DELETE /product/:id responde 403 e nao apaga o produto", async () => {
            const res = await customer.delete(`/product/${product.id}`);
            expect(res.status).toBe(403);

            const depois = await prisma.product.findUnique({where: {id: product.id}});
            expect(depois).not.toBeNull();
        });
    });

    describe("como ADMIN", () => {
        it("POST /product cria o produto", async () => {
            const res = await admin.post("/product").send({name: `${PRODUCT_NAME} novo`, price: 20});
            expect(res.status).toBe(200);
            expect(res.body.data.name).toBe(`${PRODUCT_NAME} novo`);
        });

        it("POST /product com preco negativo responde 400", async () => {
            const res = await admin.post("/product").send({name: `${PRODUCT_NAME} novo`, price: -5});
            expect(res.status).toBe(400);
        });

        it("PATCH /product/:id atualiza o produto", async () => {
            const res = await admin.patch(`/product/${product.id}`).send({price: 55});
            expect(res.status).toBe(200);

            const depois = await prisma.product.findUnique({where: {id: product.id}});
            expect(depois.price).toBe(55);
        });

        it("PATCH /product/:id com body vazio responde 400 (valida o body)", async () => {
            const res = await admin.patch(`/product/${product.id}`).send({});
            expect(res.status).toBe(400);
        });

        it("DELETE /product/:id apaga o produto", async () => {
            const res = await admin.delete(`/product/${product.id}`);
            expect(res.status).toBe(200);

            const depois = await prisma.product.findUnique({where: {id: product.id}});
            expect(depois).toBeNull();
        });
    });
});
