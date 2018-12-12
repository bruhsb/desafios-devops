const express = require('express')
const app = express()
const port = 3000;
const fibonacci = require ('fibonacci');

app.listen(port);
console.log(`Aplicação teste executando em http://localhost: ${port}`);
app.get('/', (req, res) => {
  const name = process.env.NAME || 'amigo';
  const number = process.env.NUMBER;
  const bigNumber = fibonacci.iterate (number);
  res.send(`Olá ${name}!`);
});
