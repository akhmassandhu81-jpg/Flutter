package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.widget.ImageButton;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class ModeratorRegisterActivity extends AppCompatActivity {

    private TextInputEditText etFirstName;
    private TextInputEditText etLastName;
    private TextInputEditText etDomain;
    private TextInputEditText etAddress;
    private TextInputEditText etContactNumber;
    private android.widget.RadioGroup rgGender;
    private android.widget.RadioButton rbMale;
    private android.widget.RadioButton rbFemale;
    private android.widget.RadioButton rbOther;
    private ImageButton btnBack;
    private MaterialButton btnRegister;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_moderator_register);

        etFirstName = findViewById(R.id.etFirstName);
        etLastName = findViewById(R.id.etLastName);
        etDomain = findViewById(R.id.etDomain);
        etAddress = findViewById(R.id.etAddress);
        etContactNumber = findViewById(R.id.etContactNumber);
        
        rgGender = findViewById(R.id.rgGender);
        rbMale = findViewById(R.id.rbMale);
        rbFemale = findViewById(R.id.rbFemale);
        rbOther = findViewById(R.id.rbOther);
        
        btnBack = findViewById(R.id.btnBack);
        btnRegister = findViewById(R.id.btnRegister);

        btnBack.setOnClickListener(v -> finish());
        btnRegister.setOnClickListener(v -> registerModerator());
    }

    private void registerModerator() {
        String firstName = etFirstName.getText().toString().trim();
        String lastName = etLastName.getText().toString().trim();
        String domain = etDomain.getText().toString().trim();
        String address = etAddress.getText().toString().trim();
        String contactNumber = etContactNumber.getText().toString().trim();

        // Get selected gender
        String gender = "";
        int selectedGenderId = rgGender.getCheckedRadioButtonId();
        if (selectedGenderId == rbMale.getId()) {
            gender = "Male";
        } else if (selectedGenderId == rbFemale.getId()) {
            gender = "Female";
        } else if (selectedGenderId == rbOther.getId()) {
            gender = "Other";
        }

        // Validation
        if (firstName.isEmpty()) {
            Toast.makeText(this, "Please enter first name", Toast.LENGTH_SHORT).show();
            return;
        }
        if (lastName.isEmpty()) {
            Toast.makeText(this, "Please enter last name", Toast.LENGTH_SHORT).show();
            return;
        }
        if (gender.isEmpty()) {
            Toast.makeText(this, "Please select gender", Toast.LENGTH_SHORT).show();
            return;
        }
        if (domain.isEmpty()) {
            Toast.makeText(this, "Please enter domain", Toast.LENGTH_SHORT).show();
            return;
        }
        if (address.isEmpty()) {
            Toast.makeText(this, "Please enter address", Toast.LENGTH_SHORT).show();
            return;
        }
        if (contactNumber.isEmpty()) {
            Toast.makeText(this, "Please enter contact number", Toast.LENGTH_SHORT).show();
            return;
        }

        // Get current user
        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Get registration date
        String registrationDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());

        // Create moderator data
        Map<String, Object> moderatorData = new HashMap<>();
        moderatorData.put("firstName", firstName);
        moderatorData.put("lastName", lastName);
        moderatorData.put("gender", gender);
        moderatorData.put("domain", domain);
        moderatorData.put("address", address);
        moderatorData.put("contactNumber", contactNumber);
        moderatorData.put("registrationDate", registrationDate);
        moderatorData.put("role", "moderator");
        moderatorData.put("email", user.getEmail());

        // Save to Firebase
        DatabaseReference userRef = FirebaseUtil.usersRef().child(user.getUid());
        userRef.updateChildren(moderatorData)
                .addOnSuccessListener(unused -> {
                    Toast.makeText(this, "Moderator registration successful", Toast.LENGTH_SHORT).show();
                    finish();
                })
                .addOnFailureListener(e -> {
                    Toast.makeText(this, "Registration failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
    }
}
