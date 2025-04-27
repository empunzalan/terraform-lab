const redis = require('redis');
const client = redis.createClient({ url: 'redis://db-redis:6379' });

async function run() {
    await client.connect();

    await client.set('node_key', 'Hello from Node.js App!');
    const value = await client.get('node_key');
    console.log('Node.js App retrieved:', value);

    setTimeout(run, 5000);
}

run().catch(console.error);
