import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/auth/auth_bloc.dart';
import '../../controllers/auth/auth_event.dart';
import '../../controllers/profile/profile_bloc.dart';
import '../../controllers/profile/profile_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFF85606),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                //=============================> Avatar <==========================
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFF85606),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),

                //============================> Name <============================
                Center(
                  child: Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '@${user.username}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                //=========================> Info cards <=======================
                _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone,
                ),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value:
                      '${user.address.number} ${user.address.street}, ${user.address.city} ${user.address.zipcode}',
                ),
                const SizedBox(height: 32),
                //==========================> Logout button <========================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFF85606)),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
