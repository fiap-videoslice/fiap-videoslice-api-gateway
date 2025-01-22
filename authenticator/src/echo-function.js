exports.handler = async function(evt){
    console.log("Received request", evt);

    try {
        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                message: 'hello from Lambda integration!',
                inputEvent: evt,
            }),
        };
    } catch (err) {
        console.log("An error happened", err);
        return {
            statusCode: 500,
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                message: 'some error happened: ' + err,
                inputEvent: evt,
            }),
        };
    }
}
