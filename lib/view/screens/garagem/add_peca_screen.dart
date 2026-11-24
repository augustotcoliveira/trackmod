import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../data/models/peca.dart';
import '../../../logic/manage_garagem/manage_garagem_bloc.dart';
import '../../theme/app_theme.dart';
import 'confirmacao_screen.dart';

/// Formulário "Adicionar Modificação" (requisito "Coleta de Informações").
///
/// Elementos usados:
///  - TextFormField ........ nome da peça e valor pago (com máscara R$)
///  - RadioButton .......... categoria (Motor / Estética / Eletrônica)
///  - DatePicker ........... data da compra
///  - Slider ............... ganho de potência estimado (HP)
///  - Switch ............... peça instalada? / item de estoque (consumível)
///  - CheckBox ............. comprada usada / possui nota fiscal
///  - BottomSheet .......... escolher câmera ou galeria para a foto
///  - Dialog ............... confirmação antes de gravar e erro ao gravar
class AddPecaScreen extends StatefulWidget {
  /// Se vier preenchida, a tela entra em modo edição.
  final Peca? pecaExistente;
  const AddPecaScreen({super.key, this.pecaExistente});

  @override
  State<AddPecaScreen> createState() => _AddPecaScreenState();
}

class _AddPecaScreenState extends State<AddPecaScreen> {
  final _formKey = GlobalKey<FormState>();
  // Edição trabalha numa cópia, para não mexer na lista antes de salvar
  late final Peca _peca = widget.pecaExistente?.clone() ?? Peca();
  bool get _editando => widget.pecaExistente != null;

  // Controllers guardam o texto mesmo se o campo sair da tela ao rolar
  late final TextEditingController _nomeCtrl =
      TextEditingController(text: _peca.nome);
  late final TextEditingController _valorCtrl = TextEditingController(
      text: _editando ? _formatoNumero.format(_peca.valor) : '');

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  static final _formatoNumero = NumberFormat('#,##0.00', 'pt_BR');
  static final _formatoData = DateFormat('dd/MM/yyyy');

  // ---------------------------------------------------------------
  // AÇÕES
  // ---------------------------------------------------------------

  Future<void> _escolherFoto() async {
    // BottomSheet para escolher a origem da imagem
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tirar foto da peça'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (origem == null) return;

    // Foto pequena e comprimida: o documento do Firestore aceita no máximo
    // 1 MiB, e o base64 aumenta o tamanho em cerca de 33%.
    final arquivo = await ImagePicker()
        .pickImage(source: origem, maxWidth: 600, imageQuality: 50);
    if (arquivo == null) return;
    final bytes = await arquivo.readAsBytes(); // funciona também na web
    setState(() => _peca.foto = bytes);
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _peca.dataCompra,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data != null) setState(() => _peca.dataCompra = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confira os campos destacados')));
      return;
    }
    _formKey.currentState!.save();
    // Lê direto dos controllers: não depende do onSaved
    _peca.nome = _nomeCtrl.text.trim();
    _peca.valor = _paraDouble(_valorCtrl.text);

    // Dialog de confirmação com o resumo do que será gravado
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(_editando ? 'Salvar alterações?' : 'Registrar na garagem?'),
        content: Text(
          '${_peca.nome}\n'
          '${_peca.categoria}  |  R\$ ${_formatoNumero.format(_peca.valor)}\n'
          'Ganho estimado: +${_peca.ganhoHp.round()} HP',
          style: AppText.label(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Revisar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmou == true && mounted) {
      context.read<ManageGaragemBloc>().add(
          _editando ? UpdatePeca(_peca) : SubmitPeca(_peca));
    }
  }

