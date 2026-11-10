/**
 * @param {import('express').Response} res
 * @param {number} statusCode
 * @param {boolean} ok
 * @param {string} message
 * @param {any} [data]
 */
const sendResponse = (res, statusCode, ok, message, data = null) => {
  return res.status(statusCode).json({
    ok,
    message,
    ...(data && { data }), // Só inclui 'data' se ele não for nulo/indefinido
  });
};

export const responseHelper = {
  success: (res, data, message = 'Success') =>
    sendResponse(res, 200, true, message, data),

  badRequest: (res, message = 'Bad request', data = null) =>
    sendResponse(res, 400, false, message, data),

  unauthorized: (res, message = 'Unauthorized', data = null) =>
    sendResponse(res, 401, false, message, data),

  forbidden: (res, message = 'Forbidden', data = null) =>
    sendResponse(res, 403, false, message, data),

  notFound: (res, message = 'Not found', data = null) =>
    sendResponse(res, 404, false, message, data),

  validationErrors: (res, message = 'Validation error', errors) =>
    sendResponse(res, 422, false, message, { errors }),

  error: (res, message = 'Internal server error', data = null) =>
    sendResponse(res, 500, false, message, data),
};

export default responseHelper;
