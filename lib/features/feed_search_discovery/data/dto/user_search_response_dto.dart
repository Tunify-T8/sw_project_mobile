import 'user_preview_dto.dart';

class UserSearchResponseDto {
  final List<UserPreviewDto> items;
  final int page;
  final int limit;
  final int total;

  UserSearchResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory UserSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return UserSearchResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => UserPreviewDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}