package com.example.ecomerceapp.activities;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.databinding.ActivityAdminProductFormBinding;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.models.Vendor;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.StorageReference;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

public class AdminProductFormActivity extends AppCompatActivity {

    private ActivityAdminProductFormBinding binding;
    private Uri selectedImageUri;
    private Uri cameraImageUri;

    private String editingProductId;
    private String existingImageUrl;
    private String selectedCategory;
    private String selectedVendorId;
    private String selectedVendorName;
    
    private final String[] categories = {"Electronics", "Sports", "Food", "Fashion and Clothing"};
    private List<Vendor> vendorList = new ArrayList<>();

    private final ActivityResultLauncher<String> requestCameraPermission =
            registerForActivityResult(new ActivityResultContracts.RequestPermission(), granted -> {
                if (granted) {
                    openCamera();
                }
            });

    private final ActivityResultLauncher<Intent> pickImageLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                    selectedImageUri = result.getData().getData();
                    if (selectedImageUri != null) {
                        try {
                            getContentResolver().takePersistableUriPermission(selectedImageUri,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION);
                        } catch (Exception ignored) {
                        }
                        showSelectedImage(selectedImageUri);
                    }
                }
            });

    private final ActivityResultLauncher<Intent> cameraLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK) {
                    if (cameraImageUri != null) {
                        selectedImageUri = cameraImageUri;
                        showSelectedImage(selectedImageUri);
                    }
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminProductFormBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        editingProductId = getIntent().getStringExtra("productId");

        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnPickImage.setOnClickListener(v -> showImagePickerDialog());
        binding.btnSave.setOnClickListener(v -> saveProduct());

        // Setup category spinner
        setupCategorySpinner();

        // Setup vendor spinner
        setupVendorSpinner();

        if (!TextUtils.isEmpty(editingProductId)) {
            binding.tvTitle.setText("Update Product");
            loadProduct();
        } else {
            binding.tvTitle.setText("Add Product");
        }
    }
    
    private void setupCategorySpinner() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, categories);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        binding.spinnerCategory.setAdapter(adapter);
        
        binding.spinnerCategory.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(android.widget.AdapterView<?> parent, View view, int position, long id) {
                selectedCategory = categories[position];
            }
            
            @Override
            public void onNothingSelected(android.widget.AdapterView<?> parent) {
                selectedCategory = categories[0];
            }
        });
    }

    private void setupVendorSpinner() {
        // Load vendors from Firebase
        FirebaseUtil.vendorsRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                vendorList.clear();
                List<String> vendorNames = new ArrayList<>();
                vendorNames.add("Select Vendor");
                
                for (DataSnapshot data : snapshot.getChildren()) {
                    Vendor vendor = data.getValue(Vendor.class);
                    if (vendor != null && "Active".equals(vendor.getStatus())) {
                        vendor.setVendorId(data.getKey());
                        vendorList.add(vendor);
                        String displayName = vendor.getFirstName() + " " + vendor.getLastName() + 
                                           " (" + vendor.getShopName() + ")";
                        vendorNames.add(displayName);
                    }
                }
                
                ArrayAdapter<String> adapter = new ArrayAdapter<>(AdminProductFormActivity.this, 
                    android.R.layout.simple_spinner_item, vendorNames);
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                binding.spinnerVendor.setAdapter(adapter);
                
                binding.spinnerVendor.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(android.widget.AdapterView<?> parent, View view, int position, long id) {
                        if (position == 0) {
                            selectedVendorId = null;
                            selectedVendorName = null;
                        } else {
                            Vendor vendor = vendorList.get(position - 1);
                            selectedVendorId = vendor.getVendorId();
                            selectedVendorName = vendor.getFirstName() + " " + vendor.getLastName();
                        }
                    }
                    
                    @Override
                    public void onNothingSelected(android.widget.AdapterView<?> parent) {
                        selectedVendorId = null;
                        selectedVendorName = null;
                    }
                });
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(AdminProductFormActivity.this, "Error loading vendors: " + error.getMessage(), 
                    Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadProduct() {
        setLoading(true);
        FirebaseUtil.productsRef().child(editingProductId)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        setLoading(false);
                        Product p = snapshot.getValue(Product.class);
                        if (p == null) return;

                        binding.etName.setText(p.getName());
                        binding.etPrice.setText(trimDouble(p.getPrice()));
                        binding.etQuantity.setText(String.valueOf(p.getQuantity()));
                        binding.etDescription.setText(p.getDescription() != null ? p.getDescription() : "");
                        existingImageUrl = p.getImageUrl();

                        if (!TextUtils.isEmpty(existingImageUrl)) {
                            Glide.with(AdminProductFormActivity.this)
                                    .load(existingImageUrl)
                                    .centerCrop()
                                    .into(binding.ivPreview);
                        }
                        
                        // Restore category selection
                        if (p.getCategory() != null) {
                            for (int i = 0; i < categories.length; i++) {
                                if (categories[i].equals(p.getCategory())) {
                                    binding.spinnerCategory.setSelection(i);
                                    selectedCategory = categories[i];
                                    break;
                                }
                            }
                        }

                        // Restore vendor selection
                        if (p.getVendorId() != null) {
                            selectedVendorId = p.getVendorId();
                            selectedVendorName = p.getVendorName();
                            // Find and select vendor in spinner
                            for (int i = 0; i < vendorList.size(); i++) {
                                if (vendorList.get(i).getVendorId().equals(p.getVendorId())) {
                                    binding.spinnerVendor.setSelection(i + 1); // +1 because of "Select Vendor" placeholder
                                    break;
                                }
                            }
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        setLoading(false);
                    }
                });
    }

    private void showImagePickerDialog() {
        String[] items = new String[]{"Camera", "Gallery"};
        new AlertDialog.Builder(this)
                .setTitle("Select Image")
                .setItems(items, (d, which) -> {
                    if (which == 0) {
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                            requestCameraPermission.launch(Manifest.permission.CAMERA);
                        } else {
                            openCamera();
                        }
                    } else {
                        openGallery();
                    }
                })
                .show();
    }

    private void openGallery() {
        Intent i = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("image/*");
        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        i.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
        pickImageLauncher.launch(i);
    }

    private void openCamera() {
        try {
            File imageFile = File.createTempFile("product_", ".jpg", getCacheDir());
            cameraImageUri = FileProvider.getUriForFile(this, "com.example.ecomerceapp.fileprovider", imageFile);
            Intent i = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
            i.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, cameraImageUri);
            i.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            cameraLauncher.launch(i);
        } catch (Exception e) {
            // ignore
        }
    }

    private void showSelectedImage(Uri uri) {
        Glide.with(this)
                .load(uri)
                .centerCrop()
                .into(binding.ivPreview);
    }

    private void saveProduct() {
        String name = binding.etName.getText().toString().trim();
        String priceStr = binding.etPrice.getText().toString().trim();
        String quantityStr = binding.etQuantity.getText().toString().trim();
        String description = binding.etDescription.getText().toString().trim();

        if (TextUtils.isEmpty(name)) {
            binding.etName.setError("Required");
            return;
        }
        if (TextUtils.isEmpty(priceStr)) {
            binding.etPrice.setError("Required");
            return;
        }
        if (TextUtils.isEmpty(quantityStr)) {
            binding.etQuantity.setError("Required");
            return;
        }

        // Validate vendor selection
        if (TextUtils.isEmpty(selectedVendorId)) {
            Toast.makeText(this, "Please select a vendor", Toast.LENGTH_SHORT).show();
            return;
        }

        double price;
        int quantity;
        try {
            price = Double.parseDouble(priceStr);
        } catch (Exception e) {
            binding.etPrice.setError("Invalid price");
            return;
        }

        try {
            quantity = Integer.parseInt(quantityStr);
        } catch (Exception e) {
            binding.etQuantity.setError("Invalid quantity");
            return;
        }

        if (quantity < 0) {
            binding.etQuantity.setError("Quantity must be >= 0");
            return;
        }

        setLoading(true);

        final String productId;
        if (TextUtils.isEmpty(editingProductId)) {
            productId = FirebaseUtil.productsRef().push().getKey();
        } else {
            productId = editingProductId;
        }

        if (TextUtils.isEmpty(productId)) {
            setLoading(false);
            return;
        }

        if (selectedImageUri != null) {
            uploadImageAndSave(productId, name, price, quantity, description, selectedImageUri);
        } else {
            String imageUrl = existingImageUrl;
            if (TextUtils.isEmpty(imageUrl) && TextUtils.isEmpty(editingProductId)) {
                setLoading(false);
                binding.btnPickImage.setText("Select Image (Required)");
                Toast.makeText(this, "Please select an image for the product", Toast.LENGTH_LONG).show();
                return;
            }
            
            // Get date added (use existing or current date)
            String dateAdded = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());

            // Create product with full fields including category and vendor
            // Set status = "pending" for moderator approval
            Product model = new Product(productId, name, price, quantity, imageUrl,
                    selectedCategory, null, dateAdded, null, "pending");
            model.setVendorId(selectedVendorId);
            model.setVendorName(selectedVendorName);
            model.setDescription(description);
            model.setSold(0); // Initialize sold count to 0 for new products
            FirebaseUtil.productsRef().child(productId).setValue(model)
                    .addOnCompleteListener(t -> {
                        setLoading(false);
                        if (t.isSuccessful()) {
                            finish();
                        } else {
                            String err = t.getException() != null ? t.getException().getMessage() : "Save failed";
                            Toast.makeText(this, err, Toast.LENGTH_LONG).show();
                        }
                    });
        }
    }

    private void uploadImageAndSave(String productId, String name, double price, int quantity, String description, Uri uri) {
        // Check if user is authenticated
        if (FirebaseUtil.auth().getCurrentUser() == null) {
            setLoading(false);
            Toast.makeText(this, "Error: User not authenticated. Please login again.", Toast.LENGTH_LONG).show();
            return;
        }

        // Convert image to base64 (no Firebase Storage needed)
        String base64Image = convertImageToBase64(uri);
        if (base64Image == null) {
            setLoading(false);
            Toast.makeText(this, "Error: Could not process image. Try a smaller image.", Toast.LENGTH_LONG).show();
            return;
        }

        // Save product with base64 image directly in Realtime Database
        String dateAdded = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());
        // Set status = "pending" for moderator approval
        Product model = new Product(productId, name, price, quantity, base64Image,
                selectedCategory, null, dateAdded, null, "pending");
        model.setVendorId(selectedVendorId);
        model.setVendorName(selectedVendorName);
        model.setDescription(description);
        model.setSold(0); // Initialize sold count to 0 for new products
        FirebaseUtil.productsRef().child(productId).setValue(model)
                .addOnCompleteListener(t -> {
                    setLoading(false);
                    if (t.isSuccessful()) {
                        Toast.makeText(this, "Product saved successfully!", Toast.LENGTH_SHORT).show();
                        finish();
                    } else {
                        String err = t.getException() != null ? t.getException().getMessage() : "Save failed";
                        Toast.makeText(this, "Database error: " + err, Toast.LENGTH_LONG).show();
                    }
                });
    }

    private String convertImageToBase64(Uri uri) {
        try {
            // Load and resize image to reduce size
            InputStream inputStream = getContentResolver().openInputStream(uri);
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inSampleSize = 2; // Reduce size by half
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream, null, options);
            if (inputStream != null) inputStream.close();
            
            if (bitmap == null) return null;
            
            // Compress and convert to base64
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 70, outputStream); // 70% quality
            byte[] imageBytes = outputStream.toByteArray();
            
            // Convert to base64
            String base64String = Base64.encodeToString(imageBytes, Base64.DEFAULT);
            
            // Add data URI prefix for Glide compatibility
            return "data:image/jpeg;base64," + base64String;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void setLoading(boolean loading) {
        binding.progress.setVisibility(loading ? View.VISIBLE : View.GONE);
        binding.btnSave.setEnabled(!loading);
        binding.btnPickImage.setEnabled(!loading);
    }

    private String trimDouble(double v) {
        DecimalFormat df = new DecimalFormat("0.##");
        return df.format(v);
    }
}
