const {
  Joi,
  celebrate
} = require("celebrate");

const loginSchema = celebrate({
  body: Joi.object().keys({
    username: Joi.string().required(),
    password: Joi.string().required(),
  }),
});

module.exports = loginSchema