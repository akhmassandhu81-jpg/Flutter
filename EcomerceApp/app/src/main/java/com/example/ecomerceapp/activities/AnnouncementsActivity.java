package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.AnnouncementAdapter;
import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class AnnouncementsActivity extends AppCompatActivity {

    private RecyclerView rvAnnouncements;
    private ProgressBar progressBar;
    private View tvEmpty;

    private AnnouncementAdapter adapter;
    private List<Announcement> announcementList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_announcements);

        initViews();
        setupRecyclerView();
        loadAnnouncements();

        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
    }

    private void initViews() {
        rvAnnouncements = findViewById(R.id.rvAnnouncements);
        progressBar = findViewById(R.id.progressBar);
        tvEmpty = findViewById(R.id.tvEmpty);
    }

    private void setupRecyclerView() {
        adapter = new AnnouncementAdapter(this, announcementList, null);
        rvAnnouncements.setLayoutManager(new LinearLayoutManager(this));
        rvAnnouncements.setAdapter(adapter);
    }

    private void loadAnnouncements() {
        progressBar.setVisibility(View.VISIBLE);
        FirebaseUtil.announcementsRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                progressBar.setVisibility(View.GONE);
                announcementList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Announcement announcement = data.getValue(Announcement.class);
                    if (announcement != null && announcement.isActive()) {
                        announcement.setId(data.getKey());
                        announcementList.add(announcement);
                    }
                }

                // Sort by timestamp (newest first)
                Collections.sort(announcementList, new Comparator<Announcement>() {
                    @Override
                    public int compare(Announcement a1, Announcement a2) {
                        String t1 = a1.getTimestamp() != null ? a1.getTimestamp() : "";
                        String t2 = a2.getTimestamp() != null ? a2.getTimestamp() : "";
                        return t2.compareTo(t1);
                    }
                });

                adapter.submit(announcementList);
                tvEmpty.setVisibility(announcementList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progressBar.setVisibility(View.GONE);
                tvEmpty.setVisibility(View.VISIBLE);
            }
        });
    }
}
