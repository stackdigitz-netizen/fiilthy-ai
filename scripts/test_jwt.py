import os
import sys
sys.path.insert(0, os.path.join(os.getcwd(), 'ceo', 'backend'))

from ai_services.auth_utils import create_access_token, decode_token, SECRET_KEY

print('PYTHONPATH:', os.environ.get('PYTHONPATH'))
print('JWT_SECRET env:', os.environ.get('JWT_SECRET'))
print('JWT_SECRET_KEY env:', os.environ.get('JWT_SECRET_KEY'))
print('SECRET_KEY used by module:', SECRET_KEY)

token = create_access_token('user_test', 'test@example.com')
print('\nGenerated token:', token)

payload = decode_token(token)
print('Decoded payload:', payload)
