import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/peca.dart';
import '../../data/provider/garagem_provider.dart';

// ---------------- EVENTOS ----------------
abstract class ManageGaragemEvent {}

class SubmitPeca extends ManageGaragemEvent {
  final Peca peca; // a foto já vai dentro de peca.foto
  SubmitPeca(this.peca);
}

/// Edição de uma peça que já existe (precisa de peca.id preenchido).
class UpdatePeca extends ManageGaragemEvent {
  final Peca peca;
  UpdatePeca(this.peca);
}

class DeletePeca extends ManageGaragemEvent {
  final String id;
  DeletePeca(this.id);
}

// ---------------- ESTADOS ----------------
abstract class ManageGaragemState {}

class ManageIdle extends ManageGaragemState {}

class ManageSalvando extends ManageGaragemState {}

class ManageSucesso extends ManageGaragemState {
  final String mensagem;
  ManageSucesso(this.mensagem);
}

class ManageErro extends ManageGaragemState {
  final String mensagem;
  ManageErro(this.mensagem);
}

// ---------------- BLOC ----------------
/// Responsável por ESCREVER no banco (inserir / atualizar / remover).
class ManageGaragemBloc extends Bloc<ManageGaragemEvent, ManageGaragemState> {
  ManageGaragemBloc() : super(ManageIdle()) {
    on<SubmitPeca>((event, emit) async {
      emit(ManageSalvando());
      try {
        await GaragemProvider.helper.inserirPeca(event.peca);
        emit(ManageSucesso('Peça registrada na garagem!'));
      } on FotoGrandeException catch (e) {
        emit(ManageErro(e.mensagem));
      } catch (e) {
        emit(ManageErro('Não foi possível salvar: $e'));
      }
    });

    on<UpdatePeca>((event, emit) async {
      emit(ManageSalvando());
      try {
        await GaragemProvider.helper.atualizarPeca(event.peca);
        emit(ManageSucesso('Alterações salvas!'));
      } on FotoGrandeException catch (e) {
        emit(ManageErro(e.mensagem));
      } catch (e) {
        emit(ManageErro('Não foi possível atualizar: $e'));
      }
    });

    on<DeletePeca>((event, emit) async {
      try {
        await GaragemProvider.helper.removerPeca(event.id);
        emit(ManageSucesso('Peça removida do inventário.'));
      } catch (e) {
        emit(ManageErro('Não foi possível remover: $e'));
      }
    });
  }
}
