const // Get those values in runtime
  language = process.env.LANGUAGE,
  token = process.env.TOKEN;

require("http")
  .createServer((request, response) => {
    response.write(`Language: ${language}\n`);
    response.write(`Token   : ${token}\n`);
    response.end(`\n`);
  })
  // Set the default port to 5000
  .listen(process.env.PORT || 5000);
