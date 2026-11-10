import { prisma } from '../lib/prisma';
import jwt from 'jsonwebtoken';
import ms from 'ms';
import authConfig from '../config/auth.config.js';
import response from '../utils/response.utils';
import userService from "../services/userService.js";
import {UnauthorizedError} from "../errors/AppError.js";

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await userService.validateCredentials(email, password);

    const accessToken = jwt.sign({ userId: user.id, role: user.role }, authConfig.secret, {
      expiresIn: authConfig.secret_expires_in,
    });
    const refreshToken = jwt.sign(
        { userId: user.id, role: user.role },
        authConfig.refresh_secret,
        { expiresIn: authConfig.refresh_secret_expires_in },
    );

    const refreshExpiresIn = ms(authConfig.refresh_secret_expires_in);
    const accessTokenExpiresIn = ms(authConfig.secret_expires_in);

    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt: new Date(Date.now() + refreshExpiresIn),
      },
    });

    res.cookie('accessToken', accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: accessTokenExpiresIn,
      sameSite: 'strict',
    });
    res.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: refreshExpiresIn,
      sameSite: 'strict',
    });

    return response.success(res, {
      id: user.id,
      name: user.name,
      email: user.email,
    });
  } catch (e) {
    next(e);
  }
};
const register = async (req, res,next) => {
  try {
    const user = await userService.createUser(req.body)

    const {password, ...userWithoutPassword} = user
    return response.success(
      res,
      userWithoutPassword,
      'User successfully registered',
    );
  } catch (e) {
    next(e)
  }
};

const logout = async (req, res,next) => {
  try {
    const token = req.cookies.refreshToken;

await userService.logout(token)

    res.clearCookie('accessToken');
    res.clearCookie('refreshToken');

    return response.success(res, null, 'Logged out successfully');
  } catch (e) {
next(e)  }
};

const refreshToken = async (req, res,next) => {
  try {
    const token = req.cookies.refreshToken;


    if (!token) {
      throw new UnauthorizedError('Refresh token not found');
    }
    // Verify JWT signature and expiry
    const payload = jwt.verify(token, authConfig.refresh_secret);

  const storedToken=await  userService.refreshToken(token)


    const refreshExpiresIn = ms(authConfig.refresh_secret_expires_in);
    const accessTokenExpiresIn = ms(authConfig.secret_expires_in);

    // @ts-ignore
    const newAccessToken = jwt.sign({ userId: payload.userId, role: storedToken.user.role }, authConfig.secret, {
      expiresIn: authConfig.secret_expires_in,
    });

    // @ts-ignore
    const newRefreshToken = jwt.sign({ userId: payload.userId, role: storedToken.user.role }, authConfig.refresh_secret, {
      expiresIn: authConfig.refresh_secret_expires_in,
    });

    await userService.saveRefreshToken({
      token: newRefreshToken,
      userId: payload.userId,
      expiresAt: new Date(Date.now() + refreshExpiresIn),
    });

    res.cookie('accessToken', newAccessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: accessTokenExpiresIn,
      sameSite: 'strict',
    });
    res.cookie('refreshToken', newRefreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: refreshExpiresIn,
      sameSite: 'strict',
    });

    return response.success(res, null, 'Access token refreshed successfully');
  } catch (e) {
next(e)
  }
};

const me = async (req, res,next) => {
  try {
    const user = await userService.getUserById(req.user.userId)

    return response.success(res, {
      id: user.id,
      name: user.name,
      email: user.email,
    });
  } catch (e) {
    next(e)
  }
};

export default {
  login,
  register,
  logout,
  me,
  refreshToken,
};
