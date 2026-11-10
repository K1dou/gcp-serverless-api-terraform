import express from "express";
import authController from "../controllers/authController.js"
import {validate} from "../middlewares/validate.js";
import {createUserSchema, userLoginSchema} from "../schemas/userSchema.js";
import {authenticate} from "../middlewares/authenticate.js";

const router = express.Router()


router.post("/login",validate(userLoginSchema), authController.login)
router.post("/register",validate(createUserSchema), authController.register)
router.post("/logout",authenticate, authController.logout)
router.post("/refresh", authController.refreshToken)
router.get("/me", authenticate, authController.me)


export default router;