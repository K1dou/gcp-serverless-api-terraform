import response from '../utils/response.utils.js';

export const authorize = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return response.forbidden(res, 'Access denied');
  }
  return next();
};