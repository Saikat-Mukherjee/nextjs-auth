import mongoose from "mongoose";

export async function connect() {
    if (mongoose.connection.readyState !== 0) {
        return;
    }

    const uri = process.env.MONGO_URI;
    if (!uri) {
        console.warn("MONGO_URI is not set; skipping MongoDB connection");
        return;
    }

    try {
        await mongoose.connect(uri);
        console.log("Connected to MongoDB");
    } catch (error) {
        console.error("Error connecting to MongoDB:", error);
    }
}