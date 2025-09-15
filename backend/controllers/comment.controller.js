import Comment from "../models/comment.model.js";
import Journal from "../models/journal.model.js";
import mongoose from "mongoose";

// Create a new comment
export const createComment = async (req, res) => {
  try {
    const { content, parentCommentId } = req.body;
    const { journalId } = req.params;

    if (!content || !content.trim()) {
      return res.status(400).json({ message: "Comment content is required" });
    }

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    // Check if journal exists
    const journal = await Journal.findById(journalId);
    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    // If it's a reply, check if parent comment exists
    if (parentCommentId) {
      const parentComment = await Comment.findById(parentCommentId);
      if (!parentComment) {
        return res.status(404).json({ message: "Parent comment not found" });
      }
      // Ensure parent comment belongs to the same journal
      if (parentComment.journal.toString() !== journalId) {
        return res.status(400).json({ message: "Invalid parent comment" });
      }
    }

    const comment = new Comment({
      content: content.trim(),
      author: req.user.userId,
      journal: journalId,
      parentComment: parentCommentId || null,
    });

    await comment.save();

    // Populate the comment with author details
    await comment.populate('author', 'username email');

    res.status(201).json({
      message: "Comment created successfully",
      comment: comment
    });
  } catch (error) {
    console.error("Error creating comment:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Get all comments for a journal (with nested replies)
export const getJournalComments = async (req, res) => {
  try {
    const { journalId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!mongoose.Types.ObjectId.isValid(journalId)) {
      return res.status(400).json({ message: "Invalid journal ID" });
    }

    // Check if journal exists
    const journal = await Journal.findById(journalId);
    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    // Get top-level comments (no parent)
    const topLevelComments = await Comment.find({
      journal: journalId,
      parentComment: null
    })
    .populate('author', 'username email')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

    // Get replies for each top-level comment
    const commentsWithReplies = await Promise.all(
      topLevelComments.map(async (comment) => {
        const replies = await Comment.find({
          parentComment: comment._id
        })
        .populate('author', 'username email')
        .sort({ createdAt: 1 }); // Replies in chronological order

        return {
          ...comment.toObject(),
          replies: replies
        };
      })
    );

    // Get total count for pagination
    const totalComments = await Comment.countDocuments({
      journal: journalId,
      parentComment: null
    });

    const totalPages = Math.ceil(totalComments / limit);

    res.status(200).json({
      comments: commentsWithReplies,
      pagination: {
        currentPage: page,
        totalPages: totalPages,
        totalComments: totalComments,
        hasNext: page < totalPages,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error("Error fetching comments:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Get a specific comment by ID
export const getCommentById = async (req, res) => {
  try {
    const { commentId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(commentId)) {
      return res.status(400).json({ message: "Invalid comment ID" });
    }

    const comment = await Comment.findById(commentId)
      .populate('author', 'username email')
      .populate('journal', 'title');

    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    // Get replies if it's a top-level comment
    let replies = [];
    if (!comment.parentComment) {
      replies = await Comment.find({ parentComment: commentId })
        .populate('author', 'username email')
        .sort({ createdAt: 1 });
    }

    res.status(200).json({
      comment: {
        ...comment.toObject(),
        replies: replies
      }
    });
  } catch (error) {
    console.error("Error fetching comment:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update a comment (only by author)
export const updateComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const { content } = req.body;

    if (!content || !content.trim()) {
      return res.status(400).json({ message: "Comment content is required" });
    }

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    if (!mongoose.Types.ObjectId.isValid(commentId)) {
      return res.status(400).json({ message: "Invalid comment ID" });
    }

    const comment = await Comment.findOne({
      _id: commentId,
      author: req.user.userId
    });

    if (!comment) {
      return res.status(404).json({ message: "Comment not found or you don't have permission to edit it" });
    }

    comment.content = content.trim();
    comment.isEdited = true;
    comment.editedAt = new Date();

    await comment.save();
    await comment.populate('author', 'username email');

    res.status(200).json({
      message: "Comment updated successfully",
      comment: comment
    });
  } catch (error) {
    console.error("Error updating comment:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Delete a comment (only by author)
export const deleteComment = async (req, res) => {
  try {
    const { commentId } = req.params;

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    if (!mongoose.Types.ObjectId.isValid(commentId)) {
      return res.status(400).json({ message: "Invalid comment ID" });
    }

    const comment = await Comment.findOne({
      _id: commentId,
      author: req.user.userId
    });

    if (!comment) {
      return res.status(404).json({ message: "Comment not found or you don't have permission to delete it" });
    }

    // Delete all replies to this comment first
    await Comment.deleteMany({ parentComment: commentId });

    // Delete the comment itself
    await Comment.findByIdAndDelete(commentId);

    res.status(200).json({ message: "Comment and its replies deleted successfully" });
  } catch (error) {
    console.error("Error deleting comment:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Get user's own comments
export const getUserComments = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    const comments = await Comment.find({ author: req.user.userId })
      .populate('journal', 'title')
      .populate('author', 'username email')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const totalComments = await Comment.countDocuments({ author: req.user.userId });
    const totalPages = Math.ceil(totalComments / limit);

    res.status(200).json({
      comments: comments,
      pagination: {
        currentPage: page,
        totalPages: totalPages,
        totalComments: totalComments,
        hasNext: page < totalPages,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error("Error fetching user comments:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};