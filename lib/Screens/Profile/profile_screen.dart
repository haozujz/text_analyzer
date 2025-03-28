import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utilities/constants.dart';
import '../../ViewModels/auth_vm.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 92),

            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 78,
                  backgroundColor: AppColors.surface,
                  backgroundImage: NetworkImage(
                    'https://pics.craiyon.com/2024-09-08/4rXFZUQWTO2XzUVI0Zr50w.webp',
                  ),
                ),

                Positioned(
                  bottom: 6, // Adjust to move it slightly up/down
                  right: 6, // Adjust to move it closer to the avatar's edge
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Edit profile picture
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.button,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 92),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authState.email ?? 'user@example.com',
                style: const TextStyle(color: AppColors.text, fontSize: 16),
              ),
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {
                // TODO: Reset password
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                minimumSize: const Size(400, 60),
              ),
              child: const Text(
                "Reset Password",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () async {
                await Amplify.Auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                minimumSize: const Size(400, 60),
              ),
              child: const Text("Sign Out", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
