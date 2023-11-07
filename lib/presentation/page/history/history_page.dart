import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_record/config/app_color.dart';
import 'package:money_record/config/app_format.dart';
import 'package:money_record/data/model/history.dart';
import 'package:money_record/data/source/source_history.dart';
import 'package:money_record/presentation/controller/c_user.dart';
import 'package:money_record/presentation/controller/history/c_history.dart';
import 'package:money_record/presentation/page/history/detail_history_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final cHistory = Get.put(CHistory());
  final cUser = Get.put(CUser());
  final controllerSearch = TextEditingController();

  final _initDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;
  String get initDate => _initDate.value;

  refresh() {
    cHistory.getList(cUser.data.idUser);
  }

  delete(String idHistory) async {
    bool? confirm = await DInfo.dialogConfirmation(
      context,
      'Hapus',
      'Yakin menghapus history ini?',
      textNo: 'Batal',
      textYes: 'Ya',
    );

    if (confirm!) {
      bool success = await SourceHistory.delete(idHistory);
      if (success) refresh();
    }
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
              const Text('Riwayat'),
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
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppColor.chart.withOpacity(0.5),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      suffixIcon: IconButton(
                        iconSize: 20,
                        onPressed: () {
                          if (controllerSearch.text.isEmpty) {
                            refresh();
                          } else {
                            cHistory.search(
                              cUser.data.idUser,
                              controllerSearch.text,
                            );
                          }
                        },
                        hoverColor: Colors.red,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GetBuilder<CHistory>(builder: (_) {
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
                    index == _.list.length - 1 ? 16 : 8,
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.to(() => DetailHistoryPage(
                          idUser: cUser.data.idUser!,
                          date: history.date!,
                          type: history.type!));
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        DView.spaceWidth(),
                        history.type == 'Pemasukan'
                            ? Icon(
                                Icons.south_west,
                                color: Colors.green[300],
                              )
                            : Icon(
                                Icons.north_east,
                                color: Colors.red[300],
                              ),
                        DView.spaceWidth(),
                        Text(
                          AppFormat.date(history.date!),
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppFormat.currency(history.total!),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            delete(history.idHistory!);
                          },
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.red[300],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }));
  }
}
