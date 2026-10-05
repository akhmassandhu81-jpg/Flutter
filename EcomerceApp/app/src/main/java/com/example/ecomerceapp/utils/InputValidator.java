package com.example.ecomerceapp.utils;

import android.text.TextUtils;
import android.util.Patterns;

import java.util.regex.Pattern;

/**
 * Utility class for input validation and injection prevention.
 * Ensures clean, safe data before sending to Firebase.
 */
public class InputValidator {

    // Suspicious patterns that could indicate injection attempts
    private static final String[] SUSPICIOUS_PATTERNS = {
        "'", "\"", ";", "--", "/*", "*/", "xp_", "union", "select", "insert",
        "delete", "drop", "update", "exec", "script", "javascript:", "<script",
        "</script>", "onerror", "onload", "onclick", "eval(", "expression("
    };

    /**
     * Validates email format
     * @param email Email to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidEmail(String email) {
        if (TextUtils.isEmpty(email)) {
            return false;
        }
        return Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }

    /**
     * Validates password strength
     * @param password Password to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPassword(String password) {
        if (TextUtils.isEmpty(password)) {
            return false;
        }
        // Minimum 6 characters
        return password.length() >= 6;
    }

    /**
     * Validates strong password requirements
     * Password must:
     * - Be at least 8 characters long
     * - Contain at least 1 uppercase letter (A-Z)
     * - Contain at least 1 lowercase letter (a-z)
     * - Contain at least 1 number (0-9)
     * @param password Password to validate
     * @return true if strong, false otherwise
     */
    public static boolean isStrongPassword(String password) {
        if (TextUtils.isEmpty(password)) {
            return false;
        }
        
        // At least 8 characters
        if (password.length() < 8) {
            return false;
        }
        
        // At least 1 uppercase letter
        if (!password.matches(".*[A-Z].*")) {
            return false;
        }
        
        // At least 1 lowercase letter
        if (!password.matches(".*[a-z].*")) {
            return false;
        }
        
        // At least 1 number
        if (!password.matches(".*[0-9].*")) {
            return false;
        }
        
        return true;
    }

    /**
     * Validates phone number format (basic)
     * @param phone Phone number to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPhone(String phone) {
        if (TextUtils.isEmpty(phone)) {
            return false;
        }
        // Allow digits, spaces, +, -, (, )
        String phonePattern = "^[+]?[0-9\\s\\-\\(\\)]{10,20}$";
        return Pattern.matches(phonePattern, phone);
    }

    /**
     * Checks if input contains suspicious patterns (injection prevention)
     * @param input Input to check
     * @return true if safe, false if suspicious pattern detected
     */
    public static boolean isSafeTextInput(String input) {
        if (TextUtils.isEmpty(input)) {
            return true; // Empty is safe (handled separately)
        }

        String lowerInput = input.toLowerCase();
        
        for (String pattern : SUSPICIOUS_PATTERNS) {
            if (lowerInput.contains(pattern.toLowerCase())) {
                return false;
            }
        }
        
        return true;
    }

    /**
     * Sanitizes text input by removing harmful characters
     * @param input Input to sanitize
     * @return Sanitized input
     */
    public static String sanitizeInput(String input) {
        if (TextUtils.isEmpty(input)) {
            return input;
        }
        
        // Trim whitespace
        String sanitized = input.trim();
        
        // Remove potentially harmful characters (basic sanitization)
        sanitized = sanitized.replaceAll("'", "");
        sanitized = sanitized.replaceAll("\"", "");
        sanitized = sanitized.replaceAll(";", "");
        sanitized = sanitized.replaceAll("--", "");
        
        return sanitized;
    }

    /**
     * Validates name (letters, spaces, hyphens, apostrophes allowed)
     * @param name Name to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidName(String name) {
        if (TextUtils.isEmpty(name)) {
            return false;
        }
        // Allow letters, spaces, hyphens, apostrophes
        String namePattern = "^[a-zA-Z\\s\\-']{2,50}$";
        return Pattern.matches(namePattern, name);
    }

    /**
     * Validates address (basic validation)
     * @param address Address to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidAddress(String address) {
        if (TextUtils.isEmpty(address)) {
            return false;
        }
        // Allow alphanumeric, spaces, commas, periods, hyphens
        String addressPattern = "^[a-zA-Z0-9\\s,\\.\\-]{5,100}$";
        return Pattern.matches(addressPattern, address);
    }

    /**
     * Validates input length
     * @param input Input to validate
     * @param minLength Minimum length
     * @param maxLength Maximum length
     * @return true if within range, false otherwise
     */
    public static boolean isValidLength(String input, int minLength, int maxLength) {
        if (TextUtils.isEmpty(input)) {
            return false;
        }
        int length = input.length();
        return length >= minLength && length <= maxLength;
    }

    /**
     * Comprehensive validation for login
     * @param email Email to validate
     * @param password Password to validate
     * @return ValidationResult with error message if invalid
     */
    public static ValidationResult validateLogin(String email, String password) {
        if (TextUtils.isEmpty(email)) {
            return new ValidationResult(false, "Email is required");
        }
        
        if (!isValidEmail(email)) {
            return new ValidationResult(false, "Invalid email format");
        }
        
        if (TextUtils.isEmpty(password)) {
            return new ValidationResult(false, "Password is required");
        }
        
        if (!isValidPassword(password)) {
            return new ValidationResult(false, "Password must be at least 6 characters");
        }
        
        if (!isSafeTextInput(email) || !isSafeTextInput(password)) {
            return new ValidationResult(false, "Suspicious input detected");
        }
        
        return new ValidationResult(true, null);
    }

    /**
     * Comprehensive validation for signup
     * @param name Name to validate
     * @param email Email to validate
     * @param password Password to validate
     * @param phone Phone to validate
     * @return ValidationResult with error message if invalid
     */
    public static ValidationResult validateSignup(String name, String email, String password, String phone) {
        if (TextUtils.isEmpty(name)) {
            return new ValidationResult(false, "Name is required");
        }
        
        if (!isValidName(name)) {
            return new ValidationResult(false, "Invalid name format");
        }
        
        if (TextUtils.isEmpty(email)) {
            return new ValidationResult(false, "Email is required");
        }
        
        if (!isValidEmail(email)) {
            return new ValidationResult(false, "Invalid email format");
        }
        
        if (TextUtils.isEmpty(password)) {
            return new ValidationResult(false, "Password is required");
        }
        
        if (!isStrongPassword(password)) {
            return new ValidationResult(false, "Password must be at least 8 characters and include uppercase, lowercase, and a number");
        }
        
        if (!TextUtils.isEmpty(phone) && !isValidPhone(phone)) {
            return new ValidationResult(false, "Invalid phone number format");
        }
        
        if (!isSafeTextInput(name) || !isSafeTextInput(email) || 
            !isSafeTextInput(password) || !isSafeTextInput(phone)) {
            return new ValidationResult(false, "Suspicious input detected");
        }
        
        return new ValidationResult(true, null);
    }

    /**
     * Result class for validation operations
     */
    public static class ValidationResult {
        public final boolean isValid;
        public final String errorMessage;

        public ValidationResult(boolean isValid, String errorMessage) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }
    }
}
