const { textSpanContainsPosition } = require("typescript");



module.exports = {
  async test(request, response){
     var ePrimo = (n) => {
        let i, divisores = 0

        for(i = 1; i <= n; i++){
          if(n % i == 0)
            divisores++
        }
        if(divisores == 2)
          return 1 // n é primo
        else
          return 0 // n não é primo
      };
    
    let aux = []
    for(let i = 0;i < request.query.number;i++){
      if(ePrimo(i))
        aux.push(i)
    }

    return response.status(200).json({ resultado: aux});
  }


}