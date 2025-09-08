import mongoose from "mongoose";
import { getbucket } from "../config/db.js";
import { Readable } from "stream";


/**
 * Uploads a file buffer to GridFS storage.
 * @param {Buffer} fileBuffer - The file data as a Buffer.
 * @param {string} originalName - The original filename.
 * @param {Object} metadata - Additional metadata to store with the file (optional).
 * @returns {Promise<Object>} A promise that resolves with file info containing fileId, filename, and size.
 */
export const uploadFileToGridFS = async (fileBuffer, originalName, metadata = {}) => {
  try {
    // Create a readable stream from buffer
    const readableStream = new Readable();
    readableStream.push(fileBuffer);
    readableStream.push(null);

    // Create upload stream to GridFS
    const uploadStream = getbucket().openUploadStream(originalName, {
      metadata: {
        originalName: originalName,
        uploadDate: new Date(),
        ...metadata, // Spread any additional metadata
      },
    });

    // Return a promise that resolves with file info
    return new Promise((resolve, reject) => {
      uploadStream.on('finish', () => {
        resolve({
          fileId: uploadStream.id,
          filename: originalName,
          size: uploadStream.bytesUploaded,
        });
      });

      uploadStream.on('error', (error) => {
        reject(error);
      });

      // Pipe the readable stream to GridFS
      readableStream.pipe(uploadStream);
    });

  } catch (error) {
    throw new Error(`File upload failed: ${error.message}`);
  }
};

/**
 * Retrieves file metadata from GridFS by its ID.
 * @param {string} fileId - The MongoDB ObjectId of the file to retrieve.
 * @returns {Promise<Object>} A promise that resolves with the file metadata object.
 * @throws {Error} Throws an error if the file ID is invalid or file is not found.
 */
export const getFileFromGridFS = async (fileId) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(fileId)) {
      throw new Error('Invalid file ID format.');
    }

    const objectId = new mongoose.mongo.ObjectId(fileId);
    
    // Find file info
    const files = await getbucket().find({ _id: objectId }).toArray();
    
    if (!files || files.length === 0) {
      throw new Error("File not found");
    }

    return files[0];
  } catch (error) {
    throw new Error(`Get file failed: ${error.message}`);
  }
};

/**
 * Deletes a file from GridFS by its ID.
 * @param {string} fileId - The MongoDB ObjectId of the file to delete.
 * @returns {Promise<boolean>} A promise that resolves to true when the file is successfully deleted.
 * @throws {Error} Throws an error if the deletion fails.
 */
export const deleteFileFromGridFS = async (fileId) => {
  try {
    const objectId = new mongoose.mongo.ObjectId(fileId);
    await getbucket().delete(objectId);
    return true;
  } catch (error) {
    throw new Error(`Delete file failed: ${error.message}`);
  }
};

/**
 * Validates an image file buffer and filename for security and format compliance.
 * @param {Buffer} fileBuffer - The file data as a Buffer to validate.
 * @param {string} originalName - The original filename to check extension.
 * @param {number} maxSizeInMB - Maximum allowed file size in megabytes (default: 5MB).
 * @returns {boolean} Returns true if the file is valid.
 * @throws {Error} Throws an error if validation fails (size, extension, or format).
 */
export const validateImageFile = (fileBuffer, originalName, maxSizeInMB = 5) => {
  // Check file size
  if (fileBuffer.length > maxSizeInMB * 1024 * 1024) {
    throw new Error(`File size exceeds ${maxSizeInMB}MB limit`);
  }

  // Check file extension
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  const fileExtension = originalName.toLowerCase().substring(originalName.lastIndexOf('.'));
  
  if (!allowedExtensions.includes(fileExtension)) {
    throw new Error('Only image files (jpg, jpeg, png, webp) are allowed');
  }

  // Check file signature (magic numbers) for basic validation
  const signatures = {
    jpg: [0xFF, 0xD8, 0xFF],
    png: [0x89, 0x50, 0x4E, 0x47],
    webp: [0x52, 0x49, 0x46, 0x46], // Note: WEBP has RIFF header
  };

  const header = Array.from(fileBuffer.slice(0, 4));
  
  const isValidImage = Object.values(signatures).some(signature => 
    signature.every((byte, index) => header[index] === byte)
  );

  if (!isValidImage) {
    throw new Error('Invalid image file format');
  }

  return true;
};