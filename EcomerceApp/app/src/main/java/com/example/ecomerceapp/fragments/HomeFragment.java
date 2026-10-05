package com.example.ecomerceapp.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.activities.AnnouncementsActivity;
import com.example.ecomerceapp.adapters.AnnouncementAdapter;
import com.example.ecomerceapp.adapters.HomeProductAdapter;
import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.viewmodels.HomeViewModel;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class HomeFragment extends Fragment {

    private EditText etSearch;
    private ImageButton btnFilter;
    private RecyclerView recyclerCategories;
    private RecyclerView recyclerAllProducts;
    private RecyclerView recyclerAnnouncements;
    private TextView tvViewAllAnnouncements;

    private HomeProductAdapter allProductsAdapter;
    private CategoryAdapter categoryAdapter;
    private AnnouncementAdapter announcementAdapter;
    
    private HomeViewModel viewModel;
    
    private final String[] categories = {"All", "Electronics", "Sports", "Food", "Fashion and Clothing"};
    private final String[] sortOptions = {"Default", "Price: Low to High", "Price: High to Low", "Name: A-Z"};
    private boolean hasLoadedData = false;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        try {
            View view = inflater.inflate(R.layout.activity_user_home, container, false);

            etSearch = view.findViewById(R.id.etSearch);
            btnFilter = view.findViewById(R.id.btnFilter);
            recyclerCategories = view.findViewById(R.id.recyclerCategories);
            recyclerAllProducts = view.findViewById(R.id.recyclerAllProducts);
            recyclerAnnouncements = view.findViewById(R.id.recyclerAnnouncements);
            tvViewAllAnnouncements = view.findViewById(R.id.tvViewAllAnnouncements);

            // Hide bottom nav from the layout since MainActivity has it
            View bottomNav = view.findViewById(R.id.bottomNav);
            if (bottomNav != null) {
                bottomNav.setVisibility(View.GONE);
            }

            // Initialize ViewModel
            viewModel = new ViewModelProvider(this).get(HomeViewModel.class);

            setupUI();
            setupAdapters();
            observeData();
            
            // Load data only once
            if (!hasLoadedData) {
                viewModel.loadProducts(false);
                viewModel.loadAnnouncements(false);
                hasLoadedData = true;
            }

            return view;
        } catch (Exception e) {
            android.util.Log.e("HomeFragment", "Error in onCreateView: " + e.getMessage());
            TextView errorView = new TextView(requireContext());
            errorView.setText("Error loading home screen");
            errorView.setPadding(32, 32, 32, 32);
            return errorView;
        }
    }

    private void setupAdapters() {
        // Categories
        categoryAdapter = new CategoryAdapter(categories, this::onCategorySelected);
        recyclerCategories.setLayoutManager(new LinearLayoutManager(requireContext(), RecyclerView.HORIZONTAL, false));
        recyclerCategories.setHasFixedSize(true);
        recyclerCategories.setAdapter(categoryAdapter);

        // Products
        allProductsAdapter = new HomeProductAdapter();
        GridLayoutManager gridLayoutManager = new GridLayoutManager(requireContext(), 2);
        recyclerAllProducts.setLayoutManager(gridLayoutManager);
        recyclerAllProducts.setHasFixedSize(true);
        recyclerAllProducts.setAdapter(allProductsAdapter);

        // Announcements
        announcementAdapter = new AnnouncementAdapter(requireContext(), new ArrayList<>());
        recyclerAnnouncements.setLayoutManager(new LinearLayoutManager(requireContext(), RecyclerView.HORIZONTAL, false));
        recyclerAnnouncements.setHasFixedSize(true);
        recyclerAnnouncements.setAdapter(announcementAdapter);

        // "View All" click listener
        tvViewAllAnnouncements.setOnClickListener(v -> {
            startActivity(new Intent(requireContext(), AnnouncementsActivity.class));
        });
    }

    private void observeData() {
        // Observe products
        viewModel.getProducts().observe(getViewLifecycleOwner(), products -> {
            if (products != null) {
                viewModel.setProducts(products);
            }
        });

        // Observe filtered products
        viewModel.getFilteredProducts().observe(getViewLifecycleOwner(), filteredProducts -> {
            if (filteredProducts != null) {
                allProductsAdapter.submitList(filteredProducts);
            }
        });

        // Observe announcements
        viewModel.getAnnouncements().observe(getViewLifecycleOwner(), announcements -> {
            if (announcements != null) {
                announcementAdapter.submit(announcements);
            }
        });
    }

    private void onCategorySelected(String category) {
        viewModel.setSelectedCategory(category);
    }

    private void setupUI() {
        // Search (filter locally by product name)
        etSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.setSearchQuery(s != null ? s.toString() : "");
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        // Filter button (sort options)
        btnFilter.setOnClickListener(v -> showSortDialog());
    }

    private void showSortDialog() {
        new androidx.appcompat.app.AlertDialog.Builder(requireContext())
                .setTitle("Sort")
                .setSingleChoiceItems(sortOptions, 0, (dialog, which) -> {
                    // Selection handled in Apply
                })
                .setPositiveButton("Apply", (dialog, which) -> {
                    viewModel.setSortMode(((androidx.appcompat.app.AlertDialog) dialog).getListView().getCheckedItemPosition());
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    // Simple Category Adapter
    private static class CategoryAdapter extends RecyclerView.Adapter<CategoryAdapter.ViewHolder> {
        private final String[] categories;
        private final java.util.function.Consumer<String> onClick;
        private int selectedPosition = 0;

        CategoryAdapter(String[] categories, java.util.function.Consumer<String> onClick) {
            this.categories = categories;
            this.onClick = onClick;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_category_chip, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            String category = categories[position];
            holder.tvCategory.setText(category);

            // Styling based on selection
            if (position == selectedPosition) {
                holder.cardView.setCardBackgroundColor(0xFF2D5A4A);
                holder.tvCategory.setTextColor(0xFFFFFFFF);
                holder.cardView.setStrokeWidth(0);
            } else {
                holder.cardView.setCardBackgroundColor(0xFFFFFFFF);
                holder.tvCategory.setTextColor(0xFF6B7280);
                holder.cardView.setStrokeWidth(1);
            }

            holder.itemView.setOnClickListener(v -> {
                selectedPosition = position;
                onClick.accept(category);
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return categories.length;
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            com.google.android.material.card.MaterialCardView cardView;
            TextView tvCategory;

            ViewHolder(View itemView) {
                super(itemView);
                cardView = (com.google.android.material.card.MaterialCardView) itemView;
                tvCategory = itemView.findViewById(R.id.tvCategory);
            }
        }
    }
}
