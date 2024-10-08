import 'package:accounts_payable/data/data_base_helper.dart';
import 'package:accounts_payable/models/account_model.dart';
import 'package:accounts_payable/page/details_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AccountPayabledPage extends StatefulWidget {
  const AccountPayabledPage({super.key});

  @override
  State<AccountPayabledPage> createState() => _AccountPayabledPageState();
}

class _AccountPayabledPageState extends State<AccountPayabledPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = MoneyMaskedTextController(decimalSeparator: ',');
  final _dueDateController = MaskedTextController(mask: '00/00/0000');
  late Future<List<Account>> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture = DataBaseHelper.instance.queryAllRows();
  }

  void _refreshData() {
    setState(() {
      _accountFuture = DataBaseHelper.instance.queryAllRows();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a pagar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DetailsAccountPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira uma descrição';
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira um valor';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _dueDateController,
                    decoration:
                        const InputDecoration(labelText: 'Data do pagamento'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a data do pagamento';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String valueText = _valueController.text
                              .replaceAll('.', '')
                              .replaceAll(',', '');
                          Account newAccount = Account(
                            description: _descriptionController.text,
                            value: double.parse(valueText) / 100,
                            dueDate: _dueDateController.text,
                            paid: false,
                          );
                          await DataBaseHelper.instance.insert(newAccount);
                          _descriptionController.clear();
                          _valueController.updateValue(0);
                          _dueDateController.text = '';
                          _refreshData();
                        }
                      },
                      child: const Text('Adiciona conta'))
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Account>>(
              future: _accountFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma conta cadastrada.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Account account = snapshot.data![index];
                      return ListTile(
                        title: Text(account.description),
                        subtitle: Text(
                            'R\$ ${account.value} - Data do pagamento: ${account.dueDate}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                account.paid
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: account.paid ? Colors.green : null,
                              ),
                              onPressed: () async {
                                await DataBaseHelper.instance
                                    .updateStatus(account.id!, !account.paid);
                                _refreshData();
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.blue),
                              onPressed: () async {
                                await DataBaseHelper.instance
                                    .delete(account.id!);
                                _refreshData();
                              },
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
