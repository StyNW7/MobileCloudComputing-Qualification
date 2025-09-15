import express from "express";
import {
  registerUser,
  loginUser,
  changePassword,
} from "../controllers/auth.controller.js";
import { getUserProfile } from "../controllers/user.controller.js";

import {
  createJournal,
  getJournals,
  getJournalById,
  updateJournal,
  deleteJournal,
} from "../controllers/journal.controller.js";

import { protect } from "../middleware/protect.js";

const router = express.Router();

//auth routes
router.post("/auth/register", registerUser);
router.post("/auth/login", loginUser);
router.put("/auth/change-password/:id", changePassword);

//user routes
router.get("/user/profile", protect, getUserProfile);

// Journal CRUD routes
router.post("/journals", protect, createJournal);
router.get("/journals", protect, getJournals);
router.get("/journals/:id", protect, getJournalById);
router.put("/journals/:id", protect, updateJournal);
router.delete("/journals/:id", protect, deleteJournal);

export default router;