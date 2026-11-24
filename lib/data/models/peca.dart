import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Categorias aceitas pelo formulário (RadioButtons).
class Categorias {
  static const String motor = 'Motor';
  static const String estetica = 'Estética';
  static const String eletronica = 'Eletrônica';

  static const List<String> todas = [motor, estetica, eletronica];
}

/// Modelo de uma peça/produto registrado na garagem.
/// Segue o padrão visto em aula: construtor vazio + campos preenchidos
/// pelos onSaved do Form, e conversão toMap/fromMap para o banco.
class Peca {
  String? id;
  String nome = '';
  String categoria = Categorias.motor;
  double valor = 0;
  DateTime dataCompra = DateTime.now();
  double ganhoHp = 0; // Slider
  bool instalada = false; // Switch
  bool consumivel = false; // Switch (item de estoque)
  int quantidade = 1; // usado só quando consumivel == true
  bool usada = false; // CheckBox
  bool comNotaFiscal = false; // CheckBox
  /// Bytes da foto (JPEG comprimido). No Firestore vira texto base64
  /// no campo 'fotoBase64', já que não usamos o Firebase Storage.
  Uint8List? foto;

  Peca();

  Peca.fromMap(this.id, Map<String, dynamic> map) {
    nome = map['nome'] ?? '';
    categoria = map['categoria'] ?? Categorias.motor;
    valor = (map['valor'] ?? 0).toDouble();
    dataCompra = (map['dataCompra'] as Timestamp?)?.toDate() ?? DateTime.now();
    ganhoHp = (map['ganhoHp'] ?? 0).toDouble();
    instalada = map['instalada'] ?? false;
    consumivel = map['consumivel'] ?? false;
    quantidade = map['quantidade'] ?? 1;
    usada = map['usada'] ?? false;
    comNotaFiscal = map['comNotaFiscal'] ?? false;
    final texto = map['fotoBase64'] as String?;
    foto = texto == null ? null : base64Decode(texto);
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'valor': valor,
      'dataCompra': Timestamp.fromDate(dataCompra),
      'ganhoHp': ganhoHp,
      'instalada': instalada,
      'consumivel': consumivel,
      'quantidade': consumivel ? quantidade : 1,
      'usada': usada,
      'comNotaFiscal': comNotaFiscal,
      'fotoBase64': foto == null ? null : base64Encode(foto!),
    };
  }

  /// Valor total desta linha do inventário (consumíveis multiplicam pela qtd).
  double get valorTotal => consumivel ? valor * quantidade : valor;

  String get estadoTexto => usada ? 'Usada' : 'Nova';

  /// Cópia independente, usada na edição para não alterar a lista do
  /// MonitorGaragemBloc antes de o usuário confirmar as mudanças.
  Peca clone() {
    final c = Peca();
    c.id = id;
    c.nome = nome;
    c.categoria = categoria;
    c.valor = valor;
    c.dataCompra = dataCompra;
    c.ganhoHp = ganhoHp;
    c.instalada = instalada;
    c.consumivel = consumivel;
    c.quantidade = quantidade;
    c.usada = usada;
    c.comNotaFiscal = comNotaFiscal;
    c.foto = foto;
    return c;
  }
}
