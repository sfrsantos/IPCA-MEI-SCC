const express = require("express");
const router = express.Router();

const UserController = require('../controllers/UserController')


router.get("/me", UserController.index)

module.exports = router;