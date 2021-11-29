const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
var fs = require('fs');
var util = require('util');


var folder = __dirname +"/logs"
if (!fs.existsSync(folder)){
    fs.mkdirSync(folder);
}
var file = 'cleanner_'+getDate()+'.log'
var log_file = fs.createWriteStream(folder+'/'+file, {flags : 'a+'});
var log_stdout = process.stdout;
console.log = function(d) { //
  log_file.write(util.format(d) + '\n');
  log_stdout.write(util.format(d) + '\n');
};

try {
    const query = "delete from PUBLIC.\"Blacklist\" where expiration <= " + Math.floor(Date.now() / 1000)
    const del = prisma.$queryRawUnsafe(query).then(() => {})
  } catch (e) {
    console.log("[ "+getDateHour()+" ] -> An error occurred on cleanner : " + e)
  }
  finally{ 
    console.log("[ "+getDateHour()+" ] -> Invalid tokens were cleared")
  }


function getDate(){
  var date_ob = new Date();
  var day = ("0" + date_ob.getDate()).slice(-2);
  var month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
  var year = date_ob.getFullYear();
    
  return year + "-" + month + "-" + day;
}

function getDateHour(){
  var date_ob = new Date();
  var day = ("0" + date_ob.getDate()).slice(-2);
  var month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
  var year = date_ob.getFullYear();
    
  return year + "-" + month + "-" + day + " " + ("0" + date_ob.getHours()).slice(-2) + ":" + ("0" + date_ob.getMinutes()).slice(-2) + ":" + ("0" + date_ob.getSeconds()).slice(-2);
}