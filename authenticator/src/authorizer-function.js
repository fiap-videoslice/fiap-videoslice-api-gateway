const { CognitoIdentityProviderClient, AdminGetUserCommand, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { createHmac } = require('crypto');

const config = {}

const client = new CognitoIdentityProviderClient(config);

const openServices = ['/', '/healthcheck', '/echo']

// (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult>
exports.handler = async function (evt) {
    try {
        // Can contain sensitive data such as Basic Auth headers - do not keep this in production
        console.log("Received Auth request", evt);

        ///
        const cognitoClientId = process.env["COGNITO_CLIENT_ID"]
        const cognitoClientSecret = process.env["COGNITO_CLIENT_SECRET"]

        if (!cognitoClientId || !cognitoClientSecret) {
            console.warn("Missing environment variables: COGNITO_CLIENT_ID|COGNITO_CLIENT_SECRET")
            return {
                "isAuthorized": false
            };
        }

        const headers = evt.headers;

        const authorizationHeader = headers.Authorization ?? headers.authorization

        if (authorizationHeader) {
            if (authorizationHeader.startsWith("Basic ")) {
                return basicAuth(authorizationHeader, cognitoClientId, cognitoClientSecret)
            }

            if (authorizationHeader.startsWith("Bearer ")) {
                return tokenAuth(authorizationHeader, cognitoClientId, cognitoClientSecret)
            }

            return {
                "isAuthorized": false,
                "context": {
                    "authError": "Unrecognized Authorization header"
                }
            };
        }

        if (openServices.includes(evt.path)) {
            return {
                "isAuthorized": true,
                "context": {
                }
            }
        } else {
            return {
                "isAuthorized": false,
                "context": {
                    "authError": "Authorization info not provided"
                }
            }
        }

    } catch (e) {
        console.warn("Authorization error!", e)
        return {
            "isAuthorized": false,
            "context": {
                "authError": "Authorization error"
            }
        }
    }
}

async function basicAuth(authorizationHeader, cognitoClientId, cognitoClientSecret) {
    const encoded = authorizationHeader.split(" ")[1]
    const buff = Buffer.from(encoded, 'base64');
    const decoded = buff.toString("utf8")

    if (!decoded.includes(":")) {
        console.warn("Invalid authentication token found", authorizationHeader, decoded)
        return {
            "isAuthorized": false
        }
    }

    const parts = decoded.split(":")
    const username = parts[0]
    const password = parts[1]

    const command = new InitiateAuthCommand({
        AuthFlow: "USER_PASSWORD_AUTH",
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password,
            SECRET_HASH: secretHash(username, cognitoClientId, cognitoClientSecret)
        },
        ClientId: cognitoClientId
    })

    let authResult

    await client.send(command).then(response => {
        console.log("AUTH RESPONSE", response)

        if (response["$metadata"] && response["$metadata"].httpStatusCode === 200
            && response.AuthenticationResult && response.AuthenticationResult.IdToken) {

            console.log("OK!")

            authResult = {
                "isAuthorized": true,
                "context": {
                    "CustomIdentityToken": response.AuthenticationResult.IdToken
                }
            }
        } else {
            console.warn("Unexpected authentication response", response)
            authResult = {
                "isAuthorized": false,
                "context": {
                    "authErrorDetails": "Unexpected authentication response"
                }
            };
        }
    }).catch(err => {
       // if (!err.message || !err.message.includes("Incorrect username or password")) {
            console.warn("Unexpected auth exception", err)
       // }

        authResult = {
            "isAuthorized": false,
            "context": {
                "authErrorDetails": "Exception: " + (err.message ? err.message : err)
            }
        };
    });

    return authResult;
}

async function tokenAuth(authorizationHeader, cognitoClientId, cognitoClientSecret) {
    const token = authorizationHeader.split(" ")[1]

    /*
    NOTE:
    During this lab phase we are skipping the token validation here. The token is just forwarded to the application,
    which is currently responsible for the validation - including expiration and Cognito signature check.

    This works and is safe (unauthorized access is still forbidden), but the solution will be a lot more robust if we
    also implement the verification in this auth layer. With this change the application won't be even reached by users without a valid token.

    To be changed before moving to production!
     */

    return {
        "isAuthorized": true,
        "context": {
            "CustomIdentityToken": token
        }
    }
}

function secretHash(username, clientId, clientSecret) {
    const hasher = createHmac('sha256', clientSecret);
    hasher.update(username + clientId)
    return hasher.digest('base64')
}