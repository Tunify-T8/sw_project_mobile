class CloudinaryUploadConfig {
  CloudinaryUploadConfig._();

  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dorh77k3j',
  );

  static const String audioUploadPreset = String.fromEnvironment(
    'CLOUDINARY_AUDIO_UPLOAD_PRESET',
    defaultValue: 'audio_preset',
  );

  static const String imageUploadPreset = String.fromEnvironment(
    'CLOUDINARY_IMAGE_UPLOAD_PRESET',
    defaultValue: 'artwork_preset',
  );

  static const String apiKey = String.fromEnvironment(
    'CLOUDINARY_API_KEY',
    defaultValue: '',
  );

  static const String apiSecret = String.fromEnvironment(
    'CLOUDINARY_API_SECRET',
    defaultValue: '',
  );
}
