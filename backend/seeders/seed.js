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

    // 1. Bersihkan collection lama
    await User.deleteMany({});
    await Journal.deleteMany({});
    console.log("🗑️  Old data cleared");

    // 2. Buat user dengan password hash
    const users = await User.insertMany([
      {
        username: "user",
        email: "user@gmail.com",
        password: await bcrypt.hash("user1234", 10),
        role: "user",
      },
      {
        username: "admin",
        email: "admin@gmail.com",
        password: await bcrypt.hash("admin1234", 10),
        role: "admin",
      },
    ]);

    console.log("✅ Users seeded:", users.map(u => u.email));

    // 3. Generate 20 journals random
    const journals = Array.from({ length: 20 }).map(() => ({
      title: faker.lorem.sentence(5),
      content: faker.lorem.paragraphs(2),
      author: faker.helpers.arrayElement(users)._id, // assign random user
    }));

    await Journal.insertMany(journals);
    console.log(`✅ Journals seeded (${journals.length} entries)`);

    console.log("🌱 Seeding completed successfully");
    mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding data:", error);
    mongoose.connection.close();
    process.exit(1);
  }
}

seed();
