const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
const jwt = require("jsonwebtoken");

async function verifyToken(request, response, next) {
  const token = request.header('token')

  if (!token) return response.status(401).send('Access Denied')

  try {
    const verified = jwt.verify(token, process.env.TOKEN)

    const blacklist = await prisma.blacklist.findFirst({
      where: {
        token:token
      },
    })

    if(!blacklist)
      request.user = verified
    else
      return response.status(401).send('Access Denied')

    next()
  } catch (e) {
    response.status(400).send('Access Denied')
  }
}

module.exports = verifyToken