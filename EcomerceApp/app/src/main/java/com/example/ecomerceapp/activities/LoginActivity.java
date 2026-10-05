
package com.example.ecomerceapp.activities;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.InputValidator;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthInvalidUserException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseAuthWeakPasswordException;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.Random;

    public class LoginActivity extends AppCompatActivity {

        private EditText etEmail;
        private EditText etPassword;
        private EditText etCaptcha;
        private TextView tvCaptcha;
        private ImageButton btnRefreshCaptcha;
        private Button btnLogin;
        private ProgressBar progress;
        private TextView tvError;
        private TextView tvGoRegister;
        private TextView tvForgotPassword;

        private String generatedCaptcha;
        private final Random random = new Random();

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_login);

            etEmail = findViewById(R.id.etEmail);
            etPassword = findViewById(R.id.etPassword);
            etCaptcha = findViewById(R.id.etCaptcha);
            tvCaptcha = findViewById(R.id.tvCaptcha);
            btnRefreshCaptcha = findViewById(R.id.btnRefreshCaptcha);
            btnLogin = findViewById(R.id.btnLogin);
            progress = findViewById(R.id.progress);
            tvError = findViewById(R.id.tvError);
            tvGoRegister = findViewById(R.id.tvGoRegister);
            tvForgotPassword = findViewById(R.id.tvForgotPassword);

            // Generate initial captcha
            generateCaptcha();

            btnRefreshCaptcha.setOnClickListener(v -> generateCaptcha());
            btnLogin.setOnClickListener(v -> doLogin());
            tvGoRegister.setOnClickListener(v -> {
                startActivity(new Intent(com.example.ecomerceapp.activities.LoginActivity.this, RegisterActivity.class));
                finish();
            });
            tvForgotPassword.setOnClickListener(v -> {
                Toast.makeText(this, "Forgot Password feature coming soon", Toast.LENGTH_SHORT).show();
            });
        }

        private void doLogin() {
            String email = etEmail.getText().toString().trim();
            String password = etPassword.getText().toString().trim();
            String captchaInput = etCaptcha.getText().toString().trim();

            // Validate CAPTCHA first
            if (TextUtils.isEmpty(captchaInput)) {
                etCaptcha.setError("Enter captcha");
                return;
            }

            // Validate CAPTCHA (case-insensitive)
            if (!captchaInput.equalsIgnoreCase(generatedCaptcha)) {
                showError("Invalid captcha. Please try again.");
                etCaptcha.setText("");
                generateCaptcha(); // Auto-refresh on wrong attempt
                return;
            }

            // Use InputValidator for comprehensive validation
            InputValidator.ValidationResult validation = InputValidator.validateLogin(email, password);
            if (!validation.isValid) {
                showError(validation.errorMessage);
                if (!InputValidator.isValidEmail(email)) {
                    etEmail.setError("Invalid email");
                }
                if (!InputValidator.isValidPassword(password)) {
                    etPassword.setError("Invalid password");
                }
                return;
            }

            // Sanitize inputs before sending to Firebase
            String sanitizedEmail = InputValidator.sanitizeInput(email);
            String sanitizedPassword = InputValidator.sanitizeInput(password);

            // Check network connectivity before attempting login
            if (!isNetworkAvailable()) {
                showError("No internet connection. Please check your network.");
                return;
            }

            setLoading(true);

            // Firebase authentication only - no extra DB calls during login
            FirebaseUtil.auth().signInWithEmailAndPassword(sanitizedEmail, sanitizedPassword)
                    .addOnCompleteListener(task -> {
                        if (!task.isSuccessful()) {
                            setLoading(false);
                            handleLoginError(task.getException());
                            return;
                        }

                        // Authentication successful - now check role for navigation
                        String userId = task.getResult().getUser().getUid();
                        FirebaseUtil.usersRef().child(userId).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot snapshot) {
                                setLoading(false);
                                String role = snapshot.child("role").getValue(String.class);
                                navigateBasedOnRole(role);
                            }

                            @Override
                            public void onCancelled(@NonNull DatabaseError error) {
                                setLoading(false);
                                // If role check fails, default to MainActivity
                                showError("Login successful. Proceeding to home...");
                                navigateBasedOnRole(null);
                            }
                        });
                    });
        }

        private void generateCaptcha() {
            // Generate random 6-character captcha
            String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            StringBuilder captcha = new StringBuilder();
            for (int i = 0; i < 6; i++) {
                captcha.append(chars.charAt(random.nextInt(chars.length())));
            }
            generatedCaptcha = captcha.toString();

            // Display captcha with slight styling
            tvCaptcha.setText(generatedCaptcha);
            tvCaptcha.setTypeface(Typeface.DEFAULT_BOLD);
            tvCaptcha.setLetterSpacing(0.15f);

            // Add random color to captcha text for better visual
            int[] colors = {Color.BLACK, Color.BLUE, Color.parseColor("#009688"), Color.parseColor("#E91E63")};
            tvCaptcha.setTextColor(colors[random.nextInt(colors.length)]);
        }

        private boolean isNetworkAvailable() {
            ConnectivityManager connectivityManager =
                    (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            if (connectivityManager == null) return false;

            NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
            return activeNetworkInfo != null && activeNetworkInfo.isConnected();
        }

        private void handleLoginError(Exception exception) {
            if (exception == null) {
                showError("Login failed. Please try again.");
                return;
            }

            String errorMessage;

            try {
                if (exception instanceof FirebaseAuthInvalidUserException) {
                    errorMessage = "No account found with this email";
                } else if (exception instanceof FirebaseAuthInvalidCredentialsException) {
                    errorMessage = "Invalid email or password";
                } else if (exception instanceof FirebaseAuthUserCollisionException) {
                    errorMessage = "Email already in use";
                } else if (exception instanceof FirebaseAuthWeakPasswordException) {
                    errorMessage = "Password is too weak";
                } else {
                    errorMessage = exception.getMessage();
                    if (errorMessage == null || errorMessage.isEmpty()) {
                        errorMessage = "Login failed. Please try again.";
                    }
                }
            } catch (Exception e) {
                errorMessage = "Login failed. Please try again.";
            }

            showError(errorMessage);
        }

        private void showError(String message) {
            tvError.setText(message);
            tvError.setVisibility(View.VISIBLE);
        }

        private void navigateBasedOnRole(String role) {
            Intent intent;
            if ("admin".equals(role)) {
                intent = new Intent(com.example.ecomerceapp.activities.LoginActivity.this, AdminPanelActivity.class);
            } else if ("moderator".equals(role)) {
                intent = new Intent(com.example.ecomerceapp.activities.LoginActivity.this, ModeratorDashboardActivity.class);
            } else {
                // Default to MainActivity for regular users
                intent = new Intent(com.example.ecomerceapp.activities.LoginActivity.this, com.example.ecomerceapp.MainActivity.class);
            }

            // Clear back stack to prevent going back to login
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        }

        private void setLoading(boolean loading) {
            progress.setVisibility(loading ? View.VISIBLE : View.GONE);
            btnLogin.setEnabled(!loading);
            if (loading) {
                tvError.setVisibility(View.GONE);
            }
        }
    }


