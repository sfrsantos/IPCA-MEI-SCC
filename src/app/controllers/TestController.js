const { textSpanContainsPosition } = require("typescript");



module.exports = {
  async test(request, response){
    var fib = function(n) {
      if (n === 1) {
        return [0, 1];
      } else {
        var arr = fib(n - 1);
        arr.push(arr[arr.length - 1] + arr[arr.length - 2]);
        return arr;
      }
    };

    return response.status(200).json({ message:"fib = " + fib(request.query.fib_number)});
  }


}