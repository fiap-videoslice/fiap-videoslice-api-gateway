const {handler} = require('./authorizer-function')

const appArgs = process.argv.slice(2)

if (appArgs.length !== 2) {
    throw "Required args: user password"
}

const buff = Buffer.from(appArgs[0] + ":" + appArgs[1])
const base64Auth = buff.toString('base64')

handler({
    "path": "/request",
    "httpMethod": "GET",
    headers: {
        "Authorization": "Basic " + base64Auth
    },
    queryStringParameters: {},
    pathParameters: {}
}).then(result => console.log("RESULT", result))

