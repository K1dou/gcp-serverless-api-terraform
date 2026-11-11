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

// Atrás do Cloud Run há um proxy: confia no primeiro salto para que req.ip e
// req.protocol reflitam o cliente real (importante para rate limit e logs).
app.set('trust proxy', 1);

// Middleware
app.use(morgan('dev'));
app.use(express.json());
app.use(cookieParser()); // lê os cookies da requisição e coloca em req.cookies

// Rotas
const healthCheck = (req, res) => {
  res.send('Servidor rodando com Express!');
};

app.get('/', healthCheck);

// Liveness: só diz que o processo está de pé. Não consulta o banco de propósito,
// para uma falha momentânea do banco não derrubar a checagem de saúde.
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});



app.use('/auth',authRouter)
app.use('/user', userRouter);
app.use('/product',productRouter)
app.use('/order',orderRouter)


app.use(errorHandler)

export default app;
