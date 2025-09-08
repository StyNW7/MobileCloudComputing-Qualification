import mongoose from "mongoose";
import User from "../models/user.model.js";
import dotenv from "dotenv";
// import Question from "../models/question.model.js";

dotenv.config();


const dummyUser = [
  {
    username: "tes",
    email: "test@gmail.com",
    password: "tes",
    role: "user"
  },
];


const yogyakartaLandmarks = [
  {
    name: "Candi Sambisari",
    description:
      "Candi Sambisari adalah candi Hindu yang terletak di Sleman, Yogyakarta. Diperkirakan dibangun pada abad ke-9 selama masa Kerajaan Mataram Kuno. Candi ini unik karena ditemukan terkubur sekitar 6,5 meter di bawah permukaan tanah dan kini menjadi salah satu situs arkeologi penting di Yogyakarta.",
    image: "/Images/landmarks/sambisari.jpg",
    yearBuilt: 825,
    city: "Sleman",
    placeCategory: "Yogyakarta",
    position: { x: 1, y: 0, z: 0 },
  },
];

const questions = [
  {
    imageSrc: "/Images/quizz/jam-gadang.png",
    hint: "Menara jam ikonik ini terletak di jantung kota besar Sumatera",
    correctAnswer: "Padang/Bukittinggi",
    description:
      "Ini adalah Jam Gadang yang terkenal di Bukittinggi, dekat Padang, Sumatera Barat.",
    coordinates: { lat: -0.3049, lng: 100.3694 },
  },
  {
    imageSrc: "/Images/quizz/tanah-lot.png",
    hint: "Pura Hindu yang indah ini berada di atas formasi batu di tepi laut",
    correctAnswer: "Bali",
    description:
      "Ini adalah Pura Tanah Lot, salah satu landmark paling ikonik di Bali.",
    coordinates: { lat: -8.6211, lng: 115.0868 },
  },
];

async function seed() {

  try {

    await mongoose.connect("mongodb+srv://root:root@cluster0.llarrr4.mongodb.net/calis-fun?retryWrites=true&w=majority&appName=Cluster0");

    console.log("MongoDB connected for seeding");

    // Optional: Clear existing data
    // await User.deleteMany({});

    // Insert seed data
    await User.insertMany(dummyUser);
    // await Question.insertMany(questions);

    console.log("Data seeded successfully!");
    mongoose.connection.close();
  } catch (error) {
    console.error("Error seeding data:", error);
    mongoose.connection.close();
  }

}

seed();