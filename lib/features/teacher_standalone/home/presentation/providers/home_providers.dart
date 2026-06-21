import 'package:edveo/features/teacher_standalone/home/data/home_repository.dart';
import 'package:edveo/features/teacher_standalone/home/data/models/home_data_model.dart';
import 'package:edveo/features/teacher_standalone/home/data/models/ai_banner_model.dart';
import 'package:edveo/features/teacher_standalone/home/data/repositories/ai_banner_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeNotifier extends AsyncNotifier<HomeDataModel> {
  @override
  Future<HomeDataModel> build() {
    return ref.read(homeRepositoryProvider).getHomeData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getHomeData(),
    );
  }
}

final homeProvider =
    AsyncNotifierProvider<HomeNotifier, HomeDataModel>(HomeNotifier.new);

final aiBannerProvider = FutureProvider<AiBannerModel>((ref) async {
  try {
    return await ref.read(aiBannerRepositoryProvider).fetchBanner();
  } catch (_) {
    return AiBannerModel.fallback();
  }
});
