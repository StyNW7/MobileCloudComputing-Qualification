import Journal from "../models/journal.model.js";

// Create
export const createJournal = async (req, res) => {
  try {
    const { title, content } = req.body;

    if (!title || !content) {
      return res.status(400).json({ message: "Title and content required" });
    }

    const journal = new Journal({
      title,
      content,
      author: req.user.userId, // dari middleware protect
    });

    await journal.save();
    res.status(201).json(journal);
  } catch (error) {
    console.error("Error creating journal:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Read All
export const getJournals = async (req, res) => {
  try {
    const journals = await Journal.find({ author: req.user.userId }).sort({
      createdAt: -1,
    });
    res.status(200).json(journals);
  } catch (error) {
    console.error("Error fetching journals:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Read One
export const getJournalById = async (req, res) => {
  try {
    const journal = await Journal.findOne({
      _id: req.params.id,
      author: req.user.userId,
    });

    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    res.status(200).json(journal);
  } catch (error) {
    console.error("Error fetching journal:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Update
export const updateJournal = async (req, res) => {
  try {
    const { title, content } = req.body;

    const journal = await Journal.findOneAndUpdate(
      { _id: req.params.id, author: req.user.userId },
      { title, content },
      { new: true }
    );

    if (!journal) {
      return res.status(404).json({ message: "Journal not found" });
    }

    res.status(200).json(journal);
  } catch (error) {
    console.error("Error updating journal:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Delete
export const deleteJournal = async (req, res) => {
  try {
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
    res.status(500).json({ message: "Server error" });
  }
};
