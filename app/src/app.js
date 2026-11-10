import 'dotenv/config';
import userRouter from './routes/userRouter.js';
import { errorHandler } from './middlewares/errorHandler.js';

import express from 'express';
import cookieParser from 'cookie-parser';
import authRouter from "./routes/authRouter.js";
import productRouter from "./routes/productRouter.js";
import morgan from "morgan";
import orderRouter from "./routes/orderRouter.js";

const app = express();

// Middleware
app.use(morgan('dev'));
app.use(express.json());
app.use(cookieParser()); // lê os cookies da requisição e coloca em req.cookies

// Rotas
const healthCheck = (req, res) => {
  res.send('Servidor rodando com Express!');
};

app.get('/', healthCheck);



app.use('/auth',authRouter)
app.use('/user', userRouter);
app.use('/product',productRouter)
app.use('/order',orderRouter)


app.use(errorHandler)

export default app;
