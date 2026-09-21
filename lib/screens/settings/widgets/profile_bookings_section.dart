import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/booking/booking_confirmation.dart';
import '../../../models/index.dart' show UserModel;
import '../../../services/index.dart';

/// "Bookings" block on the Profile screen: the customer's upcoming and past
/// appointments, which the FluxBuilder profile has no option to show.
class ProfileBookingsSection extends StatefulWidget {
  const ProfileBookingsSection({super.key});

  @override
  State<ProfileBookingsSection> createState() => _ProfileBookingsSectionState();
}

class _ProfileBookingsSectionState extends State<ProfileBookingsSection> {
  List<BookingConfirmation> _bookings = [];
  bool _isLoading = true;
  String? _loadedForUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Provider.of<UserModel>(context).user?.id;
    if (userId != _loadedForUser) {
      _loadedForUser = userId;
      _load(userId);
    }
  }

  Future<void> _load(String? userId) async {
    if (userId == null || userId.isEmpty) {
      setState(() {
        _bookings = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    final bookings = await Services().api.fetchCustomerBookings(
      customerId: userId,
    );
    if (!mounted) return;
    setState(() {
      _bookings = bookings ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to say to a signed-out user, or to one with no appointments.
    if (_loadedForUser == null || (!_isLoading && _bookings.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Bookings',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            for (final booking in _bookings.take(5))
              _buildBookingCard(theme, booking),
        ],
      ),
    );
  }

  Widget _buildBookingCard(ThemeData theme, BookingConfirmation booking) {
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final isUpcoming = booking.start.isAfter(DateTime.now());

    final meta = [
      DateFormat('MMM d').format(booking.start),
      DateFormat('HH:mm').format(booking.start),
      if (booking.durationInMinutes > 0) '${booking.durationInMinutes} min',
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.10),
            ),
            child: Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 20,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isUpcoming ? 'Upcoming' : 'Past'}: '
                  '${booking.serviceName ?? 'Booking'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (booking.practitionerName != null)
                  Text(
                    booking.practitionerName!,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (booking.status?.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status![0].toUpperCase() +
                        booking.status!.substring(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (booking.total != null) ...[
                const SizedBox(height: 8),
                Text(
                  booking.total!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
