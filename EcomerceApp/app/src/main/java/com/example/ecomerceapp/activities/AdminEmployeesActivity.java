package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.databinding.ActivityAdminEmployeesBinding;
import com.example.ecomerceapp.databinding.DialogEmployeeFormBinding;
import com.example.ecomerceapp.models.Employee;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class AdminEmployeesActivity extends AppCompatActivity {

    private ActivityAdminEmployeesBinding binding;
    private EmployeeAdapter adapter;
    private List<Employee> employeeList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminEmployeesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadEmployees();
    }

    private void setupRecyclerView() {
        adapter = new EmployeeAdapter(employeeList, this::onEditEmployee, this::onDeleteEmployee);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> showEmployeeDialog(null));
        
        binding.btnSearch.setOnClickListener(v -> {
            String query = binding.etSearch.getText().toString().trim().toLowerCase();
            searchEmployees(query);
        });
    }

    private void loadEmployees() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.employeesRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                employeeList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Employee emp = data.getValue(Employee.class);
                    if (emp != null) {
                        employeeList.add(emp);
                    }
                }
                binding.progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                binding.tvEmpty.setVisibility(employeeList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(AdminEmployeesActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void searchEmployees(String query) {
        if (TextUtils.isEmpty(query)) {
            adapter.updateList(employeeList);
            return;
        }
        
        List<Employee> filtered = new ArrayList<>();
        for (Employee emp : employeeList) {
            if ((emp.getFirstName() != null && emp.getFirstName().toLowerCase().contains(query)) ||
                (emp.getLastName() != null && emp.getLastName().toLowerCase().contains(query)) ||
                (emp.getEmployeeId() != null && emp.getEmployeeId().toLowerCase().contains(query))) {
                filtered.add(emp);
            }
        }
        adapter.updateList(filtered);
    }

    private void showEmployeeDialog(Employee employee) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        DialogEmployeeFormBinding dialogBinding = DialogEmployeeFormBinding.inflate(LayoutInflater.from(this));
        builder.setView(dialogBinding.getRoot());

        if (employee != null) {
            dialogBinding.etEmployeeId.setText(employee.getEmployeeId());
            dialogBinding.etFirstName.setText(employee.getFirstName());
            dialogBinding.etLastName.setText(employee.getLastName());
            dialogBinding.etEmail.setText(employee.getEmail());
            dialogBinding.etContact.setText(employee.getContactNo());
            dialogBinding.etAddress.setText(employee.getAddress());
            dialogBinding.etPosition.setText(employee.getPosition());
        }

        builder.setTitle(employee == null ? "Add Employee" : "Edit Employee");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveEmployee(employee, dialogBinding);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveEmployee(Employee existing, DialogEmployeeFormBinding binding) {
        String employeeId = binding.etEmployeeId.getText().toString().trim();
        String firstName = binding.etFirstName.getText().toString().trim();
        String lastName = binding.etLastName.getText().toString().trim();
        String email = binding.etEmail.getText().toString().trim();
        String contact = binding.etContact.getText().toString().trim();
        String address = binding.etAddress.getText().toString().trim();
        String position = binding.etPosition.getText().toString().trim();

        if (TextUtils.isEmpty(firstName) || TextUtils.isEmpty(lastName) || TextUtils.isEmpty(employeeId)) {
            Toast.makeText(this, "Employee ID, First Name and Last Name are required", Toast.LENGTH_SHORT).show();
            return;
        }

        String id = existing != null ? existing.getId() : UUID.randomUUID().toString();
        String date = existing != null ? existing.getDateOfJoining() : 
                new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());

        Employee employee = new Employee(id, employeeId, firstName, lastName, email, 
                contact, address, position, date);
        
        FirebaseUtil.employeesRef().child(id).setValue(employee)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Employee saved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditEmployee(Employee employee) {
        showEmployeeDialog(employee);
    }

    private void onDeleteEmployee(Employee employee) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Employee")
            .setMessage("Are you sure you want to delete " + employee.getFullName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.employeesRef().child(employee.getId()).removeValue()
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Employee deleted", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    // Simple adapter class for employees
    private static class EmployeeAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<EmployeeAdapter.ViewHolder> {
        private List<Employee> list;
        private final java.util.function.Consumer<Employee> onEdit;
        private final java.util.function.Consumer<Employee> onDelete;

        EmployeeAdapter(List<Employee> list, java.util.function.Consumer<Employee> onEdit, 
                       java.util.function.Consumer<Employee> onDelete) {
            this.list = list;
            this.onEdit = onEdit;
            this.onDelete = onDelete;
        }

        void updateList(List<Employee> newList) {
            this.list = newList;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            android.view.View view = LayoutInflater.from(parent.getContext())
                .inflate(android.R.layout.simple_list_item_2, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Employee emp = list.get(position);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1))
                .setText(emp.getFullName() + " (" + emp.getEmployeeId() + ")");
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2))
                .setText(emp.getPosition() + " | " + emp.getContactNo());
            
            holder.itemView.setOnClickListener(v -> onEdit.accept(emp));
            holder.itemView.setOnLongClickListener(v -> {
                onDelete.accept(emp);
                return true;
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
            ViewHolder(android.view.View itemView) {
                super(itemView);
            }
        }
    }
}
