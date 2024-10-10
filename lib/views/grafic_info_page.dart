import 'package:accounts_payable/data/data_base_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficInfoPage extends StatefulWidget {
  const GraficInfoPage({super.key});

  @override
  State<GraficInfoPage> createState() => _GraficInfoPageState();
}

class _GraficInfoPageState extends State<GraficInfoPage> {
  late Future<List<Map<String, dynamic>>> _totaisMensais;

  @override
  void initState() {
    super.initState();
    _totaisMensais = DataBaseHelper.instance.queryTotaisMensais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Totais Mensais'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _totaisMensais,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum dado disponível.'));
          } else {
            return Center(
              child: PieChartSample2(data: snapshot.data!),
            );
          }
        },
      ),
    );
  }
}

class PieChartSample2 extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PieChartSample2({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: const Color(0xff2c4260),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 28,
            ),
            const Text(
              'Totais Mensais',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
            const SizedBox(
              height: 28,
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Handle touch events if necessary
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
            const SizedBox(
              height: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return data.map((entry) {
      int index = data.indexOf(entry);
      double total = entry['total'];
      String mes = entry['mes'];
      String titulo = "$mes\nR\$ ${total.toStringAsFixed(2)}";
      return PieChartSectionData(
        color: Colors.primaries[index % Colors.primaries.length],
        value: total,
        title: titulo,
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff)),
      );
    }).toList();
  }
}
