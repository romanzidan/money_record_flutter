import 'package:d_chart/commons/axis.dart';
import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/commons/style.dart';
import 'package:d_chart/ordinal/bar.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_record/config/app_asset.dart';
import 'package:money_record/config/app_color.dart';
import 'package:money_record/config/app_format.dart';
import 'package:money_record/config/session.dart';
import 'package:money_record/presentation/controller/c_home.dart';
import 'package:money_record/presentation/controller/c_user.dart';
import 'package:money_record/presentation/page/auth/login_page.dart';
import 'package:money_record/presentation/page/history/add_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cUser = Get.put(CUser());
  final cHome = Get.put(CHome());

  @override
  void initState() {
    cHome.getAnalysis(cUser.data.idUser!);
    super.initState();
  }

  List<OrdinalData> get ordinalDataList => [
        OrdinalData(
            domain: 'income',
            measure: cHome.monthIncome,
            color: AppColor.primary),
        OrdinalData(
          domain: 'outcome',
          measure: cHome.monthOutcome,
          color: AppColor.bg,
        ),
        if (cHome.monthIncome == 0 && cHome.monthOutcome == 0)
          OrdinalData(
            domain: 'nol',
            measure: 1,
            color: AppColor.bg.withOpacity(0.5),
          )
      ];

  List<OrdinalData> get ordList => List.generate(7, (index) {
        return OrdinalData(
            domain: cHome.weekText()[index], measure: cHome.week[index]);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: drawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Row(
              children: [
                Image.asset(AppAsset.profile),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hi,',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() {
                        return Text(
                          cUser.data.name ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Builder(builder: (ctx) {
                  return Material(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColor.chart,
                    child: InkWell(
                      onTap: () {
                        Scaffold.of(ctx).openEndDrawer();
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.menu,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                cHome.getAnalysis(cUser.data.idUser!);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  Text(
                    'Pengeluaran Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DView.spaceHeight(),
                  cardToday(context),
                  DView.spaceHeight(30),
                  Center(
                    child: Container(
                      height: 5,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColor.bg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  DView.spaceHeight(30),
                  Text(
                    'Pengeluaran Minggu Ini',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DView.spaceHeight(),
                  weekly(),
                  DView.spaceHeight(30),
                  Text(
                    'Perbandingan bulan ini',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DView.spaceHeight(),
                  monthly(context)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            margin: const EdgeInsets.only(bottom: 0),
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(AppAsset.profile),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return Text(
                              cUser.data.name ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          Obx(() {
                            return Text(
                              cUser.data.email ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ],
                ),
                Material(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColor.primary,
                  child: InkWell(
                    onTap: () {
                      Session.clearUser();
                      Get.off(() => const LoginPage());
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            onTap: () {
              Get.to(() => AddHistoryPage())?.then((value) {
                //cek jika ada perubahan pada add history page
                //maka refresh analysis pada home page
                if (value ?? false) {
                  cHome.getAnalysis(cUser.data.idUser!);
                }
              });
            },
            leading: const Icon(Icons.add),
            title: const Text('Tambah Baru'),
            horizontalTitleGap: 0,
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.south_west),
            title: const Text('Pemasukan'),
            horizontalTitleGap: 0,
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.north_east),
            title: const Text('Pengeluaran'),
            horizontalTitleGap: 0,
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.history),
            title: const Text('Riwayat'),
            horizontalTitleGap: 0,
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  AspectRatio weekly() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Obx(() {
        return DChartBarO(
          groupList: [
            OrdinalGroup(
              id: '1',
              data: ordList,
            ),
          ],
          fillColor: (group, ordinalData, index) {
            return AppColor.primary;
          },
          animate: true,
          measureAxis: const MeasureAxis(
            showLine: true,
            desiredMinTickCount: 2,
            gapAxisToLabel: 10,
            lineStyle: LineStyle(
              color: AppColor.primary,
              thickness: 2,
            ),
          ),
          domainAxis: const DomainAxis(
            gapAxisToLabel: 10,
            lineStyle: LineStyle(
              color: AppColor.primary,
              thickness: 2,
            ),
          ),
        );
      }),
    );
  }

  Row monthly(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
          child: Stack(
            children: [
              Obx(() {
                return DChartPieO(
                  data: ordinalDataList,
                  animate: true,
                  configRenderPie: const ConfigRenderPie(arcWidth: 20),
                );
              }),
              Center(
                child: Obx(() {
                  return Text(
                    '${cHome.percentIncome}%',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  );
                }),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 16,
                  width: 16,
                  color: AppColor.primary,
                ),
                DView.spaceWidth(8),
                const Text('Pemasukan'),
              ],
            ),
            DView.spaceHeight(8),
            Row(
              children: [
                Container(
                  height: 16,
                  width: 16,
                  color: AppColor.bg,
                ),
                DView.spaceWidth(8),
                const Text('Pengeluaran'),
              ],
            ),
            DView.spaceHeight(20),
            Obx(() {
              return Text(cHome.monthPercent);
            }),
            DView.spaceHeight(10),
            const Text('Atau setara:'),
            Obx(() {
              return Text(
                AppFormat.currency(cHome.differentMonth.toString()),
                style: const TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Material cardToday(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      color: AppColor.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 5),
            child: Obx(() {
              return Text(
                AppFormat.currency(cHome.today.toString()),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondary,
                    ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
            child: Obx(() {
              return Text(
                cHome.todayPercent,
                style: const TextStyle(
                  color: AppColor.bg,
                  fontSize: 16,
                ),
              );
            }),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 0, 16),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Selengkapnya',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.navigate_next,
                  color: AppColor.primary,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
