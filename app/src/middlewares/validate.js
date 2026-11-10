import { ZodError } from 'zod';

export const validate = (schema) => (req, res, next) => {
  try {
    req.body = schema.parse(req.body);
    return next();
  } catch (error) {
    if (error.message && error.message.startsWith('[')) {
      try {
        const zodErrors = JSON.parse(error.message);

        return res.status(400).json({
          status: 'error',
          errors: zodErrors.map((err) => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        });
      } catch (e) {}
    }

    // Qualquer outro erro do sistema cai aqui
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Erro interno na validação',
    });
  }
};
