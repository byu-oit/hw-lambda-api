/*
const { DynamoDBClient, ScanCommand } = require('@aws-sdk/client-dynamodb')
const { S3Client, ListObjectsV2Command } = require('@aws-sdk/client-s3')
const dynamodb = new DynamoDBClient({ region: 'us-west-2' })
const s3 = new S3Client({})
*/

exports.handler = async function (event, context) {
  /*
  const event = {
    'requestContext': {
      'elb': {
        'targetGroupArn': 'arn:aws:elasticloadbalancing:region:123456789012:targetgroup/my-target-group/6d0ecf831eec9f09'
      }
    },
    'httpMethod': 'GET',
    'path': '/',
    'queryStringParameters': { some_query: 'blah' },
    'headers': {
      'accept': 'text/html,application/xhtml+xml',
      'accept-language': 'en-US,en;q=0.8',
      'content-type': 'text/plain',
      'cookie': 'cookies',
      'host': 'lambda-846800462-us-east-2.elb.amazonaws.com',
      'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6)',
      'x-amzn-trace-id': 'Root=1-5bdb40ca-556d8b0c50dc66f0511bf520',
      'x-forwarded-for': '72.21.198.66',
      'x-forwarded-port': '443',
      'x-forwarded-proto': 'https'
    },
    'isBase64Encoded': false,
    'body': 'request_body' // This is a string - If you want an object, you'll need to parse it
  }
  */

  console.log(event)
  console.log(context)

  /*
  const scanCommand = new ScanCommand({ TableName: process.env.DYNAMO_TABLE_NAME })
  const listObjectsV2Command = new ListObjectsV2Command({ Bucket: process.env.BUCKET_NAME })
  try {
    const [dynamoData, s3Data] = await Promise.all([
      dynamodb.send(scanCommand),
      s3.send(listObjectsV2Command)
    ])
    res.send({
      secret: process.env.SOME_SECRET,
      table: process.env.DYNAMO_TABLE_NAME,
      numItemsInDynamo: dynamoData.Count,
      bucket: process.env.BUCKET_NAME,
      numObjectsInS3: s3Data.KeyCount
    })
  } catch (err) {
    console.log(err, err.stack)
    res.status(500).send('Error reading table or S3')
  }
  */
  if (event.path === '/health') {
    return {
      isBase64Encoded: false,
      statusCode: 200,
      statusDescription: '200 OK',
      headers: {
        'Content-Type': 'text/plain'
      },
      body: 'healthy'
    }
  } else if (event.path === '/') {
    const body = {
      secret: 'TODO: get secret, table name, and bucket name', // process.env.SOME_SECRET,
      table: 'hw-lambda-api-dev', // process.env.DYNAMO_TABLE_NAME,
      numItemsInDynamo: 0, // dynamoData.Count,
      bucket: 'hw-lambda-api-dev', // process.env.BUCKET_NAME,
      numObjectsInS3: 0 // s3Data.KeyCount
    }
    return {
      isBase64Encoded: false,
      statusCode: 200,
      statusDescription: '200 OK',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    }
  } else {
    return {
      isBase64Encoded: false,
      statusCode: 404,
      statusDescription: '404 Not Found',
      headers: {},
      body: ''
    }
  }
}
