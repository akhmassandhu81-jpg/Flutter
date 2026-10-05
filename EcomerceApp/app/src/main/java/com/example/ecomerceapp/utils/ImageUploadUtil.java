package com.example.ecomerceapp.utils;

import android.content.Context;
import android.net.Uri;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.util.UUID;

/**
 * Utility class for uploading images to Firebase Storage
 */
public class ImageUploadUtil {
    
    private static final String PRODUCT_IMAGES_PATH = "product_images/";
    
    public interface UploadCallback {
        void onSuccess(String imageUrl);
        void onFailure(String error);
    }
    
    /**
     * Upload an image to Firebase Storage
     * @param context Application context
     * @param imageUri URI of the image to upload
     * @param callback Callback for success/failure
     */
    public static void uploadProductImage(Context context, Uri imageUri, UploadCallback callback) {
        if (imageUri == null) {
            callback.onFailure("No image selected");
            return;
        }
        
        // Create a unique filename
        String fileName = PRODUCT_IMAGES_PATH + UUID.randomUUID().toString() + ".jpg";
        StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(fileName);
        
        // Upload the image
        UploadTask uploadTask = storageRef.putFile(imageUri);
        
        uploadTask.addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                // Get the download URL
                storageRef.getDownloadUrl().addOnSuccessListener(new OnSuccessListener<Uri>() {
                    @Override
                    public void onSuccess(Uri downloadUri) {
                        callback.onSuccess(downloadUri.toString());
                    }
                }).addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        callback.onFailure("Failed to get download URL: " + e.getMessage());
                    }
                });
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                callback.onFailure("Upload failed: " + e.getMessage());
            }
        });
    }
    
    /**
     * Delete an image from Firebase Storage
     * @param imageUrl URL of the image to delete
     * @param callback Callback for success/failure
     */
    public static void deleteImage(String imageUrl, UploadCallback callback) {
        if (imageUrl == null || imageUrl.isEmpty()) {
            callback.onFailure("Invalid image URL");
            return;
        }
        
        try {
            StorageReference storageRef = FirebaseStorage.getInstance().getReferenceFromUrl(imageUrl);
            storageRef.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    callback.onSuccess("Image deleted successfully");
                }
            }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    callback.onFailure("Failed to delete image: " + e.getMessage());
                }
            });
        } catch (Exception e) {
            callback.onFailure("Invalid image URL format");
        }
    }
}
