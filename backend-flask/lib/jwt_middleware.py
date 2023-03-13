import jwt
from flask import request, jsonify

class JWTMiddleware:
    def __init__(self, app, secret_key):
        self.app = app
        self.secret_key = secret_key

    def __call__(self, environ, start_response):
        auth_header = request.headers.get('Authorization')

        if auth_header and auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]

            try:
                payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
                request.jwt_payload = payload
            except jwt.InvalidTokenError:
                response = jsonify({'error': 'Invalid token'})
                response.status_code = 401
                return response(environ, start_response)

        return self.app(environ, start_response)
