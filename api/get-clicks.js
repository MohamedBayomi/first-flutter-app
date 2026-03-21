import clientPromise from "./_mongodb.js";

const DB_NAME = process.env.MONGO_DATABASE || "flutter_app";
const COLLECTION = process.env.MONGO_COLLECTION || "counters";
const COUNTER_KEY = "number of clicks";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const client = await clientPromise;
    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION);

    const doc = await collection.findOne({ key: COUNTER_KEY });
    const value = doc?.value ?? 0;

    return res.status(200).json({ value });
  } catch (error) {
    console.error("get-clicks error:", error);
    return res.status(500).json({ error: "Failed to fetch click count" });
  }
}
