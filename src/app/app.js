const express = require('express');
const env = require("dotenv");
const app = express();
const auth = require('./routes/auth')
const user = require('./routes/user')
const jwtVerify = require('./routes/verifyToken');
const LoginController = require('./controllers/LoginController');
const TestController = require('./controllers/TestController');

//Test
app.use(express.json())
app.get('/api', (req, res) => { res.status(200).json({ "message": 'All its fine!' }) })

//routes
app.use("/api/auth", auth);
app.get("/api/auth/logout",jwtVerify, LoginController.logout)
app.use("/api/profile", jwtVerify, user);
app.get("/api/test", TestController.test)

//Env
env.config();

//Listen
console.log("Port: " + process.env.LISTEN_PORT)
console.log("Hostname: " + process.env.LISTEN_HOSTNAME)
app.listen(process.env.LISTEN_PORT, process.env.LISTEN_HOSTNAME);