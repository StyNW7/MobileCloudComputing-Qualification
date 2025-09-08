import express from "express";
import dotenv from "dotenv";
import { connectDB } from "./config/db.js";
import router from "./routes/routes.js";
import cors from "cors";

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// CORS configuration

let corsOptions;

if (process.env.NODE_ENV === "development") {
  corsOptions = {
    origin: (origin, callback) => {
      // Jika origin tidak ada (contoh: Postman, curl), izinkan
      if (!origin) return callback(null, true);
      return callback(null, true); // Semua origin diizinkan
    },
    credentials: true,
  };
} else {
  corsOptions = {
    credentials: true,
  };
  corsOptions.origin = "https://flutter.app";
}

app.use(cors(corsOptions));

// Routes
app.get("/", (req, res) => res.send("Express on Vercel"));
app.use("/api", router);

// For Vercel deployment
export default async (req, res) => {
  try {
    await connectDB();
    return app(req, res);
  } catch (err) {
    console.error("Failed to connect to DB", err);
    return res.status(500).json({ error: "Internal Server Error" });
  }
};

// For local development
if (process.env.NODE_ENV === "development") {
  const startServer = async () => {
    try {
      await connectDB();
      app.listen(port, () => {
        console.log(`Server running in development mode`);
        console.log(`Server running on port ${port}`);
        console.log(`Access the server at http://localhost:${port}`);
      });
    } catch (err) {
      console.error("Failed to connect to DB", err);
      process.exit(1);
    }
  };
  startServer();
}