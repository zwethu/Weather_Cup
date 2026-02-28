import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // Show loading state
    if (userProvider.isLoadingWeather) {
      return _buildCard(
        context,
        icon: CupertinoIcons.cloud,
        title: 'Loading weather...',
        subtitle: 'Fetching current conditions',
        isLoading: true,
      );
    }

    // Show weather data or fallback
    final hasWeather = userProvider.hasWeather;
    final emoji = userProvider.weatherEmoji;
    final temp = userProvider.temperatureString;
    final condition = userProvider.weatherCondition;
    final tip = userProvider.weatherTip;

    // Calculate weather-adjusted info
    final baseGoal = userProvider.baseWaterIntake;
    final adjustedGoal = userProvider.recommendedDailyIntake;
    final extraWater = adjustedGoal - baseGoal;

    String subtitle = tip;
    if (hasWeather && extraWater > 0) {
      subtitle = '$tip (+${extraWater}ml today)';
    }

    return _buildCard(
      context,
      emoji: emoji,
      title: hasWeather ? '$temp · $condition' : 'Weather unavailable',
      subtitle: subtitle,
      isLoading: false,
      onRefresh: () => userProvider.refreshWeather(),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    IconData? icon,
    String? emoji,
    required String title,
    required String subtitle,
    bool isLoading = false,
    VoidCallback? onRefresh,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Weather icon or emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                      ),
                    )
                  : emoji != null
                      ? Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        )
                      : Icon(
                          icon ?? CupertinoIcons.sun_max,
                          size: 28,
                          color: const Color(0xFF00B4D8),
                        ),
            ),
          ),
          const SizedBox(width: 16),
          // Weather info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Refresh button
          if (onRefresh != null && !isLoading)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(
                CupertinoIcons.refresh,
                size: 20,
                color: Color(0xFF00B4D8),
              ),
              tooltip: 'Refresh weather',
            ),
        ],
      ),
    );
  }
}
