import 'package:eClassify/data/Repositories/seller/seller_items_repository.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';

import '../../../exports/main_export.dart';

abstract class FetchSellerServicesState {}

class FetchSellerServicesInitial extends FetchSellerServicesState {}

class FetchSellerServicesInProgress extends FetchSellerServicesState {}

class FetchSellerServicesSuccess extends FetchSellerServicesState {
  final List<ItemModel> items;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;

  FetchSellerServicesSuccess(
      {required this.items,
      required this.isLoadingMore,
      required this.loadingMoreError,
      required this.page,
      required this.total});

  FetchSellerServicesSuccess copyWith({
    List<ItemModel>? items,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
  }) {
    return FetchSellerServicesSuccess(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchSellerServicesFail extends FetchSellerServicesState {
  final dynamic error;

  FetchSellerServicesFail(this.error);
}

class FetchSellerServicesCubit extends Cubit<FetchSellerServicesState> {
  FetchSellerServicesCubit() : super(FetchSellerServicesInitial());

  final SellerItemsRepository _sellerServicesRepository = SellerItemsRepository();

  void fetch({required int sellerId}) async {
    try {
      emit(FetchSellerServicesInProgress());
      DataOutput<ItemModel> result = await _sellerServicesRepository
          .fetchSellerServicesAllServices(page: 1, sellerId: sellerId);

      emit(
        FetchSellerServicesSuccess(
          page: 1,
          isLoadingMore: false,
          loadingMoreError: false,
          items: result.modelList,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchSellerServicesFail(e.toString()));
    }
  }

  Future<void> fetchMore({required int sellerId}) async {
    try {
      if (state is FetchSellerServicesSuccess) {
        if ((state as FetchSellerServicesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchSellerServicesSuccess).copyWith(isLoadingMore: true));
        DataOutput<ItemModel> result =
            await _sellerServicesRepository.fetchSellerServicesAllServices(
                page: (state as FetchSellerServicesSuccess).page + 1,
                sellerId: sellerId);

        FetchSellerServicesSuccess itemModelState =
            (state as FetchSellerServicesSuccess);
        itemModelState.items.addAll(result.modelList);
        emit(FetchSellerServicesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            items: itemModelState.items,
            page: (state as FetchSellerServicesSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchSellerServicesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchSellerServicesSuccess) {
      return (state as FetchSellerServicesSuccess).items.length <
          (state as FetchSellerServicesSuccess).total;
    }
    return false;
  }
}
