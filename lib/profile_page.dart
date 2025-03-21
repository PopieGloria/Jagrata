import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_page.dart'; // Import the WelcomePage
import 'main.dart' as app; // Import main.dart to access global methods
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfilePage({Key? key, this.onProfileUpdated}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isProfileComplete = false;
  bool _isEditing = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _govtIdController = TextEditingController();
  String? _selectedCountry;
  String? _selectedGender;

  // Lists for dropdowns
  final List<String> countries = ['India', 'Other'];
  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    print('ProfilePage initState called');
    
    // Initialize default values for dropdown menus
    if (_selectedCountry == null) {
      _selectedCountry = countries.isNotEmpty ? countries[0] : null;
    }
    if (_selectedGender == null) {
      _selectedGender = genders.isNotEmpty ? genders[0] : null;
    }
    
    // Set loading state immediately before doing anything else
    setState(() => _isLoading = true);
    
    // Load profile status from the global variable or shared preferences
    _checkProfileStatusFromCache();
    
    // Use a simple postFrameCallback instead of a microtask
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ProfilePage postFrameCallback triggered');
      // Only proceed if still mounted
      if (mounted) {
        _loadUserProfile();
      }
    });
  }

  // First check if we already know the profile status from cache
  Future<void> _checkProfileStatusFromCache() async {
    try {
      // First check the global variable
      if (app.globalProfileComplete) {
        if (mounted) {
          setState(() {
            _isProfileComplete = true;
            print('Profile completion status set from global variable: $_isProfileComplete');
          });
        }
        return;
      }
      
      // Then check shared preferences
      final prefs = await SharedPreferences.getInstance();
      final isComplete = prefs.getBool('profile_complete') ?? false;
      if (isComplete && mounted) {
        setState(() {
          _isProfileComplete = true;
          print('Profile completion status set from shared prefs: $_isProfileComplete');
        });
      }
    } catch (e) {
      print('Error checking cached profile status: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    print('--- LOADING USER PROFILE ---');
    
    // Double-check if widget is mounted
    if (!mounted) {
      print('Widget no longer mounted during _loadUserProfile');
      return;
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user found, setting _isLoading to false');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      print('Loading profile data for user: ${user.uid}');
      // Get user data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      // Check if widget is still mounted
      if (!mounted) {
        print('Widget no longer mounted after Firestore fetch');
        return;
      }
      
      if (userData.exists) {
        final data = userData.data()!;
        print('User document exists. Loaded data:');
        print('Name: ${data['name']}, Phone: ${data['phone']}, GovtId: ${data['govtId']}');
        print('Country: ${data['country']}, Gender: ${data['gender']}');
        print('isProfileComplete flag: ${data['isProfileComplete']}');
        
        // Update controllers and state variables
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _govtIdController.text = data['govtId'] ?? '';
          _selectedCountry = data['country'];
          _selectedGender = data['gender'];
          _isProfileComplete = data['isProfileComplete'] == true; // Ensure we use == true to avoid null issues
          // Set loading to false AFTER updating controllers
          _isLoading = false;
          print('Profile state set: isProfileComplete = $_isProfileComplete');
        });
        
        // Update global status based on database value
        await app.updateProfileCompletionStatus(_isProfileComplete);
        print('Updated global profile status to: $_isProfileComplete');
        
        // Perform a completeness check independent of the flag
        bool hasAllRequiredFields = _nameController.text.isNotEmpty && 
                          _phoneController.text.isNotEmpty && 
                          _govtIdController.text.isNotEmpty &&
                          _selectedCountry != null && 
                          _selectedGender != null;
        
        print('Profile has all required fields: $hasAllRequiredFields');
        
        // Auto-fix the isProfileComplete flag if needed
        if (hasAllRequiredFields && !_isProfileComplete && mounted) {
          print('Profile has all required fields but flag is not set. Updating flag to true.');
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isProfileComplete': true});
            
            // Update global status FIRST
            await app.updateProfileCompletionStatus(true);
            print('Updated global profile status to TRUE after fixing flag in database');
            
            if (mounted) {
              setState(() {
                _isProfileComplete = true;
                print('Profile completion flag updated in database and state');
              });
              
              // Notify the parent if we auto-updated the profile status
              if (widget.onProfileUpdated != null) {
                print('Calling onProfileUpdated callback after flag update');
                widget.onProfileUpdated!();
              }
            }
          } catch (updateError) {
            print('Error updating profile completion flag: $updateError');
          }
        }
      } else {
        print('No user document exists in Firestore database');
        // No user data exists, set loading to false
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _govtIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Error handling wrapper
    return Builder(
      builder: (context) {
        try {
          return _buildProfilePage(context);
        } catch (e) {
          // If any error occurs during building, show a fallback UI
          print('Error building profile page: $e');
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'We encountered an error loading your profile. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        _loadUserProfile();
                      }
                    },
                    child: Text('Reload Profile'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Moved the actual profile page building to a separate method
  Widget _buildProfilePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your profile...'),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            _isProfileComplete ? 
                              (_nameController.text.isNotEmpty ? 
                                _nameController.text.substring(0, 1).toUpperCase() : 
                                'U') 
                              : 'U',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_isProfileComplete) ...[
                        Text(
                          _nameController.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? '',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      SizedBox(height: 30),
                    ],
                  ),
                ),

                // Profile Details or Form
                if (_isProfileComplete)
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileDetail(
                          'Phone Number',
                          _phoneController.text,
                          Icons.phone_outlined,
                        ),
                        Divider(height: 1),
                        _buildProfileDetail(
                          'Government ID',
                          _govtIdController.text,
                          Icons.badge_outlined,
                        ),
                        Divider(height: 1),
                        _buildProfileDetail(
                          'Country',
                          _selectedCountry ?? 'Not specified',
                          Icons.public,
                        ),
                        Divider(height: 1),
                        _buildProfileDetail(
                          'Gender',
                          _selectedGender ?? 'Not specified',
                          Icons.person_outline,
                        ),
                      ],
                    ),
                  )
                else
                  // Profile Completion Form
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: _buildProfileForm(),
                  ),

                // Spacer to push buttons to bottom
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // Bottom Buttons
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_isProfileComplete) 
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _isProfileComplete = false; // Show the form
                            });
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: Icon(Icons.logout),
                        label: Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _showDeleteAccountDialog(context),
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        label: Text('Delete Account'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileDetail(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile completion notification
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please complete your profile before submitting any reports. This information is necessary for verification purposes.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          
          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          
          // Government ID field
          TextFormField(
            controller: _govtIdController,
            decoration: InputDecoration(
              labelText: 'Government ID',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your government ID';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          
          // Country dropdown - use the new smooth dropdown
          _buildDropdownField(
            label: 'Country',
            value: _selectedCountry,
            items: countries,
            onChanged: (value) {
              if (value != _selectedCountry) {
                setState(() {
                  _selectedCountry = value;
                });
              }
            },
            prefixIcon: Icons.public,
            readOnly: false,
          ),
          
          // Gender dropdown - use the new smooth dropdown
          _buildDropdownField(
            label: 'Gender',
            value: _selectedGender,
            items: genders,
            onChanged: (value) {
              if (value != _selectedGender) {
                setState(() {
                  _selectedGender = value;
                });
              }
            },
            prefixIcon: Icons.person_outline,
            readOnly: false,
          ),
          
          SizedBox(height: 40),
          
          // Save button
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              if (_formKey.currentState!.validate()) {
                print('Complete Profile button pressed');
                _saveProfile();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _isEditing ? 'Update Profile' : 'Complete Profile',
                  style: TextStyle(fontSize: 16),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    print('--- SAVING USER PROFILE ---');
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Saving profile for user: ${user.uid}');
        
        // Create profile data map with all required fields
        Map<String, dynamic> profileData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'govtId': _govtIdController.text.trim(),
          'country': _selectedCountry,
          'gender': _selectedGender,
          'lastUpdated': FieldValue.serverTimestamp(),
          'isProfileComplete': true, // Explicitly mark as complete
          'email': user.email, // Include email for identification
        };

        print('Profile data to save: $profileData');

        // IMPORTANT: Update the global status in shared preferences FIRST
        await app.updateProfileCompletionStatus(true);
        print('Updated shared preferences with profile_complete=true');

        // Save to Firestore with merge option
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(profileData, SetOptions(merge: true));

        print('Profile saved successfully with isProfileComplete=true');
        
        // Verify that the isProfileComplete flag was properly saved
        try {
          final updatedDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
              
          final bool savedFlag = updatedDoc.data()?['isProfileComplete'] == true;
          print('Verification - isProfileComplete saved as: $savedFlag');
          
          // Force update if not properly saved
          if (!savedFlag) {
            print('CRITICAL: isProfileComplete flag not saved correctly. Force updating...');
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isProfileComplete': true});
            
            // Force update shared preferences again
            await app.updateProfileCompletionStatus(true);
                
            // Re-verify
            final recheck = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
                
            print('Re-verification after force update: ${recheck.data()?['isProfileComplete']}');
          }
        } catch (verifyError) {
          print('Error verifying profile save: $verifyError');
        }
        
        if (mounted) {
          setState(() {
            _isProfileComplete = true;
            _isEditing = false;
            _isLoading = false;
            print('Updated local state: isProfileComplete=true');
          });
          
          // Only call callback if it exists
          if (widget.onProfileUpdated != null) {
            print('Calling onProfileUpdated callback after profile save');
            widget.onProfileUpdated!();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Profile updated successfully' : 'Profile completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // First dismiss the dialog
              Navigator.pop(dialogContext);
              // Then handle account deletion
              _handleDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Show loading indicator
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Show progress message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleting account...'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete user account
        await user.delete();

        // Clear SharedPreferences data
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        } catch (e) {
          print('Error clearing preferences: $e');
        }

        // Navigate to welcome page
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => WelcomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // If we get here, the user is still on the profile page
      setState(() => _isLoading = false);
      
      // Show detailed error message
      String errorMessage = 'Error deleting account: ${e.toString()}';
      
      // Handle specific Firebase auth errors
      if (e is FirebaseAuthException) {
        if (e.code == 'requires-recent-login') {
          errorMessage = 'For security, please log out and log in again before deleting your account.';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Completely rewrite the _buildDropdownField implementation to fix the issue
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData prefixIcon,
    bool readOnly = false,
  }) {
    // Only use the dropdown if not in read-only mode
    if (readOnly) {
      return Container(); // Return empty container as we're now using _buildProfileDetail instead
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show a dialog instead of a bottom sheet to avoid rebuilding the parent widget
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text('Select $label'),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  content: Container(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        final item = items[index];
                        final isSelected = item == value;
                        
                        return ListTile(
                          dense: true,
                          title: Text(item),
                          trailing: isSelected 
                              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                              : null,
                          onTap: () {
                            if (item != value) {
                              // Pop the dialog first to prevent rebuild issues
                              Navigator.of(dialogContext).pop();
                              // Then update the value
                              onChanged(item);
                            } else {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Icon(prefixIcon, color: Colors.blue.shade700),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          value ?? 'Select $label',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: value == null ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}