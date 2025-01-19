exports.handler = async function(evt){
    try {
        // This endpoint is expected to work together with the Authorizer function, which saves the token
        // on this Header
        const token = evt.requestContext && evt.requestContext.authorizer ? evt.requestContext.authorizer.CustomIdentityToken : null;

        if (token) {
            return {
                statusCode: 200,
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    IdToken: token,
                })
            };
        } else {
            return {
                statusCode: 401,
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    message: 'Not authenticated',
                })
            }
        }

    } catch (err) {
        console.log("An error happened", err);
        return {
            statusCode: 500,
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                message: 'some error happened: ' + err
            }),
        };
    }
}