import express from 'express';
import userController from '../controllers/userController.js';
import { validate } from '../middlewares/validate';
import {updateUserSchema} from '../schemas/userSchema.js';
import {authorize} from "../middlewares/authorize.js";
import {authenticate} from "../middlewares/authenticate.js";

const router = express.Router();



router.get('/',authenticate,authorize('ADMIN'),userController.getUsers)
router.get('/:userId',authenticate,userController.getUserById)
router.patch("/:userId",authenticate,validate(updateUserSchema),userController.updateUser)
router.delete("/:userId",authenticate,authorize('ADMIN'),userController.deleteUser)


export default router;