  // ---------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_editando ? 'EDITAR MODIFICAÇÃO' : 'ADICIONAR MODIFICAÇÃO')),
      body: BlocConsumer<ManageGaragemBloc, ManageGaragemState>(
        // Só reage ao resultado do envio feito nesta tela
        listenWhen: (anterior, atual) => anterior is ManageSalvando,
        listener: (context, state) {
          if (state is ManageSucesso) {
            if (_editando) {
              // Edição: avisa com SnackBar e volta para os detalhes
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.mensagem)));
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ConfirmacaoScreen(peca: _peca)),
              );
            }
          } else if (state is ManageErro) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Falha ao salvar'),
                content: Text(state.mensagem),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK')),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final salvando = state is ManageSalvando;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _areaFoto(),
                const SizedBox(height: 24),

                // ---------- NOME ----------
                const _Rotulo('NOME DA PEÇA'),
                TextFormField(
                  controller: _nomeCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppText.body(size: 18),
                  decoration:
                      const InputDecoration(hintText: 'ex. Kit Suspensão'),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Informe o nome da peça'
                      : null,
                  onSaved: (v) => _peca.nome = v!.trim(),
                ),
                const SizedBox(height: 24),

                // ---------- VALOR ----------
                const _Rotulo('VALOR PAGO'),
                TextFormField(
                  controller: _valorCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: AppText.label(size: 24, color: AppColors.onSurface),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    _MoedaInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0,00',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text('R\$',
                          style: AppText.label(color: AppColors.primary)),
                    ),
                  ),
                  validator: (v) => (_paraDouble(v) <= 0)
                      ? 'Informe o valor pago'
                      : null,
                  onSaved: (v) => _peca.valor = _paraDouble(v),
                ),
                const SizedBox(height: 24),

                // ---------- CATEGORIA (RadioButtons) ----------
                const _Rotulo('CATEGORIA'),
                _Painel(
                  // RadioGroup (Flutter 3.32+) guarda o valor escolhido;
                  // cada RadioListTile só informa o próprio value.
                  child: RadioGroup<String>(
                    groupValue: _peca.categoria,
                    onChanged: (v) => setState(() => _peca.categoria = v!),
                    child: Column(
                      children: [
                        _radioCategoria(
                            Categorias.motor,
                            Icons.settings_input_component,
                            'Upgrades mecânicos'),
                        _radioCategoria(Categorias.estetica,
                            Icons.auto_awesome, 'Limpeza e detalhamento'),
                        _radioCategoria(Categorias.eletronica, Icons.memory,
                            'Multimídia, iluminação, sensores'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- DATA (DatePicker) ----------
                const _Rotulo('DATA DA COMPRA'),
                InkWell(
                  onTap: _escolherData,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today_outlined)),
                    child: Text(_formatoData.format(_peca.dataCompra),
                        style: AppText.label(
                            size: 16, color: AppColors.onSurface)),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- GANHO DE POTÊNCIA (Slider) ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Rotulo('GANHO ESTIMADO'),
                    Text('+${_peca.ganhoHp.round()} HP',
                        style: AppText.label(
                            size: 16, color: AppColors.primary)),
                  ],
                ),
                _Painel(
                  child: Column(
                    children: [
                      Slider(
                        value: _peca.ganhoHp,
                        min: 0,
                        max: 150,
                        divisions: 30,
                        label: '+${_peca.ganhoHp.round()} HP',
                        onChanged: (v) => setState(() => _peca.ganhoHp = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          'Deixe em 0 para itens que não alteram a performance',
                          style: AppText.label(size: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- STATUS (Switches) ----------
                const _Rotulo('STATUS'),
                _Painel(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.build_circle_outlined),
                        title: const Text('Já instalada no carro'),
                        subtitle: Text(
                            _peca.instalada
                                ? 'Rodando no projeto'
                                : 'Guardada, aguardando instalação',
                            style: AppText.label(size: 11)),
                        value: _peca.instalada,
                        onChanged: (v) => setState(() => _peca.instalada = v),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Item de estoque (consumível)'),
                        subtitle: Text('Ex: shampoo, cera, toalhas',
                            style: AppText.label(size: 11)),
                        value: _peca.consumivel,
                        onChanged: (v) => setState(() => _peca.consumivel = v),
                      ),
                      if (_peca.consumivel) _seletorQuantidade(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- PROCEDÊNCIA (CheckBoxes) ----------
                const _Rotulo('PROCEDÊNCIA'),
                _Painel(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Comprada usada (seminova)'),
                        value: _peca.usada,
                        onChanged: (v) =>
                            setState(() => _peca.usada = v ?? false),
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Tenho nota fiscal / garantia'),
                        value: _peca.comNotaFiscal,
                        onChanged: (v) =>
                            setState(() => _peca.comNotaFiscal = v ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ---------- SALVAR ----------
                ElevatedButton.icon(
                  onPressed: salvando ? null : _salvar,
                  icon: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(salvando
                      ? 'Salvando...'
                      : (_editando ? 'Salvar Alterações' : 'Salvar Peça')),
                ),
                const SizedBox(height: 24),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // WIDGETS AUXILIARES
  // ---------------------------------------------------------------

  Widget _areaFoto() {
    return GestureDetector(
      onTap: _escolherFoto,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _peca.foto != null
              ? Image.memory(_peca.foto!, fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate,
                        size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Carregar Foto da Peça', style: AppText.label()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _radioCategoria(String valor, IconData icone, String descricao) {
    return RadioListTile<String>(
      value: valor,
      title: Text(valor),
      subtitle: Text(descricao, style: AppText.label(size: 11)),
      secondary: Icon(icone,
          color: _peca.categoria == valor
              ? AppColors.primary
              : AppColors.onSurfaceVariant),
    );
  }

  Widget _seletorQuantidade() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text('QUANTIDADE', style: AppText.label(size: 12)),
          const Spacer(),
          IconButton(
            onPressed: _peca.quantidade > 1
                ? () => setState(() => _peca.quantidade--)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('x${_peca.quantidade}',
              style: AppText.label(size: 18, color: AppColors.onSurface)),
          IconButton(
            onPressed: () => setState(() => _peca.quantidade++),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  double _paraDouble(String? texto) {
    if (texto == null || texto.isEmpty) return 0;
    return double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  }
}

/// Rótulo em JetBrains Mono, igual ao protótipo.
class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(texto, style: AppText.label()),
      );
}

/// Container padrão para agrupar Radio/Switch/Checkbox/Slider.
class _Painel extends StatelessWidget {
  final Widget child;
  const _Painel({required this.child});

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

/// Máscara de moeda: digitar 12345 vira "123,45" (mesma lógica do protótipo HTML).
class _MoedaInputFormatter extends TextInputFormatter {
  static final _formato = NumberFormat('#,##0.00', 'pt_BR');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return const TextEditingValue();
    final texto = _formato.format(int.parse(newValue.text) / 100);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
