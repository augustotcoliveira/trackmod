import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/peca.dart';

/// Lançada quando a foto deixaria o documento acima do limite do Firestore.
class FotoGrandeException implements Exception {
  final String mensagem;
  FotoGrandeException(this.mensagem);
}

/// Camada de dados da garagem. Tudo fica no Cloud Firestore, inclusive a
/// foto (em base64), para o projeto rodar no plano gratuito Spark.
/// Estrutura no Firestore:  users/{uid}/pecas/{pecaId}
class GaragemProvider {
  static final GaragemProvider helper = GaragemProvider._createInstance();
  GaragemProvider._createInstance();

  /// Limite de um documento no Firestore é 1 MiB (1.048.576 bytes).
  /// Deixamos folga para os outros campos da peça.
  static const int _limiteFotoBase64 = 900000;

  /// Definido pelo AuthBloc quando o usuário faz login.
  String? uid;

  CollectionReference<Map<String, dynamic>> get _pecas => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('pecas');

  /// Stream em tempo real do inventário (alimenta o MonitorGaragemBloc).
  Stream<List<Peca>> get streamPecas => _pecas
      .orderBy('dataCompra', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => Peca.fromMap(doc.id, doc.data())).toList());

  /// Converte a peça em mapa e confere o tamanho da foto.
  Map<String, dynamic> _mapaValidado(Peca peca) {
    final mapa = peca.toMap();
    final fotoBase64 = mapa['fotoBase64'] as String?;
    if (fotoBase64 != null && fotoBase64.length > _limiteFotoBase64) {
      throw FotoGrandeException(
          'A foto ficou grande demais. Tente outra imagem ou tire a foto mais de perto.');
    }
    return mapa;
  }

  Future<void> inserirPeca(Peca peca) async {
    await _pecas.add(_mapaValidado(peca));
  }

  Future<void> atualizarPeca(Peca peca) async {
    await _pecas.doc(peca.id).set(_mapaValidado(peca));
  }

  Future<void> removerPeca(String id) => _pecas.doc(id).delete();
}
