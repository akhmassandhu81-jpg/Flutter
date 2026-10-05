package com.example.ecomerceapp.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.OrderHistoryAdapter;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.viewmodels.OrdersViewModel;
import com.google.firebase.auth.FirebaseUser;

import java.util.ArrayList;
import java.util.List;

public class OrdersFragment extends Fragment {

    private RecyclerView recycler;
    private TextView tvEmpty;
    private ProgressBar progress;
    private OrderHistoryAdapter adapter;
    private OrdersViewModel viewModel;
    private boolean hasLoadedData = false;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        try {
            View view = inflater.inflate(R.layout.activity_order_history, container, false);

            recycler = view.findViewById(R.id.recycler);
            tvEmpty = view.findViewById(R.id.tvEmpty);
            progress = view.findViewById(R.id.progress);

            // Hide back button since MainActivity handles navigation
            ImageButton btnBack = view.findViewById(R.id.btnBack);
            if (btnBack != null) {
                btnBack.setVisibility(View.GONE);
            }

            // Hide bottom nav from the layout since MainActivity has it
            View bottomNav = view.findViewById(R.id.bottomNav);
            if (bottomNav != null) {
                bottomNav.setVisibility(View.GONE);
            }

            // Initialize ViewModel
            viewModel = new ViewModelProvider(this).get(OrdersViewModel.class);

            adapter = new OrderHistoryAdapter();
            recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
            recycler.setHasFixedSize(true);
            recycler.setAdapter(adapter);

            FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
            if (user == null) {
                tvEmpty.setVisibility(View.VISIBLE);
                tvEmpty.setText("Please login to view orders");
                return view;
            }

            observeData();
            
            // Load data only once
            if (!hasLoadedData) {
                viewModel.loadOrders(user.getUid(), false);
                hasLoadedData = true;
            }

            return view;
        } catch (Exception e) {
            android.util.Log.e("OrdersFragment", "Error in onCreateView: " + e.getMessage());
            TextView errorView = new TextView(requireContext());
            errorView.setText("Error loading orders");
            errorView.setPadding(32, 32, 32, 32);
            return errorView;
        }
    }

    private void observeData() {
        // Observe orders
        viewModel.getOrders().observe(getViewLifecycleOwner(), orders -> {
            if (orders != null) {
                adapter.submit(orders);
                tvEmpty.setVisibility(orders.isEmpty() ? View.VISIBLE : View.GONE);
            }
        });

        // Observe loading state
        viewModel.getOrdersLoading().observe(getViewLifecycleOwner(), loading -> {
            if (loading != null) {
                progress.setVisibility(loading ? View.VISIBLE : View.GONE);
            }
        });
    }
}
