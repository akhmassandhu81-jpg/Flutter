package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.UserListAdapter;
import com.example.ecomerceapp.models.UserModel;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.android.material.appbar.MaterialToolbar;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class AdminUserListActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private UserListAdapter adapter;
    private ProgressBar progress;
    private TextView tvEmpty;
    private MaterialToolbar toolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_user_list);

        toolbar = findViewById(R.id.toolbar);
        recyclerView = findViewById(R.id.recyclerView);
        progress = findViewById(R.id.progress);
        tvEmpty = findViewById(R.id.tvEmpty);

        toolbar.setNavigationOnClickListener(v -> finish());

        setupRecyclerView();
        loadUsers();
    }

    private void setupRecyclerView() {
        adapter = new UserListAdapter();
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(adapter);
    }

    private void loadUsers() {
        progress.setVisibility(View.VISIBLE);
        tvEmpty.setVisibility(View.GONE);

        try {
            FirebaseUtil.usersRef().addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    progress.setVisibility(View.GONE);
                    
                    List<UserModel> users = new ArrayList<>();
                    if (snapshot != null && snapshot.exists()) {
                        for (DataSnapshot child : snapshot.getChildren()) {
                            try {
                                UserModel user = child.getValue(UserModel.class);
                                if (user != null) {
                                    user.setUid(child.getKey());
                                    users.add(user);
                                }
                            } catch (Exception e) {
                                // Skip malformed user data
                                continue;
                            }
                        }
                    }

                    if (users.isEmpty()) {
                        tvEmpty.setText("No users found");
                        tvEmpty.setVisibility(View.VISIBLE);
                    } else {
                        tvEmpty.setVisibility(View.GONE);
                    }

                    adapter.submitList(users);
                }

                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    progress.setVisibility(View.GONE);
                    tvEmpty.setText("Error loading users: " + (error != null ? error.getMessage() : "Unknown error"));
                    tvEmpty.setVisibility(View.VISIBLE);
                }
            });
        } catch (Exception e) {
            progress.setVisibility(View.GONE);
            tvEmpty.setText("Error: " + e.getMessage());
            tvEmpty.setVisibility(View.VISIBLE);
        }
    }
}
