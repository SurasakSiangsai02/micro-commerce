import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/test_data_seeder.dart';
import '../../utils/error_handler.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test & Debug'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Auth Status
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authentication Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Logged in: ${authProvider.isAuthenticated}'),
                        if (authProvider.firebaseUser != null) ...[
                          Text('User: ${authProvider.firebaseUser!.email}'),
                          Text('UID: ${authProvider.firebaseUser!.uid}'),
                        ],
                        if (authProvider.userProfile != null) ...[
                          Text('Name: ${authProvider.userProfile!.name}'),
                        ],
                        if (authProvider.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${authProvider.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cart Status
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Items: ${cartProvider.itemCount}'),
                        Text('Total: \$${cartProvider.total.toStringAsFixed(2)}'),
                        Text('Loading: ${cartProvider.isLoading}'),
                        if (cartProvider.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${cartProvider.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Test Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await TestDataSeeder.seedProducts();
                          if (context.mounted) {
                            ErrorHandler.showSuccessSnackBar(
                              context, 
                              'Test products seeded successfully!'
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ErrorHandler.showErrorSnackBar(
                              context, 
                              'Failed to seed products: $e'
                            );
                          }
                        }
                      },
                      child: const Text('Seed Test Products'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await TestDataSeeder.clearAllData();
                          if (context.mounted) {
                            ErrorHandler.showSuccessSnackBar(
                              context, 
                              'All test data cleared!'
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ErrorHandler.showErrorSnackBar(
                              context, 
                              'Failed to clear data: $e'
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear All Data'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            await cartProvider.loadCart();
                            if (context.mounted) {
                              ErrorHandler.showInfoSnackBar(
                                context, 
                                'Cart reloaded'
                              );
                            }
                          },
                          child: const Text('Reload Cart'),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return ElevatedButton(
                          onPressed: authProvider.isAuthenticated 
                              ? () async {
                                  await authProvider.signOut();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Sign Out'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Test User
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Use these credentials to test:'),
                    const SizedBox(height: 8),
                    const SelectableText('Email: test@example.com'),
                    const SelectableText('Password: 123456'),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Register with these credentials first, then login.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}