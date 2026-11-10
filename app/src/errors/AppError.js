class AppError extends Error {
    constructor(message, statusCode) {
        super(message)
        this.statusCode = statusCode
    }
}

class NotFoundError extends AppError {
    constructor(message = 'Not found') {
        super(message, 404)
    }
}

class UnauthorizedError extends AppError {
    constructor(message = 'Unauthorized') {
        super(message, 401)
    }
}

class ForbiddenError extends AppError {
    constructor(message = 'Forbidden') {
        super(message, 403)
    }
}

class BadRequestError extends AppError {
    constructor(message = 'Bad request') {
        super(message, 400)
    }
}

class ConflictError extends AppError {
    constructor(message = 'Conflict') {
        super(message, 409)
    }
}

export { AppError, NotFoundError, UnauthorizedError, ForbiddenError, BadRequestError, ConflictError }