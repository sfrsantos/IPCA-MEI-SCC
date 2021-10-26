const Crypto = require('crypto-js')

module.exports = {
  decrypt(encryptedText){
    const bytes = Crypto.AES.decrypt(encryptedText, process.env.AES_TOKEN)
    return bytes.toString(Crypto.enc.Utf8);
  },
  encrypt(rawText){
    return Crypto.AES.encrypt(rawText, process.env.AES_TOKEN).toString();
  }
}
