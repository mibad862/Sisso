import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/booking/booking_confirmation.dart';
import '../../models/index.dart' show UserModel;
import '../../services/index.dart';

/// Shown after an appointment has been paid for, so the customer can see
/// what they booked and put it in their calendar.
class BookingConfirmationScreen extends StatefulWidget {
  final String orderId;
  final String? customerId;

  /// Opens the customer's bookings. Falls back to the orders screen, which
  /// is where bookings appear until a dedicated list exists.
  final VoidCallback? onViewBookings;

  /// Already loaded bookings, to avoid fetching them twice when the caller
  /// has them.
  final List<BookingConfirmation>? bookings;

  /// False when embedded in a screen that provides its own Scaffold.
  final bool useScaffold;

  const BookingConfirmationScreen({
    super.key,
    required this.orderId,
    this.customerId,
    this.onViewBookings,
    this.bookings,
    this.useScaffold = true,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  List<BookingConfirmation> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final provided = widget.bookings;
    if (provided != null) {
      _bookings = provided;
      _isLoading = false;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final bookings = await Services().api.fetchBookingConfirmations(
      orderId: widget.orderId,
      customerId: widget.customerId,
    );
    if (!mounted) return;
    setState(() {
      _bookings = bookings ?? [];
      _isLoading = false;
    });
  }

  /// Opens the system "Add Event" editor prefilled with the booking.
  ///
  /// iOS does not accept .ics through the share sheet (Calendar is not a
  /// share target), so the native editor is the only way to reach it.
  Future<void> _addToCalendar(BookingConfirmation booking) async {
    final description = [
      if (booking.practitionerName != null)
        'Practitioner: ${booking.practitionerName}',
      'Booking reference: #${booking.id}',
    ].join('\n');

    try {
      final event = add2cal.Event(
        title: booking.serviceName ?? 'Booking',
        description: description,
        startDate: booking.start,
        endDate: booking.end,
        iosParams: const add2cal.IOSParams(reminder: Duration(hours: 1)),
        androidParams: const add2cal.AndroidParams(emailInvites: []),
      );
      await add2cal.Add2Calendar.addEvent2Cal(event);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the calendar')),
      );
    }
  }

  void _openBookings() {
    // The orders route builds its model from a User argument and shows the
    // not-found page without one.
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to see your bookings')),
      );
      return;
    }
    Navigator.of(context).pushNamed(RouteList.orders, arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = _buildBody(theme);
    if (!widget.useScaffold) {
      return Container(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFF7F7F9),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: isDark
            ? theme.colorScheme.surface
            : const Color(0xFFF7F7F9),
        elevation: 0,
        centerTitle: true,
        title: const Text('Confirmed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBody(ThemeData theme) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildHeader(theme),
                const SizedBox(height: 24),
                if (_bookings.isEmpty)
                  _buildCard(
                    theme,
                    child: Text(
                      'Your order is confirmed. Booking details will '
                      'appear here once they are available.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  for (final booking in _bookings) ...[
                    _buildBookingCard(theme, booking),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 24),
              ],
            ),
          );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Booking confirmed!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We emailed your receipt and details.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }

  Widget _buildBookingCard(ThemeData theme, BookingConfirmation booking) {
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.serviceName ?? 'Booking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              if (booking.status?.isNotEmpty ?? false) ...[
                const SizedBox(width: 8),
                _statusChip(theme, booking.status!),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // When: the detail people look for first.
          Row(
            children: [
              _iconBadge(theme, Icons.calendar_today_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(booking.start),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        '${DateFormat('HH:mm').format(booking.start)}'
                            ' – ${DateFormat('HH:mm').format(booking.end)}',
                        if (booking.durationInMinutes > 0)
                          '${booking.durationInMinutes} min',
                        if (booking.timezone?.isNotEmpty ?? false)
                          booking.timezone!,
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),

          if (booking.practitionerName != null)
            _detailRow(theme, 'Practitioner', booking.practitionerName!),
          _detailRow(theme, 'Booking reference', '#${booking.id}'),
          if (booking.paymentMethodTitle != null)
            _detailRow(theme, 'Paid with', booking.paymentMethodTitle!),

          if (booking.total != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total paid',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                Text(
                  '${booking.currency ?? ''} ${booking.total}'.trim(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addToCalendar(booking),
                  icon: const Icon(Icons.event_rounded, size: 18),
                  label: const Text('Add to Calendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onViewBookings ?? _openBookings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text('My bookings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(ThemeData theme, IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: theme.primaryColor),
    );
  }

  Widget _statusChip(ThemeData theme, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Label on the left, value on the right, so the values line up instead of
  /// reading as a paragraph of loose sentences.
  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
