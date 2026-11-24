import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/peca.dart';
import '../../data/provider/garagem_provider.dart';

// ---------------- EVENTOS ----------------
abstract class MonitorGaragemEvent {}

/// Disparado quando a tela Garagem abre com usuário logado.
class IniciarMonitor extends MonitorGaragemEvent {}

/// Disparado antes de sair da conta: encerra a escuta e limpa a lista.
class PararMonitor extends MonitorGaragemEvent {}

/// Evento interno: o Firestore mandou uma nova versão da lista.
class AtualizarLista extends MonitorGaragemEvent {
  final List<Peca> pecas;
  AtualizarLista(this.pecas);
}

// ---------------- ESTADO ----------------
class MonitorGaragemState {
  final List<Peca> pecas;
  MonitorGaragemState(this.pecas);

  double get totalInvestido =>
      pecas.fold(0, (soma, p) => soma + p.valorTotal);
}

// ---------------- BLOC ----------------
/// Responsável por LER o banco em tempo real (stream do Firestore).
class MonitorGaragemBloc
    extends Bloc<MonitorGaragemEvent, MonitorGaragemState> {
  StreamSubscription<List<Peca>>? _sub;

  MonitorGaragemBloc() : super(MonitorGaragemState([])) {
    on<IniciarMonitor>((event, emit) {
      _sub?.cancel();
      if (GaragemProvider.helper.uid == null) return;
      _sub = GaragemProvider.helper.streamPecas.listen(
        (lista) => add(AtualizarLista(lista)),
        // Ao sair da conta o Firestore pode negar a leitura; ignoramos
        onError: (_) {},
      );
    });

    on<PararMonitor>((event, emit) {
      _sub?.cancel();
      _sub = null;
      emit(MonitorGaragemState([]));
    });

    on<AtualizarLista>((event, emit) {
      emit(MonitorGaragemState(event.pecas));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
