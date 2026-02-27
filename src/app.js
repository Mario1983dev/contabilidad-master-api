require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Contabilidad Master API funcionando 🚀' });
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});