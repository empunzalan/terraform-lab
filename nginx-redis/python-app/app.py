import redis
import time

r = redis.Redis(host='db-redis', port 6379)

while True:
    try:
        r.set('python_key', 'Hello from Python App!')
        value = r.get('python_key')
        print("Python App retrieved:", value.decode('utf-8'))
        time.sleep(5)
    except redis.ConnectionError:
        print("Waiting for Redis...")
        time.sleep(2)
