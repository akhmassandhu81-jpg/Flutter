package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.databinding.ActivityRegisterBinding;
import com.example.ecomerceapp.models.UserModel;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.InputValidator;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class RegisterActivity extends AppCompatActivity {

    private ActivityRegisterBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRegisterBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        binding.btnRegister.setOnClickListener(v -> doRegister());
        binding.tvGoLogin.setOnClickListener(v -> {
            startActivity(new Intent(RegisterActivity.this, LoginActivity.class));
            finish();
        });
        binding.btnClose.setOnClickListener(v -> finish());
    }

    private void doRegister() {
        String firstName = binding.etFirstName.getText().toString().trim();
        String lastName = binding.etLastName.getText().toString().trim();
        String email = binding.etEmail.getText().toString().trim();
        String password = binding.etPassword.getText().toString().trim();
        String confirm = binding.etConfirmPassword.getText().toString().trim();
        String contact = binding.etContact.getText().toString().trim();
        String address = binding.etAddress.getText().toString().trim();

        // Get gender
        String gender;
        if (binding.rbMale.isChecked()) {
            gender = "Male";
        } else if (binding.rbFemale.isChecked()) {
            gender = "Female";
        } else {
            gender = "Other";
        }

        // Use InputValidator for comprehensive validation
        String fullName = firstName + " " + lastName;
        InputValidator.ValidationResult validation = InputValidator.validateSignup(fullName, email, password, contact);
        
        if (!validation.isValid) {
            binding.tvError.setText(validation.errorMessage);
            binding.tvError.setVisibility(View.VISIBLE);
            
            // Set specific field errors
            if (!InputValidator.isValidName(firstName)) {
                binding.etFirstName.setError("Invalid first name");
            }
            if (!InputValidator.isValidName(lastName)) {
                binding.etLastName.setError("Invalid last name");
            }
            if (!InputValidator.isValidEmail(email)) {
                binding.etEmail.setError("Invalid email");
            }
            if (!InputValidator.isStrongPassword(password)) {
                binding.etPassword.setError("Password must be at least 8 characters and include uppercase, lowercase, and a number");
            }
            if (!TextUtils.isEmpty(contact) && !InputValidator.isValidPhone(contact)) {
                binding.etContact.setError("Invalid phone number");
            }
            return;
        }

        // Password confirmation check
        if (!password.equals(confirm)) {
            binding.etConfirmPassword.setError("Passwords do not match");
            return;
        }

        // Sanitize inputs before sending to Firebase
        String sanitizedFirstName = InputValidator.sanitizeInput(firstName);
        String sanitizedLastName = InputValidator.sanitizeInput(lastName);
        String sanitizedEmail = InputValidator.sanitizeInput(email);
        String sanitizedPassword = InputValidator.sanitizeInput(password);
        String sanitizedContact = InputValidator.sanitizeInput(contact);
        String sanitizedAddress = InputValidator.sanitizeInput(address);

        setLoading(true);
        FirebaseUtil.auth().createUserWithEmailAndPassword(sanitizedEmail, sanitizedPassword)
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful() || task.getResult() == null || task.getResult().getUser() == null) {
                        setLoading(false);
                        binding.tvError.setText(task.getException() != null ? task.getException().getMessage() : "Registration failed");
                        binding.tvError.setVisibility(View.VISIBLE);
                        return;
                    }

                    String uid = task.getResult().getUser().getUid();
                    String dateOfRegistration = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());
                    
                    // Create full user model with all profile fields
                    UserModel model = new UserModel(uid, sanitizedEmail, "user", sanitizedFirstName, sanitizedLastName, 
                            gender, sanitizedAddress, sanitizedContact, dateOfRegistration);
                    FirebaseUtil.usersRef().child(uid).setValue(model)
                            .addOnCompleteListener(saveTask -> {
                                setLoading(false);
                                if (saveTask.isSuccessful()) {
                                    startActivity(new Intent(RegisterActivity.this, com.example.ecomerceapp.MainActivity.class));
                                    finish();
                                } else {
                                    String error = saveTask.getException() != null
                                        ? saveTask.getException().getMessage()
                                        : "Failed to save user data";
                                    binding.tvError.setText("Error: " + error);
                                    binding.tvError.setVisibility(View.VISIBLE);
                                }
                            })
                            .addOnFailureListener(e -> {
                                setLoading(false);
                                binding.tvError.setText("Database Error: " + e.getMessage());
                                binding.tvError.setVisibility(View.VISIBLE);
                            });
                })
                .addOnFailureListener(e -> {
                    setLoading(false);
                    binding.tvError.setText("Auth Error: " + e.getMessage());
                    binding.tvError.setVisibility(View.VISIBLE);
                });
    }

    private void setLoading(boolean loading) {
        binding.progress.setVisibility(loading ? View.VISIBLE : View.GONE);
        binding.btnRegister.setEnabled(!loading);
        if (loading) {
            binding.tvError.setVisibility(View.GONE);
        }
    }
}
