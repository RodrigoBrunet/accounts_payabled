import 'package:accounts_payable/data/data_base_helper.dart';
import 'package:accounts_payable/models/account_model.dart';
import 'package:flutter/material.dart';

class DetailsAccountPage extends StatefulWidget {
  const DetailsAccountPage({super.key});

  @override
  State<DetailsAccountPage> createState() => _DetailsAccountPageState();
}

class _DetailsAccountPageState extends State<DetailsAccountPage> {
  late Future<List<Account>> _futureAccount;
  late Future<double> _totalPaymentInTheMonth;

  @override
  void initState() {
    super.initState();
    _futureAccount = DataBaseHelper.instance.queryContasPagas();
    _totalPaymentInTheMonth = DataBaseHelper.instance.calcTotalPaidOnMouth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas Pagas'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Account>>(
              future: _futureAccount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma conta paga.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Account account = snapshot.data![index];
                      if (!account.paid) {
                        return Container(); // Excluir itens não pagos
                      }
                      return ListTile(
                        title: Text(account.description),
                        subtitle: Text(
                            'R\$ ${account.value} - Vencimento: ${account.dueDate}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<double>(
              future: _totalPaymentInTheMonth,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else {
                  return Text(
                      'Total Pago no Mês: R\$ ${snapshot.data!.toStringAsFixed(2)}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
