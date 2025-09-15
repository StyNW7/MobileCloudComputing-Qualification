import mongoose from "mongoose";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import { faker } from "@faker-js/faker";
import User from "../models/user.model.js";
import Journal from "../models/journal.model.js";
import Comment from "../models/comment.model.js";

dotenv.config();

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ MongoDB connected for seeding");

    // 1. Clear old collections
    await User.deleteMany({});
    await Journal.deleteMany({});
    await Comment.deleteMany({});
    console.log("🗑️  Old data cleared");

    // 2. Create users with hashed passwords
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
      {
        username: "john_doe",
        email: "john@gmail.com",
        password: await bcrypt.hash("john1234", 10),
        role: "user",
      },
      {
        username: "jane_smith",
        email: "jane@gmail.com",
        password: await bcrypt.hash("jane1234", 10),
        role: "user",
      },
    ]);

    console.log("✅ Users seeded:", users.map(u => u.email));

    // 3. Generate journals
    const journals = Array.from({ length: 15 }).map(() => ({
      title: faker.lorem.sentence(5),
      content: faker.lorem.paragraphs(3),
      author: faker.helpers.arrayElement(users)._id,
    }));

    const createdJournals = await Journal.insertMany(journals);
    console.log(`✅ Journals seeded (${createdJournals.length} entries)`);

    // 4. Generate comments for journals
    const comments = [];
    
    // Create top-level comments
    for (const journal of createdJournals) {
      const numComments = faker.number.int({ min: 2, max: 8 });
      
      for (let i = 0; i < numComments; i++) {
        comments.push({
          content: faker.lorem.sentences(faker.number.int({ min: 1, max: 3 })),
          author: faker.helpers.arrayElement(users)._id,
          journal: journal._id,
          parentComment: null, // Top-level comment
        });
      }
    }

    const createdComments = await Comment.insertMany(comments);
    console.log(`✅ Top-level comments seeded (${createdComments.length} entries)`);

    // 5. Generate replies to some comments
    const replies = [];
    const topLevelComments = createdComments.filter(c => !c.parentComment);
    
    // Add replies to about 40% of top-level comments
    const commentsToReply = faker.helpers.arrayElements(
      topLevelComments, 
      Math.floor(topLevelComments.length * 0.4)
    );

    for (const parentComment of commentsToReply) {
      const numReplies = faker.number.int({ min: 1, max: 4 });
      
      for (let i = 0; i < numReplies; i++) {
        replies.push({
          content: faker.lorem.sentences(faker.number.int({ min: 1, max: 2 })),
          author: faker.helpers.arrayElement(users)._id,
          journal: parentComment.journal,
          parentComment: parentComment._id,
        });
      }
    }

    if (replies.length > 0) {
      await Comment.insertMany(replies);
      console.log(`✅ Comment replies seeded (${replies.length} entries)`);
    }

    // 6. Generate some edited comments
    const commentsToEdit = faker.helpers.arrayElements(
      await Comment.find({}), 
      faker.number.int({ min: 3, max: 8 })
    );

    for (const comment of commentsToEdit) {
      comment.content = `${comment.content} [EDITED: ${faker.lorem.sentence()}]`;
      comment.isEdited = true;
      comment.editedAt = faker.date.recent({ days: 7 });
      await comment.save();
    }

    console.log(`✅ ${commentsToEdit.length} comments marked as edited`);

    // 7. Summary
    const finalStats = {
      users: await User.countDocuments(),
      journals: await Journal.countDocuments(),
      comments: await Comment.countDocuments(),
      topLevelComments: await Comment.countDocuments({ parentComment: null }),
      replies: await Comment.countDocuments({ parentComment: { $ne: null } }),
      editedComments: await Comment.countDocuments({ isEdited: true }),
    };

    console.log("\n📊 Seeding Summary:");
    console.log(`   👥 Users: ${finalStats.users}`);
    console.log(`   📝 Journals: ${finalStats.journals}`);
    console.log(`   💬 Total Comments: ${finalStats.comments}`);
    console.log(`   ├── Top-level: ${finalStats.topLevelComments}`);
    console.log(`   ├── Replies: ${finalStats.replies}`);
    console.log(`   └── Edited: ${finalStats.editedComments}`);

    console.log("\n🌱 Seeding completed successfully!");
    console.log("\n🔐 Test Accounts:");
    console.log("   User: user@gmail.com / user1234");
    console.log("   Admin: admin@gmail.com / admin1234");
    console.log("   John: john@gmail.com / john1234");
    console.log("   Jane: jane@gmail.com / jane1234");

    mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding data:", error);
    mongoose.connection.close();
    process.exit(1);
  }
}

seed();