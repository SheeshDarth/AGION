import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../data/models/nutrition_log_model.dart';
import '../../../data/remote/food_api_client.dart';
import '../../../providers/nutrition_provider.dart';
import '../../../providers/player_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  final _foodClient = FoodApiClient();
  final _searchCtrl = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _searching = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _search() async {
    if (_searchCtrl.text.isEmpty) return;
    setState(() => _searching = true);
    final results = await _foodClient.searchFood(_searchCtrl.text);
    if (mounted) setState(() { _searchResults = results; _searching = false; });
  }

  Future<void> _addFood(FoodItem item, String mealType) async {
    await ref.read(nutritionProvider.notifier).addFood(mealType, item);
    const center = Offset(200, 400);
    ref.read(playerProvider.notifier).addXP(5, 'nutrition', center);
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(nutritionProvider);
    final totalCal = ref.read(nutritionProvider.notifier).totalCalories;
    final totalPro = ref.read(nutritionProvider.notifier).totalProtein;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20)),
                      const SizedBox(width: 12),
                      SLText('◈ FUEL LOG', style: SLType.headline(size: 18)),
                    ],
                  ),
                ),
              ),
              // Macro ring
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SystemPanel(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100, height: 100,
                          child: PieChart(PieChartData(
                            sections: [
                              PieChartSectionData(value: totalPro * 4, color: SLColors.rankC, radius: 16, title: ''),
                              PieChartSectionData(value: totalCal - totalPro * 4, color: SLColors.glowDim, radius: 16, title: ''),
                            ],
                            centerSpaceRadius: 34,
                          )),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SLText('${totalCal.round()} kcal', style: SLType.hudNum(size: 22, color: SLColors.textBright)),
                              SLText('CONSUMED', style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
                              const SizedBox(height: 8),
                              SLText('${totalPro.round()}g PROTEIN', style: SLType.body(size: 13, color: SLColors.rankC)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Water
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: SystemPanel(
                    glowColor: SLColors.rankC,
                    glowIntensity: 0.3,
                    child: Row(
                      children: [
                        SLText('💧 ${log?.waterMl ?? 0} ML', style: SLType.hudNum(size: 16, color: SLColors.rankC)),
                        const Spacer(),
                        ...([250, 500].map((ml) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: SystemButton(
                            label: '+${ml}ml',
                            variant: SystemButtonVariant.ghost,
                            color: SLColors.rankC,
                            onTap: () {
                              ref.read(nutritionProvider.notifier).addWater(ml);
                              const center = Offset(200, 400);
                              ref.read(playerProvider.notifier).addXP(5, 'hydration', center);
                            },
                          ),
                        ))),
                      ],
                    ),
                  ),
                ),
              ),
              // Food search
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: SLType.body(color: SLColors.textBright),
                          decoration: InputDecoration(hintText: 'SEARCH FOOD...'),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SystemButton(label: 'SEARCH', onTap: _search, isLoading: _searching),
                    ],
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final item = _searchResults[i];
                        return GestureDetector(
                          onTap: () => _addFood(item, 'midday'),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SystemPanel(
                              glowIntensity: 0.2,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SLText(item.name, style: SLType.body(size: 13, color: SLColors.textBright), maxLines: 1),
                                      if (item.brand != null)
                                        SLText(item.brand!, style: SLType.body(size: 11, color: SLColors.textMid)),
                                    ],
                                  )),
                                  SLText('${item.caloriesPer100g.round()} kcal/100g',
                                      style: SLType.tag(size: 10, color: SLColors.xpBright)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _searchResults.length,
                    ),
                  ),
                ),
              SliverPadding(padding: const EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
