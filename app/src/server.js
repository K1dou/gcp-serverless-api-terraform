import app from './app.js';

// O Cloud Run define a porta pela variável PORT. Localmente cai em 3000.
const PORT = Number(process.env.PORT) || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
