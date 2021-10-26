const {
  Joi,
  celebrate
} = require("celebrate");

const userSchema = celebrate({
  body: Joi.object().keys({
    name: Joi.string().required(),
    username: Joi.string().required(),
    email: Joi.string().required(),
    password: Joi.string().required(),
  }),
});

module.exports = userSchema