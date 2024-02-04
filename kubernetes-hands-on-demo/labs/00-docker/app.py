import requests
r = requests.get('https://www.google.com')
print('Response is: {}'.format(r.status_code))
