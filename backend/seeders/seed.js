import mongoose from "mongoose";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import { faker } from "@faker-js/faker";
import User from "../models/user.model.js";
import Journal from "../models/journal.model.js";

dotenv.config();

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ MongoDB connected for seeding");

    // Bersihkan collection lama
    await User.deleteMany({});
    await Journal.deleteMany({});

    // Hash password
    const userPassword = await bcrypt.hash("user1234", 10);
    const adminPassword = await bcrypt.hash("admin1234", 10);

    // Insert users
    const users = await User.insertMany([
      {
        username: "user",
        email: "user@gmail.com",
        password: userPassword,
        role: "user",
      },
      {
        username: "admin",
        email: "admin@gmail.com",
        password: adminPassword,
        role: "admin",
      },
    ]);

    console.log("✅ Users seeded");

    // Generate 20 random journals
    const journals = [];
    for (let i = 0; i < 20; i++) {
      journals.push({
        title: faker.lorem.sentence(5),
        content: faker.lorem.paragraphs(2),
        author: faker.helpers.arrayElement(users)._id, // assign random user
      });
    }

    await Journal.insertMany(journals);
    console.log("✅ Journals seeded (20 entries)");

    mongoose.connection.close();
    console.log("🌱 Seeding completed and connection closed");
  } catch (error) {
    console.error("❌ Error seeding data:", error);
    mongoose.connection.close();
  }
}

seed();