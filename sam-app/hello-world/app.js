// const axios = require('axios')
// const url = 'http://checkip.amazonaws.com/';
let response;

/**
 *
 * Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
 * @param {Object} event - API Gateway Lambda Proxy Input Format
 *
 * Context doc: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-context.html 
 * @param {Object} context
 *
 * Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
 * @returns {Object} object - API Gateway Lambda Proxy Output Format
 * 
 */
exports.lambdaHandler = async (event) => { // <1>
    var result = "Hello "
    if (event.queryStringParameters && event.queryStringParameters.name) {
        console.log("received name: " + event.queryStringParameters.name);
        result = result + event.queryStringParameters.name
    } else {
        result = result + "World"
    }

    console.log("Result: " + result);

    const response = {
        statusCode: 200,
        body: JSON.stringify(result),
    };

    return response;
};
