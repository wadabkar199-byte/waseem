import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة المصادقة المركزية عبر Supabase
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// إنشاء حساب جديد مع تمرير الاسم والدور الأولي في البيانات الوصفية
  /// الدور يُفرض خادمياً عبر Trigger يمنع ترقية المستخدم لمدير
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'client', // 'client' or 'barber'
  }) async {
    try {
      return await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// إرسال رابط استعادة كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// جلب دور المستخدم الحالي من جدول profiles المحمي
  Future<String> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return 'guest';

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      return response['role'] as String? ?? 'client';
    } catch (e) {
      debugPrint('Error fetching role: $e');
      return 'client';
    }
  }
}
