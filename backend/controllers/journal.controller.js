import Journal from "../models/journal.model.js";

// Create
export const createJournal = async (req, res) => {
  try {
    const { title, content } = req.body;

    if (!title || !content) {
      return res.status(400).json({ message: "Title and content required" });
    }

    // Add debugging
    console.log("User from middleware:", req.user);
    
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    const journal = new Journal({
      title,
      content,
      author: req.user.userId,
    });

    await journal.save();
    res.status(201).json(journal);
  } catch (error) {
    console.error("Error creating journal:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Read All - Fixed with better debugging
export const getJournals = async (req, res) => {
  try {
    // Add debugging logs
    console.log("Request user:", req.user);
    console.log("User ID:", req.user?.userId);

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    // First, let's check if any journals exist at all
    const totalJournals = await Journal.countDocuments();
    console.log("Total journals in database:", totalJournals);

    // Check journals for this specific user
    const userJournalCount = await Journal.countDocuments({ author: req.user.userId });
    console.log("Journals for this user:", userJournalCount);

    const journals = await Journal.find({ author: req.user.userId })
      .populate('author', 'username email')
      .sort({ createdAt: -1 });

    console.log("Found journals:", journals.length);
    
    res.status(200).json({
      count: journals.length,
      journals: journals
    });
  } catch (error) {
    console.error("Error fetching journals:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Read All Journals (for debugging - remove in production)
export const getAllJournals = async (req, res) => {
  try {
    const journals = await Journal.find({})
      .populate('author', 'username email')
      .sort({ createdAt: -1 });
    
    res.status(200).json({
      count: journals.length,
      journals: journals
    });
  } catch (error) {
    console.error("Error fetching all journals:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Read One - Updated with better error handling
export const getJournalById = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    const journal = await Journal.findOne({
      _id: req.params.id,
      author: req.user.userId,
    }).populate('author', 'username email');

    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    res.status(200).json(journal);
  } catch (error) {
    console.error("Error fetching journal:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update
export const updateJournal = async (req, res) => {
  try {
    const { title, content } = req.body;

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    const journal = await Journal.findOneAndUpdate(
      { _id: req.params.id, author: req.user.userId },
      { title, content },
      { new: true }
    ).populate('author', 'username email');

    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    res.status(200).json(journal);
  } catch (error) {
    console.error("Error updating journal:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Delete
export const deleteJournal = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    const journal = await Journal.findOneAndDelete({
      _id: req.params.id,
      author: req.user.userId,
    });

    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    res.status(200).json({ message: "Journal deleted successfully" });
  } catch (error) {
    console.error("Error deleting journal:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};