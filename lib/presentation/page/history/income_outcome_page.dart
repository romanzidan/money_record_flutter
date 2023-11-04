import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_record/config/app_color.dart';
import 'package:money_record/config/app_format.dart';
import 'package:money_record/data/model/history.dart';
import 'package:money_record/presentation/controller/c_user.dart';
import 'package:money_record/presentation/controller/history/c_income_outcome.dart';

class IncomeOutcomePage extends StatefulWidget {
  const IncomeOutcomePage({super.key, required this.type});
  final String type;

  @override
  State<IncomeOutcomePage> createState() => _IncomeOutcomePageState();
}

class _IncomeOutcomePageState extends State<IncomeOutcomePage> {
  final cInOut = Get.put(CIncomeOutcome());
  final cUser = Get.put(CUser());

  final controllerSearch = TextEditingController();

  final _initDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;
  String get initDate => _initDate.value;

  refresh() {
    cInOut.getList(cUser.data.idUser, widget.type);
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Text(widget.type),
              Expanded(
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controllerSearch,
                    onTap: () async {
                      DateTime? result = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(initDate),
                        firstDate: DateTime(2023, 01, 01),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (result != null) {
                        controllerSearch.text =
                            DateFormat('yyyy-MM-dd').format(result);
                        _initDate.value = controllerSearch.text;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '2023/12/12',
                      filled: true,
                      fillColor: AppColor.chart.withOpacity(0.5),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (controllerSearch.text.isEmpty) {
                            refresh();
                          } else {
                            cInOut.search(
                              cUser.data.idUser,
                              widget.type,
                              controllerSearch.text,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      isDense: true,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GetBuilder<CIncomeOutcome>(builder: (_) {
          if (_.loading) return DView.loadingCircle();
          if (_.list.isEmpty) return DView.empty('Tidak ada data');
          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.builder(
              itemCount: _.list.length,
              itemBuilder: (context, index) {
                History history = _.list[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.fromLTRB(
                    16,
                    index == 0 ? 16 : 8,
                    16,
                    index == 9 ? 16 : 8,
                  ),
                  child: Row(
                    children: [
                      DView.spaceWidth(),
                      Text(
                        AppFormat.date(history.date!),
                        style: const TextStyle(
                          color: AppColor.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppFormat.currency(history.total!),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [],
                        onSelected: (value) {},
                      )
                    ],
                  ),
                );
              },
            ),
          );
        }));
  }
}
