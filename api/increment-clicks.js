const clientPromise = require("./_mongodb.js");

const DB_NAME = process.env.MONGO_DATABASE || "flutter_app";
const COLLECTION = process.env.MONGO_COLLECTION || "counters";
const COUNTER_KEY = "number of clicks";

module.exports = async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const client = await clientPromise;
    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION);

    const result = await collection.findOneAndUpdate(
      { key: COUNTER_KEY },
      { $inc: { value: 1 }, $setOnInsert: { key: COUNTER_KEY } },
      { upsert: true, returnDocument: "after" }
    );

    const value = result?.value ?? 0;
    return res.status(200).json({ value: value });
  } catch (error) {
    console.error("increment-clicks error:", error);
    return res.status(500).json({ error: "Failed to increment click count" });
  }
};
