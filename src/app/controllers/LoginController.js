const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const Crypto = require('crypto-js');
const crypt_decrypt= require('../utils/encrypt_decrypt');


module.exports = {
  async create(request, response) {
    
    const username = request.body.username;
    const usernameExists = await prisma.user.findFirst({
      where: {
        username:username
      },
    })

    if (usernameExists) return response.status(400).json({ "message": "Username already exists" });

    const name = request.body.name;
    const email = request.body.email
    const encryptedEmail = crypt_decrypt.encrypt(email)
    const password = await bcrypt.hash(request.body.password, 10);

    const user = prisma.user.create({
      data:{
        name,
        username,
        email:encryptedEmail,
        password:password
      }
    }).then(()=>{console.log("Registo efetuado com sucesso")});

    try {
      return response.status(201).json({ name,  email});
    } catch (e) {
      console.log(e);
      return response.status(400);
    }
  },
  async login(request, response) {
    const user = await prisma.user.findFirst({
      where:{
        username:request.body.username
      }
    });

    if (!user) return response.status(400).send("Username or password not matches!");

    const validPW = await bcrypt.compare(request.body.password, user.password);

    if (!validPW) return response.status(400).send("Username or password not matches!");

    const exp = Math.floor(Date.now() / 1000) + (60 * 60);
    const token = jwt.sign({
      exp,
      data: { id: user.id }
    }, process.env.TOKEN);
    response.header("auth-token", token).json({ exp, token });
  },
  async logout(request, response){
    try {
      const userlogged = jwt.verify(request.header('token'), process.env.TOKEN)
      const token = request.header("token")
      const expiration = userlogged.exp

      const newEntry = prisma.blacklist.create({
        data:{
          token,
          expiration
        }
      }).then(()=>{console.log("Token "+ token +" are invalidated now")});  
    } catch (error) {
      return response.status(500).json({ message:"An error are occurred"});
    }
    
    return response.status(200).json({ message:"User successful logout"});
  }
}