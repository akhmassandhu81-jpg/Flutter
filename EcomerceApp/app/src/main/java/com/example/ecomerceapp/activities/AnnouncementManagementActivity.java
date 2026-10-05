package com.example.ecomerceapp.activities;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.AnnouncementAdapter;
import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class AnnouncementManagementActivity extends AppCompatActivity {

    private RecyclerView rvAnnouncements;
    private ProgressBar progressBar;
    private EditText etSearch;
    private Spinner spinnerFilter;
    private View tvEmpty;

    private AnnouncementAdapter adapter;
    private List<Announcement> announcementList = new ArrayList<>();
    private List<Announcement> filteredList = new ArrayList<>();

    private String editingAnnouncementId;

    private final String[] types = {"Offer", "Alert", "News"};
    private final String[] filterOptions = {"All", "Offer", "Alert", "News"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_announcement_management);

        initViews();
        setupRecyclerView();
        setupSearch();
        loadAnnouncements();

        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        findViewById(R.id.btnAdd).setOnClickListener(v -> showAddDialog());
    }

    private void initViews() {
        rvAnnouncements = findViewById(R.id.rvAnnouncements);
        progressBar = findViewById(R.id.progressBar);
        etSearch = findViewById(R.id.etSearch);
        spinnerFilter = findViewById(R.id.spinnerFilter);
        tvEmpty = findViewById(R.id.tvEmpty);
    }

    private void setupRecyclerView() {
        adapter = new AnnouncementAdapter(this, announcementList, new AnnouncementAdapter.Listener() {
            @Override
            public void onEdit(Announcement announcement) {
                showEditDialog(announcement);
            }

            @Override
            public void onDelete(Announcement announcement) {
                showDeleteDialog(announcement);
            }
        });
        rvAnnouncements.setLayoutManager(new LinearLayoutManager(this));
        rvAnnouncements.setAdapter(adapter);
    }

    private void setupSearch() {
        ArrayAdapter<String> filterAdapter = new ArrayAdapter<>(this, 
            android.R.layout.simple_spinner_item, filterOptions);
        filterAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerFilter.setAdapter(filterAdapter);

        etSearch.addTextChangedListener(new android.text.TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                filterAnnouncements();
            }

            @Override
            public void afterTextChanged(android.text.Editable s) {}
        });

        spinnerFilter.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(android.widget.AdapterView<?> parent, View view, int position, long id) {
                filterAnnouncements();
            }

            @Override
            public void onNothingSelected(android.widget.AdapterView<?> parent) {}
        });
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
                    if (announcement != null) {
                        announcement.setId(data.getKey());
                        announcementList.add(announcement);
                    }
                }
                filterAnnouncements();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progressBar.setVisibility(View.GONE);
                Toast.makeText(AnnouncementManagementActivity.this, 
                    "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void filterAnnouncements() {
        String query = etSearch.getText().toString().toLowerCase().trim();
        String filter = spinnerFilter.getSelectedItem().toString();

        filteredList.clear();
        for (Announcement announcement : announcementList) {
            boolean matchesQuery = announcement.getTitle().toLowerCase().contains(query) ||
                                  announcement.getMessage().toLowerCase().contains(query);
            boolean matchesFilter = filter.equals("All") || 
                                   announcement.getType().equalsIgnoreCase(filter);

            if (matchesQuery && matchesFilter) {
                filteredList.add(announcement);
            }
        }

        adapter.submit(filteredList);
        tvEmpty.setVisibility(filteredList.isEmpty() ? View.VISIBLE : View.GONE);
    }

    private void showAddDialog() {
        editingAnnouncementId = null;
        showAnnouncementDialog(null);
    }

    private void showEditDialog(Announcement announcement) {
        editingAnnouncementId = announcement.getId();
        showAnnouncementDialog(announcement);
    }

    private void showAnnouncementDialog(Announcement existingAnnouncement) {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_announcement, null);
        
        EditText etTitle = dialogView.findViewById(R.id.etTitle);
        EditText etMessage = dialogView.findViewById(R.id.etMessage);
        EditText etDiscount = dialogView.findViewById(R.id.etDiscount);
        EditText etProductName = dialogView.findViewById(R.id.etProductName);
        Spinner spinnerType = dialogView.findViewById(R.id.spinnerType);
        Button btnCancel = dialogView.findViewById(R.id.btnCancel);
        Button btnSave = dialogView.findViewById(R.id.btnSave);

        // Setup type spinner
        ArrayAdapter<String> typeAdapter = new ArrayAdapter<>(this, 
            android.R.layout.simple_spinner_item, types);
        typeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerType.setAdapter(typeAdapter);

        // Pre-fill if editing
        if (existingAnnouncement != null) {
            etTitle.setText(existingAnnouncement.getTitle());
            etMessage.setText(existingAnnouncement.getMessage());
            etDiscount.setText(existingAnnouncement.getDiscount());
            etProductName.setText(existingAnnouncement.getProductName());
            
            for (int i = 0; i < types.length; i++) {
                if (types[i].equalsIgnoreCase(existingAnnouncement.getType())) {
                    spinnerType.setSelection(i);
                    break;
                }
            }
        }

        AlertDialog dialog = new AlertDialog.Builder(this)
            .setView(dialogView)
            .create();

        btnCancel.setOnClickListener(v -> dialog.dismiss());
        btnSave.setOnClickListener(v -> {
            String title = etTitle.getText().toString().trim();
            String message = etMessage.getText().toString().trim();
            String discount = etDiscount.getText().toString().trim();
            String productName = etProductName.getText().toString().trim();
            String type = spinnerType.getSelectedItem().toString();

            if (TextUtils.isEmpty(title)) {
                etTitle.setError("Required");
                return;
            }
            if (TextUtils.isEmpty(message)) {
                etMessage.setError("Required");
                return;
            }

            saveAnnouncement(title, message, type, discount, productName, dialog);
        });

        dialog.show();
    }

    private void saveAnnouncement(String title, String message, String type, String discount, 
                                  String productName, AlertDialog dialog) {
        progressBar.setVisibility(View.VISIBLE);

        String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());
        String announcementId = editingAnnouncementId != null ? editingAnnouncementId : 
                               FirebaseUtil.announcementsRef().push().getKey();

        saveToDatabase(announcementId, title, message, type, discount, productName, null, timestamp, dialog);
    }

    private void saveToDatabase(String announcementId, String title, String message, String type,
                                String discount, String productName, String imageUrl, String timestamp,
                                AlertDialog dialog) {
        Announcement announcement = new Announcement();
        announcement.setTitle(title);
        announcement.setMessage(message);
        announcement.setType(type.toLowerCase());
        announcement.setDiscount(discount);
        announcement.setProductName(productName);
        announcement.setImageUrl(imageUrl);
        announcement.setTimestamp(timestamp);
        announcement.setDate(timestamp.split(" ")[0]);
        announcement.setActive(true);

        FirebaseUtil.announcementsRef().child(announcementId).setValue(announcement)
            .addOnCompleteListener(task -> {
                progressBar.setVisibility(View.GONE);
                if (task.isSuccessful()) {
                    dialog.dismiss();
                    loadAnnouncements();
                    Toast.makeText(this, "Announcement saved successfully", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, "Save failed: " + task.getException().getMessage(), 
                        Toast.LENGTH_SHORT).show();
                }
            });
    }

    private void showDeleteDialog(Announcement announcement) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Announcement")
            .setMessage("Are you sure you want to delete this announcement?")
            .setPositiveButton("Delete", (d, which) -> {
                FirebaseUtil.announcementsRef().child(announcement.getId()).removeValue()
                    .addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            loadAnnouncements();
                            Toast.makeText(this, "Announcement deleted", Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(this, "Delete failed", Toast.LENGTH_SHORT).show();
                        }
                    });
            })
            .setNegativeButton("Cancel", null)
            .show();
    }
}
