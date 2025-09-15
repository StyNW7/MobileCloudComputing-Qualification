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

import {
  createComment,
  getJournalComments,
  getCommentById,
  updateComment,
  deleteComment,
  getUserComments,
} from "../controllers/comment.controller.js";

import { protect } from "../middleware/protect.js";

const router = express.Router();

// Auth routes
router.post("/auth/register", registerUser);
router.post("/auth/login", loginUser);
router.put("/auth/change-password/:id", changePassword);

// User routes
router.get("/user/profile", protect, getUserProfile);
router.get("/user/comments", protect, getUserComments); // Get user's own comments

// Journal CRUD routes
router.post("/journals", protect, createJournal);
router.get("/journals", protect, getJournals);
router.get("/journals/:id", protect, getJournalById);
router.put("/journals/:id", protect, updateJournal);
router.delete("/journals/:id", protect, deleteJournal);

// Comment routes
router.post("/journals/:journalId/comments", protect, createComment); // Create comment for a journal
router.get("/journals/:journalId/comments", getJournalComments); // Get all comments for a journal (public)
router.get("/comments/:commentId", getCommentById); // Get specific comment (public)
router.put("/comments/:commentId", protect, updateComment); // Update comment (author only)
router.delete("/comments/:commentId", protect, deleteComment); // Delete comment (author only)

export default router;