import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Select Role',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: UserRole.values.map((role) {
            final isSelected = selectedRole == role;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: role == UserRole.owner ? 0 : 8,
                  right: role == UserRole.cashier ? 0 : 8,
                ),
                child: _RoleCard(
                  role: role,
                  isSelected: isSelected,
                  onTap: () => onRoleChanged(role),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (role) {
      case UserRole.owner:
        return Iconsax.crown_15;
      case UserRole.manager:
        return Iconsax.chart_215;
      case UserRole.cashier:
        return Iconsax.card_pos5;
    }
  }

  Gradient get _gradient {
    switch (role) {
      case UserRole.owner:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.manager:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.cashier:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06D6A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color get _accentColor {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFFFFD700);
      case UserRole.manager:
        return const Color(0xFF8B5CF6);
      case UserRole.cashier:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        _accentColor.withOpacity(0.2),
                        _accentColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: isSelected ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _accentColor : AppColors.surfaceBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Icon with gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isSelected ? _gradient : null,
                    color: isSelected ? null : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _accentColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icon,
                    size: 24,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                const SizedBox(height: 12),

                // Role name
                Text(
                  role.displayName,
                  style: TextStyle(
                    color: isSelected ? _accentColor : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // Checkmark
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: _gradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
