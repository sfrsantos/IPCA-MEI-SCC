const express = require("express");
const router = express.Router();

const LoginController = require('../controllers/LoginController')

const userSchema = require("../validations/user");
const loginSchema = require("../validations/login");


router.post("/register", userSchema, LoginController.create)
router.post("/login", loginSchema, LoginController.login);

module.exports = router;