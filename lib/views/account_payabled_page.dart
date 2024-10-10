import 'package:accounts_payable/data/data_base_helper.dart';
import 'package:accounts_payable/models/account_model.dart';
import 'package:accounts_payable/resources/strings/string_resourses.dart';
import 'package:accounts_payable/views/components/custom_text_form_field.dart';
import 'package:accounts_payable/views/details_account_page.dart';
import 'package:accounts_payable/views/grafic_info_page.dart';
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

  _converteValor() {
    String text = _valueController.text.replaceAll('.', '').replaceAll(',', '');
    var textConverter = double.parse(text);
    return textConverter / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          StringResources.titulo,
          style: TextStyle(color: Colors.white),
        ),
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
          // IconButton(
          //   icon: const Icon(Icons.show_chart),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const GraficInfoPage()),
          //     );
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CustomTextFormField(
                      controller: _descriptionController,
                      labelText: StringResources.labelTextInput1,
                      inputType: TextInputType.name,
                      inputValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return StringResources.inputvalidatorInput1;
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    CustomTextFormField(
                      controller: _valueController,
                      labelText: StringResources.labelTextInput2,
                      inputType: TextInputType.number,
                      inputValidator: (value) {
                        if (value!.startsWith('0,00') || value.isEmpty) {
                          return StringResources.inputvalidatorInput2;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    CustomTextFormField(
                      controller: _dueDateController,
                      labelText: StringResources.labelTextInput3,
                      inputType: TextInputType.number,
                      inputValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return StringResources.inputvalidatorInput3;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 50)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Account newAccount = Account(
                              description: _descriptionController.text,
                              value: _converteValor(),
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
                        child: const Text(
                          StringResources.elevatedButtonText,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ))
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
                    return const Center(
                        child: Text(StringResources.feedbackText));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Account account = snapshot.data![index];
                        return ListTile(
                          title: Text(account.description),
                          subtitle: Text(
                            'R\$ ${account.value} - Data do pagamento: ${account.dueDate}',
                            style: account.paid
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : null,
                          ),
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
                                icon: const Icon(Icons.delete,
                                    color: Colors.blue),
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
      ),
    );
  }
}
