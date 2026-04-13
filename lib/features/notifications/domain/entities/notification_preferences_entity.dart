/// Granular on/off toggles for a single notification delivery channel.
class PreferenceChannel {
  final bool trackLiked;
  final bool trackCommented;
  final bool trackReposted;
  final bool userFollowed;
  final bool newRelease;
  final bool newMessage;
  final bool system;
  final bool subscription;

  const PreferenceChannel({
    this.trackLiked = true,
    this.trackCommented = true,
    this.trackReposted = true,
    this.userFollowed = true,
    this.newRelease = true,
    this.newMessage = true,
    this.system = true,
    this.subscription = true,
  });

  PreferenceChannel copyWith({
    bool? trackLiked,
    bool? trackCommented,
    bool? trackReposted,
    bool? userFollowed,
    bool? newRelease,
    bool? newMessage,
    bool? system,
    bool? subscription,
  }) =>
      PreferenceChannel(
        trackLiked: trackLiked ?? this.trackLiked,
        trackCommented: trackCommented ?? this.trackCommented,
        trackReposted: trackReposted ?? this.trackReposted,
        userFollowed: userFollowed ?? this.userFollowed,
        newRelease: newRelease ?? this.newRelease,
        newMessage: newMessage ?? this.newMessage,
        system: system ?? this.system,
        subscription: subscription ?? this.subscription,
      );

  Map<String, bool> toMap() => {
        'trackLiked': trackLiked,
        'trackCommented': trackCommented,
        'trackReposted': trackReposted,
        'userFollowed': userFollowed,
        'newRelease': newRelease,
        'newMessage': newMessage,
        'system': system,
        'subscription': subscription,
      };
}

/// User notification preferences split by delivery channel.
class NotificationPreferencesEntity {
  final PreferenceChannel push;
  final PreferenceChannel email;

  const NotificationPreferencesEntity({
    this.push = const PreferenceChannel(),
    this.email = const PreferenceChannel(),
  });

  NotificationPreferencesEntity copyWith({
    PreferenceChannel? push,
    PreferenceChannel? email,
  }) =>
      NotificationPreferencesEntity(
        push: push ?? this.push,
        email: email ?? this.email,
      );
}
