const jwt = require("jsonwebtoken");

function verifyToken(request, response, next) {
  const token = request.header('token')

  if (!token) return response.status(401).send('Access Denied')

  try {
    const verified = jwt.verify(token, process.env.TOKEN)
    request.user = verified
    next()
  } catch (e) {
    response.status(400).send('Invalid Token')
  }
}

module.exports = verifyToken