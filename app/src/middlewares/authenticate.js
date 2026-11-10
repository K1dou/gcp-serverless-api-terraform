import jwt from 'jsonwebtoken';
import authConfig from '../config/auth.config.js';
import response from '../utils/response.utils.js';



export const authenticate = (req, res, next) => {

    const token = req.cookies.accessToken;

    if (!token) {
      return response.unauthorized(res, "Not authenticated");
    }

    try {
      req.user = jwt.verify(token, authConfig.secret);
      return next();
    } catch {
      return response.unauthorized(res, "Invalid or expired token");
    }

};
