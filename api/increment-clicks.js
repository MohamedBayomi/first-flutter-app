const MONGO_API_URL = process.env.MONGO_API_URL;
const MONGO_API_KEY = process.env.MONGO_API_KEY;
const MONGO_DATA_SOURCE = process.env.MONGO_DATA_SOURCE || 'Cluster0';
const MONGO_DATABASE = process.env.MONGO_DATABASE || 'flutter_app';
const MONGO_COLLECTION = process.env.MONGO_COLLECTION || 'counters';

const COUNTER_KEY = 'number of clicks';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Increment the counter
    await fetch(`${MONGO_API_URL}/action/updateOne`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': MONGO_API_KEY,
      },
      body: JSON.stringify({
        dataSource: MONGO_DATA_SOURCE,
        database: MONGO_DATABASE,
        collection: MONGO_COLLECTION,
        filter: { key: COUNTER_KEY },
        update: {
          $inc: { value: 1 },
          $setOnInsert: { key: COUNTER_KEY },
        },
        upsert: true,
      }),
    });

    // Fetch the updated value
    const getResponse = await fetch(`${MONGO_API_URL}/action/findOne`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': MONGO_API_KEY,
      },
      body: JSON.stringify({
        dataSource: MONGO_DATA_SOURCE,
        database: MONGO_DATABASE,
        collection: MONGO_COLLECTION,
        filter: { key: COUNTER_KEY },
      }),
    });

    const data = await getResponse.json();
    const value = data.document?.value ?? 0;
    return res.status(200).json({ value });
  } catch (error) {
    return res.status(500).json({ error: 'Failed to increment click count' });
  }
}
