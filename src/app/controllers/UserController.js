const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
const jwt = require("jsonwebtoken");
const crypt_decrypt= require('../utils/encrypt_decrypt');

module.exports = {
  async index(request, response) {

    const userlogged = jwt.verify(request.header('token'), process.env.TOKEN)
    try{
      const user = await prisma.user.findFirst({
        where: {
          id:userlogged.data.id
        }
      })
    
      const decryptedEmail = crypt_decrypt.decrypt(user.email)
      
      const userResponse = {
        name: user.name,
        username: user.username,
        email: decryptedEmail
      }

      return response.status(200).json(userResponse);
    }catch(e){
      return response.status(500).json({
        error: "Internal server error! We are checking!"
      })
    }
  }
}