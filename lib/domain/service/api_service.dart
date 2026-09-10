// lib/domain/service/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/data/models/user.dart';

class ApiService {
  static const String baseUrl = 'https://quester-backend-vj7h.onrender.com';

  static Future<List<dynamic>> fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Errore di connessione: $e');
      return [];
    }
  }

  static Future<bool> syncUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sync/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': user.username,
          'xpTotale': user.xpTotale,
          'livello': user.livello,
          'coins': user.coins,
          'equippedHat': user.equippedHat,
          'equippedWeapon': user.equippedWeapon,
          'equippedFrame': user.equippedFrame,
          'updated_at': user.updatedAt,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Errore durante la sincronizzazione utente: $e');
      return false;
    }
  }

  static Future<bool> syncMission(Map<String, dynamic> missionData) async {
    try {
      final userId = missionData['user_id'];
      final response = await http.post(
        Uri.parse('$baseUrl/api/sync/mission/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(missionData),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Errore sync missione: $e');
      return false;
    }
  }

  static Future<bool> syncOwnedCosmetics(int userId, List<String> itemIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sync/cosmetics/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item_ids': itemIds}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Errore sync cosmetici: $e');
      return false;
    }
  }

  static Future<bool> deleteMissionOnCloud(int missionId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/mission/$missionId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserDataFromCloud(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/user/$userId/data'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> registerOnCloud(String username, String? email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Errore di registrazione');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> loginOnCloud(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Credenziali non valide');
      }
    } catch (e) {
      rethrow;
    }
  }
}