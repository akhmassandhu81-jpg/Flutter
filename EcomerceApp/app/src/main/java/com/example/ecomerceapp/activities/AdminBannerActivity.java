package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.view.View;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.databinding.ActivityAdminBannerBinding;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

public class AdminBannerActivity extends AppCompatActivity {

    private ActivityAdminBannerBinding binding;
    private Uri selectedImageUri;
    private ActivityResultLauncher<Intent> imagePickerLauncher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminBannerBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Setup image picker
        imagePickerLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                        selectedImageUri = result.getData().getData();
                        showSelectedImage();
                    }
                }
        );

        loadCurrentBanner();
        setupClickListeners();
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());

        binding.btnSelectImage.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            imagePickerLauncher.launch(intent);
        });

        binding.btnUpload.setOnClickListener(v -> {
            if (selectedImageUri == null) {
                Toast.makeText(this, "Please select an image first", Toast.LENGTH_SHORT).show();
                return;
            }
            uploadBanner();
        });
    }

    private void showSelectedImage() {
        binding.imgSelected.setVisibility(View.VISIBLE);
        binding.imgSelected.setImageURI(selectedImageUri);
    }

    private void loadCurrentBanner() {
        FirebaseUtil.db().child("banner").child("imageUrl")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        String imageUrl = snapshot.getValue(String.class);
                        if (imageUrl != null && !imageUrl.isEmpty()) {
                            binding.tvNoBanner.setVisibility(View.GONE);
                            Glide.with(AdminBannerActivity.this)
                                    .load(imageUrl)
                                    .into(binding.imgCurrentBanner);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                    }
                });
    }

    private void uploadBanner() {
        binding.progress.setVisibility(View.VISIBLE);
        binding.btnUpload.setEnabled(false);

        try {
            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), selectedImageUri);

            // Resize to reasonable dimensions
            int maxSize = 800;
            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            if (width > maxSize || height > maxSize) {
                float scale = Math.min((float) maxSize / width, (float) maxSize / height);
                width = (int) (width * scale);
                height = (int) (height * scale);
                bitmap = Bitmap.createScaledBitmap(bitmap, width, height, true);
            }

            // Convert to base64
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 80, baos);
            byte[] imageBytes = baos.toByteArray();
            String base64Image = Base64.encodeToString(imageBytes, Base64.DEFAULT);

            // Save to Firebase
            FirebaseUtil.db().child("banner").child("imageUrl").setValue(base64Image)
                    .addOnSuccessListener(aVoid -> {
                        binding.progress.setVisibility(View.GONE);
                        binding.btnUpload.setEnabled(true);
                        Toast.makeText(this, "Banner uploaded successfully!", Toast.LENGTH_SHORT).show();
                        finish();
                    })
                    .addOnFailureListener(e -> {
                        binding.progress.setVisibility(View.GONE);
                        binding.btnUpload.setEnabled(true);
                        Toast.makeText(this, "Failed to upload: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    });

        } catch (IOException e) {
            binding.progress.setVisibility(View.GONE);
            binding.btnUpload.setEnabled(true);
            Toast.makeText(this, "Error processing image", Toast.LENGTH_SHORT).show();
        }
    }
}
