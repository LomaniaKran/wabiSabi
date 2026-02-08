import express from 'express'
import posts from './data/db.js';

const app = express();


app.use(express.json());

app.get('/posts', (req, res) => {
  res.json(posts);
});

app.post('/posts', (req, res) => {
  let post = req.body;
  posts.push(post)
  res.status(201).json(post);
});

app.listen(3000, () => {
  console.log('Server started on port 3000');
});