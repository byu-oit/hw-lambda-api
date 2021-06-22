'use strict'
const { handler } = require('./index')

describe('GET /health', () => {
  test('should return 200', async () => {
    const event = {
      httpMethod: 'GET',
      path: '/health'
    }
    const context = {}

    const response = await handler(event, context)

    expect(response.statusCode).toBe(200)
  })
})
