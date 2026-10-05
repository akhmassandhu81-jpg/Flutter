package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        FirebaseUtil.usersRef().child(user.getUid()).child("role")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        String role = snapshot.getValue(String.class);
                        if (role == null) role = "user";

                        Intent intent;
                        // TEMPORARY: Force all users to MainActivity for testing
                        // Remove this block after testing
                        intent = new Intent(SplashActivity.this, com.example.ecomerceapp.MainActivity.class);

                        /* Original logic - uncomment after testing
                        if ("admin".equals(role)) {
                            intent = new Intent(SplashActivity.this, AdminPanelActivity.class);
                        } else if ("moderator".equals(role)) {
                            intent = new Intent(SplashActivity.this, ModeratorDashboardActivity.class);
                        } else {
                            intent = new Intent(SplashActivity.this, com.example.ecomerceapp.MainActivity.class);
                        }
                        */
                        startActivity(intent);
                        finish();
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        startActivity(new Intent(SplashActivity.this, com.example.ecomerceapp.MainActivity.class));
                        finish();
                    }
                });
    }
}
